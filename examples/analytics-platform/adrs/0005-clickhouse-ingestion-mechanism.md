# 0005. Design ClickHouse ingestion mechanism
Date: 2025-08-28

## Status
Proposed

## Context
- Business drivers: multi-tenant web/app analytics, near-real-time dashboards, cost-efficient scale-out, indefinite retention across regions.
- Related Quality Attributes (from Quality Tree):
  - P-1 Performance (Report latency): P95 ≤1.5s over ≤3 months of data.
  - P-2 Performance (Data freshness): P95 ≤60 min, P99 ≤100 min end-to-end.
  - S-1 Scalability (Ingestion throughput): ~100B events/day (~1.16M/s avg), 3× peak for ≥10 min; 0% loss.
  - R-1 Retention: Hot ≥3 months; warm/cold indefinite; restore ≤24h; integrity verified.
- Workload & constraints: SDKs and batch importers produce append-only events; at-least-once delivery with idempotency; OSS-first; three regions; per-AZ HA. ADR-0003 selected ClickHouse as hot tier; ADR-0004 defines scaling/tiering.

## Comparison

| Option / Criteria                                                          | P-2 Freshness                           | S-1 Ingestion                                       | P-1 Latency (indirect)                     | R-1 Retention / Integrity                          |
|----------------------------------------------------------------------------|-----------------------------------------|-----------------------------------------------------|--------------------------------------------|----------------------------------------------------|
| A) External writer tier (Kafka Connect/Vector/Flink) → HTTP/native insert  | 🟩 Minutes-scale; batch control         | 🟩 Independently scalable tasks; shard-aware writes | 🟩 Batching controls parts/merges          | 🟩 DLQ/replay in writer; idempotency + checksums   |
| B) Kafka Engine + Materialized Views → MergeTree (in-cluster consumers)    | 🟩 Sub-minute to few minutes            | 🟥 Coupled to CH nodes; can’t scale independently   | 🟨 Merge/parts contention possible         | 🟨 DLQ/replay external; relies on MV dedupe        |
| C) HTTP batch inserts (async) → Distributed/ReplicatedMergeTree (fallback) | 🟨 Seconds–minutes; depends on batching | 🟨 App-side batching/LB headroom needed             | 🟨 Higher CPU per request; variable tail   | 🟨 API backpressure; dedupe via ReplacingMergeTree |
| D) Staged S3/Blob + INSERT SELECT (backfill/restore path)                  | 🟥 Not realtime                         | 🟩 Very high throughput for historical loads        | 🟨 Not for realtime; no impact on hot path | 🟩 Cost-efficient bulk loads; good for restores    |

## Decision
Adopt Option A (external writer tier) as the primary ingestion mechanism. Use D for backfills/restores. Keep C as a limited fallback for small tenants/offline edge uploads. Restrict B (Kafka Engine + MVs) to narrow cases and operational convenience; do not use as primary at scale due to its coupling to ClickHouse node count.

Architectural tactics and configuration (mapped to QAs):
- Event envelope and idempotency (S-1, P-2, R-1): include event_id (UUID), tenant_id, ts_event, write_timestamp, and optional version. Target tables use ReplacingMergeTree(version) or AggregatingMergeTree with deterministic keys to enable de-duplication and late correction. Include a dedupe token (event_id) column and periodic OPTIMIZE or dedup passes within the lateness window.
- External writer tier (S-1, P-2):
  - Writers: Kafka Connect ClickHouse Sink, Vector → clickhouse sink, or Flink/Spark jobs. Scale task count independently of ClickHouse; pin tasks per shard/tenant for locality.
  - Batching & flow control: size by rows/bytes/time (e.g., 100k rows or 16–64MB) with gzip/zstd; backoff on HTTP 429/500; retries with idempotency keys; enforce max_inflight.
  - Shard-aware routing: write to local shard via Distributed tables with prefer_localhost=1 or direct to shard endpoints using a routing service; partition mapping by tenant_id and time bucket to balance load.
  - DLQ & replay: route parse/validation failures to DLQ topics/files with offsets; provide replay tooling to reprocess ranges; surface per-tenant error budgets.
- Late arrivals & freshness (P-2): define a watermark per tenant/stream; accept late events within a configurable window; use ReplacingMergeTree(version) for corrections; schedule periodic deduplication/OPTIMIZE within the window; expose stage budgets in dashboards.
- Backfill/restore (R-1, S-1): load parquet/CSV from object storage into staging tables; INSERT SELECT into targets with tuned max_threads and max_insert_block_size to avoid merge thrash. Use manifest indexes and quotas.
- HTTP fallback (P-2, S-1): enable async_insert=1 and async_insert_max_data_size for small/edge uploads; set insert_quorum for critical tenants; route writes to regional clusters; prefer_localhost=1 on Distributed tables.
- Observability & SLOs (P-1, P-2, S-1): track producer lag, writer task throughput, insert latency/error rates, ClickHouse parts count and merges backlog, kafka_rows_read (if applicable), E2E freshness; alert on QA thresholds.
- Security & compliance: TLS for brokers and ClickHouse; authn/authz per tenant; PII handling in ETL where applicable.

## Consequences
- Positive:
  - Meets P-2 with streaming ingest and clear stage budgets; independent writer scaling maintains freshness under peaks.
  - Meets S-1 via horizontal scaling of writer tasks and shard-aware batching; reduces parts explosion risk versus in-cluster consumers.
  - Supports P-1 indirectly by delivering hot data in MergeTree with controlled batch sizes and pre-aggregations; isolates query nodes from consumer scaling.
  - Supports R-1 with reliable DLQ/replay, idempotent writes, and cost-effective bulk backfills/restores from object storage.
- Negative / Risks:
  - Additional components (Connect/Vector/Flink) increase operational footprint and require monitoring/runbooks.
  - Exactly-once end-to-end remains limited; depends on idempotency/deduplication semantics and careful routing.
  - Misrouted or undersized batches can increase parts/merge pressure; requires tuning and conformance checks.

Related ADRs: ADR-0003 (Choose primary analytics database), ADR-0004 (ClickHouse scaling strategy).
