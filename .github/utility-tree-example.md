# Utility Tree Example

This is a compact utility tree with IDs for traceability.  
Use these IDs in ADRs to show which quality scenarios they address.

| Tier | ID  | Scenario / Attribute | Fit Criteria (measurable)       | Priority | Trade-offs                     |
|------|-----|----------------------|---------------------------------|----------|--------------------------------|
| 1    | P   | **Performance**      | Meet latency/throughput targets | —        | Cost vs maintainability        |
| 2    | P-1 | API read latency     | P95 <120ms @10k rps             | High     | Caching ↑ staleness            |
| 2    | P-2 | Write latency        | P95 <200ms @3k rps              | High     | Strong consistency ↑ latency   |
| 2    | P-3 | Batch analytics SLA  | 2 TB ETL <60 min, <$25/run      | Medium   | Larger cluster ↑ cost          |
| 1    | S   | **Scalability**      | Horizontal scale                | —        | Sharding ↑ complexity          |
| 2    | S-1 | Elastic scale-out    | 2× traffic in ≤5 min            | High     | Over-provision vs cold-start   |
| 2    | S-2 | Data scale           | 100 TB hot, 2 PB warm           | Medium   | Rebalance impacts availability |
| 1    | A   | **Availability**     | 99.95% uptime, MTTR ≤5m         | —        | Replication ↑ cost             |
| 2    | A-1 | Uptime               | 99.95% monthly                  | High     | HA design needed               |
| 2    | A-2 | Node recovery        | MTTR ≤5m, no data loss          | High     | Auto-healing infra             |
| 2    | A-3 | AZ outage            | Failover ≤1m, <1% errors        | Medium   | Multi-AZ cost                  |
| 1    | C   | **Consistency**      | Selective strong consistency    | —        | CAP trade-off                  |
| 2    | C-1 | Reads                | Staleness ≤1s, <0.5% stale      | High     | Eventual OK for UI             |
| 2    | C-2 | Monetary writes      | Serializable, no anomalies      | High     | ↑ Write latency                |
| 2    | C-3 | Idempotency          | 0 dup side-effects              | High     | Requires keys                  |
| 1    | M   | **Maintainability**  | Ship fast, low coupling         | —        | Modularity vs perf             |
| 2    | M-1 | Lead time            | Merge→Prod <1h                  | High     | CI/CD discipline               |
| 2    | M-2 | Service boundaries   | ≤10 deps/service                | Medium   | Avoid tight coupling           |
| 2    | M-3 | Backward compat      | Support 2 API versions/6m       | High     | Versioning overhead            |
| 1    | T   | **Testability**      | High automation, low flake      | —        | ↑ Test infra cost              |
| 2    | T-1 | Coverage             | ≥80% critical paths             | Medium   | Focus risk-based               |
| 2    | T-2 | CI duration          | ≤30m full regression            | High     | Parallelization                |
| 2    | T-3 | Flake rate           | <0.5%/7d                        | Medium   | Quarantine policy              |
| 1    | O   | **Observability**    | Fast detect/diagnose            | —        | Telemetry ↑ cost               |
| 2    | O-1 | Tracing              | 100% trace-ID; 10% sampled      | High     | Perf overhead                  |
| 2    | O-2 | SLO alerting         | Burn-rate 2× → alert ≤30m       | High     | Good SLO design                |
| 2    | O-3 | Log retention        | 30d hot / 365d cold             | Medium   | Tiered storage                 |
| 1    | D   | **Deployability**    | Fast, repeatable deploys        | —        | Abstractions vs PaaS           |
| 2    | D-1 | Region bring-up      | ≤2h via IaC                     | Medium   | Golden images                  |
| 2    | D-2 | Canary / Blue-Green  | ≤1% traffic, rollback auto      | High     | Traffic shaping                |
| 2    | D-3 | Multi-cloud          | 80% portable                    | Low/Med  | Abstraction cost               |
| 1    | $   | **Cost Efficiency**  | Meet budget + SLOs              | —        | Cost vs perf/HA                |
| 2    | $-1 | Cost per request     | ≤$0.80 / 1M req                 | High     | Caching, right-size            |
| 2    | $-2 | Autoscale policy     | Idle <20%, save ≥40%            | Medium   | Cold starts                    |
| 2    | $-3 | Storage tiering      | ≥50% cost saving                | Medium   | Latency for cold data          |

---

## Usage Guidelines

- **Prioritize:** Focus on 5–7 high-priority scenarios (e.g., P-1, A-1, A-2, C-2, O-1, D-2, $-1).  
- **Map to mechanisms:** E.g., CDN+cache → P-1; multi-AZ+quorum → A-1, C-2; OpenTelemetry+alerts → O-1/O-2.  
- **Acknowledge trade-offs:** Call out where you accept staleness, extra latency, or extra cost.  
- **Quantify:** Keep criteria numeric and realistic.  
- **Iterate:** Add/reprioritize if stakeholders raise new constraints.  

---
