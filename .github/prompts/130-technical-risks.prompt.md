---
mode: 'agent'
description: 'Generate Technical Risks section in arc42 AsciiDoc format'
---

<context>
You are completing the `11_technical_risks.adoc` section of an arc42 architecture document.  
This section must document risks, trace them to quality attributes, and capture known technical debts.  
</context>

<inputs>
- Technical risks: `11_technical_risks.adoc`
- Quality attributes and scenarios: `10_quality_requirements.adoc`  
</inputs>

<instructions>
- Create a **Technical Risk Register** in AsciiDoc table format.  
- Add a **Technical Debts** subsection in bullet-list form.  
- Ensure risks are traceable to QA IDs (from section 10).  
- Keep all content concise, professional, and directive.  
</instructions>

<tasks>
1. Build the Technical Risk Register table with mandatory columns:  
   - ID (e.g., RISK-XYZ)  
   - Risk (short description)  
   - Related QAs (IDs like P-1, S-1)  
   - Likelihood (Low/Medium/High)  
   - Impact (Low/Medium/High, use 🟩🟨🟥 for clarity)  
   - Mitigations (specific, actionable)  
   - Triggers / Monitors (measurable signals)  
2. Add a **Technical Debts** subsection with clear, actionable items.  
</tasks>

<constraints>
- Output must be **AsciiDoc** (not Markdown).  
- Use `=== Technical Risk Register` and `=== Technical Debts`.  
- Precede the table with `[options="header"]`.  
- Table cells must be short: keywords, short phrases, or numbers only.  
- Link every risk to at least one QA ID from `10_quality_requirements.adoc`.  
</constraints>

<recommendations>
- Use emojis for impact severity:  
  - 🟩 Low  
  - 🟨 Medium  
  - 🟥 High  
- Keep language precise and concise (no long sentences).  
- Prefer measurable mitigations and triggers.  
</recommendations>

<formatting>
- Section headers: `=== Technical Risk Register`, `=== Technical Debts`.  
- Use AsciiDoc table syntax with `[options="header"]`.  
- Use bullet points (`-`) for Technical Debts.  
</formatting>

<files>
- Edit `11_technical_risks.adoc` only
- Don't modify or add other files
</files>

<output>
AsciiDoc text containing a Technical Risk Register table and a Technical Debts subsection.  
</output>

<example>
```adoc
=== Technical Risk Register

[options="header"]
|===
| ID | Risk | Related QAs | Likelihood | Impact | Mitigations | Triggers / Monitors

| RISK-INGEST-THROUGHPUT | Ingestion backlog at ~1.2M events/s | S-1, P-2 | Medium | 🟥 High | Scale partitions, autoscale consumers, DLQ | Lag >10m; DLQ rate spikes
| RISK-QUERY-LATENCY | Queries exceed P95 ≤1.5s | P-1 | Medium | 🟥 High | Pre-aggregations, OLAP pushdown, caching | P95 >1.5s; cache miss >40%
|===

=== Technical Debts

- [] Missing synthetic load tests for ingest/query SLOs
- [] Runbooks for failover and lag recovery
- [] Documentation for late-arrival correction processes
</example>