# 3. Choose ingestion to ClickHouse

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Scale to ~100B events/day across tenants with 50–100 min ingest-to-availability.
- Low-latency analytical queries (<= 1.5s) over up to 3 months of data.
- At-least-once delivery with deduplication; late arrivals and evolving schemas.
- Cost control, portability, and operational simplicity where feasible.

Architectural tactics influencing the choice:
- Durable, replayable buffer for backpressure smoothing and recoverability.
- Batch-oriented ingestion into column store with rollups via materialized views.
- Idempotency/dedup using event_id + version with ReplacingMergeTree/AggregatingMergeTree.
- Schema management via registry (Avro/Protobuf), contracts and validation.

Comparison of alternatives (higher is better):

| Ingestion / Criteria                               | Delivery semantics           | Replay & retention              | Ordering (per key)         | Latency to availability       | Throughput & batching        | Transformations in-flight            | Schema evolution            | Ops complexity                | Cost & lock-in           | Portability/open |
|----------------------------------------------------|------------------------------|----------------------------------|-----------------------------|-------------------------------|-------------------------------|--------------------------------------|-----------------------------|-------------------------------|--------------------------|------------------|
| Kafka + CH Kafka Engine + Materialized Views       | ★★★ At-least-once, idempotent| ★★★ Long via Kafka + reconsume  | ★★★ Partition-key ordering  | ★★ Low-minutes with MV        | ★★★ High via consumer batches | ★★★ SQL in MVs, rollups/sketches     | ★★★ With Schema Registry    | ★★ Requires ops for Kafka/CH | ★★ Infra cost, portable  | ★★★ Open source   |
| Kafka Connect ClickHouse Sink (direct INSERT)      | ★★ At-least-once, idempotent | ★★★ Long via Kafka + reconsume  | ★★★ Partition-key ordering  | ★★ Low-minutes                | ★★ Good, connector dependent  | ★★ Limited; transform SMTs           | ★★★ With Schema Registry    | ★★ Connector mgmt, simpler    | ★★ Infra cost, portable  | ★★★ Open source   |
| HTTP bulk inserts to ClickHouse (edge -> CH)       | ★ Best-effort unless idempot | ★ Limited, app-managed          | ★ App-managed               | ★★ Seconds-minutes            | ★★ Good with batching         | ★ Basic; push to staging tables       | ★ App-managed               | ★★★ Simple to start           | ★★★ Low lock-in          | ★★★ Open          |
| S3 staged batch + CH S3Queue/s3() + MVs            | ★★ At-least-once via files   | ★★★ Very long via object store  | ★★ Per-file                 | ★ Batches; slower to minutes  | ★★★ Very high via large files | ★★ Transform in MVs after load        | ★★ Via file schemas         | ★★ Manage compaction/listener | ★★★ Cheap storage         | ★★★ Open          |
| Managed ingest (CH Cloud Tasks/ETL service)        | ★★ At-least-once, varies     | ★★ Varies by service            | ★★ Varies                   | ★★ Low-minutes                | ★★ Good                       | ★★ Varies; usually limited            | ★★ Varies                   | ★★★ Low ops                   | ★ Lock-in                | ★ Proprietary     |

Notes:
- Kafka-based options provide durable buffering, backpressure handling, consumer scaling, and replays. ClickHouse Kafka engine allows SQL-based transformations and materialized views to land into MergeTree tables.
- HTTP-only ingest is simple but pushes complexity to edge services for retries, idempotency, and replays; riskier at this scale.
- S3 staged ingest is excellent for backfills and cold path, but latency is higher and operational patterns differ from streaming.

## Decision

Use Apache Kafka as the durable ingestion backbone and ingest into ClickHouse via Kafka Engine tables with Materialized Views that transform and load into MergeTree family tables. Events are Avro or Protobuf-encoded with a Schema Registry. Deduplication uses a stable event_id and optional version column with ReplacingMergeTree or AggregatingMergeTree patterns. Partitioning is by tenant and time (e.g., day) to support rollups and merges. Maintain a dead-letter topic for poison messages and validation failures. For large backfills or reprocessing, stage batches to object storage (S3-compatible) and load via S3Queue/s3() into the same tables.

## Consequences

Positive:
- Durable buffer with replay enables recovery, backfills, and smoothing of traffic spikes; consumer scaling matches throughput needs.
- SQL-based transformations in ClickHouse MVs support rollups, sketches (HLL/TDigest), and schema evolution with minimal extra services.
- Clear path for exactly-once at query level via idempotent writes and dedup keys; late data handled via partition merges.
- Portable and cost-efficient; avoids strong vendor lock-in while remaining compatible with managed Kafka/CH offerings if desired.

Negative / risks:
- Operating Kafka and ClickHouse requires tuning (partitions, batch sizes, merges, retention, quotas) and observability.
- Kafka Engine has caveats (consumer offsets per replica, careful deployment/DDL discipline); needs runbooks and guardrails.
- S3 staged backfills are a second pattern to maintain; requires coordination to prevent double ingestion without proper dedup.

