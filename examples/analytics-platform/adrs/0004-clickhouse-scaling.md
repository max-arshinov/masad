# 0004. ClickHouse Scaling Strategy
Date: 2025-08-28

## Status
Superseded by [0005. Design ClickHouse ingestion mechanism](0005-clickhouse-ingestion-mechanism.md)

## Context
Business drivers
- Multi-tenant analytics with near-real-time dashboards and indefinite retention.
- Cost-efficient scale-out for ~100B events/day with regional presence.

Related Quality Attributes (from Quality Tree)
- P-1 Performance (Report latency): P95 ≤1.5s over ≤3 months.
- P-2 Performance (Freshness): P95 ≤60 min, P99 ≤100 min end-to-end.
- S-1 Scalability (Ingestion): ~100B events/day (~1.16M/s avg), 3× peak for ≥10 min, 0% loss.
- R-1 Retention: Hot ≥3 months; warm/cold indefinite; restore ≤24h; integrity verified.

Assumptions and constraints
- ADR-0003 selected ClickHouse for the hot analytical tier.
- Three regions; per-AZ high availability is required; OSS-first; object storage available for warm/cold.

## Comparison
Scaling options for ClickHouse

| Option / Criteria                                                                                | P-1 Latency                                                        | P-2 Freshness                                  | S-1 Ingestion                                     | R-1 Retention                                            |
|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|------------------------------------------------|---------------------------------------------------|----------------------------------------------------------|
| A) Single regional cluster: sharded on local NVMe (MergeTree), 2–3 replicas, Distributed queries | 🟩 Strong locality; prune by time/tenant; vectorized scans         | 🟩 Kafka→MV path; minute-scale; simple routing | 🟩 Horizontal shards scale writes; proven >1M eps | 🟨 TTL to S3 possible; hot on SSD; careful capacity mgmt |
| B) Cell-based multi-cluster (per-tenant/segment) with federation                                 | 🟨 Router/query fan-out increases tail                             | 🟩 Isolate ingest; freshness per cell          | 🟩 Add cells to scale; blast radius reduced       | 🟩 Each cell can tier; operational isolation             |
| C) Compute–storage separation: S3 disks for most data; stateless compute                         | 🟨 Remote IO; cache needed; higher tail                            | 🟨 Object-store consistency adds delay         | 🟨 Writes slower; merges affected                 | 🟩 Excellent durability/cost; easy infinite retention    |

## Decision
Adopt a hybrid strategy centered on Option A for the hot tier and Option C for warm/cold:
- Primary: one sharded-and-replicated ClickHouse cluster per region using local NVMe (MergeTree) for hot data (≤3 months).
- Tiering: TTL-based movement of older partitions to S3/object storage (S3 disks) as warm/cold, with selective restore.
- Federation: reserve Option B (additional cells) for scale-out beyond thresholds (e.g., shards >64, parts/partition > target) or tenant isolation needs.

Key tactics and configuration (mapped to QAs)
- Sharding/replication (S-1, P-1): shard by tenant_id and time; 2–3 replicas per shard; use Distributed tables with optimize_skip_unused_shards=1 and prefer_localhost=1; ClickHouse Keeper for coordination; per-AZ replica spread.
- Partitioning/indexing (P-1): partition by month/day (toYYYYMM/ toYYYYMMDD); ORDER BY (tenant_id, event_date, bucket, …); low-cardinality and bloom/skip indexes for high-selectivity filters; projection indexes or AggregatingMergeTree for common rollups.
- Ingestion (S-1, P-2): Kafka engine + Materialized Views to MergeTree; idempotent keys for dedupe; async inserts; control parts via max_partitions_per_insert_block, min_bytes_for_wide_part; tune background_pool_size/merge constraints to sustain 3× peaks.
- Query latency (P-1): pre-aggregations (hour/day); result_cache; mark_cache and uncompressed_cache sized; column pruning; LIMIT with partial aggregation; approximate distincts (uniqCombined) where acceptable.
- Freshness (P-2): per-stage budgets; watermarking/late arrival windows; consumer autoscaling; priority lanes for hot partitions; monitor age-of-last-event.
- Retention & cost (R-1): storage policies with TTL move to S3 disks; compression ZSTD/LZ4HC; periodic scrubbing and checksum verification; selective restore tooling.
- Operations (S-1, R-1): admission control and resource groups; per-tenant quotas; online resharding/rebalancing (ALTER TABLE … MOVE/REBALANCE PARTITION); capacity SLOs for parts count, merges, disk usage; HA via rolling restarts and replica lag limits.

## Consequences
Positive
- Meets P-1 and P-2 for hot data via local-SSD shards, pruning, pre-aggregations, and Kafka→MV pipeline.
- Meets S-1 by horizontal sharding and controlled merge/ingest settings; scale per region independently.
- Meets R-1 with TTL tiering to S3 and selective restore; cost efficiency for long-term data.
- Clear path to further scale by adding shards or, if needed, new cells for isolation.

Negative / Risks
- Operational tuning required (merges, parts count, Keeper, tiering). Misconfiguration can hurt P-1.
- Remote object storage access for warm/cold increases tail latency for ad-hoc queries.
- Cross-cell queries (if introduced) add complexity and may impact P-1.

Related ADRs
- ADR-0003: Choose primary analytics database (ClickHouse).
