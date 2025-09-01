# 2. Identify Parameters for Estimation of Technical Risks

Date: 2025-09-01

## Status

Proposed

## Context

This ADR captures the assumptions and parameters needed for a subsequent back-of-the-envelope estimation of the URL Shortener, and explicitly references relevant Quality Attribute Requirements (QARs) and Scenarios (QASs).

Assumptions (no calculations):
- User growth: +1,000,000 users per year (net new).
- Link creation rate: 100 links per user per year.
- Redirect frequency: 10 reads per link per day (average).
- Traffic variability: peak-to-average multiplier ×3.
- Redirect payload size over the wire: ~400 bytes (headers + minimal body).
- Record shapes: ~400 bytes per link (incl. index/overhead), ~1,024 bytes per user.
- Replication factor for durability/capacity planning: 3×.
- Cache effectiveness: steady-state cache miss ratio for redirects = 10%.
- Token namespace: Base62, length 7–8 characters.

Referenced QARs/QASs (to feed later estimates):

| ID  | Quality Attribute | Scenario                   | Key Numbers / Constraints                                |
|-----|-------------------|----------------------------|----------------------------------------------------------|
| P-1 | Performance       | Fast redirect latency      | P95 ≤ 50 ms; P99 ≤ 120 ms                                |
| P-2 | Performance       | High throughput redirects  | Sustain 20k rps; err < 0.5%; P95 ≤ 100 ms                |
| A-1 | Availability      | Failover on node/zone loss | RTO < 5 min; SLO ≥ 99.95% monthly                        |
| S-1 | Security          | Block token enumeration    | ≥ 99.99% attempts throttled/denied; no destination leak  |
| S-2 | Security          | Authorize admin mutations  | 100% writes require auth; 0 unauthorized changes         |
| R-1 | Reliability       | No data loss on failure    | RPO = 0; redirect path ≥ 99.9% available during incident |

## Decision

We will estimate, without calculating yet, the following parameters to validate capacity, latency, and reliability against the QARs/QASs above:

Users and links
- New users per year and cumulative users over time.
- New links per year and cumulative links over time.

Throughput and peaks
- Write RPS (average and peak) for link creation.
- Read RPS (average and peak) for redirects.
- Backend read RPS as a function of cache miss ratio (e.g., 10%).

Latency and budgets
- End-to-end redirect latency budget allocation across tiers to meet P-1.
- Error and downtime budgets implied by A-1 (RTO, SLO) and R-1.

Storage and capacity
- Logical data sizes for users and links given record shapes.
- Effective storage footprint including replication factor (3×) and overheads.

Network and concurrency
- Average and peak bandwidth derived from response size and read RPS.
- Connection concurrency requirements and limits on the redirect path.

Security and abuse resistance
- Brute-force horizon based on Base62 token space (7–8) and acceptable request rates.
- Rate-limiting and anomaly-detection thresholds to satisfy S-1 and protect P-1/A-1.

## Consequences

- The identified parameters will guide sizing for compute, storage, and networking, and highlight potential bottlenecks (cache effectiveness, datastore capacity, connection limits) relevant to P-1 and P-2.
- Availability and reliability risks (failover, replication, backup/restore, maintenance windows) will be assessed against A-1 and R-1 before detailed design.
- Security risks from token enumeration and unauthorized mutations will be framed against S-1 and S-2 to define rate limits, authentication, and auditing requirements.
- Once estimates are completed, trade-offs and cost impacts can be articulated early, reducing rework during implementation.
