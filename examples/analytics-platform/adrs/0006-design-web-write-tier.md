# 0006. Design web tier for write operations
Date: 2025-08-28

## Status
Accepted

## Context
- Business drivers: capture high-volume client events (web/app SDKs) with low overhead, multi-tenant isolation, and predictable costs while enabling near-real-time analytics.
- Related Quality Attributes (from Quality Tree):
  - S-1 Scalability: Ingestion ~100B events/day (~1.16M/s avg), 3× peak for ≥10 min; 0% loss.
  - P-2 Performance (Freshness): End-to-end freshness P95 ≤60 min, P99 ≤100 min.
  - P-1 Performance (Report latency): Indirectly affected by upstream batching/validation and enqueue latency.
  - R-1 Retention: Indirect (ensure durable handoff to storage tiers via stream).
- Operational constraints: active-active multi-region, autoscaling frontends, per-tenant auth/quotas, backpressure during peaks, zero data loss on accept.

## Decision
Adopt a stateless, horizontally scalable HTTP ingestion API tier that accepts batched events, authenticates and validates requests, applies admission control, and durably enqueues to the streaming backbone.

Architecture and tactics:
- Network & load balancing: Anycast/Geo-DNS to nearest region; L7 load balancer → stateless ingestion pods; health checks and slow-start enabled.
- API surface:
  - POST /v1/events (batch). Body: JSON array or NDJSON; supports Content-Encoding: gzip. Limits: ≤500 events or ≤512 KB per request (first hit wins). Response 202 on durable enqueue, 4xx for client errors, 5xx for transient server errors.
  - Optional endpoints: POST /v1/events:debug (non-durable validation echo, rate-limited), HEAD /health for probes.
- Authentication & multitenancy: per-tenant API keys passed via Authorization: Bearer or X-Api-Key; keys scoped to tenant and environment; rotate without downtime. Basic request signatures optional for high-risk tenants.
- Idempotency & de-duplication: support X-Idempotency-Key per request (TTL 24h) to prevent client retries duplicating batches; per-event event_id encouraged for downstream dedupe; producer uses idempotent writes.
- Validation & enrichment: lightweight schema validation (required fields, size, timestamp sanity); normalize timestamps to ms; attach server-received_at and region; reject PII-in-disallowed-fields policy violations (422) per config.
- Backpressure & admission control: per-tenant and per-IP rate limits; burst tokens sized to 3× normal; queue-depth-based shedding with 429 Retry-After; global kill-switch for heavy tenants; circuit breakers for downstream.
- Durability & enqueue: write to message bus (e.g., Kafka) with acks=all, idempotent producer, retries with exponential backoff, and reasonable timeouts; DLQ on permanent validation failures; 202 only after broker acks.
- Batching & efficiency: encourage client SDK batching (flush interval ~500 ms, max 50–100 events); server-side compression via gzip pass-through; keep request handling <50 ms P95 on healthy path.
- Observability: trace IDs per request; metrics — accepted_eps, 2xx/4xx/5xx rates, enqueue_latency, broker_lag, tenant_quota_utilization; structured logs with tenant_id and request_id.
- Multi-region operation: active-active; consistent hashing by tenant to spread load; regional topics/partitions with async cross-region replication; graceful drain during deploys.
- Security: TLS everywhere; WAF for basic abuse patterns; request size/time limits; PII guardrails; minimal data at edge.

## Consequences
- Positive:
  - Meets S-1 via stateless horizontal scale, per-tenant quotas, and durable enqueue with idempotent producers.
  - Supports P-2 by keeping ingestion latency low and enabling immediate downstream processing; backpressure prevents overload cascades.
  - Clear API contract for SDKs with efficient batching and compression reduces cost and client overhead.
  - Strong isolation and observability simplify operations and incident response.
- Negative / Risks:
  - Increased complexity around multi-region topics and replication requires careful ops and monitoring.
  - Idempotency-key storage adds a small stateful component (cache/DB) with eviction policy.
  - Strict validation can increase 4xx rates for misconfigured clients; needs good SDK ergonomics and docs.

Related ADRs: ADR-0003 (Choose primary analytics database), ADR-0004 (ClickHouse scaling), ADR-0005 (ClickHouse ingestion mechanism).

