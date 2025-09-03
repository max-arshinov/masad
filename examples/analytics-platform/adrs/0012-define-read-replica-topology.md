# 12. Define Read Replica Topology

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design read replica topology for ClickHouse to distribute 100K concurrent analyst queries while maintaining sub-1.5s response times and ensuring query consistency across the hybrid caching architecture established in ADR-011.

Business drivers: Analytics platform requires global deployment with users distributed across regions. Read workload must be balanced across replicas while maintaining data consistency for multi-tier aggregation strategy from ADR-010.

Relevant QAs (IDs): P-1 Performance (Report response time ≤1.5s), P-3 Performance (100K concurrent users), R-2 Reliability (Query consistency), A-2 Availability (System uptime).

## Decision

### Compare **Replica Architectures**

| Architecture          | Read Scalability     | Consistency Model   | Operational Complexity| Network Latency    | Failover Capability| Cost Efficiency    |
|-----------------------|----------------------|---------------------|----------------------|--------------------|--------------------|--------------------|
| **Single Master**     | 🟥 bottleneck       | 🌟 strong          | 🟩 simple           | 🟨 single region   | 🟥 SPOF           | 🟩 minimal        |
| **Master-Slave**      | 🟩 read distribution | 🟩 eventual        | 🟨 replication lag  | 🟩 regional        | 🟨 manual failover | 🟩 cost-effective |
| **Multi-Master**      | 🌟 write+read scale  | 🟨 conflict resolution| 🟥 complex sync   | 🟩 distributed     | 🟩 automatic      | 🟨 higher overhead |
| **Federated Clusters**| 🌟 horizontal       | 🟨 eventual        | 🟥 cross-cluster mgmt| 🌟 locality       | 🟩 cluster isolation| 🟨 resource intensive|

### Compare **Replication Strategies**

| Strategy              | Replication Lag      | Data Consistency    | Resource Usage     | Geographic Distribution| Query Routing     | Maintenance Overhead|
|-----------------------|----------------------|---------------------|--------------------|-----------------------|-------------------|---------------------|
| **Sync Replication** | 🟩 <100ms           | 🌟 immediate       | 🟥 high CPU/network| 🟨 latency sensitive | 🟩 any replica    | 🟨 coordination    |
| **Async Replication**| 🟨 1-5 minutes      | 🟨 eventual        | 🟩 efficient       | 🟩 global support    | 🟨 lag-aware      | 🟩 independent     |
| **Tiered Replication**| 🟩 <1 minute       | 🟩 configurable    | 🟨 balanced        | 🟩 hierarchical      | 🟩 intelligent    | 🟨 multi-tier mgmt |
| **Event Sourcing**   | 🟩 near real-time   | 🟩 event consistency| 🟨 event overhead  | 🟩 replay capability | 🟩 source-based   | 🟥 complex rebuild |

**Decision:** Implement **tiered replication topology** with regional read replica clusters:

**Tier 1 - Primary Cluster (US-East):**
- 3-node ClickHouse cluster for writes and real-time aggregation
- Handles raw event ingestion and immediate query processing
- Synchronous replication within cluster (RF=2)

**Tier 2 - Regional Read Replicas:**
- US-West, EU-Central, APAC-Singapore clusters (3 nodes each)
- Asynchronous replication with <60 second lag for aggregated data
- Optimized for dashboard queries and historical analysis

**Tier 3 - Edge Query Nodes:**
- Single-node replicas for specific geographic markets
- Cache-heavy configuration with local SSD storage
- Fallback to regional replicas for cache misses

**Query Routing Strategy:**
- Route by user location and query type (real-time vs historical)
- Automatic failover to next tier on replica unavailability

Supersedes: none.

## Consequences

- ✅ Sub-1.5s response times through geographic proximity and query locality (P-1).
- ✅ 100K+ concurrent users distributed across regional replicas (P-3).
- ✅ 60-second replication lag maintains acceptable consistency for analytics use cases (R-2).
- ✅ High availability through multi-tier failover and cluster redundancy (A-2).
- ✅ Cost optimization through tiered resource allocation based on query patterns.
- ⚠️ Complex query routing logic requires sophisticated load balancer configuration.
- ⚠️ Replication lag monitoring and alerting needed for consistency SLA compliance.
- Follow-ups: Implement geographic DNS routing, replication monitoring dashboards, automatic failover procedures.
