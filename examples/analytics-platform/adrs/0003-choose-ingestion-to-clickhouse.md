# 3. Choose decoupled Kafka ingestion for ClickHouse

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Independent scaling of ingestion and query workloads; predictable performance and cost at ~100B events/day.
- At-least-once delivery with idempotent writes and deduplication; robust replays/backfills and DLQ flows.
- Operational simplicity, observability, and safe deployability (blue/green, canary) for ingestion.
- Portability and low lock-in, keeping ClickHouse self-managed but not overloading it with consumer responsibilities.

Architectural tactics influencing the choice:
- Decouple Kafka consumption from ClickHouse nodes; run stateless consumers that can be autoscaled separately.
- Batch and compress writes over ClickHouse HTTP/native protocol into staging MergeTree tables; transform via MVs.
- Use Schema Registry (Avro/Protobuf), event_id(+version) for idempotency with Replacing/AggregatingMergeTree.
- Maintain DLQs and reprocessing pipelines; use S3-staged batch loads for large backfills.

Comparison of alternatives (higher is better):

| Ingestion / Criteria                                         | Decoupled scaling | Delivery semantics & dedup | Throughput & batching  | Transform flexibility          | Replay/backfill            | Ops complexity            | Cost & lock-in        | Portability/open |
|--------------------------------------------------------------|-------------------|----------------------------|------------------------|-------------------------------|----------------------------|---------------------------|-----------------------|------------------|
| ClickHouse Kafka Engine + Materialized Views (ADR-0003)      | ★                 | ★★★ At-least-once, idemp   | ★★★ High via engine    | ★★★ SQL in MVs                | ★★★ Reconsume via Kafka    | ★★ CH+engine specifics   | ★★ Infra cost          | ★★★ Open         |
| Kafka Connect ClickHouse Sink (direct INSERT)                | ★★                | ★★ At-least-once, idemp    | ★★ Good, task based    | ★★ SMTs limited               | ★★★ Reconsume via Kafka    | ★★ Manage Connect        | ★★ Infra cost          | ★★★ Open         |
| Custom consumer svc (Go/Java, librdkafka) -> CH HTTP/native  | ★★★               | ★★★ At-least-once, idemp   | ★★★ High, tuned batches| ★★★ In-svc + CH MVs           | ★★★ Reconsume + S3 backfill| ★★ Build/operate svc     | ★★★ Low lock-in        | ★★★ Open         |
| Stream proc (Flink/Spark) -> CH                              | ★★                | ★★★ Exactly/at-least-once  | ★★★ High               | ★★★ Rich operators            | ★★★ Strong                 | ★ Higher platform ops     | ★★ Platform cost       | ★★ Portable      |
| Managed ingest (ClickPipes/ETL SaaS)                         | ★★                | ★★ Varies                  | ★★ Good                | ★★ Varies                     | ★★ Varies                  | ★★★ Low (managed)        | ★ Lock-in              | ★ Proprietary    |

Notes:
- A dedicated ingestion service lets us right-size ClickHouse purely for storage/query, while scaling consumers independently and deploying changes safely (canary, blue/green). We retain SQL-based rollups/sketches in MVs on staging→fact tables.
- Kafka Connect is viable but limits transformations and observability; stream processors add platform overhead.

## Decision

Adopt decoupled ingestion services that consume Kafka using librdkafka-based clients (e.g., Go or Java), perform validation/enrichment, and write batched, compressed INSERTs to ClickHouse over HTTP/native protocol into staging MergeTree tables. Materialized Views perform rollups and sketch updates into destination tables. Maintain idempotency via event_id(+version) and Replacing/AggregatingMergeTree patterns. Scale consumers independently of ClickHouse; use DLQs and S3-staged batch loads for large backfills/reprocessing. Continue using Schema Registry for Avro/Protobuf event contracts.


## Consequences

Positive:
- Independent scaling and deployability of ingestion; isolates query workload from consumer throughput and backpressure.
- High throughput via tuned batching and compression; retains SQL transformations in ClickHouse MVs where beneficial.
- Clear, portable architecture without engine coupling; easier blue/green, versioned schemas, and observability.

Negative / risks:
- Additional service to build and operate; requires careful tuning of producer→consumer→ClickHouse batch sizes.
- Exactly-once remains at-least-once with dedup at query-time; must test idempotency rigorously.
- Requires disciplined schema evolution and backfill coordination across consumers and ClickHouse tables.