---
mode: 'agent'
description: 'ADR: back-of-the-envelope estimates to identify technical risks'
---

<context>
Perform back-of-the-envelope calculations to validate further design choices, 
then document the result as an Architecture Decision Record (ADR).
Use `10_quality_requirements.adoc` to identify relevant 
Quality Attribute Requirements (QARs) and Quality Attribute Scenarios (QASs).
</context>

<instructions>
- Create a new ADR draft that captures assumptions, estimates, and implications without making final decisions.
- Present the main results as a **multi-year projection table** (3 years).
- ALWAYS use `mcp-server-calculator` for calculations and show steps transparently.
</instructions>

<constraints>
- Follow ADR format (adr-tools style).
- Do NOT propose or finalize design decisions.
- Use only back-of-the-envelope style estimates (orders of magnitude).
- Show calculation steps transparently.
- Explicitly list which QARs and QASs the ADR relates to.
- Output must include a **table with projections** for key parameters by year.
- Keep explanations concise and professional.
- Prefer conservative assumptions if uncertain.
</constraints>

<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences.
- Title: short and action-oriented (e.g., "Estimate System Growth and Technical Risks").
- Status: "Proposed".
- Context: list assumptions and referenced QARs/QASs.
- Decision: include:
  * transparent calculation steps
  * a projection table (3 years) with key parameters:
    - # of users
    - DB size (GB/TB)
    - Write RPS
    - Read RPS
    - Peak Read RPS
    - Storage size
    - Bandwidth (GB/s)
    - Other relevant metrics
  * confidence level
- Consequences: outline risks, feasibility concerns, and cost/bottleneck insights.
</formatting>

<example>
# 43. Estimate System Growth and Technical Risks
Date: 2025-08-30

## Status
Proposed

## Context
- Assumption: 1M new users per year.
- Each user creates ~100 short links/year.
- Each short link read ~10 times/day.
- Peak load multiplier = ×3 of average.
- Relevant QARs: P-1 (Performance), A-1 (Availability), S-1 (Scalability).
- Relevant QASs: P-1 (Throughput under load), A-1 (Recovery from failure).

## Decision
Step 1: User growth = +1M/year.  
Step 2: Requests/day = users × links × reads.  
Step 3: Convert to RPS (divide by 86,400).  
Step 4: Peak = average ×3.  
Step 5: Estimate DB growth, storage, bandwidth.

# Projection Table

| Year | # of users | User DB (GB) | # of links  | Link DB (GB) | Write RPS | Read RPS | Peak Read RPS | Stat Size (TB) | Bandwidth (GB/s) |
|------|------------|--------------|-------------|--------------|-----------|----------|---------------|----------------|------------------|
| 1    | 1,000,000  | 0.93         | 100,000,000 | 9.59         | 3.17      | 11,575   | 34,725        | 0.36           | 0.04             |
| 2    | 2,000,000  | 1.86         | 300,000,000 | 28.78        | 6.34      | 34,723   | 104,169       | 1.07           | 0.12             |
| 3    | 3,000,000  | 2.79         | 600,000,000 | 57.56        | 9.51      | 69,445   | 208,335       | 2.13           | 0.23             |


Confidence: conservative, rough order-of-magnitude.

## Consequences
- DB growth manageable early but steep at scale.
- Bandwidth increases ~10× over 5 years.
- Peak load may stress read replicas and caching.
- Cost of storage and networking rises significantly.
</example>

<validation>
- Verify ADR includes all required sections.
- Verify all assumptions and calculations are transparent.
- Verify ADR references QARs/QASs consistently.
- Verify the projection table is complete and realistic.
- Verify no design decisions are made — only estimates.
</validation>

<output>
Return ONLY ADR text in adr-tools format with AsciiDoc table.  
No explanations. No comments. No introductions.
</output>
