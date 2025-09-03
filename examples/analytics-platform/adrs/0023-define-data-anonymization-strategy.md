# 23. Define data anonymization strategy

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Define data anonymization strategy to balance GDPR/CCPA compliance requirements with analytics utility while supporting the privacy by design architecture established in ADR-021 and audit trail system from ADR-022.

Business drivers: Analytics platform must preserve analytical value while protecting individual privacy. Anonymization strategy must work across tiered storage and support both data subject deletion and research/analytics use cases.

Relevant QAs (IDs): SE-1 Security (GDPR/CCPA compliance with audit trail), U-1 Usability (SDK integration), R-1 Reliability (Data durability), P-1 Performance (Report response time ≤1.5s).

## Decision

### Compare **Anonymization Techniques**

| Technique             | Privacy Protection   | Analytics Utility   | Reversibility      | Implementation     | Performance Impact | Regulatory Acceptance|
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Data Masking**      | 🟨 format preservation| 🟩 maintained structure| 🟥 potentially reversible| 🟩 simple rules| 🟩 minimal      | 🟨 limited protection|
| **Pseudonymization** | 🟩 indirect identification| 🟩 full analytics| 🟨 with key management| 🟩 deterministic | 🟩 fast lookup    | 🟩 GDPR compliant |
| **K-Anonymity**      | 🟩 group protection | 🟨 reduced granularity| 🟥 irreversible  | 🟨 complex grouping| 🟨 computation    | 🟩 research standard|
| **Differential Privacy**| 🌟 mathematical guarantee| 🟨 noise addition| 🟥 irreversible  | 🟥 complex math   | 🟨 query overhead | 🌟 gold standard  |
| **Synthetic Data**    | 🌟 no real data     | 🟨 statistical similarity| 🟥 irreversible| 🟥 model training | 🟥 generation cost| 🟩 emerging standard|

### Compare **Anonymization Technologies**

| Technology            | Technique Support    | Scale Capability    | Integration Effort | Audit Integration  | Performance        | Compliance Features|
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **AWS Glue DataBrew** | 🟩 masking/hashing  | 🟩 serverless scale| 🟩 visual interface| 🟩 CloudTrail     | 🟩 managed        | 🟩 PII detection  |
| **Apache ARX**        | 🌟 research-grade   | 🟨 single-machine  | 🟨 Java integration| 🟨 custom logging | 🟨 computation    | 🌟 privacy models |
| **Privacera**         | 🟩 enterprise       | 🟩 distributed     | 🟨 policy engine   | 🟩 comprehensive  | 🟩 optimized      | 🟩 compliance-first|
| **Custom Kafka Streams**| 🟨 basic techniques| 🟩 streaming scale | 🟩 existing pipeline| 🟩 event-driven  | 🟩 real-time      | 🟨 manual compliance|
| **ClickHouse Functions**| 🟨 SQL-based       | 🟩 columnar performance| 🟩 database native| 🟨 query logs     | 🌟 very fast     | 🟨 limited features|

**Decision:** Implement **layered anonymization strategy** with technique selection based on data sensitivity and use case:

**Layer 1 - Real-time Pseudonymization:**
- Kafka Streams processors for immediate PII pseudonymization during ingestion
- Deterministic hashing with rotating salt keys for consistent analytics
- Preserves analytical relationships while protecting direct identification

**Layer 2 - Storage-tier Anonymization:**
- Hot tier: Pseudonymized identifiers with secure key management
- Warm tier: K-anonymity grouping for historical analysis (k≥5)
- Cold tier: Differential privacy for long-term research datasets

**Layer 3 - Query-time Protection:**
- ClickHouse user-defined functions for dynamic anonymization
- Context-aware anonymization based on user roles and data sensitivity
- Automatic audit logging of all anonymization operations

**Key Management:**
- AWS KMS for pseudonymization key rotation (quarterly)
- Separate key stores for different data classifications
- Emergency key destruction capability for data subject deletion

Supersedes: none.

## Consequences

- ✅ Multi-layer anonymization preserves analytics utility while ensuring GDPR/CCPA compliance (SE-1).
- ✅ Real-time pseudonymization maintains data relationships for consistent analytics (U-1, P-1).
- ✅ Differential privacy for historical data provides mathematical privacy guarantees (R-1).
- ✅ Context-aware anonymization adapts protection level to access patterns and user roles.
- ✅ Automated audit integration tracks all anonymization operations for compliance verification.
- ⚠️ Key management complexity requires robust operational procedures and disaster recovery.
- ⚠️ Performance impact from real-time anonymization may require optimization during peak loads.
- Follow-ups: ADR-024 (SDK security controls), key rotation procedures, anonymization performance tuning.
