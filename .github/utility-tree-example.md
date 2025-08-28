# Utility(Quality) Tree Example

This is a compact quality tree with IDs for traceability.  
Use these IDs in ADRs to show which quality scenarios they address.  
Format aligned with arc42 quality tree style.

| ID  | Quality Attribute | Scenario            | Description                | Priority |
|-----|-------------------|---------------------|----------------------------|----------|
| P-1 | Performance       | API read latency    | P95 <120ms @10k rps        | High     |
| P-2 | Performance       | Write latency       | P95 <200ms @3k rps         | High     |
| P-3 | Performance       | Batch analytics SLA | 2 TB ETL <60 min, <$25/run | Medium   |
| S-1 | Scalability       | Elastic scale-out   | 2× traffic in ≤5 min       | High     |
| S-2 | Scalability       | Data scale          | 100 TB hot, 2 PB warm      | Medium   |
| A-1 | Availability      | Uptime              | 99.95% monthly             | High     |
| A-2 | Availability      | Node recovery       | MTTR ≤5m, no data loss     | High     |
| A-3 | Availability      | AZ outage           | Failover ≤1m, <1% errors   | Medium   |
| C-1 | Consistency       | Reads               | Staleness ≤1s, <0.5% stale | High     |
| C-2 | Consistency       | Monetary writes     | Serializable, no anomalies | High     |
| C-3 | Consistency       | Idempotency         | 0 dup side-effects         | High     |
| M-1 | Maintainability   | Lead time           | Merge→Prod <1h             | High     |
| M-2 | Maintainability   | Service boundaries  | ≤10 deps/service           | Medium   |
| M-3 | Maintainability   | Backward compat     | Support 2 API versions/6m  | High     |
| T-1 | Testability       | Coverage            | ≥80% critical paths        | Medium   |
| T-2 | Testability       | CI duration         | ≤30m full regression       | High     |
| T-3 | Testability       | Flake rate          | <0.5%/7d                   | Medium   |
| O-1 | Observability     | Tracing             | 100% trace-ID; 10% sampled | High     |
| O-2 | Observability     | SLO alerting        | Burn-rate 2× → alert ≤30m  | High     |
| O-3 | Observability     | Log retention       | 30d hot / 365d cold        | Medium   |
| D-1 | Deployability     | Region bring-up     | ≤2h via IaC                | Medium   |
| D-2 | Deployability     | Canary / Blue-Green | ≤1% traffic, rollback auto | High     |
| D-3 | Deployability     | Multi-cloud         | 80% portable               | Low/Med  |
| $-1 | Cost Efficiency   | Cost per request    | ≤$0.80 / 1M req            | High     |
| $-2 | Cost Efficiency   | Autoscale policy    | Idle <20%, save ≥40%       | Medium   |
| $-3 | Cost Efficiency   | Storage tiering     | ≥50% cost saving           | Medium   |

---

## Usage Guidelines

- **Prioritize:** Focus on 5–7 high-priority scenarios (e.g., P-1, A-1, A-2, C-2, O-1, D-2, $-1).
- **Map to mechanisms:** E.g., CDN+cache → P-1; multi-AZ+quorum → A-1, C-2; OpenTelemetry+alerts → O-1/O-2.
- **Acknowledge trade-offs:** Call out where you accept staleness, extra latency, or extra cost.
- **Quantify:** Keep criteria numeric and realistic.
- **Iterate:** Add/reprioritize if stakeholders raise new constraints.

---