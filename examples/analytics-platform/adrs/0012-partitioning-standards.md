# 0012. Partitioning standards (tenant/time bucketing, part-size thresholds, auto-rebalancing)
Date: 2025-08-29

## Status
Proposed

## Context
- Business drivers: predictable query latency for interactive analytics and sustainable ingestion at ~100B events/day with 3× peaks, across multi-tenant workloads.
- Related Quality Attributes (from Quality Tree):
  - P-1 Performance: Report latency P95 ≤1.5s (≤3 months), P99 ≤2.5s.
  - S-1 Scalability: Ingestion throughput ~1.16M/s avg; 3× peaks ≥10 min; 0% loss.
- Secondary: R-1 Retention (hot ≤90d, warm/cold beyond), cost control, operability.
- Risks addressed (Section 11): RISK-PARTITIONING, RISK-QUERY-LATENCY, RISK-HOT-STORAGE, RISK-COST-DRIFT.
- Prior decisions: ADR-0003 (ClickHouse), ADR-0005 (Ingestion), ADR-0007 (Read tier), ADR-0009 (Autoscaling), ADR-0011 (Materializations).
- Problem: Non-standardized partition keys and part sizing cause excessive scanned bytes, merge thrash, hot shards, and tail-latency regressions under load.

## Comparison

Partitioning/bucketing strategies
| Option / Criteria | P-1 Latency | S-1 Ingestion/merges | Operability | Notes |
|-------------------|-------------|----------------------|-------------|------|
| A) Partition by month (toYYYYMM), ORDER BY (tenant_id, event_date, bucket, …), bucket per hour | 🟩 Strong pruning; small scan ranges | 🟩 Few partitions; controlled parts via buckets | 🟨 Needs bucket discipline | Good default for most tenants |
| B) Partition by day (toYYYYMMDD), ORDER BY (tenant_id, event_date, bucket, …) | 🟩 Strong pruning; finest time window | 🟨 More partitions to manage | 🟨 Higher metadata overhead | For very high-volume tenants only |
| C) Partition by tenant then time (multi-level) | 🟨 Pruning ok; can skew part counts | 🟨 Ingest localized; hot-tenant risk | 🟨 Complex | Tenant skew needs isolation via shards |

Part sizing and merge policy
| Option / Criteria | P-1 Latency (scan/IO) | S-1 (merge load) | Operability |
|-------------------|-----------------------|------------------|-------------|
| 1) Target 100–512 MB parts; cap parts/partition/shard; enforce insert batch size | 🟩 Predictable scan; cache-friendly | 🟩 Lower merge thrash | 🟨 Requires conformance checks |
| 2) Unbounded small parts; rely on background merges | 🟥 Fragmentation hurts scans | 🟥 Merge storms risk | 🟩 Simple but unsafe |

Rebalancing policies
| Option / Criteria | P-1 (hotspot relief) | S-1 (throughput balance) | Operability |
|-------------------|----------------------|--------------------------|-------------|
| X) Periodic auto-rebalance by bytes/rows/parts thresholds | 🟩 Reduces hotspots | 🟩 Smooths ingest | 🟨 Job + runbooks needed |
| Y) Manual/on-demand only | 🟨 Slow response | 🟨 Operators become bottleneck | 🟩 Simple but reactive |

## Decision
Adopt A) month partitions with hourly buckets for general use, B) day partitions for very high-volume tenants, combine with 1) 100–512 MB target part size and insert batching controls, and X) periodic auto-rebalancing based on thresholds.

Standards and tactics (mapped to P-1, S-1):
- Keys and partitions
  - Default facts: PARTITION BY toYYYYMM(event_date).
  - ORDER BY (tenant_id, event_date, bucket, /* optional dims */) with LowCardinality where applicable; bucket = toStartOfHour(event_date) or hashed bucket for wide tenants.
  - High-volume tenants: PARTITION BY toYYYYMMDD(event_date) to cap parts/partition.
  - optimize_skip_unused_shards=1 and prefer_localhost=1 on Distributed tables; shard by (tenant_id, toYYYYMM(event_date) [or day]) with consistent hashing.
- Part size & merge targets
  - Target part size 100–512 MB; enforce via writer batch sizing (rows/bytes/time) and ClickHouse settings (min_bytes_for_wide_part, max_partitions_per_insert_block).
  - Caps per shard: parts_per_partition ≤500; partitions open ≤64; merges backlog below SLO. Alert when exceeded.
  - Late-arrival window: allow corrections within N days; schedule OPTIMIZE/FINAL during low-traffic windows.
- Auto-rebalancing policy
  - Metrics: bytes_per_shard, rows_per_shard, parts_per_shard, QPS per shard.
  - Triggers: if any metric >1.5× cluster median for ≥30 min, initiate rebalance/move of partitions or buckets to underutilized shards.
  - Actions: ALTER TABLE … MOVE PARTITION/RESHARD PARTITION; throttle to protect merges; prefer moving old (sealed) partitions; run during off-peak.
  - Safety: dry-run and capacity checks; abort on Keeper lag or merge backlog thresholds.
- Guardrails & governance
  - Catalog of partitioning schemes by table; change control for key changes; backfill/migration playbooks.
  - Per-tenant isolation option: pin heavy tenants to dedicated shard group when skew >X%.
  - Observability: dashboards/alerts for parts/partition, merge backlog, scanned bytes, shard skew.

## Consequences
- Positive:
  - Strong time/tenant pruning and bounded part size reduce scanned bytes and P95/P99 tails (P-1).
  - Controlled parts/merges and periodic rebalancing sustain ingest under peaks and prevent hot shards (S-1).
  - Clear thresholds and automation reduce operator toil; predictable capacity planning.
- Negative / Risks:
  - Rebalancing and key changes add operational complexity; require careful scheduling and tooling.
  - Overly aggressive thresholds can cause churn/oscillation; tuning needed with real workloads.

Related ADRs: ADR-0002 (Baselines), ADR-0003 (ClickHouse), ADR-0005 (Ingestion), ADR-0007 (Read tier), ADR-0009 (Autoscaling), ADR-0011 (Materializations).

