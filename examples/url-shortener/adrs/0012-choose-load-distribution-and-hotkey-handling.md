# 12. Choose Load Distribution and Hotkey Handling

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 3 goal: Fault Tolerance and High Availability. System must handle hotkey concentration and peak traffic distribution while maintaining <0.1s degradation during failures and ensuring 99.9% uptime across varying load patterns.

Business drivers: Viral content handling, peak traffic resilience, consistent user experience, prevention of cascading failures from popular URLs.

Relevant QAs (IDs): P-3 (node failure tolerance), A-1 (99.9% uptime), P-1 (redirect latency <0.2s).

## Decision

### Table 1 — Compare Load Distribution Strategies

| Distribution Strategy | Hotkey Resilience | Load Balance | Failure Isolation | Implementation Complexity | Scalability | Cache Efficiency |
|----------------------|------------------|--------------|-------------------|--------------------------|-------------|----------------|
| **Round Robin** | 🟥 poor hotkey handling | 🟩 even distribution | 🟨 cascading failures | 🟩 simple | 🟨 limited | 🟨 random caching |
| **Consistent Hashing** | 🟨 hotkey concentration | 🟩 stable distribution | 🟩 isolated failures | 🟨 hash implementation | 🟩 elastic scaling | 🟩 locality |
| **Weighted Round Robin** | 🟨 capacity-based | 🟩 capacity-aware | 🟨 weighted failures | 🟨 weight management | 🟨 static weights | 🟨 predictable |
| **Least Connections** | 🟨 connection-based | 🟩 adaptive | 🟩 overload protection | 🟨 state tracking | 🟨 stateful | 🟨 connection locality |
| **Random with Power of Two** | 🟩 distributed sampling | 🟩 balanced load | 🟩 failure resilience | 🟩 simple algorithm | 🟩 stateless | 🟨 random distribution |
| **Rendezvous Hashing** | 🟩 distributed hotkeys | 🟩 stable mapping | 🟩 node failure tolerance | 🟨 computation overhead | 🟩 elastic | 🟩 consistent locality |

**Shortlist:** Consistent Hashing and Rendezvous Hashing best address hotkey distribution with failure tolerance.

### Table 2 — Compare Hotkey Mitigation Techniques

| Mitigation Technique | Hotkey Detection | Load Reduction | Implementation | Response Time | Scalability | Cache Hit Rate |
|---------------------|------------------|----------------|----------------|---------------|-------------|----------------|
| **Multi-tier Caching** | 🟨 reactive | 🟩 layer distribution | 🟩 standard CDN/Redis | 🟩 cache speeds | 🟩 horizontal | 🌟 high hit rates |
| **Hotkey Replication** | 🟩 proactive monitoring | 🌟 dedicated replicas | 🟨 dynamic replication | 🟩 dedicated resources | 🟨 resource intensive | 🌟 100% for hotkeys |
| **Circuit Breaker** | 🟩 failure detection | 🟨 fallback only | 🟩 library integration | 🟨 degraded mode | 🟩 stateless | 🟥 bypasses cache |
| **Rate Limiting** | 🟨 threshold-based | 🟨 request throttling | 🟩 API gateway | 🟥 delayed requests | 🟩 distributed | 🟨 reduces load |
| **Shard Splitting** | 🟩 load monitoring | 🌟 balanced redistribution | 🟥 complex resharding | 🟩 restored balance | 🌟 elastic | 🟩 redistributed |
| **Edge Computing** | 🟨 geographic patterns | 🌟 geographic distribution | 🟨 edge deployment | 🌟 edge latency | 🌟 global scale | 🟩 edge caching |

**Decision:** Implement Rendezvous Hashing with Multi-tier Caching and Hotkey Replication:

**Load Distribution Architecture:**
- Rendezvous hashing for consistent URL-to-server mapping
- AWS Application Load Balancer with sticky sessions disabled
- Kubernetes horizontal pod autoscaler based on CPU and custom metrics
- Health check-based node exclusion with automatic recovery

**Hotkey Detection and Mitigation:**
- Real-time hotkey detection using Redis counters with sliding windows
- Automatic hotkey replication to dedicated high-capacity cache nodes
- CDN edge caching with 5-minute TTL for viral content
- Circuit breaker pattern for database protection during traffic spikes

**Multi-tier Caching Strategy:**
```
Tier 1: CloudFront CDN (Global Edge) - 5 min TTL
Tier 2: Redis Cluster (Regional) - 60 min TTL  
Tier 3: Application Cache (Local) - 10 min TTL
Tier 4: Database Read Replicas (Fallback)
```

**Hotkey Handling Algorithm:**
1. Monitor request frequency per URL (1-minute sliding window)
2. Identify hotkeys exceeding 1000 requests/minute threshold
3. Replicate hotkey data to 3+ dedicated cache nodes
4. Route hotkey requests using weighted distribution
5. Gradual de-escalation when traffic normalizes

**Failure Tolerance:**
- Rendezvous hashing maintains consistent mapping during node failures
- Automatic cache warming for replacement nodes
- Cross-region cache replication for disaster recovery
- Graceful degradation to database reads with circuit breaker protection

Supersedes: none.

## Consequences

- ✅ Addresses P-3 with <0.1s degradation through hotkey distribution and circuit breakers
- ✅ Maintains A-1 uptime with failure-tolerant load distribution
- ✅ Preserves P-1 latency through multi-tier caching and edge distribution
- ✅ Handles viral content scenarios with automatic hotkey replication
- ⚠️ Increased monitoring complexity for hotkey detection and cache coordination
- ⚠️ Additional infrastructure costs for dedicated hotkey cache nodes
- Follow-ups: ADR on cache invalidation strategies, hotkey threshold tuning, cross-region cache synchronization policies
