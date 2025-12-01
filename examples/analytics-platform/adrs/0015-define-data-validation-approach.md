# 15. Define Data Validation Approach

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Define comprehensive data validation approach across stream and batch processing layers to ensure zero data loss and maintain data quality while processing 1.16M events/sec with 50-100min processing latency SLA.

Business drivers: Analytics platform must detect and handle data corruption, schema violations, and processing errors without impacting downstream analytics. Validation must scale with event volume growth while providing audit trails for compliance.

Relevant QAs (IDs): R-1 Reliability (Zero data loss), A-1 Availability (Data processing latency within 50-100min), SE-1 Security (Data privacy compliance), R-2 Reliability (Query consistency).

## Decision

### Compare **Validation Strategies**

| Strategy              | Error Detection      | Performance Impact  | Recovery Capability| Audit Trail        | Operational Overhead| Data Quality Assurance|
|-----------------------|----------------------|---------------------|--------------------|--------------------|---------------------|----------------------|
| **Schema Validation** | 🟩 structure errors | 🟩 minimal overhead| 🟨 reject/retry    | 🟩 logged events   | 🟩 automated       | 🟩 prevents corruption|
| **Business Rules**    | 🟩 logic violations | 🟨 rule complexity  | 🟩 configurable   | 🟩 detailed logs   | 🟨 rule maintenance | 🌟 domain accuracy   |
| **Statistical Anomaly**| 🟩 pattern deviations| 🟨 computation cost| 🟨 manual review   | 🟩 trend analysis  | 🟨 model tuning     | 🟩 detects drift     |
| **End-to-End Checksums**| 🌟 data integrity | 🟨 hash computation | 🟩 replay capability| 🌟 complete audit | 🟨 infrastructure   | 🌟 guarantees accuracy|

### Compare **Validation Technologies**

| Technology            | Real-time Validation | Batch Validation    | Schema Evolution   | Error Handling     | Monitoring         | Integration Effort |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Apache Avro + Registry**| 🟩 schema checks | 🟩 backward compat | 🌟 evolution support| 🟨 fail-fast      | 🟨 basic metrics   | 🟩 Kafka native    |
| **Great Expectations** | 🟨 lightweight     | 🌟 comprehensive   | 🟨 manual updates  | 🟩 flexible actions| 🟩 rich reporting  | 🟨 Python ecosystem|
| **AWS Glue Data Quality**| 🟩 real-time      | 🟩 scheduled       | 🟩 managed         | 🟩 configurable   | 🟩 CloudWatch      | 🟩 AWS native      |
| **Custom Kafka Streams**| 🌟 inline validation| 🟨 limited scope  | 🟨 manual coding   | 🟩 custom logic    | 🟨 custom metrics  | 🟩 existing framework|
| **ClickHouse Constraints**| 🟨 insert-time   | 🟩 query-time      | 🟩 SQL-based      | 🟨 reject records  | 🟨 basic logs      | 🟩 database native |

**Decision:** Implement **multi-layer validation architecture**:

**Layer 1 - Stream Validation (Kafka Streams + Avro):**
- Schema validation using Confluent Schema Registry
- Basic business rules (required fields, value ranges)
- Dead letter queue for invalid events
- <1ms validation latency per event

**Layer 2 - Batch Validation (Great Expectations):**
- Statistical anomaly detection every 15 minutes
- Complex business rule validation
- Data quality metrics and alerting
- Historical trend analysis

**Layer 3 - Storage Validation (ClickHouse):**
- Database constraints for final data integrity
- Duplicate detection and deduplication
- Cross-table consistency checks
- Query-time validation alerts

Supersedes: none.

## Consequences

- ✅ Zero data loss through comprehensive validation at ingestion, processing, and storage (R-1).
- ✅ Sub-minute validation in stream layer maintains 50-100min processing SLA (A-1).
- ✅ Schema evolution support enables backward compatibility and smooth deployments.
- ✅ Audit trail creation supports GDPR/CCPA compliance requirements (SE-1).
- ✅ Statistical monitoring detects data quality issues before they impact analytics (R-2).
- ⚠️ Multi-layer validation adds operational complexity and monitoring overhead.
- ⚠️ Performance impact from validation may require optimization under peak loads.
- Follow-ups: ADR-016 (backup procedures), implement validation rule configuration, set up alerting thresholds.
