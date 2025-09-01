---
mode: 'agent'
description: 'ADR: perform back-of-the-envelope estimates for technical risks'
---

<context>
- You are continuing the ADR started earlier.  
- Now you must perform transparent back-of-the-envelope calculations for the parameters identified in the previous ADR.  
- Use `mcp-server-calculator` for all numeric steps.
</context>

<inputs>
- `./01_introduction_and_goals.adoc`
- `./10_quality_requirements.adoc`
</inputs>

<constraints>
- Follow ADR format (adr-tools style).
- Include transparent calculation steps.
- Output must include a **projection table** with numeric values for:
  * # of users
  * DB size (GB/TB)
  * Write RPS
  * Read RPS
  * Peak Read RPS
  * Storage size
  * Bandwidth (GB/s)
  * Other relevant metrics
- Do NOT make design decisions — only estimates.
</constraints>

<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences.
- Title: short and action-oriented (e.g., "Estimate System Growth and Technical Risks").
- Status: "Proposed".
- Context: briefly restate assumptions and QARs/QASs.
- Decision: include calculations + projection table.
- Consequences: highlight risks, feasibility concerns, cost/bottleneck insights.
</formatting>

## Decision
Parameters for estimation: users, links, DB size, write/read RPS, bandwidth, storage.

