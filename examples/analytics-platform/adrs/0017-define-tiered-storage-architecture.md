# 17. Define Tiered Storage Architecture

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Define tiered storage architecture to support "forever" data retention with 24TB/year growth while maintaining cost efficiency and zero data loss guarantees for the analytics platform.

Business drivers: Analytics platform requires permanent data retention for compliance and historical analysis while managing storage costs that could spiral with 120TB+ cumulative growth over 5 years. Storage strategy must balance access patterns, performance requirements, and cost optimization.

Relevant QAs (IDs): S-2 Scalability (Storage capacity accommodates 24TB/year growth), R-1 Reliability (Zero data loss), S-1 Scalability (Event volume growth).

## Decision

### Compare **Storage Tiering Strategies**

| Strategy              | Cost Optimization    | Access Performance  | Data Migration     | Operational Complexity| Recovery Time      | Compliance Support |
|-----------------------|----------------------|---------------------|--------------------|-----------------------|--------------------|--------------------| 
| **Hot-Warm-Cold**     | 🟩 standard tiers   | 🟩 predictable     | 🟩 automated      | 🟩 well-established   | 🟩 tier-dependent  | 🟩 audit-friendly  |
| **Time-based Aging** | 🟩 lifecycle rules  | 🟨 degrading       | 🌟 automatic       | 🟩 rule-based         | 🟨 retrieval delays| 🟩 retention policies|
| **Usage-based Tiers**| 🌟 intelligent     | 🌟 adaptive        | 🟨 ML complexity   | 🟥 complex algorithms | 🟩 performance-aware| 🟨 unpredictable   |
| **Flat Storage**      | 🟥 single tier cost| 🌟 consistent      | 🟩 none needed     | 🌟 simple             | 🌟 immediate       | 🟨 cost inefficient|

### Compare **Storage Technologies**

| Technology            | Cost per TB/Month    | Retrieval Time      | Durability         | Query Performance  | Integration        | Lifecycle Automation|
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **S3 Standard**       | 🟨 $23/TB           | 🌟 immediate       | 🌟 99.999999999%   | 🟩 fast access    | 🌟 native AWS     | 🟩 lifecycle rules |
| **S3 Intelligent-Tiering**| 🟩 $20-23/TB     | 🟩 adaptive        | 🌟 99.999999999%   | 🟩 tier-dependent  | 🌟 automatic      | 🌟 ML-based        |
| **S3 Glacier Flexible**| 🟩 $4/TB           | 🟨 1-5 minutes     | 🌟 99.999999999%   | 🟨 retrieval delay | 🟩 S3 API         | 🟩 configurable   |
| **S3 Glacier Deep**   | 🌟 $1/TB            | 🟥 12+ hours       | 🌟 99.999999999%   | 🟥 archive only    | 🟩 long-term      | 🟩 scheduled      |
| **ClickHouse SSD**    | 🟨 $100+/TB         | 🌟 <1ms            | 🟩 replica-based   | 🌟 columnar       | 🌟 query engine   | 🟨 manual         |
| **EBS GP3**           | 🟨 $80/TB           | 🌟 immediate       | 🟩 99.999%         | 🟩 block storage  | 🟩 EC2 attached   | 🟨 snapshot-based |

**Decision:** Implement **time-based tiering architecture** with automated lifecycle transitions:

**Tier 1 - Hot Storage (0-30 days):**
- ClickHouse SSD for real-time and recent analytics queries
- Raw events, hourly aggregates, and daily summaries
- Optimized for sub-1.5s query response times

**Tier 2 - Warm Storage (30 days - 2 years):**
- S3 Standard for historical analytics and monthly aggregates
- Compressed Parquet format for cost efficiency
- Direct query via AWS Athena for ad-hoc analysis

**Tier 3 - Cold Storage (2+ years):**
- S3 Glacier Flexible for compliance and long-term retention
- Automated transition with 5-minute retrieval capability
- Maintains "forever" retention with 95% cost reduction

Supersedes: none.

## Consequences

- ✅ 90%+ cost reduction for historical data while maintaining query capabilities (S-2).
- ✅ Zero data loss through S3's 99.999999999% durability across all tiers (R-1).
- ✅ Automated lifecycle transitions scale with 24TB/year growth without manual intervention (S-1).
- ✅ "Forever" retention compliance with cost-optimized long-term storage.
- ✅ Query performance maintained for recent data while historical access remains feasible.
- ⚠️ Query complexity increases for cross-tier analytics spanning multiple years.
- ⚠️ Retrieval costs and delays for deep archive access need operational planning.
- Follow-ups: ADR-018 (compression strategy), ADR-019 (lifecycle policies), ADR-020 (cost monitoring).
