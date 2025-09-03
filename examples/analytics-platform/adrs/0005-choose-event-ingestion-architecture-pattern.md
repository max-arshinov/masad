# 5. Choose Event Ingestion Architecture Pattern

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design high-volume data ingestion architecture to handle 100B events/day capacity requirement with sustained 1.16M events/sec and peak loads up to 3.47M events/sec by year 1, scaling to 146B events/day by year 5.

Business drivers: Analytics platform must ingest massive event volumes from websites (page views, clicks) while ensuring zero data loss and maintaining system availability during traffic spikes up to 3x daily average.

Relevant QAs (IDs): P-2 Performance (High event ingestion throughput), S-1 Scalability (Event volume growth), R-1 Reliability (Data durability), A-2 Availability (System uptime).

## Decision

### Compare **Ingestion Patterns**

| Pattern                | Throughput           | Fault Tolerance     | Scalability         | Complexity         | Data Durability     | Backpressure Handling |
|------------------------|----------------------|---------------------|---------------------|--------------------|--------------------|----------------------|
| **Direct Write**       | 🟨 limited by DB    | 🟥 single point    | 🟥 vertical only   | 🟩 simple         | 🟨 depends on DB   | 🟥 poor             |
| **Message Queue**      | 🟩 high via buffering| 🟩 queue durability| 🟩 horizontal      | 🟨 moderate        | 🟩 persistent queue| 🟩 excellent        |
| **Event Streaming**    | 🌟 very high        | 🟩 partitioned     | 🌟 elastic         | 🟨 moderate        | 🟩 replicated logs | 🟩 excellent        |
| **Batch Collection**   | 🟩 high throughput  | 🟨 batch loss risk | 🟨 scale with delay| 🟩 simple         | 🟨 batch boundaries| 🟨 delayed          |

### Compare **Technologies**

| Technology         | Peak Throughput    | Durability         | Operational Complexity | Cost Efficiency | Ecosystem         | Multi-Region      |
|--------------------|--------------------|--------------------|------------------------|-----------------|-------------------|-------------------|
| **Apache Kafka**   | 🌟 millions/sec    | 🟩 replicated logs | 🟨 cluster mgmt        | 🟩 open source  | 🌟 rich ecosystem | 🟩 native support |
| **AWS Kinesis**    | 🟩 1M records/sec  | 🟩 managed         | 🟩 serverless          | 🟨 usage-based  | 🟩 AWS integrated | 🟩 managed        |
| **Google Pub/Sub** | 🟩 high throughput | 🟩 managed         | 🟩 serverless          | 🟨 usage-based  | 🟩 GCP integrated | 🟩 global         |
| **RabbitMQ**       | 🟨 moderate        | 🟩 durable queues  | 🟨 cluster setup       | 🟩 open source  | 🟨 traditional    | 🟨 manual setup   |
| **Amazon SQS**     | 🟨 300K msgs/sec   | 🟩 managed         | 🟩 serverless          | 🟩 pay per use  | 🟩 AWS ecosystem  | 🟩 global         |

**Decision:** Adopt **Event Streaming with Apache Kafka** as the primary ingestion pattern. Kafka's partitioned, replicated log architecture provides the throughput (millions of events/sec), horizontal scalability, and fault tolerance required for 1.16M+ sustained writes and 3.47M peak loads. The streaming model enables real-time processing while maintaining durability through configurable replication.

Supersedes: none.

## Consequences

- ✅ Handles peak ingestion loads (P-2) with horizontal partitioning and producer scaling (S-1).
- ✅ Zero data loss through configurable replication and acknowledgment policies (R-1).
- ✅ High availability during traffic spikes via partition redundancy (A-2).
- ✅ Decouples ingestion from processing, enabling independent scaling of consumers.
- ⚠️ Requires Kafka cluster operational expertise and monitoring.
- ⚠️ Additional complexity for schema evolution and message ordering guarantees.
- Follow-ups: ADR-006 (Kafka deployment strategy), ADR-007 (partitioning strategy), ADR-008 (auto-scaling policies).
