# 13. Choose Stream Processing Framework

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Select stream processing framework to ensure events appear in analytics reports within 50-100 minutes while handling 1.16M events/sec sustained throughput and maintaining zero data loss during processing.

Business drivers: Analytics platform requires real-time data pipeline to transform raw events into aggregated data for ClickHouse storage. Processing must scale with event volume growth to 146B events/day by year 5 while maintaining data consistency.

Relevant QAs (IDs): A-1 Availability (Data processing latency within 50-100min), R-1 Reliability (Zero data loss), S-1 Scalability (Event volume growth), P-2 Performance (High event ingestion throughput).

## Decision

### Compare **Stream Processing Paradigms**

| Paradigm              | Processing Latency   | Fault Tolerance     | Scalability         | Operational Model  | State Management   | Exactly-Once Delivery|
|-----------------------|----------------------|---------------------|---------------------|--------------------|--------------------|----------------------|
| **Micro-batch**       | 🟨 seconds to minutes| 🟩 checkpoint recovery| 🟩 horizontal     | 🟩 mature tooling  | 🟩 distributed    | 🟩 built-in         |
| **True Streaming**    | 🌟 milliseconds     | 🟩 message replay  | 🟩 elastic         | 🟨 complex setup   | 🟨 in-memory      | 🟨 complex config   |
| **Lambda Architecture**| 🟨 dual path       | 🟩 redundant paths  | 🟩 independent     | 🟥 operational overhead| 🟨 dual state   | 🟨 eventual consistency|
| **Serverless**        | 🟩 auto-scaling    | 🟩 managed         | 🌟 infinite        | 🌟 no ops         | 🟨 limited        | 🟩 managed          |

### Compare **Stream Processing Technologies**

| Technology            | Throughput           | Latency             | Fault Tolerance    | Operational Complexity| Ecosystem         | AWS Integration    |
|-----------------------|----------------------|---------------------|--------------------|-----------------------|-------------------|--------------------|
| **Apache Kafka Streams**| 🟩 millions/sec   | 🟩 low latency     | 🟩 exactly-once    | 🟨 library-based     | 🟩 Kafka native   | 🟨 self-managed    |
| **Apache Flink**      | 🌟 very high        | 🌟 true streaming   | 🌟 advanced checkpointing| 🟥 complex ops    | 🟩 rich features  | 🟨 deployment overhead|
| **Apache Spark Streaming**| 🟩 high throughput| 🟨 micro-batch     | 🟩 RDD lineage     | 🟩 mature ecosystem  | 🌟 extensive      | 🟩 EMR integration |
| **Amazon Kinesis Analytics**| 🟨 moderate     | 🟩 real-time       | 🟩 managed         | 🌟 serverless        | 🟨 SQL-based      | 🌟 native AWS      |
| **AWS Lambda + Kinesis**| 🟨 event-driven   | 🟩 near real-time  | 🟩 auto-retry      | 🟩 minimal ops       | 🟩 serverless     | 🌟 native AWS      |

**Decision:** Select **Apache Kafka Streams** as the primary stream processing framework. Kafka Streams provides native integration with the MSK infrastructure established in ADR-006, enabling exactly-once processing semantics for zero data loss while maintaining sub-minute processing latency. The library-based approach reduces operational overhead compared to cluster-based solutions while providing sufficient throughput for 1.16M+ events/sec.

Supersedes: none.

## Consequences

- ✅ Sub-minute processing latency enables 50-100min analytics SLA with buffer for aggregation (A-1).
- ✅ Exactly-once semantics prevents data loss during stream processing transformations (R-1).
- ✅ Horizontal scaling through Kafka partitions supports event volume growth (S-1, P-2).
- ✅ Native MSK integration reduces operational complexity and network overhead.
- ✅ Stateful processing capabilities enable complex aggregations and windowing operations.
- ⚠️ Library-based deployment requires application lifecycle management vs managed services.
- ⚠️ Java/Scala expertise needed for stream topology development and optimization.
- Follow-ups: ADR-014 (batch processing for complex aggregations), ADR-015 (data validation), ADR-016 (backup procedures).
