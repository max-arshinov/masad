# 8. Design Data Retention and Archival System

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 2 goal: Database Architecture and Data Management. System must retain data for 3 years while managing storage costs and maintaining query performance. With 100M links/year and associated click data, storage requirements grow to ~TB scale requiring tiered storage strategy.

Business drivers: 3-year retention compliance, cost optimization, query performance for recent data, compliance with data lifecycle policies.

Relevant QAs (IDs): R-1 (3-year data retention), S-2 (100M links/year), M-1 (100% click tracking).

## Decision

### Table 1 — Compare Data Lifecycle Strategies

| Lifecycle Strategy | Storage Cost | Query Performance | Compliance | Operational Complexity | Recovery Time | Data Integrity |
|-------------------|--------------|-------------------|------------|----------------------|---------------|----------------|
| **Single-Tier (Hot)** | 🟥 expensive at scale | 🌟 consistent fast | 🟩 simple compliance | 🟩 minimal complexity | 🌟 immediate | 🌟 full ACID |
| **Two-Tier (Hot/Cold)** | 🟩 cost reduction | 🟩 hot fast, cold slow | 🟩 clear policies | 🟨 migration logic | 🟨 cold retrieval | 🟩 maintained |
| **Three-Tier (Hot/Warm/Cold)** | 🌟 optimized costs | 🟩 graduated performance | 🟩 flexible policies | 🟨 complex transitions | 🟨 tiered access | 🟩 maintained |
| **Archive-Only** | 🌟 minimal cost | 🟥 slow queries | 🟨 retrieval delays | 🟩 simple archival | 🟥 hours/days | 🟨 eventual |
| **Hybrid (DB + Object Store)** | 🟩 balanced cost | 🟩 fast operational | 🟩 compliant archival | 🟥 dual systems | 🟨 depends on tier | 🟩 operational |

**Shortlist:** Three-Tier and Hybrid approaches best balance R-1 compliance, cost optimization, and query performance.

### Table 2 — Compare Storage Technologies by Tier

| Storage Technology | Cost per GB | Query Performance | Durability | Retrieval Time | Integration | Automation |
|-------------------|-------------|-------------------|------------|----------------|-------------|------------|
| **PostgreSQL (SSD)** | 🟥 $0.10-0.15 | 🌟 <10ms | 🟩 99.999% | 🌟 immediate | 🌟 native | 🟩 SQL triggers |
| **PostgreSQL (HDD)** | 🟨 $0.05-0.08 | 🟨 50-100ms | 🟩 99.99% | 🟩 immediate | 🌟 native | 🟩 SQL triggers |
| **Amazon S3 Standard** | 🟨 $0.023 | 🟥 API only | 🌟 99.999999999% | 🟩 immediate | 🟨 external | 🟩 lifecycle rules |
| **Amazon S3 IA** | 🟩 $0.0125 | 🟥 API only | 🌟 99.999999999% | 🟩 immediate | 🟨 external | 🟩 lifecycle rules |
| **Amazon Glacier** | 🌟 $0.004 | 🟥 API only | 🌟 99.999999999% | 🟥 1-12 hours | 🟨 external | 🟩 lifecycle rules |
| **Compressed Tables** | 🟩 30-50% reduction | 🟨 decompression overhead | 🟩 99.99% | 🟩 immediate | 🌟 native | 🟨 manual policies |

**Decision:** Implement three-tier data retention using hybrid PostgreSQL + S3 approach:

**Tier 1 (Hot - 0-6 months):**
- PostgreSQL SSD storage for active URLs and recent clicks
- Full indexing and query optimization
- Real-time analytics and operational queries

**Tier 2 (Warm - 6-24 months):**
- PostgreSQL HDD storage with compressed tables
- Reduced indexing, optimized for analytical queries
- Automated migration via partition-based policies

**Tier 3 (Cold - 24-36 months):**
- Amazon S3 Intelligent Tiering for compliance retention
- Parquet format for analytical access via Amazon Athena
- Automated export and deletion after 36 months

Migration policies:
- Daily batch jobs for tier transitions
- Partition-level migration based on age thresholds
- Metadata tracking for data location and access patterns

Supersedes: none.

## Consequences

- ✅ Addresses R-1 with compliant 3-year retention across all tiers
- ✅ Optimizes storage costs with 70-80% reduction for aged data
- ✅ Maintains S-2 performance for active data in hot tier
- ✅ Enables M-1 analytics across all tiers via different access patterns
- ⚠️ Requires automated migration jobs and monitoring
- ⚠️ Query complexity increases for cross-tier analytical reports
- Follow-ups: ADR on migration job scheduling, monitoring and alerting for data lifecycle, cross-tier query optimization
