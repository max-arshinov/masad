# 7. Choose observability tools

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- End-to-end visibility across Web API, ingestion (Kafka), and ClickHouse with SLOs and rapid incident response.
- Handle very high throughput (up to ~100B/day events) with cost-efficient, scalable metrics, logs, and traces.
- Strong Kubernetes integration, Go SDK support, and portability with minimal vendor lock-in (ADR-0005).
- Security and privacy controls (PII minimization, redaction), multi-tenant scoping, and long-term retention options.

Architectural tactics influencing the choice:
- Standardize on OpenTelemetry for instrumentation; sample traces and limit log cardinality.
- Use pull-based metrics (Prometheus) with remote write for long-term/HA; alerting via SLO/error budgets.
- Cost control: structured JSON logs with levels and sampling; object-storage-backed log store; exemplars linking metrics↔traces.
- Single-pane dashboards for metrics/logs/traces; Infrastructure as Code for consistent environments.

Comparison of alternatives (higher is better):

| Stack / Criteria                                                                 | Metrics scale & HA | Logs cost & retention          | Tracing & sampling            | K8s & Go/CH/Kafka integration | Dashboards, SLOs & alerting  | Ops complexity               | Cost & lock-in           | Portability/open |
|----------------------------------------------------------------------------------|--------------------|-------------------------------|-------------------------------|-------------------------------|-------------------------------|------------------------------|--------------------------|------------------|
| Grafana OSS: Prometheus(+ Alertmanager) + Loki + Tempo + Grafana (+ Mimir/Thanos)| ★★★ Pull + remote  | ★★★ Object store via Loki     | ★★★ OTel -> Tempo + Grafana  | ★★★ Helm/OTel SDKs, exporters | ★★★ Grafana + SLO plugins     | ★★ Moderate (self-manage)   | ★★ Infra cost, low lock-in | ★★★ Open         |
| Grafana Cloud (managed Prom, Loki, Tempo, Grafana)                               | ★★★ Managed HA     | ★★★ Managed tiers             | ★★★ Managed, easy             | ★★★ Agents/OTel collectors    | ★★★ Built-in SLOs            | ★★★ Low (managed)           | ★ Lock-in, usage-based    | ★★ Portable       |
| Datadog (APM + Logs + Metrics)                                                   | ★★★ Scales well    | ★★ Costly at high volume      | ★★★ Excellent APM             | ★★★ Agents, K8s, OTel ingest  | ★★★ Strong                   | ★★★ Very low                 | ★ Lock-in, higher cost     | ★ Proprietary     |
| ELK/OpenSearch + Jaeger + Prometheus + Grafana                                   | ★★★ Metrics solid  | ★★ ES storage cost/ops        | ★★ Jaeger ops, good features  | ★★ More components to glue    | ★★ Good, more wiring         | ★ High (operate ES)         | ★★ Infra cost, low lock-in | ★★★ Open         |
| Cloud-native (e.g., AWS: CloudWatch + OpenSearch + X-Ray + AMP/AG)               | ★★ Varies          | ★★ OpenSearch cost/limits     | ★★ X-Ray features             | ★★★ Cloud integrations        | ★★ Good                      | ★★ Low-medium (managed)     | ★ Lock-in                 | ★★ Portable       |

Notes:
- Grafana OSS stack provides an integrated, portable solution with good cost controls: Prometheus (HA via remote write and Thanos/Mimir), Loki with object storage for logs, and Tempo for traces; Grafana unifies views and SLOs. OpenTelemetry enables consistent instrumentation.
- Managed offerings reduce ops but increase lock-in and variable costs at this scale; ELK/OpenSearch is powerful but expensive to operate at large log volumes.

## Decision

Adopt the Grafana open-source stack with OpenTelemetry:
- Instrument services with OpenTelemetry (SDKs and Collector). Export metrics to Prometheus; traces to Tempo; logs to Loki (via Collector or fluent-bit). Enable exemplars to link metrics to traces.
- Run Prometheus for scraping and Alertmanager for alerting; use Mimir or Thanos for HA/long-term metrics retention. Use Loki with object-store backend (e.g., S3) for cost-efficient logs. Use Tempo for traces with tail-based sampling in the Collector.
- Use Grafana as the unified UI for dashboards, logs, and traces, and to define SLOs, alerts, and runbooks.

## Consequences

Positive:
- Portable, cost-efficient observability with a cohesive UI and OTel-native instrumentation; good K8s and Go ecosystem support.
- Scales via object-storage-backed Loki/Tempo and remote-written metrics with Mimir/Thanos; supports SLOs and incident response.
- Minimizes vendor lock-in while allowing optional managed upgrades (Grafana Cloud) if needed per environment.

Negative / risks:
- Operating the stack requires capacity planning, storage tuning, and maintenance (indexing, compaction, retention).
- Log volumes at this scale can be costly; requires strict sampling, redaction, and routing policies.
- Additional components (OTel Collector, Mimir/Thanos) increase complexity; needs IaC, dashboards-as-code, and runbooks.

