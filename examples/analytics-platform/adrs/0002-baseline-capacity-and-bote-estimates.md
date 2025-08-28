# 2. Baseline capacity and back-of-the-envelope estimates
Date: 2025-08-28

## Status
Proposed

## Context
This ADR captures baseline assumptions and back-of-the-envelope (BOTE) estimates to validate feasibility and scope future design decisions for the analytics platform.

Business drivers:
- Multi-tenant web/app analytics with near-real-time dashboards and indefinite retention.
- Global ingestion with cost-effective scale-out.

Related Quality Attributes (by ID from Quality Tree):
- P-1 Performance: Report latency.
- P-2 Performance: Data freshness.
- S-1 Scalability: Ingestion throughput.
- R-1 Retention: Data retention.

Key assumptions (A):
- A1. Event volume: 100B events/day average (per S-1), 3× peak for ≥10 min.
- A2. Event size (on wire): 0.5–1.0 KB avg; stored (columnar) compression 3×–6×.
- A3. Regions: 3 active regions; traffic roughly evenly split for normal ops.
- A4. Hot tier retention: 3 months; warm/cold: indefinite (per R-1).
- A5. Query window: up to 3 months without precomputed materializations; cache miss allowed (per P-1).
- A6. Analyst concurrency: 100–500 concurrent queries during business peaks.
- A7. API/ETL worker throughput envelope (today’s hardware):
  - Stateless ingest API: 50–100k req/s per instance.
  - Stream partitions: 10–20 MB/s per partition sustained.
  - ETL worker: ~100k events/s effective processing.
  - Columnar scan: 1–2 GB/s per node effective (vectorized, column-pruned).
- A8. Freshness target: P95 ≤60 min; P99 ≤100 min end-to-end (per P-2).

## Decision
No technical choice is made in this ADR. We record BOTE estimates and constraints to inform subsequent ADRs that will select technologies, topologies, and tactics targeting P-1, P-2, S-1, and R-1.

## Consequences
- Provides quantitative guardrails for sizing and architecture options.
- Highlights likely bottlenecks (network, partitions, scan rates) early.
- Must be refined with benchmarks and real workload characteristics during implementation.

## Estimates and sanity checks
Notation: 1 day = 86,400 s.

1) Ingestion throughput (per S-1)
- Avg EPS: 100,000,000,000 / 86,400 ≈ 1.16M events/s.
- Peak EPS (3×): ≈ 3.47M events/s for ≥10 min.

2) Network bandwidth (ingest path)
Let S = average event size on wire.
- Avg: 1.16M/s × S.
  - At S = 1.0 KB → ≈ 1.16 GB/s ≈ 9.3 Gbps.
  - At S = 0.5 KB → ≈ 0.58 GB/s ≈ 4.7 Gbps.
- Peak: 3.47M/s × S.
  - At S = 1.0 KB → ≈ 3.47 GB/s ≈ 27.8 Gbps.
  - At S = 0.5 KB → ≈ 1.74 GB/s ≈ 13.9 Gbps.
Implication: Per-region NIC capacity and LB tiers must comfortably exceed these rates (headroom ≥2× under failures).

3) Buffering/backlog for freshness (per P-2)
To tolerate T minutes of downstream delay at peak:
- Events buffered ≈ 3.47M/s × (T × 60).
  - T = 10 min → ≈ 2.08B events; at 1.0 KB ≈ 2.08 TB.
  - T = 60 min → ≈ 12.5B events; at 1.0 KB ≈ 12.5 TB.
Implication: Stream/broker + object store must absorb TB-scale transient backlogs without loss.

4) Stream partitions and brokers (Kafka-like envelope)
Peak data rate at S = 1.0 KB ≈ 3,472 MB/s. Safe partition throughput ≈ 10 MB/s (A7):
- Minimum partitions ≈ 3,472 / 10 ≈ 347 → round to 512+ for headroom and rebalancing.
Broker sizing depends on disk/network; at ~300–500 MB/s/broker sustainable, ballpark 8–12 brokers per region for ingest-only (add replicas, consumers → 24–36+ per region).

5) Hot/warm/cold storage capacity (per R-1)
Daily raw volume (wire size S):
- At S = 1.0 KB → ≈ 100 TB/day; S = 0.5 KB → ≈ 50 TB/day.
Compression (3×–6×) in columnar/object storage:
- Hot 90 days: raw 4.5–9.0 PB → compressed ≈ 0.75–3.0 PB.
- 1 year: raw 18–36 PB → compressed ≈ 3–12 PB.
Implication: Hot tier must efficiently prune/partition; warm/cold requires lifecycle policies, checksum verification, and restore ≤24h.

6) Query scan budget for P-1 (≤3 months, cache miss accepted)
Let Rq be effective cluster scan rate per query.
- To hit 1.5 s P95, data scanned per query D ≤ Rq × 1.5 s.
- With 5–10 GB/s effective per-query scan (parallel across nodes), D should be ≤7.5–15 GB.
Implications:
- Partitioning by tenant/time and column-pruning are mandatory to bound D.
- Without materializations, designs must keep most queries within a few GB scanned.

7) Serving/query concurrency (A6)
If 100–500 concurrent queries, each scanning 1–5 GB and finishing in ~1.5–2.5 s:
- Required aggregate scan rate ≈ 100–500 × (1–5) GB / 2 s → 50–1,250 GB/s.
Implication: Either (a) strong partition pruning so effective D per query ≪1 GB, or (b) materializations/cubing for hot paths; otherwise cost explodes.

8) Rough instance counts (order-of-magnitude)
- Ingest API: at 50–100k req/s per instance → 35–70 instances to cover 3.47M/s peak; add N+2 and AZ spread → target 60–120 per region.
- Writers/ETL: at ~100k events/s → ≈ 35 to match peak; add enrichment/serialization overhead → 50–100 per region.
- Stream partitions: 512–1,024 per region to allow consumer parallelism and failures.

9) Very rough storage cost (illustrative, not a decision)
- Hot columnar tier (e.g., SSD-backed analytics store) cost is dominated by compute; omitted here.
- Warm/cold object storage at $23/TB-month (standard) or $5/TB-month (cold):
  - 3 PB compressed (hot horizon copy) → $69k/month (standard) or $15k/month (cold-tier replica).
  - 12 PB compressed (1-year) → $276k/month (standard) or $60k/month (cold).
Note: Access patterns and retrieval fees may change cold-tier economics.

## Confidence level
- Throughput/bandwidth/backlog: Medium (math straightforward; workload variance moderate).
- Storage and compression: Low–Medium (depends on schema, cardinality, and column entropy).
- Query scan/concurrency requirements: Low (highly workload-dependent; must be validated with benchmarks and realistic filters/groupings).

## Implications for future decisions
- Sizing targets: design for ≥3.5M events/s peak (per region share) with ≥2× headroom and zero loss (S-1).
- Freshness budgets: pipeline stages and queues must comfortably handle 10–60 min backlogs without data loss (P-2).
- Query path must guarantee strong pruning/partitioning and/or materializations to keep D/query within the 1–10 GB band to meet P-1 at stated concurrency.
- Storage: lifecycle policies with verified integrity and restore flows for warm/cold (R-1).

## References
- Quality Requirements: P-1, P-2, S-1, R-1 (see docs/src/10_quality_requirements.adoc).
- Instruction files consulted: .github/instructions/10_quality_requirements.instructions.md; .github/instructions/adr.instructions.md.

