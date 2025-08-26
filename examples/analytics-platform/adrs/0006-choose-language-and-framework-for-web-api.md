# 6. Choose language and framework for web API

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Browser-first ingestion API (ADR-0004) with batching, compression, CORS, and Beacon support.
- Scale to ~100B events/day with low tail latency and 202 accept-and-buffer to Kafka (ADR-0003).
- Strong observability, rate limiting, auth, and schema validation; predictable cost and simple operations (ADR-0005).
- Portability and minimal lock-in; efficient resource usage to reduce TCO.

Architectural tactics influencing the choice:
- Event-loop or lightweight concurrency for high-throughput I/O-bound workloads.
- Efficient JSON handling and streaming decompression; structured logging and metrics tracing.
- Mature Kafka producer library for backpressure, batching, retries, and delivery guarantees.
- Small container footprint, fast startup, and easy horizontal scaling on Kubernetes.

Comparison of alternatives (higher is better):

| Stack / Criteria                                          | Throughput & tail latency | Memory efficiency & footprint | Async I/O & backpressure | Kafka client maturity/perf | Dev productivity & DX | Observability & tooling | Container/runtime & startup | HTTP features (JSON, CORS, compression) | Portability & lock-in |
|-----------------------------------------------------------|---------------------------|-------------------------------|---------------------------|-----------------------------|-----------------------|-------------------------|-----------------------------|------------------------------------------|----------------------|
| Go + net/http + chi                                       | ★★★                       | ★★★                           | ★★★                       | ★★★ (librdkafka/kafka-go)  | ★★                    | ★★★                    | ★★★                        | ★★★                                     | ★★★                 |
| Node.js (TypeScript) + Fastify                            | ★★                        | ★★                            | ★★★                       | ★★ (node-rdkafka)          | ★★★                   | ★★                      | ★★                         | ★★★                                     | ★★                  |
| Java/Kotlin + Spring Boot (Netty/Tomcat)                  | ★★★                       | ★★                            | ★★★                       | ★★★ (official clients)     | ★★                    | ★★★                    | ★★                         | ★★★                                     | ★★                  |
| Rust + Axum/Actix Web                                     | ★★★                       | ★★★                           | ★★★                       | ★★ (rdkafka crate)         | ★                      | ★★                      | ★★★                        | ★★                                      | ★★★                 |
| .NET 8 + ASP.NET Core                                     | ★★★                       | ★★                            | ★★★                       | ★★ (Confluent.Kafka)       | ★★                    | ★★★                    | ★★                         | ★★★                                     | ★★                  |
| Python + FastAPI (uvicorn/gunicorn)                       | ★                         | ★★                            | ★★                        | ★★                          | ★★★                   | ★★                      | ★★                         | ★★                                      | ★★★                 |

Notes:
- Go offers strong throughput, small memory footprint, and simple deployment (static binaries). Kafka clients are mature; either confluent-kafka-go (librdkafka) or kafka-go can be used.
- Node.js and Python are productive but require more CPU/memory at this scale; Java/.NET perform well but have heavier memory/runtime footprints; Rust excels in efficiency but has slower iteration speed.

## Decision

Adopt Go with the standard net/http stack and the chi router for the Web API service. Use structured logging and OpenTelemetry instrumentation, enable gzip/br decoding and response compression, and implement strict request limits and schema validation. Produce to Kafka using the confluent-kafka-go client (librdkafka) for high-throughput, batched, at-least-once delivery with retries and backpressure. Package as a small static container image and run behind the CDN/API gateway on Kubernetes with horizontal autoscaling.

## Consequences

Positive:
- High throughput and low tail latency with efficient memory usage; simple, portable deployments (static binary, small containers).
- Mature HTTP ecosystem with middlewares for CORS, rate limiting, compression, and observability; strong tracing/metrics support.
- Proven Kafka client with robust batching and delivery controls aligns with ADR-0003; scales horizontally on Kubernetes per ADR-0005.

Negative / risks:
- Go JSON handling can be verbose; careful validation needed to avoid GC pressure; mitigated with pooling and streaming where appropriate.
- Some libraries (e.g., chi middlewares, kafka clients) require disciplined configuration for optimal throughput and backpressure.
- Developer familiarity with Go may be lower than Node/Python in some teams; training or guidelines may be required.

