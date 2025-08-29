# 0009. Scale web tier with concurrency-based autoscaling and active-active regions
Date: 2025-08-29

## Status
Accepted

## Context
- Business drivers: globally serve high-throughput writes (ingestion) and low-latency reads with predictable cost and smooth bursts while keeping the platform simple to operate.
- Related Quality Attributes (from Quality Tree):
  - S-1 Scalability: Sustain ~100B events/day (~1.16M/s avg) with 3× peaks for ≥10 min; 0% loss.
  - P-1 Performance: Read P95 ≤1.5s (≤3 months of data); P99 ≤2.5s; timeout rate <0.1%.
  - P-2 Performance: End-to-end freshness P95 ≤60 min; P99 ≤100 min (ingest path must not become the bottleneck).
- Constraints: containerized on Kubernetes; stateless web tiers (ADR-0006/0007); active-active multi-region; CDN in front of read API; Anycast/Geo-DNS in front of both; cost-efficient autoscaling with guardrails.

## Comparison

| Option / Criteria                          | S-1 Scalability                                                     | P-1 Performance (tails)                                             | Operability/Cost                                                |
|--------------------------------------------|---------------------------------------------------------------------|---------------------------------------------------------------------|-----------------------------------------------------------------|
| CPU-only HPA (utilization-based)           | 🟨 Scales under CPU-heavy load; slow/insensitive to IO-bound bursts | 🟥 Tail latency can spike on sudden traffic mix changes             | 🟩 Simple; no custom metrics                                    |
| Concurrency/RPS-based HPA (custom metrics) | 🟩 Scales on in-flight/req rate; aligns capacity to load quickly    | 🟩 Controls tails by keeping per-pod concurrency bounded            | 🟨 Needs metrics pipe, tuning, and careful SLO-based thresholds |
| Serverless (Cloud Run/Knative)             | 🟩 High elasticity; scale-to-zero                                   | 🟨 Cold starts and scaling lag can hurt tails; per-request overhead | 🟥 Platform coupling; cost variance; regional limits            |

## Decision
Adopt concurrency/RPS-based autoscaling for the web tier on Kubernetes, in active-active multi-region deployment.

Architecture and tactics:
- Autoscaling policy:
  - Horizontal Pod Autoscaler targets bounded in-flight requests per pod (or RPS per pod) with a secondary CPU target; use custom metrics from ingress/L7 (e.g., Envoy/NGINX/OpenTelemetry) exposed via metrics adapter.
  - Configure per-service SLO-aligned targets: ingestion API aims for low in-flight (e.g., 50–150) to keep handler time <50 ms P95; read API targets request concurrency that preserves P95 ≤1.5 s.
  - Min replicas per region and per AZ (PodDisruptionBudget + TopologySpreadConstraints) to avoid cold starts; slow-start and max-surge on rollouts.
- Multi-region scaling and routing:
  - Active-active with Anycast/Geo-DNS and CDN (reads) distributing to nearest healthy region; no sticky sessions required; stateless handlers.
  - Regional autoscaling independent, with cross-region failover at edge; maintain headroom ≥2× region share during normal ops (see ADR-0002 baselines).
- Admission control and backpressure:
  - Enforce per-tenant QPS/concurrency limits and 429 Retry-After when saturation triggers; protect downstream via circuit breakers and timeouts (ADR-0006/0007).
- Capacity guardrails:
  - Set request/limit resources to avoid CPU throttling; configure cluster autoscaler to scale nodes fast enough to meet burst budgets; scheduled pre-warm during known peaks.
- Observability and control:
  - Track p95/p99 latency, error rate, in_flight_requests, queue depth at LB, and autoscaling events; SLOs drive tuning. Use canary rollouts with traffic shadowing for policy changes.

## Consequences
- Positive:
  - Aligns capacity to real load, improving S-1 while keeping P-1 tails controlled under bursts.
  - Stateless active-active design preserves P-2 freshness by preventing ingest backlog at the edge.
  - Clear guardrails and metrics reduce operational toil; independent regional scaling improves resilience.
- Negative / Risks:
  - Custom metrics and HPA tuning add complexity; risk of scaling oscillations without proper dampening.
  - Higher baseline cost due to minimum replicas per region/AZ to avoid cold starts.

Related ADRs: ADR-0002 (Baseline capacity and BOTE), ADR-0006 (Design web layer for write operations), ADR-0007 (Design web layer for read operations), ADR-0008 (Choose backend programming language), ADR-0003/0004/0005 (Serving and ingestion stack).

