---
mode: 'agent'
description: 'Technical Risks section for arc42 document in AsciiDoc format'
---

You are filling out the `11_technical_risks.adoc` section of an arc42 document.  
Follow these rules:

1. Create a **Technical Risk Register** in AsciiDoc table format with the following columns:
    - ID (e.g., RISK-XYZ)
    - Risk (short description)
    - Related QAs (use IDs like P-1, S-1 from the quality tree)
    - Likelihood (Low/Medium/High)
    - Impact (Low/Medium/High)
    - Mitigations (actionable measures, not vague statements)
    - Triggers / Monitors (measurable signals the risk is happening)

2. Add a **Technical Debts** subsection (bullet list) with items such as:
    - Missing documentation or tooling
    - Missing runbooks or automation
    - Known test gaps or load test needs

3. Ensure the output is in **AsciiDoc format** (not Markdown):
    - Use `=== Technical Risk Register` and `=== Technical Debts`
    - Use `[options="header"]` before the table
    - Keep each cell concise (keywords, short phrases, numbers — no long sentences)

4. Risks must be linked to **QA IDs** from section 10 so traceability is clear.

---

### Example Output (AsciiDoc)

```adoc
=== Technical Risk Register

[options="header"]
|===
| ID | Risk | Related QAs | Likelihood | Impact | Mitigations | Triggers / Monitors

| RISK-INGEST-THROUGHPUT | Ingestion backlog or loss at ~1.2M events/s | S-1, P-2 | Medium–High | High | Scale out stream partitions, autoscale consumers, DLQ | Ingest lag >10m; DLQ rate spikes
| RISK-QUERY-LATENCY | Queries exceed P95 ≤1.5s | P-1 | Medium | High | Pre-aggregations, OLAP pushdown, caching | P95 >1.5s; cache miss >40%
|===

=== Technical Debts

- Missing synthetic load tests for ingest/query SLOs  
- Runbooks for failover and lag recovery  
- Documentation for late-arrival correction processes