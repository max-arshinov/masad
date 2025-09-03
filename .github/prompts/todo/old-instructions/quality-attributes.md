# Quality Attributes Reference

This file defines the core Quality Attributes (QAs) for use in ADRs.  
Each QA section includes **Definition**, **Example Requirements/Metrics**, and **Trade-offs**.

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
