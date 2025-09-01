# 5. Design Load Balancing and Traffic Distribution

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 1 goal: Address high-risk performance and scalability concerns. Growth projections show peak read traffic reaching 417K RPS by year 5, with risks RISK-PEAK-TRAFFIC and RISK-HOTKEY-CONCENTRATION. System must handle 3x traffic spikes and maintain P-1 latency requirements.

Business drivers: Handle peak traffic loads, ensure geographic distribution for global user base.

Relevant QAs (IDs): P-1 (redirect latency <0.2s), P-3 (<0.1s degradation with failures), A-1 (99.9% uptime), S-3 (10 requests/link/day).

## Decision

### Table 1 — Compare Load Balancing Strategies

| Strategy | Latency Impact | Fault Tolerance | Hotkey Handling | Scalability | Operational Complexity | Geographic Distribution |
|----------|---------------|-----------------|-----------------|-------------|----------------------|------------------------|
| **Round Robin** | 🟩 minimal overhead | 🟨 basic failover | 🟥 poor hotkey spread | 🟩 simple scaling | 🟩 simple | 🟥 no geo awareness |
| **Least Connections** | 🟩 load-aware | 🟩 health checks | 🟨 moderate spread | 🟩 adaptive | 🟨 connection tracking | 🟥 no geo awareness |
| **Consistent Hashing** | 🟩 cache locality | 🟨 ring rebalancing | 🟨 virtual nodes help | 🟩 horizontal scale | 🟨 hash ring mgmt | 🟨 region-aware rings |
| **Geographic Routing** | 🌟 proximity-based | 🟩 region failover | 🟥 regional hotspots | 🟩 regional scale | 🟨 DNS/routing config | 🌟 native geo support |
| **Hybrid (Geo + Consistent)** | 🌟 optimal routing | 🌟 multi-level failover | 🟩 distributed hotkeys | 🌟 full spectrum | 🟥 complex management | 🌟 optimal distribution |

**Shortlist:** Geographic Routing and Hybrid approach best address P-1 latency and hotkey distribution requirements.

### Table 2 — Compare Load Balancer Products

| Load Balancer | Performance | Health Checks | Geographic Routing | Auto-scaling Integration | Monitoring | Cost |
|---------------|-------------|---------------|-------------------|-------------------------|------------|------|
| **AWS ALB** | 🟩 managed capacity | 🟩 advanced health | 🟨 Route53 integration | 🌟 native ASG | 🟩 CloudWatch | 🟩 pay-per-use |
| **HAProxy** | 🌟 high performance | 🟩 flexible checks | 🟨 DNS integration | 🟨 external tools | 🟩 detailed stats | 🟩 open source |
| **NGINX Plus** | 🟩 high throughput | 🟩 active checks | 🟨 upstream zones | 🟨 API integration | 🟩 real-time | 🟨 licensing |
| **Cloudflare Load Balancer** | 🌟 edge performance | 🟩 global checks | 🌟 geo steering | 🟨 limited scaling | 🟩 analytics | 🟨 feature-based |
| **F5 BIG-IP** | 🟩 enterprise grade | 🌟 comprehensive | 🟩 GTM module | 🟨 complex setup | 🟩 extensive | 🟥 expensive |

**Decision:** Implement hybrid geographic + consistent hashing strategy using AWS ALB for regional load balancing combined with application-level consistent hashing for hotkey distribution. Deploy in 3 regions (US-East, EU-West, Asia-Pacific) with Route53 latency-based routing.

Traffic flow: Route53 (geo) → Regional ALB → Application instances (consistent hashing) → Cache/Database layers.

Supersedes: none.

## Consequences

- ✅ Achieves P-1 latency with geographic proximity routing
- ✅ Addresses RISK-HOTKEY-CONCENTRATION with consistent hashing distribution
- ✅ Provides P-3 fault tolerance with multi-region failover
- ✅ Handles RISK-PEAK-TRAFFIC with regional auto-scaling
- ⚠️ Requires sophisticated monitoring across regions and hash rings
- ⚠️ Cross-region data consistency considerations for cache invalidation
- Follow-ups: ADR on cross-region cache synchronization, regional failover procedures
