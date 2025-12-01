# 19. Design Storage Lifecycle Policies

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design automated storage lifecycle policies to manage data transitions across the tiered storage architecture from ADR-017 while supporting "forever" retention requirements and maintaining cost efficiency with 24TB/year growth.

Business drivers: Analytics platform requires automated data lifecycle management to prevent manual operational overhead while ensuring compliance with retention policies. Lifecycle automation must balance access patterns, cost optimization, and regulatory requirements.

Relevant QAs (IDs): S-2 Scalability (Storage capacity accommodates 24TB/year growth), R-1 Reliability (Zero data loss), S-1 Scalability (Event volume growth), SE-1 Security (Data privacy compliance).

## Decision

### Compare **Lifecycle Trigger Strategies**

| Strategy              | Automation Level     | Cost Optimization   | Compliance Support | Operational Overhead| Access Predictability| Error Recovery     |
|-----------------------|----------------------|---------------------|--------------------|--------------------|----------------------|--------------------|
| **Time-based Rules**  | 🌟 fully automated  | 🟩 predictable     | 🌟 policy-driven   | 🟩 minimal setup   | 🟩 deterministic    | 🟩 retry-able      |
| **Access-based**      | 🟩 intelligent      | 🌟 usage-optimized | 🟨 complex tracking | 🟨 monitoring req'd | 🟨 variable patterns | 🟨 state complexity|
| **Size-based Triggers**| 🟩 threshold-driven | 🟨 reactive        | 🟨 indirect        | 🟨 threshold mgmt   | 🟨 unpredictable    | 🟩 measurable      |
| **Hybrid Rules**      | 🟩 configurable     | 🟩 balanced        | 🟩 flexible        | 🟥 complex logic    | 🟨 multi-dimensional| 🟨 complex recovery|

### Compare **Lifecycle Management Technologies**

| Technology            | Rule Complexity      | Cross-Service Support| Cost Tracking     | Compliance Features| Monitoring         | Error Handling     |
|-----------------------|----------------------|----------------------|-------------------|--------------------|--------------------|--------------------| 
| **S3 Lifecycle Policies**| 🟩 rule-based     | 🌟 S3-native        | 🟩 detailed      | 🟩 retention tags  | 🟩 CloudWatch     | 🟩 retry logic     |
| **AWS Data Lifecycle Manager**| 🟩 EBS snapshots| 🟩 multi-service    | 🟩 cost allocation| 🟩 compliance tags | 🟩 comprehensive  | 🟩 managed        |
| **Custom Lambda Functions**| 🌟 unlimited     | 🌟 cross-platform   | 🟨 custom tracking| 🟨 manual impl    | 🟨 custom metrics | 🟨 custom logic   |
| **Third-party Tools** | 🟩 policy engines   | 🟨 vendor-dependent | 🟨 additional cost| 🟩 specialized    | 🟩 vendor tools   | 🟨 vendor support |
| **ClickHouse TTL**    | 🟨 table-level      | 🟨 ClickHouse only  | 🟨 compute-based  | 🟨 basic          | 🟨 database logs  | 🟨 manual recovery|

**Decision:** Implement **automated time-based lifecycle policies** with compliance integration:

**Hot → Warm Transition (30 days):**
- S3 Lifecycle policy moves ClickHouse exports to Standard storage
- Daily batch job exports aggregated data to Parquet format
- Maintains raw event access for regulatory requirements

**Warm → Cold Transition (2 years):**
- Automated transition to S3 Glacier Flexible Retrieval
- Metadata retention in ClickHouse for query routing
- Compliance tagging for audit trail preservation

**GDPR/CCPA Deletion Workflows:**
- Lambda functions triggered by deletion requests
- Cross-tier deletion with audit logging
- 30-day verification period before permanent removal

**Monitoring and Alerting:**
- CloudWatch metrics for transition success rates
- Cost anomaly detection for unexpected storage growth
- Compliance alerts for failed deletion workflows

Supersedes: none.

## Consequences

- ✅ Automated lifecycle management scales with 24TB/year growth without operational overhead (S-2).
- ✅ Time-based rules ensure predictable data transitions with zero data loss (R-1).
- ✅ Compliance integration supports GDPR/CCPA deletion requirements with audit trails (SE-1).
- ✅ Cross-tier metadata preservation enables efficient query routing and cost optimization.
- ✅ Monitoring and alerting provide visibility into lifecycle operations and cost trends.
- ⚠️ Time-based rules may not optimize for actual access patterns vs usage-based approaches.
- ⚠️ Cross-tier deletion complexity requires comprehensive testing and recovery procedures.
- Follow-ups: ADR-020 (cost optimization controls), lifecycle policy implementation, compliance workflow testing.
