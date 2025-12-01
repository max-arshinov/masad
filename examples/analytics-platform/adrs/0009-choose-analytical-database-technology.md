# 9. Choose Analytical Database Technology

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Select analytical database technology to deliver sub-1.5s query response times for 3-month data periods while supporting 100K concurrent analysts and accommodating 24TB/year data growth with "forever" retention.

Business drivers: Analytics platform must serve complex aggregation queries over massive datasets (100B+ events/day) with strict response time SLAs. System requires horizontal read scaling and query consistency across replicas.

Relevant QAs (IDs): P-1 Performance (Report response time ≤1.5s), P-3 Performance (100K concurrent users), R-2 Reliability (Query consistency), S-2 Scalability (Storage capacity).

## Decision

### Compare **Database Categories**

| Category              | Query Performance    | Concurrency Scaling | Storage Capacity   | Operational Model  | Analytics Features | Consistency Model  |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **OLTP (PostgreSQL)** | 🟨 row-based reads  | 🟨 connection limits| 🟩 vertical scale  | 🟩 mature tooling | 🟨 basic aggregates| 🌟 ACID strong    |
| **OLAP (ClickHouse)** | 🌟 columnar scans   | 🟩 parallel queries | 🌟 petabyte scale  | 🟨 specialized ops | 🌟 analytics-first| 🟨 eventual       |
| **Data Warehouse**    | 🟩 optimized queries| 🟩 concurrent users | 🌟 unlimited scale | 🟩 managed service | 🟩 SQL + BI tools | 🟩 configurable   |
| **Time Series DB**    | 🟩 time-based       | 🟨 limited patterns | 🟩 efficient       | 🟨 specialized     | 🟨 time-focused    | 🟨 eventual       |

### Compare **Analytical Database Technologies**

| Technology            | Query Latency        | Concurrent Users    | Storage Scaling    | Cost Efficiency    | SQL Compatibility  | Ecosystem Support  |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **ClickHouse**        | 🌟 <100ms typical   | 🟩 thousands       | 🌟 horizontal      | 🟩 cost-effective | 🟩 SQL standard    | 🟩 rich connectors|
| **Amazon Redshift**   | 🟩 sub-second       | 🟩 concurrent WLM   | 🌟 elastic resize  | 🟨 node-based      | 🌟 PostgreSQL compat| 🌟 AWS ecosystem  |
| **Google BigQuery**   | 🟩 serverless speed | 🌟 unlimited        | 🌟 serverless      | 🟨 query-based     | 🟩 Standard SQL    | 🟩 GCP integration|
| **Snowflake**         | 🟩 optimized        | 🟩 multi-cluster   | 🌟 elastic         | 🟨 credit-based    | 🟩 ANSI SQL       | 🟩 multi-cloud    |
| **Apache Druid**      | 🟩 real-time        | 🟩 high concurrency| 🟩 segment-based   | 🟩 open source     | 🟨 limited SQL     | 🟨 specialized     |
| **TimescaleDB**       | 🟨 time-optimized   | 🟨 PostgreSQL limits| 🟩 time partitions | 🟩 PostgreSQL costs| 🌟 full PostgreSQL| 🟩 familiar ops   |

**Decision:** Select **ClickHouse** as the primary analytical database technology. ClickHouse's columnar storage and vectorized query execution provide sub-100ms response times for aggregation queries over billions of rows. The distributed architecture supports horizontal scaling for both storage and query processing, meeting the 100K concurrent user requirement through connection pooling and query parallelization.

Supersedes: none.

## Consequences

- ✅ Sub-1.5s query response times achieved through columnar scans and parallel processing (P-1).
- ✅ Horizontal scaling supports 100K+ concurrent analysts via distributed query execution (P-3).
- ✅ Petabyte-scale storage capacity accommodates "forever" retention and 24TB/year growth (S-2).
- ✅ Cost-effective scaling with open-source core and efficient compression.
- ✅ SQL compatibility enables existing analytics tools and BI integrations.
- ⚠️ Eventual consistency model requires careful design for query consistency (R-2).
- ⚠️ Specialized operational expertise needed for cluster management and optimization.
- Follow-ups: ADR-010 (pre-aggregation strategy), ADR-011 (caching for consistency), ADR-012 (read replica topology for load distribution).
