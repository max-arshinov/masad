# 0008. Choose backend programming language
Date: 2025-08-28

## Status
Accepted

## Context
- Business drivers: high-throughput ingestion and low-latency read APIs for multi-tenant analytics; predictable cost; straightforward operability across multi-region active-active deployments.
- Related Quality Attributes (from Quality Tree):
  - P-1 Performance: Report latency P95 ≤1.5s for ≤3 months of data; P99 ≤2.5s; timeout rate <0.1%.
  - P-2 Performance: End-to-end freshness P95 ≤60 min; P99 ≤100 min.
  - S-1 Scalability: Ingestion ~100B events/day (~1.16M/s avg) with 3× peaks for ≥10 min; 0% loss.
- Constraints and considerations: containerized deployment (Kubernetes), autoscaling, strong observability, durable enqueue to stream (ADR-0005), ClickHouse-serving path (ADR-0003/0004), stateless web tiers (ADR-0006/0007).

## Comparison

| Tool / Criteria    | P-1 Report latency                                             | S-1 Ingestion throughput                                        | P-2 Freshness                | Operability/Cost                                      |
|--------------------|----------------------------------------------------------------|-----------------------------------------------------------------|------------------------------|-------------------------------------------------------|
| Go                 | 🟩 Low tail latency; efficient net/http; good pprof tooling    | 🟩 High concurrency via goroutines; mature Kafka/HTTP clients   | 🟨 Neutral (pipeline-driven) | 🟩 Static binaries; low mem/CPU; simple ops           |
| Java/Kotlin        | 🟩 Strong throughput; mature libs; GC tuning needed for tails  | 🟩 Proven at very high ingest with Kafka                        | 🟨 Neutral                   | 🟨 Heavier runtime; GC/flags complexity               |
| Node.js/TypeScript | 🟨 Good for IO-bound; single-threaded event loop affects tails | 🟨 High QPS possible; CPU-bound work limited                    | 🟨 Neutral                   | 🟨 Easy dev; higher mem; worker mgmt needed           |
| Rust               | 🌟 Excellent latency; zero-cost abstractions                   | 🌟 Excellent throughput; low overhead                           | 🟨 Neutral                   | 🟨 Smaller ecosystem; steeper learning; longer builds |
| Python             | 🟥 Higher latency; GIL; needs native ext for speed             | 🟥 Not ideal for sustained multi-M eps without heavy native use | 🟨 Neutral                   | 🟩 Fast iteration; but higher runtime cost for scale  |

## Decision
Adopt Go as the primary language for backend services (ingestion APIs, read APIs, and supporting workers).

Architectural tactics and guidelines:
- Concurrency and latency: structured concurrency with context timeouts; bounded worker pools; careful allocation to minimize GC pressure; pprof-driven tuning.
- Networking: standard net/http with HTTP/2; keep-alives; gzip; optionally gRPC for internal hops; connection pooling to ClickHouse and Kafka brokers.
- Messaging and storage: idempotent Kafka producers/consumers (acks=all) for ingest (ADR-0005); ClickHouse Go driver for reads/writes aligned with partitioning tactics (ADR-0003/0004).
- Resilience and control: admission control, per-tenant quotas, and deadlines consistent with ADR-0006/0007; metrics/tracing via OpenTelemetry exporters.
- Packaging and ops: static binaries; small container images; readiness/liveness; autoscaling on CPU and queue depth; minimal memory footprint.

## Consequences
- Positive:
  - Meets S-1 with efficient concurrency and mature Kafka/HTTP clients; predictable resource use per pod.
  - Supports P-1 with low tail latency and fine-grained timeouts/backpressure in handlers.
  - Simple runtime and static binaries reduce ops overhead and cost; good profiling/observability.
- Negative / Risks:
  - GC tuning and allocation patterns need care to avoid P99 regressions.
  - Ecosystem for some specialized analytics libs is smaller vs JVM; may require FFI or separate components.

Related ADRs: ADR-0003 (Choose primary analytics database), ADR-0004 (ClickHouse scaling), ADR-0005 (ClickHouse ingestion mechanism), ADR-0006 (Web write layer), ADR-0007 (Web read layer).

