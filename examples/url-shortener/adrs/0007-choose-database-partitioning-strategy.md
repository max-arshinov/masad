# 7. Choose Database Partitioning Strategy

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 2 goal: Database Architecture and Data Management. System must handle 100M links/year growth with 3-year retention, requiring efficient storage and query performance for both operational and analytical workloads.

Business drivers: 3-year retention, analytics tracking, cost-effective storage scaling, maintaining query performance at scale.

Relevant QAs (IDs): R-1 (3-year data retention), M-1 (100% click tracking), S-2 (100M links/year).

## Decision

### Table 1 — Compare Partitioning Approaches

| Partitioning Strategy | Query Performance | Write Performance | Storage Efficiency | Maintenance Complexity | Analytics Support | Cross-Partition Queries |
|----------------------|-------------------|-------------------|-------------------|----------------------|------------------|------------------------|
| **Horizontal (Time-based)** | 🟩 time-range queries | 🟩 append-only pattern | 🟩 old data compression | 🟩 automated retention | 🌟 time-series analytics | 🟨 time-span queries |
| **Horizontal (Hash-based)** | 🟨 point lookups only | 🌟 distributed writes | 🟨 uniform distribution | 🟨 rebalancing needed | 🟥 poor aggregations | 🟥 expensive joins |
| **Vertical (by Entity)** | 🟩 entity-specific | 🟩 isolated writes | 🟨 schema duplication | 🟥 complex relationships | 🟨 entity-based only | 🟥 cross-entity joins |
| **Hybrid (Time + Hash)** | 🟩 time + distribution | 🟩 balanced load | 🟩 flexible policies | 🟥 complex management | 🟩 time-based + distributed | 🟨 complex routing |
| **Functional (Read/Write)** | 🟩 optimized per use | 🟩 write-optimized | 🟨 data duplication | 🟨 sync complexity | 🌟 read-optimized | 🟩 dedicated analytics |

**Shortlist:** Horizontal (Time-based) and Functional (Read/Write) approaches best address R-1 retention and M-1 analytics requirements.

### Table 2 — Compare Database Technologies for Partitioning

| Database | Time Partitioning | Automated Retention | Cross-Partition Performance | Operational Complexity | Analytics Integration | Cost Efficiency |
|----------|-------------------|-------------------|----------------------------|----------------------|---------------------|----------------|
| **PostgreSQL** | 🟩 native partitioning | 🟩 partition pruning | 🟩 partition-wise joins | 🟩 familiar tooling | 🟨 OLAP extensions | 🟩 cost-effective |
| **MySQL** | 🟨 manual partitioning | 🟨 limited automation | 🟨 basic support | 🟩 widespread adoption | 🟥 limited OLAP | 🟩 cost-effective |
| **Amazon RDS/Aurora** | 🟩 managed partitioning | 🟩 automated policies | 🟩 read replicas | 🌟 fully managed | 🟩 Aurora Analytics | 🟨 managed premium |
| **Snowflake** | 🌟 auto-clustering | 🌟 time travel | 🌟 columnar performance | 🌟 serverless | 🌟 native analytics | 🟨 usage-based |
| **ClickHouse** | 🌟 MergeTree partitions | 🟩 TTL policies | 🌟 columnar queries | 🟨 specialized ops | 🌟 OLAP optimized | 🟩 efficient storage |

**Decision:** Implement hybrid time-based partitioning using PostgreSQL with monthly partitions for URL mappings and click events:

Primary strategy:
- Monthly partitions for urls table (partition key: created_at)
- Daily partitions for clicks table (partition key: clicked_at)
- Automated partition creation and pruning after 36 months
- Read replicas for analytics workloads

Secondary strategy:
- Functional separation: PostgreSQL for operational data, ClickHouse for analytics aggregations
- ETL pipeline for daily analytics data sync
- Hot/warm/cold storage tiers based on data age

Supersedes: none.

## Consequences

- ✅ Addresses R-1 with automated 3-year retention via partition pruning
- ✅ Supports S-2 scale with monthly partitions handling 8.3M links/month
- ✅ Enables M-1 analytics with dedicated read replicas and optional ClickHouse
- ✅ Provides cost efficiency through partition-level compression and archival
- ⚠️ Requires careful partition key selection to avoid cross-partition queries
- ⚠️ ETL complexity for dual-database analytics approach
- Follow-ups: ADR on partition management automation, storage tiering policies, analytics data pipeline design
