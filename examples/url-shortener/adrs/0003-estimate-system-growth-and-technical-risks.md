# 3. Estimate System Growth and Technical Risks

Date: 2025-09-01

## Status

Proposed

## Context

This ADR continues ADR-0002 by turning assumptions into explicit back-of-the-envelope estimates to validate capacity, latency, and reliability against the referenced QARs/QASs.

Assumptions (from ADR-0002; no design decisions):
- User growth: +1,000,000 users per year (net new).
- Link creation rate: 100 links per user per year.
- Redirect frequency: 10 reads per link per day (average).
- Traffic variability: peak-to-average multiplier ×3.
- Redirect payload size over the wire: ~400 bytes (headers + minimal body).
- Record shapes: ~400 bytes per link (incl. index/overhead), ~1,024 bytes per user.
- Replication factor for durability/capacity planning: 3×.
- Cache effectiveness: steady-state cache miss ratio for redirects = 10%.
- Token namespace: Base62, length 7–8 characters.

Referenced QARs/QASs:
- P-1: P95 ≤ 50 ms; P99 ≤ 120 ms (redirect latency).
- P-2: Sustain 20k rps; err < 0.5%; P95 ≤ 100 ms (throughput).
- A-1: RTO < 5 min; SLO ≥ 99.95% monthly (availability).
- R-1: RPO = 0; redirect path ≥ 99.9% available during incident (reliability).
- S-1/S-2: Block token enumeration; require auth for mutations (security).

Confidence: rough order-of-magnitude (ROM), conservative on peaks.

## Decision

Transparent calculations (step-by-step)
- Seconds per day = 24×60×60 = 86,400.
- Seconds per (365-day) year = 31,536,000.
- New links per year = 1,000,000 users × 100 = 100,000,000.
- Average write RPS (links) = 100,000,000 / 31,536,000 ≈ 3.17098 rps; Peak write RPS = ×3 ≈ 9.51294 rps.
- Year y cumulative users = y × 1,000,000; cumulative links (3-year retention within this horizon) = y × 100,000,000.
- Reads/day = links × 10; Avg read RPS = (reads/day) / 86,400; Peak read RPS = ×3.
- Backend read RPS (misses) = Avg/Peak read RPS × 10%.
- Response bandwidth (GB/s) = RPS × 400 bytes / 1e9. (Note: 1 GB/s ≈ 8 Gbps.)
- Logical storage (bytes) = users × 1,024 + links × 400; Logical GB = bytes / 1e9; Effective storage = Logical × 3 (replication).
- Latency-to-concurrency check: concurrency ≈ RPS × service_time_seconds (illustrative: 50 ms end-to-end; 15 ms backend).
- Monthly downtime budget at 99.95% SLO over 30 days: 30×24×60×60×0.0005 = 1,296 s ≈ 21.6 min; must be ≥ RTO=5 min margin.
- Token space: 62^7 = 3,521,614,606,208; 62^8 = 218,340,105,584,896. Exhaustion horizon at X guesses/s = space / X.

Three-year projection table
| Year | Users | Links | Avg Write RPS | Peak Write RPS | Avg Read RPS | Peak Read RPS | Backend Avg RPS (10% miss) | Backend Peak RPS (10% miss) | Resp BW Avg (GB/s) | Resp BW Peak (GB/s) | Logical DB Size (GB) | Effective Storage (GB) |
|------|-------:|------:|--------------:|---------------:|-------------:|--------------:|----------------------------:|-----------------------------:|-------------------:|--------------------:|---------------------:|-----------------------:|
| 1 | 1,000,000 | 100,000,000 | 3.171 | 9.513 | 11,574.074 | 34,722.222 | 1,157.407 | 3,472.222 | 0.00463 | 0.01389 | 41.024 | 123.072 |
| 2 | 2,000,000 | 200,000,000 | 3.171 | 9.513 | 23,148.148 | 69,444.444 | 2,314.815 | 6,944.444 | 0.00926 | 0.02778 | 82.048 | 246.144 |
| 3 | 3,000,000 | 300,000,000 | 3.171 | 9.513 | 34,722.222 | 104,166.667 | 3,472.222 | 10,416.667 | 0.01389 | 0.04167 | 123.072 | 369.216 |

Other derived checks (illustrative budgets, not design decisions)
- End-to-end latency budget to meet P-1 (P95 ≤ 50 ms): network+TLS 15 ms; edge/cache 5 ms; LB/app 15 ms; datastore 10 ms; margin 5 ms.
- Concurrency at peak (Year 1/2/3), 50 ms end-to-end: ≈ 1,736 / 3,472 / 5,208 concurrent redirects.
- Backend concurrency at peak (Year 1/2/3 misses only), 15 ms: ≈ 52.08 / 104.17 / 156.25 in-flight DB reads.
- Monthly downtime budget at 99.95% SLO: 1,296 s (21.6 min). Meets A-1 if failover ≤ 5 min (RTO) and incidents stay within budget.

Security and abuse-resistance (token enumeration horizon)
- 7-char Base62 space = 3.52×10^12; 8-char = 2.18×10^14.
- Exhaustion time at 10k guesses/s: 7-char ≈ 11.17 years; 8-char ≈ 692.35 years.
- Exhaustion time at 100k guesses/s: 7-char ≈ 1.12 years; 8-char ≈ 69.24 years.
- Implication vs S-1: enforce rate limits and anomaly detection such that effective global guessing is held ≪10k/s and ≥99.99% abusive attempts are throttled/denied.

Impact assessment (Year 3 peak unless noted)
| Dimension | Estimate | Impact |
|-----------|---------:|:------:|
| CPU (RPS) | ~104k rps peak | 🟥 |
| RAM | Dataset ≤ 123 GB logical; cache needs ≪ 1 TB | 🟩 |
| Disk | ~369 GB effective (3×) | 🟩 |
| Network | ~0.0417 GB/s ≈ 0.33 Gbps | 🟩 |
| Architecture style | ≥100k rps suggests micro-services | 🟥 |
| Team seniority | Senior–Expert for ops/scale | 🟨 |
| Ops comments | Migrations, backups, SRE needed | 🟨 |

Notes
- Read path dominates; cache effectiveness (10% miss) strongly influences backend RPS and storage IOPS.
- P-2 (20k rps sustained) is exceeded by Year 1 peak read demand; capacity planning must consider peak sharding, caching, and edge distribution.
- Storage growth is modest; operational risks are primarily in throughput, cache efficacy, failover orchestration, and abuse controls.

## Consequences

- Sizing guidance: plan for ~35k/70k/104k peak redirect rps over Years 1–3, with backend misses at ~3.5k/6.9k/10.4k rps respectively; write load is negligible in comparison (~10 rps peak).
- Latency budgets imply tight but feasible per-tier SLAs; concurrency scales to ~5.2k in-flight requests at Y3 peak, which informs connection pooling and thread/async limits.
- Availability budgets (21.6 min/mo at 99.95%) combined with RTO < 5 min necessitate automated failover and partial-region resilience on the redirect path.
- Token enumeration is impractical at allowed rates for 8-char tokens; 7-char is borderline under aggressive global probing—rate-limiting and monitoring thresholds must be enforced to satisfy S-1 without harming P-1/A-1.
- These estimates highlight throughput/cache/datastore hot-spot risks over raw storage; they should drive early performance tests and cost modeling before detailed design.

