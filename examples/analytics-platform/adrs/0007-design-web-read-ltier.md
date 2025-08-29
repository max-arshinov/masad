# 0007. Design web tier for read operations
Date: 2025-08-28

## Status
Accepted

## Context
- Business drivers: deliver interactive dashboards and reports with low latency, predictable costs, and straightforward client integration (browser/app), across multiple tenants.
- Related Quality Attributes (from Quality Tree):
  - P-1 Performance: Report latency P95 ≤1.5s (≤3 months of data); P99 ≤2.5s; timeout rate <0.1%.
  - P-2 Performance: Data freshness P95 ≤60 min; P99 ≤100 min end-to-end.
- Operating constraints: active-active multi-region deployment, CDN/edge presence available, need for cacheability, idempotent reads, pagination/limits, multi-tenant quotas and admission control, and compatibility with ADR-0003/0005 serving stack.

## Comparison

| Tool / Criteria              | P-1 Report latency                                                                 | P-2 Freshness                                                   | Edge cacheability                                                            | Complexity/Operability                                            |
|------------------------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------|------------------------------------------------------------------------------|-------------------------------------------------------------------|
| REST (HTTP GET/POST JSON)    | 🟩 Simple routing; CDN-friendly for GET; easy result caching and retries           | 🟨 Neutral (depends on pipeline); supports conditional requests | 🟩 Strong with GET, ETag/Cache-Control; POST cacheable with query hash       | 🟨 Low–Medium; widely adopted; versioning manageable              |
| GraphQL over HTTP            | 🟨 Flexible selection; resolver overhead; caching harder without persisted queries | 🟨 Neutral; supports live/polling but adds complexity           | 🟥 Weak by default (POST bodies); needs persisted queries/signatures for CDN | 🟨 Medium–High; schema governance and cost instrumentation needed |
| gRPC + HTTP JSON transcoding | 🟨 Low overhead; strong server perf; browser needs transcoding                     | 🟨 Neutral                                                      | 🟨 Possible via GET with transcoding; edge/CDN support varies                | 🟥 High; client/tooling overhead; CDN/cache keys less standard    |

## Decision
Adopt a stateless, horizontally scalable REST read API fronted by CDN/L7 load balancer, with deterministic query hashing and strong cache semantics.

Architecture and tactics:
- Network & delivery: Anycast/Geo-DNS → CDN/edge → L7 LB → stateless read API pods; slow-start and health probes enabled.
- API surface:
  - GET /v1/charts/<chart_id>?params=... for cacheable idempotent reads (prefer GET when URL ≤8 KB).
  - POST /v1/query for complex queries with JSON body; include computed query_hash for cache keying.
  - Responses use JSON; optional CSV export via GET /v1/exports with signed URL; pagination for large result sets.
- Cache strategy:
  - Deterministic canonicalization → query_hash; cache key: tenant_id + scope + query_hash + version.
  - HTTP semantics: ETag (hash), Cache-Control: s-maxage=60, stale-while-revalidate=300; conditional GET (If-None-Match) for 304.
  - CDN enabled for GET; POST caching via edge workers keyed by query_hash where supported; in-app result cache as fallback.
  - Invalidation & versioning policy: include api_version and schema_version in cache key; bump on breaking changes to query plan/rollups (see ADR-0011). Purge by prefix (tenant_id/scope) on schema migrations or rollup changes; perform canary rollout with dual-read (old/new version) and expiration overlap to avoid thundering-herd. Allow clients to force refresh via Cache-Control: no-cache and a bypass flag for troubleshooting.
- Admission control & quotas: per-tenant QPS and concurrent query caps; request budgets and server-side timeouts; 429 with Retry-After on overload.
- Security & multitenancy: TLS; API keys/OAuth scopes for read; enforce tenant scoping; rate limiting per token and per-IP.
- Observability: per-request trace IDs; metrics — p95_latency, p99_latency, error_rate, cache_hit_ratio (edge/app), concurrent_queries, bytes_scanned (from backend), query_queue_depth, cache_purge_count, scanned_bytes_budget_exceeded.
- Freshness and consistency: soft TTLs aligned with P-2 budgets; expose response metadata (generated_at, freshness_age); allow clients to bypass cache with Cache-Control: no-cache when needed.
- Multi-region behavior: regional affinity for tenants; edge routes to nearest healthy region; graceful drain during deploys; retries with idempotent semantics.
- Backend interaction: map API requests to pre-aggregated/parameterized queries against ClickHouse (ADR-0003/0005); enforce limits and guardrails by setting ClickHouse session settings per request (e.g., max_bytes_to_read, max_result_rows, max_execution_time, max_bytes_before_external_group_by) derived from chart shape and tenant plan. Preflight estimate and/or dry-run can reject/reshape requests exceeding budgets with 422 and guidance or reroute to rollups (ADR-0011). Log and surface budget breaches; never disable guardrails on public endpoints.

## Consequences
- Positive:
  - Meets P-1 via CDN/edge caching, conditional requests, deterministic query hashing, strict budgets/timeouts, and explicit invalidation/versioning controls.
  - Compatible with P-2 by using short s-maxage and SWR to balance cost and freshness; clients can force refresh when needed.
  - Low operational overhead and broad client compatibility; clear multi-tenant isolation and quotas.
- Negative / Risks:
  - POST caching requires edge worker/custom configuration; without it, complex queries may miss CDN cache.
  - URL length limits restrict GET usage for very complex queries; requires POST + query_hash path.
  - Cache invalidation on schema/version changes requires disciplined key versioning and purge procedures.

Related ADRs: ADR-0003 (Choose primary analytics database), ADR-0005 (ClickHouse ingestion mechanism), ADR-0006 (Design web layer for write operations), ADR-0010 (Lifecycle & integrity), ADR-0011 (Query materialization strategy), ADR-0012 (Partitioning standards), ADR-0013 (Multi-region replication/failover).
