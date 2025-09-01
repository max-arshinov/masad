# 6. Define Auto-scaling Policies and Thresholds

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 1 goal: Address high-risk performance and scalability concerns. Growth projections show read RPS growing from 11.5K (year 1) to 139K (year 5), with 3x peak traffic spikes reaching 417K RPS. System must maintain P-1 latency during traffic surges while managing costs efficiently.

Business drivers: Handle unpredictable traffic patterns, maintain service quality during peak loads, optimize operational costs.

Relevant QAs (IDs): P-1 (redirect latency <0.2s), P-3 (<0.1s degradation with failures), A-1 (99.9% uptime), S-3 (10 requests/link/day).

## Decision

### Table 1 — Compare Auto-scaling Approaches

| Scaling Approach | Response Time | Accuracy | Cost Efficiency | Complexity | Overshoot Risk | Undershoot Risk |
|------------------|---------------|----------|-----------------|------------|----------------|-----------------|
| **Reactive (CPU/Memory)** | 🟨 3-5 min delay | 🟨 lagging indicator | 🟩 resource-based | 🟩 simple | 🟨 moderate | 🟥 high during spikes |
| **Predictive (ML-based)** | 🟩 proactive | 🟨 depends on patterns | 🟨 may over-provision | 🟥 complex models | 🟨 pattern changes | 🟩 anticipates load |
| **Application Metrics (RPS)** | 🟩 traffic-responsive | 🟩 direct correlation | 🟩 load-proportional | 🟨 custom metrics | 🟩 low | 🟨 burst handling |
| **Queue Depth Based** | 🟩 backpressure-aware | 🟩 processing capacity | 🟩 workload-aligned | 🟨 requires queuing | 🟩 low | 🟩 low |
| **Hybrid (Multi-metric)** | 🌟 fastest response | 🌟 comprehensive view | 🟨 balanced approach | 🟥 complex logic | 🟩 weighted decisions | 🟩 multiple signals |

**Shortlist:** Application Metrics (RPS) and Hybrid approaches best address P-1 requirements and traffic spike handling.

### Table 2 — Compare Auto-scaling Platforms

| Platform | Scaling Speed | Metric Support | Geographic Scaling | Integration | Cost Model | Monitoring |
|----------|---------------|----------------|-------------------|-------------|------------|------------|
| **AWS Auto Scaling** | 🟩 1-3 min warmup | 🟩 CloudWatch + custom | 🟩 multi-region ASGs | 🌟 native AWS | 🟩 instance-based | 🟩 CloudWatch |
| **Kubernetes HPA/VPA** | 🟩 pod-level scaling | 🟩 custom metrics API | 🟨 cluster federation | 🟩 cloud-agnostic | 🟨 cluster overhead | 🟩 Prometheus |
| **Google Cloud Autoscaler** | 🟩 managed scaling | 🟩 Stackdriver metrics | 🟩 regional MIGs | 🟩 GCP native | 🟩 usage-based | 🟩 Stackdriver |
| **Azure VMSS** | 🟨 slower warmup | 🟨 Azure Monitor | 🟨 availability zones | 🟨 Azure ecosystem | 🟨 VM-based | 🟨 Azure Monitor |

**Decision:** Implement hybrid auto-scaling using AWS Auto Scaling Groups with multi-metric policies:

Primary metrics:
- RPS per instance (target: 5,000 RPS, scale-out threshold: 4,000 RPS)
- Average response time (target: <150ms, scale-out threshold: >180ms)
- CPU utilization (scale-out threshold: >70%, scale-in threshold: <30%)

Scaling policies:
- Scale-out: Add 50% capacity when any threshold breached
- Scale-in: Remove 25% capacity when all metrics below targets for 10 minutes
- Regional scaling: Deploy across 3 AZs with minimum 2 instances per AZ
- Cross-region: Route53 health checks trigger regional failover

Supersedes: none.

## Consequences

- ✅ Maintains P-1 latency during traffic spikes with proactive RPS-based scaling
- ✅ Addresses RISK-PEAK-TRAFFIC with 50% capacity scaling and multi-region deployment
- ✅ Provides P-3 fault tolerance with multi-AZ and cross-region redundancy
- ✅ Supports projected 417K peak RPS with horizontal scaling across regions
- ⚠️ Requires careful tuning of scale-in policies to avoid thrashing
- ⚠️ Cold start latency impact during rapid scale-out events
- Follow-ups: ADR on instance warming strategies, cost optimization policies, monitoring dashboards
