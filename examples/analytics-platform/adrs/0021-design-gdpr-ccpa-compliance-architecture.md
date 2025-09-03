# 21. Design GDPR/CCPA compliance architecture

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design GDPR/CCPA compliance architecture to handle data subject rights (access, portability, deletion) while maintaining audit trails and supporting the analytics platform's "forever" retention model across tiered storage.

Business drivers: Analytics platform must comply with GDPR/CCPA regulations while preserving analytical capabilities. System requires automated workflows for data subject requests without impacting zero data loss guarantees for non-personal data.

Relevant QAs (IDs): SE-1 Security (GDPR/CCPA compliance with audit trail), U-1 Usability (SDK integration), R-1 Reliability (Data durability).

## Decision

### Compare **Compliance Architectures**

| Architecture          | Request Processing   | Data Discovery      | Deletion Guarantees| Audit Completeness | Operational Overhead| Performance Impact |
|-----------------------|----------------------|---------------------|--------------------|--------------------|---------------------|--------------------|
| **Reactive Processing**| 🟨 manual workflows | 🟨 search-based    | 🟨 eventual        | 🟩 logged actions  | 🟥 high manual     | 🟩 minimal        |
| **Event-Driven**      | 🟩 automated        | 🟩 indexed metadata| 🟩 systematic      | 🟩 event sourced   | 🟨 automation setup| 🟨 processing load |
| **Privacy by Design** | 🌟 built-in         | 🌟 schema-aware    | 🌟 guaranteed      | 🌟 comprehensive   | 🟩 low ongoing     | 🟨 upfront design |
| **Hybrid Approach**   | 🟩 semi-automated   | 🟩 multi-method    | 🟩 verified        | 🟩 multi-layer     | 🟨 balanced        | 🟨 controlled      |

### Compare **Data Subject Request Technologies**

| Technology            | Request Automation   | Cross-System Search | Deletion Verification| Audit Trail        | Integration Effort | Compliance Features|
|-----------------------|----------------------|---------------------|----------------------|--------------------|--------------------|--------------------|
| **Custom API Gateway**| 🟩 REST endpoints   | 🟨 manual queries   | 🟨 custom validation| 🟩 access logs     | 🟥 full development| 🟨 basic          |
| **OneTrust/TrustArc** | 🌟 workflow engine  | 🟩 data mapping     | 🟩 verified deletion| 🌟 compliance dash | 🟨 integration     | 🌟 specialized    |
| **AWS Privacy Engineering**| 🟩 serverless   | 🟩 service discovery| 🟩 Lambda validation| 🟩 CloudTrail      | 🟩 AWS native      | 🟩 cloud-first    |
| **Apache Kafka + Schema Registry**| 🟩 event-driven| 🌟 schema metadata | 🟩 event verification| 🟩 event sourcing  | 🟨 stream setup    | 🟨 developer-focused|
| **Database-Native Tools**| 🟨 SQL procedures| 🟩 metadata queries | 🟩 transaction logs | 🟩 database audit  | 🟩 minimal        | 🟨 limited scope  |

**Decision:** Implement **privacy by design architecture** with automated data subject request processing:

**Data Classification Layer:**
- Schema Registry with privacy metadata for all event types
- Automated PII detection and tagging during ingestion
- Data lineage tracking across tiered storage (hot/warm/cold)

**Request Processing Engine:**
- API Gateway for data subject requests (access, portability, deletion)
- Lambda functions for cross-tier data discovery and processing
- Automated workflow with 30-day processing SLA

**Verification and Audit:**
- Cryptographic proofs for deletion completion across all storage tiers
- Immutable audit trail in dedicated compliance database
- Regular compliance reports and data retention summaries

Supersedes: none.

## Consequences

- ✅ Automated compliance workflows handle GDPR/CCPA requests with complete audit trails (SE-1).
- ✅ Privacy by design approach minimizes compliance risk and operational overhead.
- ✅ Cross-tier data discovery ensures complete data subject request fulfillment (R-1).
- ✅ Schema-aware classification enables proactive privacy protection during SDK integration (U-1).
- ✅ Cryptographic verification provides deletion guarantees while preserving analytical data integrity.
- ⚠️ Privacy metadata management adds complexity to data pipeline and schema evolution.
- ⚠️ Cross-tier deletion operations may impact query performance during processing windows.
- Follow-ups: ADR-022 (audit trail implementation), ADR-023 (anonymization strategy), ADR-024 (SDK privacy controls).
