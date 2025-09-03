# 8. Design Auto-Scaling Policies

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design auto-scaling policies for MSK ingestion pipeline to handle 3x traffic spikes (up to 3.47M events/sec peak) while maintaining cost efficiency during normal operations at 1.16M events/sec sustained load.

Business drivers: Analytics platform experiences unpredictable traffic patterns from website events with daily and seasonal variations. Auto-scaling must prevent data loss during spikes while optimizing infrastructure costs.

Relevant QAs (IDs): P-2 Performance (High event ingestion throughput), S-1 Scalability (Event volume growth), R-1 Reliability (Data durability), A-2 Availability (System uptime).

## Decision

### Compare **Scaling Triggers**

| Trigger Metric        | Responsiveness     | False Positives   | Implementation      | Cost Impact          | Reliability          |
|-----------------------|--------------------|-------------------|---------------------|----------------------|----------------------| 
| **CPU Utilization**   | 🟨 moderate lag    | 🟨 variable loads | 🟩 simple           | 🟩 cost-aware        | 🟨 indirect metric   |
| **Queue Depth**       | 🟩 fast response   | 🟩 low false pos  | 🟩 simple           | 🟨 reactive only     | 🟩 direct backlog    |
| **Consumer Lag**      | 🟩 real-time aware | 🟩 accurate       | 🟨 complex calc     | 🟩 performance-based | 🌟 processing health |
| **Ingestion Rate**    | 🌟 proactive       | 🟨 burst handling | 🟨 rate calculation | 🟨 predictive cost   | 🟩 load-based        |
| **Composite Metrics** | 🟩 balanced        | 🟩 robust         | 🟥 complex logic    | 🟩 optimized         | 🌟 multi-dimensional |

### Compare **Scaling Components**

| Component             | Scale Unit           | Scale Speed         | Cost Efficiency    | Complexity         | Impact Radius      |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------| 
| **MSK Brokers**       | 🟨 instance-based   | 🟥 slow (minutes)  | 🟨 fixed capacity  | 🟩 managed        | 🟩 cluster-wide    |
| **Producer Instances**| 🟩 container/pod    | 🟩 fast (seconds)  | 🟩 granular       | 🟨 orchestration   | 🟨 write throughput|
| **Consumer Groups**   | 🟩 consumer threads | 🌟 instant         | 🟩 fine-grained   | 🟨 partition limits| 🟨 processing speed|
| **Buffer Storage**    | 🟩 disk/memory      | 🟩 fast            | 🟩 elastic        | 🟩 simple         | 🟨 temporary relief|

**Decision:** Implement **multi-tier auto-scaling** with composite triggers:

**Tier 1 - Fast Response (seconds):**
- Scale producer instances and consumer threads based on ingestion rate >1M events/sec
- Scale consumer lag >30 seconds triggers immediate consumer scaling

**Tier 2 - Medium Response (minutes):**
- MSK broker scaling when CPU >70% sustained for 5 minutes
- Queue depth >100K messages triggers broker capacity increase

**Tier 3 - Proactive Scaling:**
- Historical pattern-based scaling for known traffic peaks
- Pre-scale during expected high-traffic periods (holidays, campaigns)

Supersedes: none.

## Consequences

- ✅ Fast response to traffic spikes prevents data loss and maintains throughput (P-2, R-1).
- ✅ Multi-tier approach optimizes both performance and cost efficiency (A-2, S-1).
- ✅ Proactive scaling reduces impact of predictable traffic patterns.
- ✅ Granular consumer scaling maximizes processing parallelism within partition limits.
- ✅ Composite triggers reduce false positives and scaling thrashing.
- ⚠️ Complex scaling logic requires comprehensive monitoring and alerting.
- ⚠️ MSK broker scaling lag may require over-provisioning for extreme spikes.
- Follow-ups: Implement CloudWatch dashboards, scaling automation scripts, cost monitoring alerts, and runbooks for manual intervention scenarios.
