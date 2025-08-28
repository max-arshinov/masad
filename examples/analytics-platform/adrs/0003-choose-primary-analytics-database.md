# 0003. Choose primary analytics database
Date: 2025-08-28

## Status
Proposed

## Context
- Business drivers: multi-tenant web/app analytics, near-real-time dashboards, cost-efficient scale-out, indefinite retention.
- Related Quality Attributes (from Quality Tree):
  - P-1 Performance: Report latency ≤1.5s P95 over ≤3 months of data.
  - P-2 Performance: Data freshness P95 ≤60 min, P99 ≤100 min end-to-end.
  - S-1 Scalability: Ingestion ~100B events/day (~1.16M/s avg), 3× peak for ≥10 min; 0% loss.
  - R-1 Retention: Hot ≥3 months; warm/cold indefinite; restore ≤24h; integrity verified.
- Workload & constraints (see ADR-0002): ~100B events/day, 3 active regions, 100–500 concurrent queries, columnar scans 1–2 GB/s/node, vectorized execution, cost efficiency, OSS-first.

## Comparison

| Tool / Criteria | P-1 Report latency | P-2 Freshness | S-1 Ingestion throughput | R-1 Retention |
|-----------------|---------------------|---------------|---------------------------|---------------|
| ClickHouse      | 🟩 Vectorized engine; MergeTree; pre-agg/caching | 🟩 Kafka engine + MVs; minutes-scale E2E | 🟩 Sharded writes; 1M+ eps with partitions | 🟩 TTL tiering; S3 disks; ZSTD; cost-efficient |
| Apache Druid    | 🟩 Segment pruning; broker cache | 🟨 Good; realtime + batch; segment handoff adds delay | 🟨 High but segment build/hand-off overhead | 🟩 Deep storage + historicals; tiering built-in |
| Apache Pinot    | 🟨 Low-latency recent data; longer windows slower | 🟩 Strong realtime ingestion | 🟩 High; append-only columnar | 🟨 Long-term retention less cost-efficient vs deep storage |
| BigQuery        | 🟨 Interactive OK; cold start and quotas apply | 🟨 Minutes–hours; streaming to tables costs | 🟨 High logical throughput; egress/quotas | 🟩 Cheap cold storage; long-term retention |
| Summary         | 🌟 Best fit on all four QAs with OSS + cost control | — | — | — |

## Decision
Select ClickHouse as the primary hot-tier analytics database.

Architectural tactics and configuration:
- Data model and engines: ReplicatedMergeTree for fact tables; AggregatingMergeTree/SummingMergeTree for rollups; dictionaries for dimensions; appropriate primary key (tenant_id, event_date, optional bucketing).
- Sharding and replication: shard by tenant and time; 2–3 replicas per shard; Distributed table for fan-out queries; ClickHouse Keeper for coordination.
- Ingestion: Kafka engine + Materialized Views for streaming ingest; batch backfills via INSERT SELECT; idempotent ingestion with dedupe keys.
- Query performance: strict partitioning by time/tenant; column pruning; pre-aggregations (hour/day); result cache; approximate distincts (uniqExact/uniqCombined) per need.
- Freshness: stage budgets in pipeline; autoscale consumers; watermarking and late-arrival handling; DLQ and replay.
- Retention & cost: TTL to move cold partitions to S3/object storage; S3 disks for warm; compression (ZSTD/LZ4HC); compaction windows tuned to load.
- Reliability & ops: per-AZ spread; backup/restore via object-store snapshots; quotas and admission control; observability (scanned bytes, P95, merges, parts count).

## Consequences
- Positive:
  - Meets P-1 with vectorized engine, partition pruning, and pre-aggregations.
  - Meets P-2 with Kafka engine + MVs enabling minutes-scale freshness.
  - Meets S-1 via horizontal sharding and high write throughput; proven at >1M eps.
  - Meets R-1 with TTL tiering to object storage and fast selective restores.
  - Strong cost efficiency (OSS, compression, S3 tiering) and mature ecosystem.
- Negative / Risks:
  - Operational complexity (merges, parts count, background tasks) requires tuning and runbooks.
  - Partition/key design errors can cause hot spots or large scans.
  - Aggregations for unique counts may need approximations to keep latency targets.
  - Multi-region replication is async; cross-region queries may need federation.

Related ADRs: ADR-0002 (Baseline capacity and BOTE estimates).
