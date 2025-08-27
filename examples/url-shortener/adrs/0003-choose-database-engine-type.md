# 3. Choose database engine type

Date: 2025-08-26

## Status
Accepted

Amends [1. Record architecture decisions](0001-record-architecture-decisions.md)

Clarifies [2. Choose URL shortening algorithm](0002-choose-url-shortening-algorithm.md)

## Context
Business drivers: shorten and resolve ~100M new links per year (1M users × 100), store for 3 years (~300M rows), and serve fast redirects (p50 ≤ 0.2s) with average traffic ~3B redirects/day (~35k rps) and seamless releases. Click statistics are handled by a third-party. Quality attributes: performance/latency for reads, scalability for high read load and steady writes, availability across failures (two-node failure adds ≤0.1s), durability for 3-year retention, cost efficiency, and operability. Workload shape: hot read path is a single key lookup slug → target URL; write path requires uniqueness on slug and simple metadata. Multi-tenant namespace may be needed later and strong global ordering is not required. The algorithm ADR requires uniqueness enforcement with retry on conflict and no global coordinator.

Comparison of engine types:

| Type                                   | Data model fit (slug→URL) | Uniqueness/conditional write | Read latency @ scale | Horizontal scaling | Multi-region/geo | Operability | Cost efficiency | Durability/TTL | Query flexibility | Maturity/portability |
|----------------------------------------|---------------------------|------------------------------|----------------------|-------------------|------------------|-------------|-----------------|----------------|-------------------|----------------------|
| Relational (RDBMS + replicas)          | ★★                        | ★★★ Unique index             | ★★                   | ★ Read-heavy only | ★ Complex        | ★★          | ★★              | ★★ Jobs needed  | ★★★               | ★★★                  |
| Distributed SQL (NewSQL)               | ★★★                       | ★★★ Strong constraints       | ★★                   | ★★★               | ★★★              | ★★          | ★               | ★★              | ★★★               | ★★                   |
| Distributed key-value / wide-column    | ★★★                       | ★★★ PK/conditional put       | ★★★                  | ★★★               | ★★               | ★★          | ★★★             | ★★★ Native TTL  | ★                 | ★★★                  |
| Document store                         | ★★                        | ★★★ Unique index             | ★★                   | ★★                | ★★               | ★★          | ★★              | ★★★ TTL support | ★★★               | ★★★                  |
| Graph database                         | ★                         | ★★                           | ★                    | ★                 | ★                | ★★          | ★               | ★★              | ★★                | ★★                   |
| Time-series database                   | ★                         | ★                            | ★                    | ★★                | ★★               | ★★          | ★★              | ★★★             | ★                 | ★★                   |
| In-memory cache as primary (volatile)  | ★★                        | ★★                           | ★★★                  | ★★★               | ★★               | ★★          | ★               | ★               | ★                 | ★★★                  |

## Decision
Use a distributed key-value / wide-column database as the primary durable store for slug→URL mappings, leveraging a single-partition primary key on slug (optionally namespace+slug) and conditional puts (create-if-not-exists) to enforce uniqueness without a global coordinator. Pair the primary store with a replicated in-memory cache at the edge for ultra-low-latency reads on the hot path. Do not select a specific product yet.

## Consequences
Positive:
- Excellent fit for simple key lookups with very low read latency and elastic horizontal scaling; native TTL and partitioning ease lifecycle/retention and scale-out.
- Conditional writes or PK uniqueness satisfy the algorithm ADR’s uniqueness requirement without central coordination; write retries handle rare collisions.
- Cost-efficient at large scale versus globally consistent relational deployments; straightforward operability with managed options available.

Negative:
- Limited ad hoc querying and joins; operational analytics/reporting may require a separate system or export pipeline.
- Cross-item transactions are constrained; modeling must keep the redirect path single-key and idempotent.
- Multi-region strong consistency varies by product; additional design (per-region writes or global tables) may be needed for active-active.
