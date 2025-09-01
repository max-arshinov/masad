# 4. Choose Caching Strategy and CDN Integration

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 1 goal: Address high-risk performance and scalability concerns for URL redirection service. Growth projections show read RPS escalating from 11.5K (year 1) to 139K (year 5), with peak traffic reaching 417K RPS by year 5. Current risks include RISK-READ-THROUGHPUT and RISK-CACHE-FAILURE.

Business drivers: 1M users/year growth, 100M links/year creation, 3-year retention requirement.

Relevant QAs (IDs): P-1 (redirect latency <0.2s), P-3 (<0.1s degradation with failures), A-1 (99.9% uptime), S-3 (10 requests/link/day).

## Decision

### Table 1 — Compare Caching Architectures

| Caching Architecture          | Read Latency      | Scalability            | Fault Tolerance         | Cache Hit Rate      | Operational Complexity | Cost               |
|-------------------------------|-------------------|------------------------|-------------------------|---------------------|------------------------|--------------------|
| **Application Cache Only**    | 🟨 local access   | 🟥 single node limit   | 🟥 single point failure | 🟨 limited scope    | 🟩 simple              | 🟩 low             |
| **Distributed Cache (Redis)** | 🟩 network hop    | 🟩 horizontal scale    | 🟨 cluster dependency   | 🟩 shared state     | 🟨 moderate            | 🟨 moderate        |
| **Multi-Tier (App + Redis)**  | 🟩 L1 hit fast    | 🟩 scale both tiers    | 🟩 fallback layers      | 🌟 layered hits     | 🟨 moderate            | 🟨 moderate        |
| **CDN + Application Cache**   | 🌟 edge proximity | 🌟 global distribution | 🟩 edge redundancy      | 🌟 geographic hits  | 🟨 edge config         | 🟨 bandwidth costs |
| **CDN + Multi-Tier Cache**    | 🌟 optimal path   | 🌟 full spectrum       | 🌟 multiple fallbacks   | 🌟 maximum coverage | 🟥 complex             | 🟨 higher costs    |

**Shortlist:** Multi-Tier (App + Redis) and CDN + Multi-Tier Cache best address P-1 latency and S-3 throughput requirements.

### Table 2 — Compare CDN Providers

| CDN Provider       | Global Coverage | Cache Control      | Performance     | Integration      | Cost Model        | Monitoring    |
|--------------------|-----------------|--------------------|-----------------|------------------|-------------------|---------------|
| **CloudFlare**     | 🌟 300+ PoPs    | 🟩 flexible TTL    | 🌟 sub-100ms    | 🟩 API/DNS       | 🟩 usage-based    | 🟩 detailed   |
| **AWS CloudFront** | 🟩 400+ PoPs    | 🟩 cache behaviors | 🟩 reliable     | 🌟 AWS ecosystem | 🟨 tiered pricing | 🟩 CloudWatch |
| **Fastly**         | 🟨 limited PoPs | 🌟 real-time purge | 🟩 edge compute | 🟩 VCL control   | 🟥 expensive      | 🟩 real-time  |
| **Azure CDN**      | 🟩 global reach | 🟨 basic control   | 🟨 variable     | 🟨 Azure-focused | 🟨 moderate       | 🟨 basic      |

**Decision:** Implement CDN + Multi-Tier caching with CloudFlare CDN, Redis distributed cache, and application-level cache. This architecture addresses P-1 (sub-0.2s latency), provides fault tolerance for P-3, and scales to handle projected 417K peak RPS.

Cache hierarchy: CloudFlare Edge (TTL: 1 hour) → Redis Cluster (TTL: 4 hours) → Application Cache (TTL: 15 minutes) → Database.

Supersedes: none.

## Consequences

- ✅ Meets P-1 latency requirements with edge caching and multi-tier fallbacks
- ✅ Addresses RISK-READ-THROUGHPUT with distributed scaling to 417K RPS
- ✅ Provides P-3 fault tolerance with multiple cache layers
- ⚠️ Operational complexity increases with cache invalidation and consistency management
- ⚠️ Cache warming strategy required for cold starts (identified technical debt)
- Follow-ups: ADR on cache invalidation policies, cache warming automation, monitoring thresholds
