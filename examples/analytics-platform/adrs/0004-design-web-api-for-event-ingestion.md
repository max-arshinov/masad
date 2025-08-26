# 4. Design Web API for event ingestion

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Browser-first ingestion with minimal page overhead and broad compatibility (modern + legacy).
- Scale to ~100B events/day with backpressure tolerance and replay via Kafka (see ADR-0003).
- Privacy and compliance (consent, no sensitive PII by default), multi-tenant isolation, abuse controls.
- Operational simplicity, good observability, and debuggability for SDK and customers.

Architectural tactics influencing the choice:
- Batch-oriented HTTP ingestion with compression; accept-and-buffer pattern (202 Accepted) to decouple edge from storage.
- Idempotency and at-least-once semantics using event_id and optional X-Idempotency-Key.
- SDK-friendly CORS policy, Beacon API support, and graceful fallbacks to fetch/XHR; CDN edge termination.
- Authentication via tenant-scoped API keys; schema validation; payload size limits and rate limiting.

Comparison of alternatives (higher is better):

| API / Criteria                                   | Browser compatibility         | Payload efficiency            | Batching support            | Delivery behavior (page unload) | CDN/Edge friendliness        | Observability & debug         | SDK complexity              | Cost & lock-in          | Portability/open |
|--------------------------------------------------|-------------------------------|-------------------------------|-----------------------------|----------------------------------|-------------------------------|-------------------------------|-----------------------------|--------------------------|------------------|
| REST/HTTP POST JSON (Beacon + fetch fallback)    | ★★★ Works everywhere           | ★★ With gzip/br               | ★★★ Natural array batches    | ★★★ Beacon sends on unload       | ★★★ Excellent                 | ★★★ Easy to inspect           | ★★★ Simple                  | ★★★ Low lock-in          | ★★★ Open          |
| REST/HTTP POST Protobuf (binary)                 | ★★ Needs custom SDK           | ★★★ Smaller, faster           | ★★★ Natural array batches    | ★★ Beacon support varies         | ★★★ Excellent                 | ★★ Harder to inspect          | ★★ Moderate                 | ★★★ Low lock-in          | ★★★ Open          |
| gRPC-Web                                         | ★ Requires proxies            | ★★★ Efficient                 | ★★ Streaming limited         | ★ Page unload unreliable         | ★★ Proxy needed               | ★★ Tooling okay               | ★ Requires gRPC stack       | ★★ Some infra              | ★★ Portable       |
| Pixel GET (image beacon with query params)       | ★★ Simple, widely supported   | ★ Limited URL size            | ★ Poor                      | ★★★ Works on unload              | ★★★ Excellent                 | ★★ Hard to debug payloads     | ★★★ Very simple             | ★★★ Low lock-in          | ★★★ Open          |
| WebSocket streaming                              | ★ Requires long-lived socket  | ★★★ Efficient                 | ★★★ Continuous               | ★ Breaks on unload               | ★★ Harder at CDN edge         | ★★ OK                        | ★ Requires complex client   | ★★ Infra cost             | ★★ Portable       |

Notes:
- JSON over HTTP is the most compatible for browsers and easiest to debug/support. Compression mitigates size overhead. Beacon API improves reliability on page unloads; fall back to fetch/XHR.
- A Protobuf variant is useful for server-to-server and mobile SDKs but increases debugging friction for web clients.

## Decision

Adopt a RESTful HTTP ingestion API with JSON batch payloads as the primary Web API. Support POST /v1/events with Content-Type: application/json and Content-Encoding: gzip or br. The API accepts an array of events, enforces size and rate limits, validates against a versioned schema, and returns 202 Accepted with a request_id. Authentication uses a tenant-scoped API key (via Authorization: Bearer or X-API-Key). Use Beacon API when available; SDKs fall back to fetch/XHR. Include headers for X-Idempotency-Key and X-SDK-Meta for diagnostics. The service buffers to Kafka as per ADR-0003. Provide an opt-in Protobuf endpoint (/v1/events.pb, Content-Type: application/x-protobuf) for high-throughput non-browser clients.

Outline (non-normative):
- Endpoint: POST /v1/events
- Headers: Authorization or X-API-Key; Content-Encoding: gzip|br (optional); X-Idempotency-Key (optional); X-SDK-Meta
- Body (JSON): { "tenant_id": "t_...", "batch": [ { "event_id": "uuid", "ts": "RFC3339 or epoch_ms", "type": "page_view|click|...", "user": { "anon_id": "..." }, "context": { "url": "...", "ua": "..." }, "props": { ... }, "v": 1 } ... ] }
- Response: 202 Accepted { "request_id": "..." }
- Limits: max 500 events/batch, 1 MB compressed; strict schema; reject unknown top-level fields

## Consequences

Positive:
- Broad browser compatibility, simple SDKs, easy debugging for customers and support.
- Efficient at scale via batching, compression, and 202 buffering to Kafka; aligns with ADR-0003.
- Clear path to stronger efficiency for non-browser clients via optional Protobuf variant.

Negative / risks:
- JSON payloads are larger than binary; mitigated by compression and batching.
- Beacon API support varies; must implement robust fallbacks and retries.
- Public API requires strong abuse protection (rate limiting, schema limits, auth hardening).

