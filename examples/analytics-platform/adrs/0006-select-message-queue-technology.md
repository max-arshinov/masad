# 6. Select Message Queue Technology

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Select specific message queue technology to implement the event streaming pattern established in ADR-005. Must handle 1.16M events/sec sustained throughput, 3.47M events/sec peak loads, with horizontal scaling to 146B events/day by year 5.

Business drivers: Cost-effective operation while maintaining zero data loss and sub-100 minute processing latency. Platform requires multi-region deployment for global website tracking.

Relevant QAs (IDs): P-2 Performance (High event ingestion throughput), S-1 Scalability (Event volume growth), R-1 Reliability (Data durability), A-2 Availability (System uptime).

## Decision

### Compare **Kafka Deployment Models**

| Deployment Model     | Operational Overhead | Throughput Limits  | Cost Structure      | Scaling Control    | Multi-Region       | Monitoring         |
|----------------------|----------------------|--------------------|---------------------|--------------------|--------------------|--------------------|
| **Self-Managed**     | 🟥 high ops burden   | 🌟 unlimited       | 🟩 compute only     | 🌟 full control    | 🟨 manual setup    | 🟨 custom tooling  |
| **Amazon MSK**       | 🟩 managed service   | 🟩 high throughput | 🟨 instance-based   | 🟩 auto-scaling    | 🟩 cross-AZ/region | 🟩 CloudWatch      |
| **Confluent Cloud**  | 🟩 fully managed     | 🟩 elastic scaling | 🟨 usage-based      | 🟩 serverless      | 🟩 global clusters | 🌟 rich dashboards |
| **Azure Event Hubs** | 🟩 managed service   | 🟩 auto-scaling    | 🟨 throughput units | 🟨 limited control | 🟩 global          | 🟩 Azure Monitor   |

### Compare **Kafka vs Alternatives**

| Technology            | Peak Throughput    | Latency      | Operational Model | Cost at Scale    | Event Ordering   | Consumer Patterns |
|-----------------------|--------------------|--------------|-------------------|------------------|------------------|-------------------|
| **Apache Kafka**      | 🌟 millions/sec    | 🟩 <10ms     | 🟨 cluster mgmt   | 🟩 efficient     | 🟩 per-partition | 🟩 flexible       |
| **AWS Kinesis**       | 🟨 1M records/sec  | 🟩 <100ms    | 🟩 serverless     | 🟨 shard-based   | 🟩 per-shard     | 🟨 limited        |
| **Google Pub/Sub**    | 🟩 high throughput | 🟨 100-200ms | 🟩 serverless     | 🟨 message-based | 🟥 no guarantees | 🟩 flexible       |
| **Azure Service Bus** | 🟨 moderate        | 🟨 variable  | 🟩 managed        | 🟨 message-based | 🟩 FIFO queues   | 🟨 traditional    |

**Decision:** Select **Amazon MSK (Managed Streaming for Apache Kafka)** as the message queue technology. MSK provides the throughput capacity for 1.16M+ events/sec while reducing operational overhead compared to self-managed Kafka. The managed service includes automated patching, monitoring, and cross-AZ replication, supporting the reliability and availability requirements.

Supersedes: none.

## Consequences

- ✅ Achieves required throughput with auto-scaling broker capacity (P-2, S-1).
- ✅ Built-in cross-AZ replication ensures data durability (R-1).
- ✅ Reduced operational complexity while maintaining Kafka ecosystem benefits (A-2).
- ✅ Cost-effective scaling with instance-based pricing model.
- ✅ Native AWS integration for monitoring, security, and multi-region setup.
- ⚠️ Vendor lock-in to AWS ecosystem for core streaming infrastructure.
- ⚠️ Instance-based pricing requires capacity planning vs pure usage-based models.
- Follow-ups: ADR-007 (MSK cluster sizing and partitioning), ADR-008 (auto-scaling policies for brokers and consumers).
