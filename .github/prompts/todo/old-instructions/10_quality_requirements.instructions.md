---
applyTo: "**/10_quality_requirements.adoc"
---

# Quality Requirements & Scenarios

You must capture **Quality Requirements** in the form of a **Quality Tree** and detailed **Quality Scenarios**.  
Each requirement must have an **ID** so ADRs can reference it.

---

## 1. Quality Tree

Represent high-level attributes with concrete scenarios.  
Use a table with the following columns:

| ID  | Attribute   | Scenario       | Fit Criteria (measurable)                       | Priority |
|-----|-------------|----------------|-------------------------------------------------|----------|
| P-1 | Performance | Report latency | Charts/reports ≤1.5s for ≤3 months data         | High     |
| P-2 | Performance | Data freshness | Events visible in dashboards ≤100 min           | Medium   |
| S-1 | Scalability | Ingestion      | ~100B events/day (~1.2M/s) across tenants       | High     |
| R-1 | Retention   | Data retention | Store data indefinitely, cost-effective tiering | High     |

Rules:
- Use short IDs (e.g., `P-1`, `S-1`).
- Always define a measurable fit criterion.
- Assign priority (High/Medium/Low).

---

## 2. Quality Scenarios

For each ID in the Quality Tree, describe a **detailed scenario** with this structure:

- **Source**: Who/what triggers the event.
- **Stimulus**: What happens.
- **Environment**: Conditions when it happens.
- **Artifact**: System element involved.
- **Response**: What the system does.
- **Response Measure**: How success is measured (quantitative).

### Example: P-1 Report Latency
- **Source**: Analyst user
- **Stimulus**: Requests chart/report for ≤3 months data
- **Environment**: Normal load, cache miss allowed
- **Artifact**: Query API, aggregation service, hot storage
- **Response**: Returns chart without timeout
- **Response Measure**: P95 latency ≤1.5s

### Example: S-1 Ingestion Throughput
- **Source**: Website/app SDKs
- **Stimulus**: Sustained global traffic ~100B events/day (~1.2M/s)
- **Environment**: Multi-tenant, rolling deploys
- **Artifact**: Ingestion API, queues, writers
- **Response**: Scales horizontally with backpressure, no data loss
- **Response Measure**: Sustain ~1.2M/s, 0% loss, backlog acceptable

---

## 3. Usage

- Always reference **QA IDs** in ADRs (e.g., ADR-002 addresses P-1 and S-1).
- When adding new requirements, update the **Quality Tree** and add scenarios.
- Keep **fit criteria measurable** (latency, throughput, error rate, retention period, etc.).

---

# Quality Attributes Reference

This file defines the core Quality Attributes (QAs) for use in ADRs.  
Each QA section includes **Definition**, **Example Requirements/Metrics**, and **Trade-offs**.
Use them as references 
---

## Scalability
**Definition:** Ability to handle increasing workload by expanding resources (vertically/horizontally).  
**Examples:**
- 100K concurrent users or 10K requests/sec
- Auto-scale nodes within 1 min under peak load  
  **Trade-offs:** Complexity (sharding, coordination), higher cost, consistency challenges.

---

## Availability & Reliability
**Definition:** Availability = fraction of time operational. Reliability = probability of correct operation.  
**Examples:**
- ≥99.9% uptime (≤8.8h downtime/year)
- MTTR < 5 min; MTBF > 1000h
- Any single-node failure must not affect service  
  **Trade-offs:** Requires redundancy (cost/complexity), CAP trade-offs with consistency.

---

## Consistency & Data Integrity
**Definition:** All users see the same data (strong vs eventual consistency). Integrity = correctness/no corruption.  
**Examples:**
- Reads reflect committed writes ≤1s ago
- ≤1% of reads return stale data
- Transactions must be atomic & isolated  
  **Trade-offs:** Strong consistency → higher latency, lower availability; weaker → simpler ops but divergence.

---

## Performance (Latency & Throughput)
**Definition:** Speed/responsiveness: latency + throughput.  
**Examples:**
- P95 latency <100ms
- ≥50K orders/sec throughput
- CPU utilization <70% under load  
  **Trade-offs:** Latency vs throughput, performance vs maintainability, caching vs consistency.

---

## Maintainability
**Definition:** Ease of modifying/adapting the system.  
**Examples:**
- New features deployable without touching core services
- Code complexity <10; 80% unit test coverage
- Time to deploy fix <2 weeks  
  **Trade-offs:** Modularity improves maintainability but can hurt performance/ops efficiency.

---

## Testability
**Definition:** Ease of testing and diagnosing failures.  
**Examples:**
- >90% code coverage
- CI regression <30min
- All APIs mockable  
  **Trade-offs:** Abstraction/test harnesses add overhead, automation infra costs time & money.

---

## Observability
**Definition:** Ability to infer state via logs, metrics, traces.  
**Examples:**
- 100% requests have trace IDs
- Health metrics polled every min
- Alerts on >1% error rate  
  **Trade-offs:** Logging/tracing adds overhead/cost; too little → blind spots.

---

## Portability & Deployability
**Definition:** Ease of running on multiple platforms/clouds.  
**Examples:**
- Same codebase runs on AWS/Azure/GCP
- Containers (Docker/K8s) used
- Provisioning <1h  
  **Trade-offs:** Abstractions reduce optimization, managed services may reduce portability.

---

## Cost Efficiency
**Definition:** Meet requirements within budget (infra, ops, licensing).  
**Examples:**
- ≤$50K monthly cloud cost
- <$1 per million requests
- CPU utilization <60%  
  **Trade-offs:** Cost vs performance, redundancy, and availability.

---

## Security (Recommended Addition)
**Definition:** Protect confidentiality, integrity, and availability of data and systems.  
**Examples:**
- All data encrypted in transit and at rest
- MFA required for admin actions
- Compliance with GDPR/PCI-DSS  
  **Trade-offs:** Security controls can add latency, cost, and complexity.

---

# Common Trade-offs (Summary)

- **CAP theorem:** consistency vs availability under partitions
- **Latency vs throughput**
- **Performance vs cost**
- **Performance vs maintainability**
- **Observability vs performance**

---
