# 6. Web tier scaling

Date: 2025-08-27

## Status

Accepted

## Context

[link](./web-tier-scaling-comparison.xml)

Drivers: very high read volume for redirects (~35k rps overall), strict latency (p50 ≤ 0.2s), resilience to node
failures (≤ +0.1s), seamless releases, and cost efficiency. Workload is dominated by short-lived GETs for redirects and
modest authenticated writes for management APIs. Session affinity is not required; the system is designed to be
stateless at the web tier with state in the key-value store (ADR 0004) and caches.

Tactics: horizontal scaling, load balancing, resource isolation, backpressure, graceful degradation, cache utilization,
and zero-downtime deploys.

Alternatives for web tier scaling:

| Alternative                                     | Elasticity | Fault isolation | Latency under load | Ops complexity | Portability/lock‑in | Cost at sustained load | Session/state handling | Rollouts (0‑downtime) |
|-------------------------------------------------|------------|-----------------|--------------------|----------------|---------------------|------------------------|------------------------|-----------------------|
| Stateless horizontal autoscaling behind L7 LB   | 🟩         | 🟩              | 🟩                 | 🟨             | 🟩                  | 🟩                     | 🟩 Externalized        | 🟩                    |
| Horizontal scaling with sticky sessions         | 🟨         | 🟨              | 🟨                 | 🟨             | 🟩                  | 🟨                     | 🟨 Affinity needed     | 🟨                    |
| Serverless/edge functions for web API/redirects | 🟩         | 🟩              | 🟨 (cold starts)   | 🟩             | 🟥                  | 🟨 (variable)          | 🟩 Externalized        | 🟨 (provider-driven)  |
| Vertical scaling on few large instances         | 🟥         | 🟥              | 🟥                 | 🟩             | 🟩                  | 🟥                     | 🟩 Externalized        | 🟨                    |

Legend: 🟥 weak, 🟨 medium, 🟩 strong (relative to our context).

## Decision

Adopt stateless horizontal autoscaling behind a Layer 7 load balancer:

- Stateless containers/pods with no session affinity; all state externalized to the database/cache per ADRs 0003–0005.
- L7 load balancer (reverse proxy/API gateway) with health checks, connection pooling, keep‑alive, and no sticky
  sessions.
- Autoscaling based on CPU and one latency/concurrency signal (e.g., p95 latency or in‑flight requests), with
  conservative cooldowns. Maintain N+2 headroom and ~30% surge capacity for failover.
- Graceful shutdown, readiness/liveness probes, and max in‑flight limits to enable backpressure and prevent overload.
  Apply rate limiting at the edge for management APIs.
- Zero‑downtime deployments via rolling or blue‑green with canaries; configure slow start/warmup to avoid cold spikes.
  No product/vendor is selected in this ADR.

## Consequences

Positive:

- High elasticity and resilience; loss of nodes triggers quick scale‑out with minimal latency impact.
- Consistent low latency under load via connection reuse, backpressure, and avoiding sticky imbalance.
- Simple rollouts and canaries; portable across environments and compatible with CDN/edge caching.

Negative:

- Requires careful autoscaling signals, pool sizing, and health probe tuning to avoid flapping or overload.
- More moving parts than vertical scaling; misconfigured backpressure can cause cascading failures.
- Serverless/edge could reduce ops but introduces lock‑in and cold‑start variability not aligned with latency goals.

