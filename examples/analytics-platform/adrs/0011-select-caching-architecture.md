# 11. Select Caching Architecture

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design caching architecture to support 100K concurrent analysts while maintaining sub-1.5s query response times and ensuring query consistency across the multi-tier aggregation strategy established in ADR-010.

Business drivers: Analytics platform must serve repeated queries efficiently while balancing cache hit rates with data freshness. Common usage patterns include dashboard refreshes, repeated report views, and exploratory analysis with similar parameters.

Relevant QAs (IDs): P-1 Performance (Report response time ≤1.5s), P-3 Performance (100K concurrent users), R-2 Reliability (Query consistency), S-2 Scalability (Storage capacity).

## Decision

### Compare **Cache Types**

| Cache Type            | Hit Rate Potential   | Consistency Model   | Implementation     | Memory Efficiency  | Network Overhead   | TTL Management     |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Query Result Cache**| 🟩 high for dashboards| 🟨 time-based TTL | 🟩 application layer| 🟨 full results   | 🟩 reduced DB calls| 🟨 complex expiry  |
| **Aggregation Cache** | 🌟 very high        | 🟩 data-driven     | 🟨 DB layer        | 🟩 compressed aggs | 🟩 minimal        | 🟩 event-based     |
| **Connection Pool**   | 🟨 connection reuse  | 🌟 transparent     | 🟩 simple          | 🟩 minimal memory  | 🟩 reduced setup   | 🟩 automatic       |
| **CDN Edge Cache**    | 🟩 geographic       | 🟨 eventual        | 🟨 edge deployment | 🟩 distributed    | 🌟 edge delivery   | 🟨 global sync     |

### Compare **Cache Technologies**

| Technology            | Throughput           | Latency             | Clustering         | Memory Efficiency  | Operational Model  | Analytics Features |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Redis Cluster**     | 🟩 high ops/sec     | 🌟 <1ms            | 🟩 native sharding | 🟩 efficient      | 🟨 manual setup    | 🟨 basic types     |
| **Amazon ElastiCache**| 🟩 managed scaling  | 🟩 low latency     | 🟩 managed cluster | 🟩 optimized      | 🌟 serverless      | 🟨 Redis/Memcached |
| **Hazelcast**         | 🟩 distributed      | 🟩 in-memory       | 🟩 automatic       | 🟩 near-cache      | 🟨 complex config  | 🟩 compute grid    |
| **Application Cache** | 🟨 single-node      | 🌟 zero network    | 🟥 no clustering   | 🟨 heap limited    | 🟩 simple          | 🟩 custom logic    |
| **ClickHouse Cache**  | 🟩 query-optimized  | 🟩 columnar        | 🟩 distributed     | 🌟 compressed      | 🟩 built-in        | 🌟 SQL-aware       |

**Decision:** Implement **hybrid caching architecture** with three cache layers:

**Layer 1 - Application Cache (In-Memory):**
- Cache frequent dashboard queries and user session data
- 15-minute TTL for real-time aggregates, 4-hour TTL for historical data
- Ehcache or Caffeine for JVM applications

**Layer 2 - Distributed Cache (Redis Cluster):**
- Cache expensive aggregation results and query metadata
- Cross-application sharing for 100K concurrent users
- 1-hour TTL with event-driven invalidation

**Layer 3 - Database Query Cache (ClickHouse):**
- Built-in query result caching for repeated SQL patterns
- Automatic invalidation based on data freshness
- Native compression and distributed storage

Supersedes: none.

## Consequences

- ✅ Sub-1.5s response times through multi-layer cache hits for 80%+ of queries (P-1).
- ✅ Horizontal scaling of cache capacity supports 100K concurrent users (P-3).
- ✅ Consistent cache invalidation maintains data accuracy across aggregation tiers (R-2).
- ✅ Memory-efficient storage through compressed aggregates and smart TTL policies.
- ✅ Reduced database load enables better resource utilization (S-2).
- ⚠️ Cache consistency complexity across three layers requires careful coordination.
- ⚠️ Memory overhead for application and distributed caches needs monitoring.
- Follow-ups: ADR-012 (read replica topology), cache warming strategies, invalidation event design.
