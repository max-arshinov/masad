# 0013. Multi-region replication and failover posture (stream + ClickHouse)
Date: 2025-08-29

## Status
Proposed

## Context
- Business drivers: globally available ingestion and low-latency analytics with resilience to a full regional outage, bounded data loss (RPO), and fast service restoration (RTO).
- Related Quality Attributes (from Quality Tree):
  - S-1 Scalability: sustain ingestion under regional failures and bursts; avoid data loss.
  - P-2 Performance (Freshness): preserve end-to-end freshness budgets during and after failover.
  - R-1 Retention: ensure durable storage and recoverability of long-term data.
- Risks addressed (Section 11): RISK-REGION-FAILOVER, RISK-INGEST-PEAK, RISK-QUERY-LATENCY (tails during failover), RISK-DATA-INTEGRITY.
- Assumptions/constraints: ADR-0006/0007/0009 define active-active web tiers and traffic routing; ADR-0005 defines ingest pipeline; ADR-0003 selects ClickHouse; object storage provides cross-region durability; inter-region latency is non-trivial; synchronous cross-region writes on hot path are undesirable for P-1/S-1.

## Comparison

Topologies
| Option / Criteria | S-1 (throughput) | P-2 Freshness during failover | RPO/RTO | Complexity/Cost |
|-------------------|------------------|-------------------------------|---------|-----------------|
| A) Active-active per region; async cross-region replication (stream) + CH backups/rehydration | 🟩 Local writes/reads scale; no cross-region sync on hot path | 🟨 Short staleness during failover; fast catch-up via replay | RPO minutes; RTO minutes | 🟨 Moderate ops (replication + drills) |
| B) Active-passive (single primary region) with sync DR | 🟥 Primary bottleneck; cross-region sync on writes | 🟨 Freshness OK on failover; steady-state latency ↑ | RPO≈0; RTO minutes | 🟥 Higher latency/cost; single hot region risk |
| C) Active-active with synchronous cross-region quorum (2PC/raft) | 🟥 Cross-region latency kills tails; throughput drops | 🟩 Consistent; no freshness gap | RPO≈0; RTO minutes | 🟥 Very high complexity/cost |

Stream replication mechanisms
| Mechanism | Integrity | Freshness | Ops |
|-----------|----------|-----------|-----|
| 1) Kafka Cluster Linking / MirrorMaker 2 (async) | 🟨 At-least-once; offset semantics manageable | 🟩 Minutes | 🟨 Standard tooling, monitoring needed |
| 2) Dual-write from API to two regions | 🟨 Higher dup risk; client complexity | 🟩 Seconds–minutes | 🟥 Error-prone; harder ops |
| 3) Vendor geo-replication (managed) | 🟩 Strong; depends on provider | 🟩 Minutes | 🟩 Simplified, but lock-in |

ClickHouse cross-region data posture
| Approach | Hot-path latency | Recovery | Ops |
|----------|-------------------|----------|-----|
| i) Region-local CH clusters; periodic snapshots + object-store shipping; rebuild via replay | 🟩 Local | 🟨 Minutes–hours for full rebuild; partial selective restores | 🟨 Backups, manifests, drills |
| ii) Cross-region synchronous replica (compute+storage) | 🟥 Cross-region commit latency | 🟩 Fast | 🟥 Complex/expensive |
| iii) Warm/cold on multi-region object storage; hydrate on demand | 🟩 Local hot | 🟨 Selective restore ≤24h | 🟨 Lifecycle + restore tooling |

## Decision
Adopt Active-active per region with asynchronous cross-region replication on the stream, region-local ClickHouse clusters for hot data, and multi-region object storage for warm/cold. Define clear SLOs and drills.

Targets
- RPO: ≤5 minutes for accepted events during regional failure (no permanent loss; duplicates allowed).
- RTO: ≤5 minutes for ingestion (clients fail over to healthy region); ≤10 minutes for read API; ≤24 hours for selective restore of warm/cold data.

Architectural tactics (mapped to QAs)
- Traffic & routing (S-1, P-2): Anycast/Geo-DNS + CDN (ADR-0006/0007/0009). Health-based regional failover; idempotent writes with keys to tolerate retries.
- Stream replication (S-1, P-2):
  - Use Kafka Cluster Linking or MirrorMaker 2 to asynchronously replicate critical topics (ingest, DLQ, control) between regions with per-tenant/topic ACLs.
  - Preserve ordering per partition; size partitions to absorb 3× peaks; monitor cross-region lag; checksum on replication.
  - Consumers restart from replicated topics on failover with idempotent sinks; reconcile offsets by timestamp/lag.
- ClickHouse posture (P-2, R-1):
  - Keep hot data region-local (ADR-0003/0012). No synchronous cross-region replication on hot path.
  - Periodic snapshots of hot partitions to object storage with manifests (see ADR-0010) and scheduled shipping to other regions.
  - On failover, rehydrate recent ranges from replicated stream or attach from snapshot/object store; accept temporary freshness gap within RPO.
- Control plane & config (S-1): replicate critical metadata (schemas, partition maps) via GitOps/CI to all regions; avoid single-region dependencies.
- Drills & observability (S-1, P-2, R-1): quarterly regional failover drills; dashboards for cross-region lag, RPO breach alerts, failover RTO timers; runbooks for cutover and rollback.
- Cost & guardrails: limit cross-region egress (compress replication, filter non-critical topics); quota cross-region traffic; test failback to restore original topology.

## Consequences
- Positive:
  - Preserves P-2 freshness and S-1 throughput in steady state by avoiding cross-region sync on hot path; bounded RPO with async replication and replay.
  - Clear RPO/RTO targets with drills and observability reduce mean-time-to-recover and operational risk.
  - Uses object storage for durable multi-region retention, aligning with R-1.
- Negative / Risks:
  - During failover, recent analytics may be stale until replay completes; read tails may increase.
  - Asynchronous replication implies non-zero RPO; requires strong idempotency and dedup semantics.
  - Additional replication infra increases cost/ops overhead; needs careful monitoring.

Related ADRs: ADR-0002 (Baselines), ADR-0003 (ClickHouse), ADR-0005 (Ingestion), ADR-0006 (Web write), ADR-0007 (Web read), ADR-0009 (Autoscaling), ADR-0010 (Lifecycle & integrity), ADR-0011 (Materializations), ADR-0012 (Partitioning).

