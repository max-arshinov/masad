# 2. Choose primary analytics database

Date: 2025-08-21

## Status

Accepted

## Context

Business drivers and quality attributes:
- Scale to ~100B events/day (multi-tenant) with 50–100 min ingest-to-availability.
- Ad-hoc segmentation over up to 3 months of data with <= 1.5s latency.
- Per-website retention "forever" with cost control; avoid strong vendor lock-in.
- High-cardinality filtering, uniques, percentiles; evolving schemas; at-least-once ingestion with dedup.

Architectural tactics influencing the choice:
- Partitioning and rollups via materialized views; approximate algorithms (HLL, TDigest) for uniques and percentiles.
- Columnar storage, compression, late compaction; hot/cold tiering to object storage.
- Workload isolation via quotas, separate consumer groups/warehouses, and guardrails.

Comparison of alternatives (higher is better):

| Platform / Criteria            | Fit: time-series OLAP | Ingest throughput/latency | Query latency & aggregations | Approx (HLL/TDigest) | Storage, tiering & retention | Multi-tenancy & isolation | Operability/managed       | Ecosystem & tooling | Cost & lock-in | Portability/open |
|--------------------------------|-----------------------|----------------------------|------------------------------|----------------------|------------------------------|---------------------------|---------------------------|---------------------|---------------|------------------|
| ClickHouse                     | ★★★                   | ★★★                        | ★★★                          | ★★★                  | ★★★                          | ★★                        | ★★ (CH Cloud exists)     | ★★★                | ★★            | ★★★             |
| Apache Druid                   | ★★★                   | ★★★                        | ★★★                          | ★★★                  | ★★★                          | ★★                        | ★★ (Imply managed)       | ★★                 | ★★            | ★★★             |
| Apache Pinot                   | ★★★                   | ★★★                        | ★★★                          | ★★                   | ★★                           | ★★                        | ★★ (StarTree managed)    | ★★                 | ★★            | ★★★             |
| BigQuery (managed warehouse)   | ★★                    | ★★                         | ★★                           | ★★                   | ★★                           | ★★                        | ★★★                      | ★★                 | ★            | ★               |
| Snowflake (managed warehouse)  | ★★                    | ★★                         | ★★                           | ★★                   | ★★                           | ★★                        | ★★★                      | ★★                 | ★            | ★               |
| TimescaleDB (Postgres ext.)    | ★★                    | ★★                         | ★★                           | ★                    | ★★                           | ★★                        | ★★★                      | ★★★                | ★★★          | ★★★             |
| InfluxDB                       | ★★                    | ★★★                        | ★★                           | ★                    | ★★                           | ★                        | ★★ (Cloud available)     | ★★                 | ★★           | ★★              |
| VictoriaMetrics                | ★★                    | ★★★                        | ★★                           | ★                    | ★★                           | ★★                        | ★★★                      | ★★                 | ★★★          | ★★★             |

Notes:
- ArchitectAdvisor classifies the problem as TimeSeries with examples like InfluxDB/TimescaleDB/VictoriaMetrics, which are strong for metrics. Our workload is analytics-at-scale with ad-hoc segmentation and high-cardinality dimensions; OLAP time-series column stores (ClickHouse/Druid/Pinot) are a better fit.
- Managed warehouses are excellent for low-ops but introduce lock-in and variable per-query cost at our scale and SLOs.

## Decision

Adopt ClickHouse as the primary analytics database for hot and warm data. Use MergeTree family engines with partitioning by time (e.g., day) and tenant, Kafka ingestion with materialized views for rollups, and approximate algorithms (HLL/TDigest) for uniques and percentiles. Use object-storage-backed disks/tiering for cost-efficient long retention; keep cold archives in open formats (e.g., Parquet) as needed.

## Consequences

Positive:
- Meets sub-1.5s query latency for ad-hoc segmentations via columnar scans, indexes, pre-aggregations, and sketches.
- Horizontally scalable with distributed tables; cost-effective and portable (open source, S3-compatible tiering).
- Supports late-arriving events, schema evolution, and dedup patterns; rich ecosystem and connectors.

Negative / risks:
- Requires operational expertise (merge tuning, partitioning, backfills, resource isolation) and careful capacity planning.
- Per-tenant isolation is limited in a shared cluster; needs quotas, workload mgmt, and potentially separate pools for noisy tenants.
- Compaction/merges and retention policies must be tuned to control storage growth and background load.

