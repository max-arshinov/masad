# 7. Define Data Partitioning Strategy

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Define partitioning strategy for Amazon MSK to distribute 1.16M events/sec sustained load across brokers and enable horizontal scaling to 146B events/day by year 5. Must ensure even load distribution while maintaining event ordering where required.

Business drivers: Analytics platform tracks events from multiple websites with varying traffic patterns. Partition strategy affects query performance, consumer parallelism, and operational complexity.

Relevant QAs (IDs): P-2 Performance (High event ingestion throughput), S-1 Scalability (Event volume growth), R-1 Reliability (Data durability), A-2 Availability (System uptime).

## Decision

### Compare **Partitioning Strategies**

| Strategy             | Load Distribution    | Event Ordering | Hotspot Risk     | Query Performance     | Operational Complexity |
|----------------------|----------------------|----------------|------------------|-----------------------|------------------------|
| **Website ID**       | 🟨 uneven by size    | 🟩 per website | 🟥 popular sites | 🟩 site-based queries | 🟩 simple              |
| **User ID Hash**     | 🟩 even distribution | 🟩 per user    | 🟨 active users  | 🟨 cross-user queries | 🟨 moderate            |
| **Timestamp Bucket** | 🟩 time-based        | 🟥 none        | 🟨 peak hours    | 🟩 time-range queries | 🟩 simple              |
| **Composite Key**    | 🟩 balanced          | 🟨 partial     | 🟩 distributed   | 🟨 complex routing    | 🟥 complex             |
| **Random Hash**      | 🌟 perfectly even    | 🟥 no ordering | 🟩 no hotspots   | 🟥 poor locality      | 🟩 simple              |

### Compare **Partition Count Strategies**

| Partition Count        | Throughput Scaling | Consumer Scaling     | Storage Overhead   | Rebalancing Impact | Broker Utilization |
|------------------------|--------------------|----------------------|--------------------|--------------------|--------------------| 
| **Low (100-500)**      | 🟥 limited         | 🟥 max 500 consumers | 🟩 minimal         | 🟩 fast rebalance  | 🟨 uneven          |
| **Medium (1000-2000)** | 🟩 good scaling    | 🟩 good parallelism  | 🟩 reasonable      | 🟨 moderate        | 🟩 balanced        |
| **High (5000+)**       | 🌟 excellent       | 🌟 high parallelism  | 🟨 higher overhead | 🟥 slow rebalance  | 🟩 even            |
| **Dynamic Scaling**    | 🌟 adaptive        | 🌟 flexible          | 🟨 variable        | 🟥 complex mgmt    | 🟩 optimized       |

**Decision:** Implement **composite key partitioning** using `hash(website_id + timestamp_hour)` with **2000 partitions** initially. This strategy balances load distribution across websites while providing time-based locality for analytics queries. The composite approach prevents hotspots from high-traffic websites while maintaining some temporal ordering for processing efficiency.

Partition scaling plan: Start with 2000 partitions, scale to 5000 by year 3 when approaching 1.4M events/sec sustained load.

Supersedes: none.

## Consequences

- ✅ Even load distribution prevents broker hotspots during traffic spikes (P-2, A-2).
- ✅ Supports horizontal scaling to 2000+ parallel consumers (S-1).
- ✅ Time-based locality improves analytics query performance and consumer efficiency.
- ✅ Website-based distribution maintains some ordering for per-site processing.
- ✅ 2000 partitions provide headroom for growth while maintaining manageable rebalancing.
- ⚠️ Composite key increases partitioning logic complexity in producers.
- ⚠️ Requires monitoring for partition skew and rebalancing when scaling.
- Follow-ups: ADR-008 (auto-scaling policies), producer partition key implementation, consumer group rebalancing strategies.
