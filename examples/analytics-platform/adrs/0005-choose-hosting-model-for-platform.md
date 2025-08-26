# 5. Choose hosting model for platform

Date: 2025-08-26

## Status

Accepted

## Context

Business drivers and quality attributes:
- Scale to ~100B events/day with 50–100 min ingest-to-availability (ADR-0002/0003).
- Low-latency queries (<= 1.5s) for 3-month windows; high availability and resilience.
- Cost control and portability; avoid strong vendor lock-in while keeping ops reasonable.
- Security, tenancy isolation guardrails, observability, and predictable SLOs.

Architectural tactics influencing the choice:
- Separate stateless from stateful; run stateless on elastic platform (Kubernetes) behind CDN/API gateway.
- Use managed services selectively for the hardest stateful pieces (Kafka), keep primary data store portable (ClickHouse with S3 tiering).
- Infrastructure as Code, multi-AZ deployments, backups and disaster recovery, and strict network boundaries.

Comparison of alternatives (higher is better):

| Hosting / Criteria                                        | Availability & HA          | Scalability & elasticity   | Performance predictability | Ops complexity              | Cost & TCO               | Time-to-market          | Security/compliance        | Observability & SRE        | Portability & lock-in     |
|-----------------------------------------------------------|----------------------------|-----------------------------|----------------------------|-----------------------------|---------------------------|--------------------------|----------------------------|----------------------------|----------------------------|
| Public cloud K8s + managed Kafka + self-managed CH (S3)   | ★★★ Multi-AZ               | ★★★ Auto-scale stateless    | ★★★ High with tuning       | ★★ Medium (CH ops remain)  | ★★ Good, infra cost       | ★★★ Fast                 | ★★★ Mature cloud controls  | ★★★ Strong tooling         | ★★ Moderate lock-in        |
| Public cloud fully self-managed (K8s + Kafka + CH)        | ★★ Depends on ops          | ★★★ High, flexible          | ★★★ High with tuning       | ★ High ops burden          | ★★ Infra cost             | ★★ Slower                | ★★ Strong with effort       | ★★ Good with investment    | ★★★ High portability       |
| Fully managed data plane (CH Cloud + Confluent + API PaaS)| ★★★ High (provider SLOs)   | ★★★ Excellent               | ★★ Noisy-neighbor risk     | ★★★ Low ops                | ★ Variable, higher        | ★★★ Fastest              | ★★ Varies per provider      | ★★ Limited visibility      | ★ Lock-in                  |
| On-prem / private cloud                                   | ★★ Depends on hardware     | ★★ Limited elasticity       | ★★★ High within capacity   | ★ High operations          | ★★ CapEx + ops            | ★ Slow                   | ★★ Strong if certified      | ★★ Build/buy observability | ★★★ High portability       |
| Serverless-first (e.g., Cloud Run/Lambda + managed data)  | ★★ Cold starts, limits     | ★★★ Great for bursts        | ★★ Variable                | ★★ Low for stateless       | ★★ Pay-per-use            | ★★★ Very fast            | ★★ Varies                  | ★★ Limited deep metrics    | ★ Lock-in                  |

Notes:
- ADR-0002/0003 prioritize portability of the analytical store (ClickHouse) and cost control, while recognizing ops reality. Managed Kafka materially reduces operational risk for ingestion at this scale. ClickHouse remains self-managed for data portability and tuning control, with S3-compatible tiering for cost-efficient retention.

## Decision

Adopt a public cloud hosting model with:
- Kubernetes for stateless services (ingestion API, control planes, batch workers) behind a CDN and API gateway; multi-AZ clusters with horizontal pod autoscaling.
- Managed Kafka (e.g., AWS MSK, GCP Pub/Sub via Kafka-compatible layer, or Redpanda Cloud) for the ingestion backbone to reduce ops risk and enable durable replay at scale.
- Self-managed ClickHouse clusters on cloud VMs/nodes with local NVMe for hot data and object-storage (S3-compatible) tiering for warm/cold retention, deployed across multiple availability zones.
- Infrastructure as Code (Terraform) for all resources, VPC isolation, private networking between components, and centralized observability (logs/metrics/traces) with alerting and SLOs.

This balances portability and cost with pragmatic operational load. Providers can vary per environment; the architecture remains cloud-agnostic within common primitives (K8s + Kafka + object storage + VMs).

## Consequences

Positive:
- Meets scale and latency SLOs with elastic stateless tiers and tuned stateful data plane; durable ingestion with low ops via managed Kafka.
- Preserves portability of core data (self-managed ClickHouse with S3 tiering) and avoids strong lock-in while leveraging mature cloud primitives.
- Faster time-to-market versus fully self-managed; strong security/compliance posture with cloud-native controls and IaC.

Negative / risks:
- ClickHouse operations remain non-trivial (capacity, merges, backups, DR, upgrades); requires SRE playbooks and automation.
- Some vendor coupling remains (managed Kafka, cloud networking/storage features); migration requires planning.
- Kubernetes adds platform complexity; needs cost governance and autoscaling guardrails.

