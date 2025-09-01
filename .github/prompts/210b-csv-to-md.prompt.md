---
mode: 'agent'
description: 'Convert CSV BOE calculation file to Markdown table'
---

<context>
- You are continuing the ADR started earlier.
- Use the **Scaling Tiers (Reference)** below to classify results and annotate risks without making design decisions.
- You are given a `.csv` file.  
- Your job is to **read its contents** and convert it into a **Markdown table**.  
- Preserve the original structure, column order, and values.
</context>

<inputs>
- `../01_introduction_and_goals.adoc`
- `../10_quality_requirements.adoc`
- `./**.md`
</inputs>

<instructions>
- Create a new ADR .md file using the converted Markdown table.
</instructions>

<output>
- Return only the ADR text (Markdown/adr-tools style), no extra explanations.
</output>

<example>
# Estimate System Growth and Technical Risks

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
