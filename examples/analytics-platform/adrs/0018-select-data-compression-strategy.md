# 18. Select Data Compression Strategy

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Select data compression strategy to optimize storage costs across the tiered storage architecture established in ADR-017 while maintaining query performance and supporting 24TB/year data growth with zero data loss.

Business drivers: Analytics platform must balance compression ratios with query performance across hot, warm, and cold storage tiers. Compression strategy affects both storage costs and CPU overhead during ingestion and retrieval operations.

Relevant QAs (IDs): S-2 Scalability (Storage capacity accommodates 24TB/year growth), R-1 Reliability (Zero data loss), P-1 Performance (Report response time ≤1.5s), S-1 Scalability (Event volume growth).

## Decision

### Compare **Compression Algorithms**

| Algorithm             | Compression Ratio    | Compression Speed   | Decompression Speed| CPU Overhead       | Query Performance  | Storage Tier Fit   |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **LZ4**               | 🟨 2-3x             | 🌟 very fast       | 🌟 very fast      | 🟩 minimal         | 🌟 excellent      | 🌟 hot storage     |
| **Snappy**            | 🟨 2-3x             | 🌟 fast            | 🌟 fast           | 🟩 low             | 🟩 good           | 🟩 hot/warm       |
| **ZSTD**              | 🟩 3-5x             | 🟩 fast            | 🟩 fast           | 🟨 moderate        | 🟩 good           | 🟩 warm/cold      |
| **Gzip**              | 🟩 4-6x             | 🟨 moderate        | 🟨 moderate       | 🟨 moderate        | 🟨 acceptable     | 🟩 cold storage   |
| **Brotli**            | 🌟 5-8x             | 🟥 slow            | 🟩 fast           | 🟥 high           | 🟨 read-optimized | 🟩 archive        |

### Compare **Columnar Formats**

| Format                | Compression Efficiency| Query Performance  | Schema Evolution   | Ecosystem Support  | Streaming Support  | Multi-Tier Usage   |
|-----------------------|----------------------|--------------------|--------------------|--------------------|--------------------|--------------------| 
| **Parquet + Snappy** | 🟩 good balance     | 🌟 analytical     | 🟩 backward compat | 🌟 universal      | 🟨 batch-oriented  | 🌟 all tiers      |
| **ORC + ZLIB**       | 🟩 efficient        | 🟩 optimized      | 🟩 schema evolution| 🟩 Hive ecosystem | 🟨 batch-oriented  | 🟩 warm/cold      |
| **Avro + Deflate**   | 🟨 moderate         | 🟨 row-oriented    | 🌟 schema registry | 🟩 streaming      | 🌟 real-time      | 🟩 hot/streaming  |
| **Delta Lake**       | 🟩 optimized        | 🟩 ACID support    | 🟩 time travel     | 🟨 Spark-focused  | 🟩 near real-time | 🟩 hot/warm       |
| **Native ClickHouse** | 🌟 best for CH      | 🌟 native engine   | 🟨 limited        | 🟨 ClickHouse only| 🟩 real-time      | 🌟 hot storage    |

**Decision:** Implement **multi-tier compression strategy** optimized for each storage tier:

**Hot Tier (ClickHouse):**
- LZ4 compression for real-time data and hourly aggregates
- Native ClickHouse columnar format with adaptive compression
- Prioritizes query speed over compression ratio

**Warm Tier (S3 Standard):**
- Parquet format with ZSTD compression for historical analytics
- Columnar layout optimized for analytical queries via Athena
- 4-5x compression ratio with good query performance

**Cold Tier (S3 Glacier):**
- Parquet format with Brotli compression for maximum space efficiency
- 6-8x compression ratio for long-term cost optimization
- Acceptable decompression performance for infrequent access

Supersedes: none.

## Consequences

- ✅ 70-80% storage reduction across all tiers maintains cost efficiency with 24TB/year growth (S-2).
- ✅ Compression algorithms preserve data integrity with error detection (R-1).
- ✅ Hot tier compression maintains sub-1.5s query performance through fast algorithms (P-1).
- ✅ Columnar formats support analytical query patterns across all storage tiers.
- ✅ Graduated compression ratios optimize cost vs performance trade-offs per tier.
- ⚠️ Multi-format strategy increases operational complexity for data pipeline management.
- ⚠️ CPU overhead for compression/decompression requires capacity planning during peak loads.
- Follow-ups: ADR-019 (lifecycle transition policies), ADR-020 (cost monitoring), compression performance tuning.
