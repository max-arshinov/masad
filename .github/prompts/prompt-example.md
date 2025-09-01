---
mode: 'agent'
description: 'Generate arc42 Technical Risks section'
---

<context>
We are documenting the `11_technical_risks.adoc` section of an arc42 architecture document.  
The goal is to capture potential technical risks, their impact, likelihood, and mitigations.  
</context>

<inputs>
- `10_quality_requirements.adoc` — list of quality attributes and scenarios  
- Known project decisions from ADRs (`adrs/*.md`)  
</inputs>

<constraints>
- Output must be in **AsciiDoc** format (not Markdown).  
- Risk table must have all required columns: ID, Risk, Related QAs, Likelihood, Impact, Mitigations, Triggers.  
- Impact and Likelihood must use emoji codes: 🟩 Low, 🟨 Medium, 🟥 High.  
</constraints>

<recommendations>
- Keep descriptions concise and professional.  
- Use short identifiers (e.g., RISK-001).  
- Focus on measurable mitigations (not vague ideas).  
</recommendations>

<instructions>
- Fill out the **Technical Risk Register** table in AsciiDoc.  
- Add a **Technical Debts** subsection below the table as a bullet list.  
</instructions>

<tasks>
1. Extract relevant risks from QAs and ADRs.  
2. Build the AsciiDoc table with required columns.  
3. Append the Technical Debts subsection.  
</tasks>

<formatting>
- Use `=== Technical Risk Register` for the table heading.  
- Use `=== Technical Debts` for the debt list.  
- Table format:  
  ```
  [options="header"]
  |===
  |ID |Risk |Related QAs |Likelihood |Impact |Mitigations |Triggers
  |===
  ```
</formatting>

<output>
- Must return **AsciiDoc** text only.  
- Do not include explanations outside the document body.  
</output>

<example>
=== Technical Risk Register

[options="header"]
|===
|ID |Risk |Related QAs |Likelihood |Impact |Mitigations |Triggers

|RISK-001 |Database latency under high load |P-1, S-1 |🟨 Medium |🟥 High |Introduce caching layer; perform load testing |P95 latency > 200ms
|RISK-002 |Team lacks runbook for failures |O-3 |🟩 Low |🟨 Medium |Create on-call runbook and automation scripts |On-call engineer escalates without clear steps
|===

=== Technical Debts
- Missing runbooks for database recovery
- No automated chaos testing in CI/CD  
  </example>

<validation>
- YAML header present with mode + description  
- Context and Inputs sections defined  
- Constraints clearly separate from Recommendations  
- Risk table includes all required columns  
- Emojis used for Impact and Likelihood  
- Output in AsciiDoc only, no Markdown  
- Example provided as reference  
</validation>
