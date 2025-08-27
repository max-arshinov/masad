# 5. Design web API layer

Date: 2025-08-27

## Status
Accepted

## Context
Business drivers and quality goals (from docs and prior ADRs): fast redirects (p50 ≤ 0.2s), steady high read volume with simple key lookups, 3-year retention, seamless releases, and resilience to node failures (≤ +0.1s). Click statistics are handled externally. The API has two audiences: (a) end-users/browsers requesting redirects via slug, and (b) authenticated clients creating and managing short URLs. The design must enable edge caching for hot-path reads, enforce uniqueness on writes, support idempotent creation, and remain simple and portable.

Alternatives for API style:

| Alternative                     | Browser friendliness | CDN/HTTP cache leverage | Simplicity & ecosystem | Latency/overhead | Tooling/SDKs | Streaming/binary | Portability |
|---------------------------------|----------------------|--------------------------|------------------------|------------------|--------------|------------------|-------------|
| REST over HTTP/JSON             | ★★★                  | ★★★                      | ★★★                    | ★★               | ★★★          | ★                | ★★★         |
| GraphQL over HTTP               | ★★                   | ★                        | ★★                     | ★★               | ★★           | ★                | ★★          |
| gRPC (including gRPC-Web)       | ★★                   | ★                        | ★★                     | ★★★              | ★★           | ★★★              | ★★          |

Alternatives for redirect status policy:

| Alternative | Browser caching behavior | Changeability of target | CDN behavior/control | SEO compatibility | Client semantics |
|-------------|--------------------------|-------------------------|----------------------|-------------------|------------------|
| 301 (Moved Permanently) | ★★★ Long-lived by clients | ★ Difficult to change | ★★★ Cacheable by default | ★★★ Strong | ★★ Some clients cache aggressively |
| 302 (Found)             | ★★ Controlled via headers | ★★★ Easy to change     | ★★★ Cacheable with Cache-Control | ★★ Adequate | ★★★ Widely supported |
| 307 (Temporary Redirect) | ★★ Controlled via headers | ★★★ Easy to change     | ★★★ Cacheable with Cache-Control | ★★ Adequate | ★★★ Preserves method |

Legend: ★ weak, ★★ medium, ★★★ strong (relative to our needs).

## Decision
Adopt a RESTful HTTP API with two surfaces and edge caching for the public read path:
- Public redirect endpoint: GET /{slug} returns 302 Found by default, with Cache-Control: public, max-age=60, stale-while-revalidate=300 to enable CDN/edge caching while allowing timely destination changes. Support 307 by configuration if preserving method is required for specific clients.
- Authenticated management API: versioned under /api/v1. Key endpoints:
  - POST /api/v1/short-urls to create a short URL. Request includes targetUrl, optional namespace and optional customSlug. Enforce idempotency via Idempotency-Key header (returning the original result on duplicates). On success return 201 Created, Location header to the canonical short URL, and the representation.
  - GET /api/v1/short-urls/{slug} for metadata lookup (non-redirect) and 404 on missing.
  - DELETE /api/v1/short-urls/{slug} for deletion/expiration where allowed by policy.
- Read path caching: cache-aside using a CDN or reverse proxy at the edge; application honors short TTLs and sets explicit cache headers. An internal L1 cache may be used in the app tier for reduced origin latency; the durable source remains the chosen key-value store from ADR 0004.
- Write semantics: uniqueness enforced at the database with conditional insert as per ADR 0004; retry on collision. Apply rate limiting and authentication (e.g., OAuth2/API keys) on management endpoints; the public redirect endpoint is unauthenticated.
- Error model and versioning: consistent JSON error envelope with machine-readable codes; explicit versioning via URL path (/api/v1) for the management API. Do not select a vendor-specific API gateway or CDN at this time.

## Consequences
Positive:
- Simple, widely compatible API that leverages standard HTTP semantics and CDNs for low-latency redirects; easy client adoption and tooling support.
- 302 with explicit cache headers enables edge caching while preserving the ability to change destinations; versioned management API provides stability.
- Idempotency and conditional inserts ensure safe creation under retries and concurrency; rate limiting and auth control abuse.

Negative:
- Redirect caching must be tuned carefully to avoid stale targets; additional invalidation hooks may be needed for instant changes.
- REST/JSON lacks strong typing and schema evolution guarantees compared to gRPC; some advanced features (streaming) are out of scope.
- Operating a CDN/reverse proxy tier and cache coherence adds complexity; misconfiguration can impact latency or correctness.

