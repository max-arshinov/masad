# 9. Define Analytics and Click Tracking Architecture

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 2 goal: Database Architecture and Data Management. System must achieve 100% click tracking with real-time analytics capabilities while handling 100M links/year generating ~1B click events annually. Analytics must support both real-time dashboards and historical reporting across 3-year retention period.

Business drivers: Complete click tracking for business intelligence, real-time monitoring, user analytics, performance optimization insights.

Relevant QAs (IDs): M-1 (100% click tracking), S-2 (100M links/year), R-1 (3-year data retention).

## Decision

### Table 1 — Compare Analytics Architectures

| Architecture Pattern | Real-time Capability | Scalability | Data Consistency | Query Flexibility | Operational Complexity | Cost Efficiency |
|---------------------|-------------------|-------------|------------------|------------------|----------------------|----------------|
| **Synchronous (Direct DB)** | 🟩 immediate | 🟨 limited by DB | 🌟 strong consistency | 🟩 full SQL | 🟩 simple | 🟨 expensive scaling |
| **Asynchronous (Message Queue)** | 🟨 near real-time | 🟩 horizontal scaling | 🟨 eventual consistency | 🟩 flexible processing | 🟨 queue management | 🟩 cost-effective |
| **Event Streaming (Kafka)** | 🌟 real-time streams | 🌟 massive scale | 🟨 eventual consistency | 🌟 stream processing | 🟥 complex operations | 🟨 infrastructure cost |
| **Hybrid (Sync + Async)** | 🟩 immediate + batch | 🟩 scalable analytics | 🟩 configurable | 🌟 multi-pattern | 🟥 dual complexity | 🟨 balanced cost |
| **CQRS (Command/Query Split)** | 🟩 optimized reads | 🟩 independent scaling | 🟨 eventual consistency | 🌟 specialized stores | 🟥 complex sync | 🟨 dual storage |

**Shortlist:** Asynchronous (Message Queue) and Event Streaming (Kafka) best address M-1 reliability and S-2 scale requirements.

### Table 2 — Compare Analytics Storage Solutions

| Storage Solution | Write Throughput | Query Performance | Real-time Analytics | Historical Analysis | Operational Overhead | Integration |
|------------------|------------------|-------------------|-------------------|-------------------|---------------------|-------------|
| **PostgreSQL (OLTP)** | 🟨 10K writes/sec | 🟨 row-based queries | 🟨 basic aggregation | 🟨 limited OLAP | 🟩 familiar | 🌟 native |
| **ClickHouse** | 🌟 1M+ writes/sec | 🌟 columnar OLAP | 🟩 materialized views | 🌟 time-series analysis | 🟨 specialized ops | 🟨 external |
| **Amazon Redshift** | 🟩 100K writes/sec | 🟩 columnar warehouse | 🟨 batch updates | 🌟 historical OLAP | 🟩 managed | 🟨 ETL required |
| **Elasticsearch** | 🟩 high ingestion | 🟩 search + aggregation | 🟩 near real-time | 🟨 time-based retention | 🟨 cluster management | 🟨 external |
| **Amazon Timestream** | 🟩 time-series optimized | 🟩 time-based queries | 🟩 real-time ingestion | 🟩 automatic retention | 🌟 serverless | 🟨 AWS native |

**Decision:** Implement event-driven analytics using Amazon Kinesis + ClickHouse architecture:

**Click Tracking Pipeline:**
- Synchronous click recording to PostgreSQL for immediate redirect tracking
- Asynchronous event streaming via Amazon Kinesis Data Streams
- Real-time analytics ingestion to ClickHouse for OLAP workloads
- Kinesis Data Firehose for S3 archival (compliance with retention policy)

**Analytics Architecture:**
- ClickHouse cluster for real-time dashboards and time-series analytics
- Materialized views for pre-computed metrics (daily/hourly aggregations)
- PostgreSQL read replicas for operational analytics and ad-hoc queries
- S3 + Amazon Athena for historical analysis (24+ months old data)

**Event Schema:**
```json
{
  "click_id": "uuid",
  "short_url": "string",
  "original_url": "string", 
  "timestamp": "iso8601",
  "user_agent": "string",
  "ip_address": "string",
  "referer": "string",
  "geo_location": "object"
}
```

**Processing Guarantees:**
- At-least-once delivery via Kinesis with deduplication in ClickHouse
- Dead letter queues for failed events
- Circuit breaker pattern for analytics pipeline failures

Supersedes: none.

## Consequences

- ✅ Achieves M-1 with dual-write pattern ensuring 100% click tracking
- ✅ Supports S-2 scale with Kinesis handling 1M+ events/second throughput
- ✅ Enables real-time analytics for business intelligence and monitoring
- ✅ Complies with R-1 through S3 archival integration
- ⚠️ Eventual consistency between operational and analytical stores
- ⚠️ Increased operational complexity with multiple data systems
- Follow-ups: ADR on event schema evolution, ClickHouse cluster sizing, monitoring and alerting for analytics pipeline
