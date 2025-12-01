---
mode: 'agent'
description: 'Convert CSV BOE calculation file to Markdown table'
---

<context>
- You are continuing the ADR started earlier.
- Use the **Scaling Tiers** below to classify results and annotate risks without making design decisions.
- You are given a `.csv` file.  
- Your job is to **read its contents** and convert it into a **Markdown table**.  
- Preserve the original structure, column order, and values.

### Scaling Tiers
| Tier            | CPU (RPS) | RAM    | Disk   | Network (aggregate) |
|-----------------|-----------|--------|--------|---------------------|
| 🟩 Minuscule    | 10        | 128 GB | 1 TB   | 1 Gbps              |
| 🟩 A few        | 100       | 512 GB | 10 TB  | 10 Gbps             |
| 🟨 Something    | 1,000     | 1 TB   | 100 TB | 40 Gbps             |
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
- Read the .csv tables in the context
- Create a new ADR .md file using the converted Markdown table.
</instructions>

<tasks>
1. Parse inputs .csv tables
3. Classify each year into **Scaling Tier**; select **Network class**.
4. Highlight risks with emojis (🟩 Low, 🟨 Medium, 🟥 High) in relevant cells.
5. Generate the ADR document (adr-tools style) with Context, Decision (calculations + table), Consequences (risks, bottlenecks, ops notes).
</tasks>


<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences.
- Title: short and action-oriented (e.g., "Estimate System Growth and Technical Risks").
- Status: "Proposed".
- Decision: include calculations + projection table.
- Consequences: highlight risks, feasibility concerns, cost/bottleneck insights.
</formatting>

<output>
- Return only the ADR text (Markdown/adr-tools style), no extra explanations.
</output>

<example>
# Estimate System Growth and Technical Risks

Date: 2025-09-01
Status: Proposed

## Context

## Decision

### Projection Table

| Year | # of users          | DB size (GB)        | RPS Write         | RPS Read             | Peak RPS Read      | Bandwidth (GB/s) | {{Other important metrics...}} |
|------|---------------------|---------------------|-------------------|----------------------|--------------------|------------------|--------------------------------|
| 1    | {{number of users}} | <low number}} 🟩    | {{low number}} 🟩 | {{medium number}} 🟨 | {{high number}} 🟥 | <low number}} 🟩 | ...                            |
| 2    | {{number of users}} | <medium number}} 🟨 | {{low number}} 🟩 | {{high number}} 🟥   | {{high number}} 🟥 | <low number}} 🟩 | ...                            |
| 3    | {{number of users}} | <high number}} 🟥   | {{low number}} 🟩 | {{high number}} 🟥   | {{high number}} 🟥 | <low number}} 🟨 | ...                            |

**Legend:** 🟩 Low · 🟨 Medium · 🟥 High

## Consequences
- Storage requirements are manageable for single database
- Read traffic requires caching strategy
- Peak load may require horizontal scaling
</example>

<validation>
- [] Emoji risk applied according to Scaling Tiers.
- [] No design decisions; Consequences discuss risks/ops complexity only.
</validation>
