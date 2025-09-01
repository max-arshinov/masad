---
mode: 'agent'
description: 'Perform back-of-the-envelope estimates for technical risks'
---

<context>
- You are continuing the ADR started earlier.
- Perform transparent back-of-the-envelope calculations for the parameters identified previously.
- Use the **Scaling Tiers (Reference)** below to classify results and annotate risks without making design decisions.

### Scaling Tiers (Reference)
| Tier            | CPU (RPS) | RAM    | Disk   | Network (aggregate) |
|-----------------|-----------|--------|--------|---------------------|
| 🟩Minuscule     | 10        | 128 GB | 1 TB   | 1 Gbps              |
| 🟩A few         | 100       | 512 GB | 10 TB  | 10 Gbps             |
| 🟨Something     | 1,000     | 1 TB   | 100 TB | 40 Gbps             |
| 🟥 A lot        | 10,000    | 10 TB  | 1 PB   | 100 Gbps            |
| 🟥 OMG          | 100,000   | 100 TB | 10 PB  | 400 Gbps            |
| 🟥 Mind-blowing | 1,000,000 | 1 PB   | 1 EB   | ≥1 Tbps             |
</context>

<inputs>
- `../01_introduction_and_goals.adoc`
- `../10_quality_requirements.adoc`
- `./**.md`
</inputs>

<instructions>
- Read inputs and extract numeric drivers (users, entities, request mix, object sizes, RF).
- Compute all metrics with `mcp-server-calculator` and **print the steps**.
- Derive **Bandwidth (GB/s)** from RPS × avg bytes per response/request (convert to GB/s).
- Add **Network class (Gbps)** using the tier table (1G / 10G / 40G / 100G / 400G / ≥1T).
</instructions>

<tasks>
1. Parse inputs; enumerate key parameters (users, entities, object sizes, RF, read/write mix).
2. Compute: users, links, DB size, write/read RPS, **peak** read RPS, storage, **bandwidth (GB/s)**.
3. Classify each year into **Scaling Tier**; select **Network class**.
4. Build a 3-year **projection table** including Tier and Network class; annotate risks with emojis.
5. Generate the ADR document (adr-tools style) with Context, Decision (calculations + table), Consequences (risks, bottlenecks, ops notes).
</tasks>

<constraints>
- Output must include a **projection table** with numeric values for:
  * # of users, DB size (GB/TB), Write RPS, Read RPS, **Peak Read RPS**, Storage size, **Bandwidth (GB/s)**.
- Show **transparent calculation steps** using `mcp-server-calculator` for all numeric operations.
- Projection table:
  * ≥ 3 years; rows = years; columns = parameters.
  * Include a **Tier** column (derived from RPS/Storage/Network against the Scaling Tiers).
  * Include a **Network class** column chosen as the **smallest standard tier** whose Gbps ≥ (computed GB/s × 8).
  * Add risk emojis in relevant cells (🟩 Low, 🟨 Medium, 🟥 High).
- Do **not** make design decisions — only estimates.
</constraints>

<recommendations>
- State and justify any assumptions (e.g., average response bytes, replication factor).
- Prefer conservative (upper-bound) estimates when uncertain.
- Keep explanations concise and professional.
</recommendations>

<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences.
- Title: short and action-oriented (e.g., "Estimate System Growth and Technical Risks").
- Status: "Proposed".
- Context: briefly restate assumptions and QARs/QASs.
- Decision: include calculations + projection table.
- Consequences: highlight risks, feasibility concerns, cost/bottleneck insights.
</formatting>

<output>
- Return only the ADR text (Markdown/adr-tools style), no extra explanations.
</output>

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

| Year | # of users        | DB size (GB)       | RPS Write       | RPS Read           | Peak RPS Read    | Bandwidth (GB/s) | <Other important metrics...> |
|------|-------------------|--------------------|-----------------|--------------------|------------------|------------------|------------------------------|
| 1    | <number of users> | <low number> 🟩    | <low number> 🟩 | <medium number> 🟨 | <high number> 🟥 | <low number> 🟩  | ...                          |
| 2    | <number of users> | <medium number> 🟨 | <low number> 🟩 | <high number> 🟥   | <high number> 🟥 | <low number> 🟩  | ...                          |
| 3    | <number of users> | <high number> 🟥   | <low number> 🟩 | <high number> 🟥   | <high number> 🟥 | <low number> 🟨  | ...                          |

**Legend:** 🟩 Low · 🟨 Medium · 🟥 High

## Consequences
- Storage requirements are manageable for single database
- Read traffic requires caching strategy
- Peak load may require horizontal scaling
</example>

<validation>
- All numeric work shown via `mcp-server-calculator`.
- Projection table includes **Tier** and **Network class** and required metrics.
- Bandwidth (GB/s) ↔ Network class mapping is consistent (Gbps ≥ GB/s × 8).
- Emoji risk applied by proximity-to-next-tier rule.
- No design decisions; Consequences discuss risks/ops complexity only.
</validation>
