# 0011. Query materialization strategy (pre-aggregations/cubes, distinct approximations)
Date: 2025-08-29

## Status
Proposed

Relates to [2. Baseline capacity and back-of-the-envelope estimates](0002-baseline-capacity-and-bote-estimates.md)


## Context
- Business drivers: interactive dashboards and ad-hoc reports must meet P95 ≤1.5s over ≤3 months without timeouts, while controlling cost at 100–500 concurrent queries.
- Related Quality Attributes (from Quality Tree):
  - P-1 Performance: Report latency (P95 ≤1.5s; P99 ≤2.5s).
- Secondary considerations: S-1 Scalability (reduce backend scan/CPU), cost efficiency.
- Prior decisions: ADR-0003 selected ClickHouse; ADR-0007 defined read tier and caching; ADR-0002 baseline shows scans must be kept to a few GB/query or lower.
- Problem: raw on-the-fly aggregation on fact tables can exceed scanned-bytes budgets and cause tail latency spikes, especially for high-cardinality dimensions and distinct counts.

## Comparison

| Option / Criteria | P-1 Latency (tails) | Freshness / Staleness | Storage/Cost Overhead | Complexity/Operability |
|-------------------|----------------------|-----------------------|-----------------------|------------------------|
| A) Native pre-aggregations in ClickHouse (Materialized Views → Aggregating/SummingMergeTree; projections) | 🟩 Lowest tails for common rollups; bytes scanned minimized | 🟨 Minutes-scale lag; depends on ingest and merges | 🟨 +20–100% for rollup tables | 🟨 MV design/governance needed |
| B) Query cache only (edge/app + CH result cache), no pre-aggregation | 🟨 Good when cache hit; 🟥 poor/miss → large scans | 🟨 Cache TTL/SWR; no additional staleness | 🟩 Minimal | 🟩 Simple but hit-rate dependent |
| C) External cube service (e.g., Cube-like precompute layer) | 🟩 Good tails; serves hot metrics | 🟨 Added handoff lag; dual storage | 🟨 Extra infra cost | 🟥 More components/ETL paths |
| D) Approximate algorithms for heavy distincts (uniqCombined/uniqHLL12) | 🟩 Large tail reduction on distincts | 🟩 No extra staleness | 🟩 Minimal | 🟩 Low; per-query control |

## Decision
Adopt a hybrid of A + B + D:
- Primary: Native pre-aggregations (Materialized Views) for the top query shapes (time-bucketed metrics by tenant and common dimensions at hour/day granularity).
- Always-on caching: Deterministic query hashing with edge/app/CH result caching for repeated queries; short s-maxage and SWR aligned with P-2 budgets.
- Approximations: Use uniqCombined/uniqHLL12 for distincts in interactive paths; exact variants reserved for background or small-scope queries.
- Fallback: Raw-table scans are allowed under strict scanned-bytes guardrails and timeouts; route to rollups when possible.

Architectural tactics and configuration (mapped to P-1):
- Rollup schema: AggregatingMergeTree/SummingMergeTree with keys (tenant_id, date_bucket, dim1[, dim2]) and partial aggregates (count, sum, uniq*). Projections for common GROUP BYs.
- Materialization: Incremental MVs fed by ingest (staging) tables; batch sizes tuned to control parts/merges; lateness window with periodic OPTIMIZE/FINAL where needed.
- Query routing: Read API maps chart definitions to rollup tables by capability matrix; falls back to raw only when filters/groupings unsupported; encode versioned query plans.
- Distinct strategy: Default to uniqCombined/approx on interactive endpoints; feature flag for exact counts; expose approximation note in response metadata.
- Guardrails: Per-tenant budgets for scanned_bytes/query, max_rows_to_read, max_query_time_ms; deny/reshape queries exceeding budgets with guidance.
- Cache policy: Query_hash keys; ETag + Cache-Control (s-maxage ~60s, stale-while-revalidate ~300s); purge/version on schema changes.
- Observability: Metrics — cache_hit_ratio, scanned_bytes, p95/p99 latency per query shape, MV lag (seconds), MV error rates.
- Governance: Catalog of rollups (owner, dims, freshness SLO); deprecation/versioning process; backfill tooling for new rollups.

## Consequences
- Positive:
  - Substantially reduces scanned bytes and tail latencies for common charts; improves P-1 adherence under concurrency.
  - Keeps infra cost in check by shifting work to incremental precompute and caches.
  - Provides explicit guardrails and visibility (MV lag, cache hit ratio) to manage SLOs.
- Negative / Risks:
  - Additional storage and MV management overhead; risk of staleness or drift without governance.
  - Query routing logic adds complexity and requires versioning/testing.
  - Approximate distincts introduce small error; must be opt-out/communicated.

Related ADRs: ADR-0002 (Baselines), ADR-0003 (ClickHouse), ADR-0005 (Ingestion/backfill), ADR-0007 (Read tier), ADR-0008 (Language), ADR-0009 (Autoscaling).

