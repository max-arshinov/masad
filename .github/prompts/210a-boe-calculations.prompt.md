---
mode: 'agent'
description: 'ADR: perform back-of-the-envelope estimates for technical risks'
---

<context>
- You are continuing the ADR started earlier.  
- Now you must perform transparent back-of-the-envelope calculations for the parameters identified in the previous ADR.  
</context>

<inputs>
- `../01_introduction_and_goals.adoc`
- `../10_quality_requirements.adoc`
- `./**.md`
</inputs>

<instructions>
- Follow ADR format (adr-tools style).
- Perform calculations for parameters: users, links, DB size, write/read RPS, bandwidth, storage.
- Use transparent calculation steps with `mcp-server-calculator` for all numeric operations.
- Do NOT make design decisions — only estimates.
</instructions>

<tasks>
1. Read and analyze the input files to understand system requirements and constraints
2. Identify the key parameters that need estimation (users, other domain entities, DB size, RPS (write/read), bandwidth, storage)
3. Use `mcp-server-calculator` to perform all calculations transparently with step-by-step breakdown
4. Create a comprehensive projection table with all required metrics across 3 years
5. Generate a complete ADR document following adr-tools format
6. Include risk assessment and consequences based on calculated values
</tasks>

<constraints>
- Output must include a **projection table** with numeric values for:
  * # of users
  * DB size (GB/TB)
  * Write RPS
  * Read RPS
  * Peak Read RPS
  * Storage size
  * Bandwidth (GB/s)
  * Other relevant metrics
- Include transparent calculation steps.
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

<example>
# ADR-003: Estimate System Growth and Technical Risks

Date: 2025-09-01
Status: Proposed

## Context
Based on requirements analysis, we need estimates for a URL shortener system expecting 1M daily active users with 99.9% availability requirement.

## Decision
### Calculations
Using mcp-server-calculator:
- Daily active users: 1,000,000
- Links created per user per day: 1,000,000 * 0.1 = 100,000
- Read-to-write ratio: 100:1
- Daily reads: 100,000 * 100 = 10,000,000

### Projection Table

| Year | # of users | User DB size (GB) | # of short links | Link DB size (GB) | RPS Write | RPS Read   | Peak RPS Read | Stat Size (TB) | Bandwidth (GB/s) |
|------|------------|-------------------|------------------|-------------------|-----------|------------|---------------|----------------|------------------|
| 1    | 1,000,000  | 0.93              | 100,000,000      | 9.59              | 3.17      | 11,575 🟨  | 34,725 🟥     | 0.36 🟩        | 0.04 🟩          |
| 2    | 2,000,000  | 1.86              | 300,000,000      | 28.78             | 6.34      | 34,723 🟥  | 104,169 🟥    | 1.07 🟨        | 0.12 🟩          |
| 3    | 3,000,000  | 2.79              | 600,000,000      | 57.56             | 9.51      | 69,445 🟥  | 208,335 🟥    | 2.13 🟨        | 0.23 🟨          |
| 4    | 4,000,000  | 3.73              | 900,000,000      | 86.33             | 12.68     | 104,167 🟥 | 312,501 🟥    | 3.20 🟥        | 0.35 🟨          |
| 5    | 5,000,000  | 4.66              | 1,200,000,000    | 115.11            | 15.85     | 138,889 🟥 | 416,667 🟥    | 4.27 🟥        | 0.47 🟨          |

**Legend:** 🟩 Low · 🟨 Medium · 🟥 High

## Consequences
- Storage requirements are manageable for single database
- Read traffic requires caching strategy
- Peak load may require horizontal scaling
</example>

<validation>
- All calculations use `mcp-server-calculator` with transparent steps
- Projection table includes all required metrics (users, DB size, RPS, bandwidth, storage)
- ADR follows adr-tools format (Title, Date, Status, Context, Decision, Consequences)
- Title is action-oriented and concise
- Status is "Proposed"
- No design decisions made, only estimates provided
- Consequences section highlights risks and bottlenecks
- All numeric values are clearly sourced from calculations
- Risk assessment addresses feasibility concerns
</validation>
