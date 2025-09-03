# 14. Design Batch Processing Strategy

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design batch processing strategy to complement Kafka Streams for complex aggregations and historical data processing while maintaining 50-100min processing latency SLA and zero data loss guarantees.

Business drivers: Analytics platform requires both real-time stream processing for immediate aggregations and batch processing for complex multi-dimensional aggregations, historical reprocessing, and data quality validation across large time windows.

Relevant QAs (IDs): A-1 Availability (Data processing latency within 50-100min), R-1 Reliability (Zero data loss), S-1 Scalability (Event volume growth), P-2 Performance (High event ingestion throughput).

## Decision

### Compare **Batch Processing Patterns**

| Pattern               | Processing Latency   | Resource Efficiency | Fault Recovery     | Data Consistency   | Operational Model  | Cost Structure     |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Scheduled ETL**     | 🟨 fixed intervals  | 🟩 predictable     | 🟨 job-level retry | 🟩 batch boundaries| 🟩 mature tooling | 🟩 scheduled resources|
| **Event-Driven**      | 🟩 triggered processing| 🟨 variable load  | 🟩 granular retry  | 🟨 eventual       | 🟨 complex orchestration| 🟨 elastic costs  |
| **Lambda Architecture**| 🟨 dual processing  | 🟥 resource duplication| 🟩 path redundancy| 🟨 merge complexity| 🟥 dual maintenance| 🟥 high overhead   |
| **Hybrid Stream-Batch**| 🟩 adaptive        | 🟩 workload optimization| 🟩 multi-level   | 🟩 configurable   | 🟨 coordination   | 🟩 optimized      |

### Compare **Batch Processing Technologies**

| Technology            | Data Volume Capacity | Processing Speed    | Resource Management| Integration        | Monitoring         | Cost Efficiency    |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Apache Spark**      | 🌟 petabyte scale   | 🟩 in-memory       | 🟩 dynamic allocation| 🟩 broad ecosystem| 🟩 comprehensive   | 🟩 cluster sharing |
| **AWS EMR**           | 🌟 elastic capacity | 🟩 managed Spark   | 🌟 auto-scaling   | 🌟 AWS native     | 🟩 CloudWatch      | 🟩 pay-per-use    |
| **AWS Glue**          | 🟩 serverless scale | 🟨 Python/Scala    | 🌟 serverless     | 🌟 data catalog   | 🟩 built-in       | 🌟 serverless      |
| **Airflow + Workers** | 🟨 depends on workers| 🟨 task-based      | 🟨 manual scaling  | 🟩 flexible       | 🟩 rich UI        | 🟨 infrastructure mgmt|
| **ClickHouse MaterializedViews**| 🟩 columnar efficiency| 🌟 real-time    | 🟩 automatic      | 🌟 native DB      | 🟨 basic          | 🌟 included       |

**Decision:** Implement **hybrid stream-batch architecture** using:

**Real-time Layer (Kafka Streams):**
- Simple aggregations (counts, sums) with 1-minute windows
- Direct writes to ClickHouse for immediate dashboard updates
- Covers 80% of analytics queries requiring <5min latency

**Batch Layer (AWS EMR with Spark):**
- Complex multi-dimensional aggregations every 15 minutes
- Historical reprocessing and data quality validation
- Covers remaining 20% of queries requiring complex analytics

**Coordination:**
- EMR jobs triggered by Kafka lag monitoring
- Incremental processing based on event timestamps
- Idempotent operations for safe reprocessing

Supersedes: none.

## Consequences

- ✅ 15-minute batch cycles ensure 50-100min processing SLA with multiple retry attempts (A-1).
- ✅ Dual processing paths provide fault tolerance and zero data loss guarantees (R-1).
- ✅ EMR auto-scaling handles event volume growth from 1.16M to 1.7M events/sec (S-1, P-2).
- ✅ Cost optimization through serverless batch processing and cluster auto-termination.
- ✅ Separation of concerns: stream for latency, batch for complexity.
- ⚠️ Coordination complexity between stream and batch processing requires monitoring.
- ⚠️ Data consistency windows during batch processing transitions.
- Follow-ups: ADR-015 (validation across both layers), ADR-016 (backup for both processing paths).
