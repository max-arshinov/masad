# 2. Estimate System Growth and Technical Risks
Date: 2025-08-31

## Status
Proposed

## Context
- Purpose: sanity-check capacity, latency, scalability, availability, and cost with rough estimates.
- Assumptions (orders of magnitude; conservative where uncertain):
  - New users per year: +1,000,000.
  - Links created per user per year: 100.
  - Reads per link per day: 10.
  - Peak-to-average multiplier: ×3.
  - Redirect response size (headers + small body): ~400 bytes.
  - Link record storage (incl. index/overhead): ~400 bytes/link.
  - User record storage: ~1,024 bytes/user.
  - Replication factor (durability/capacity): 3×.
  - Cache miss rate for reads (steady-state): 10% (to estimate DB read load only).
- Relevant QARs (from Quality Requirements): P-1 (Performance), P-2 (Performance/Throughput), A-1 (Availability), S-1 (Security/Abuse), R-1 (Reliability).
- Relevant QASs: P-1 (Fast redirect latency), P-2 (High throughput redirects), A-1 (Failover on node/zone loss), S-1 (Block token enumeration), R-1 (No data loss on failure).

## Decision
Transparent back-of-the-envelope calculations (via calculator):
- secondsPerYear = 60×60×24×365 = 31,536,000.
- secondsPerDay = 60×60×24 = 86,400.
- linksPerYear = 1,000,000×100 = 100,000,000.
- writeRps = linksPerYear ÷ secondsPerYear = 100,000,000 ÷ 31,536,000 = 3.170979198 RPS.
- Year 1 reads/day = 100,000,000×10 = 1,000,000,000; avgReadRps = 1,000,000,000 ÷ 86,400 = 11,574.074074 RPS; peakReadRps = 11,574.074074×3 = 34,722.222222 RPS.
- Year 2 reads/day = 200,000,000×10 = 2,000,000,000; avgReadRps = 2,000,000,000 ÷ 86,400 = 23,148.148148 RPS; peakReadRps = 23,148.148148×3 = 69,444.444444 RPS.
- Year 3 reads/day = 300,000,000×10 = 3,000,000,000; avgReadRps = 3,000,000,000 ÷ 86,400 = 34,722.222222 RPS; peakReadRps = 34,722.222222×3 = 104,166.666667 RPS.
- userDbGb(year N) = (users×1,024) ÷ 1e9. Example Y1: 1,000,000×1,024 = 1,024,000,000 → 1.024 GB.
- linkDbGb(year N) = (cumLinks×400) ÷ 1e9. Example Y1: 100,000,000×400 = 40,000,000,000 → 40.0 GB.
- storageTbRf3 = (userDbGb + linkDbGb)×3 ÷ 1,000. Example Y1: (1.024+40.0)×3/1,000 = 0.123072 TB.
- peakBandwidthGbPerSec = peakReadRps×400 ÷ 1e9. Example Y1: 34,722.222222×400/1e9 = 0.013889 GB/s.
- dbReadRpsAt10pcMiss = peakReadRps×0.1. Example Y1: 3,472.222222 RPS.

# Projection Table (Markdown)

| Year | # of users | User DB (GB) | # of links (cum) | Link DB (GB) | Write RPS | Read RPS (avg) | Peak Read RPS | Storage (TB, RF=3) | Peak Bandwidth (GB/s) | DB Read RPS @10% miss |
|------|------------|--------------|------------------|--------------|-----------|----------------|---------------|--------------------|-----------------------|-----------------------|
| 1    | 1,000,000  | 1.024        | 100,000,000      | 40.00        | 3.17      | 11,574.07      | 34,722.22     | 0.123              | 0.0139                | 3,472.22              |
| 2    | 2,000,000  | 2.048        | 200,000,000      | 80.00        | 3.17      | 23,148.15      | 69,444.44     | 0.246              | 0.0278                | 6,944.44              |
| 3    | 3,000,000  | 3.072        | 300,000,000      | 120.00       | 3.17      | 34,722.22      | 104,166.67    | 0.369              | 0.0417                | 10,416.67             |

Confidence: conservative, rough order-of-magnitude; intended to surface risks, not finalize design.

## Consequences
- Read path dominates throughput growth; peak read RPS reaches >100k by Year 3 (P-1, P-2).
- DB pressure is sensitive to cache miss: at 10% miss, tens of thousands of RPS can hit storage at peaks (P-2, R-1); sizing/connections must account for this.
- Storage growth remains modest early (<0.4 TB logical with 3× RF by Year 3), but indexing/TTL/policies will influence costs at scale (R-1).
- Network bandwidth (GB/s) is small compared to compute and latency constraints; connection limits and cache efficiency are likely bottlenecks (P-1).
- Availability targets (A-1) require automated failover and low-impact maintenance to stay within SLOs; spikes and abuse require rate limiting and anomaly detection (S-1).
