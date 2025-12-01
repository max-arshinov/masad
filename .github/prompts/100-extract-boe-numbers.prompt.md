---
mode: 'agent'
description: 'Extract parameters and assumptions for back-of-the-envelope estimation ADR'
---

<context>
You are preparing the groundwork for a back-of-the-envelope estimation ADR.  
Your task is to extract and document **assumptions, parameters, and relevant quality attributes**,  
but you MUST NOT perform any calculations yet.
</context>

<inputs>
- `../01_introduction_and_goals.adoc`
- `../10_quality_requirements.adoc`
</inputs>

<instructions>
- Create a new ADR draft in adr-tools style
- Identify and list all key assumptions (e.g., user growth, actions per user, peak multipliers)
- Extract relevant Quality Attribute Requirements (QARs) and Scenarios (QASs)
- Document significant system parameters that will later require numeric estimation (e.g., # of users, DB size, write/read RPS, peak RPS, storage, bandwidth)
- Extract all important numbers per relevant QARs/QASs
</instructions>

<constraints>
- List important QARs/QASs and numbers that will be used in back-of-the-envelope calculations
- Do NOT perform any numeric calculations
- Do NOT include projection tables — only list parameters that will appear there later
- Ensure Context section references QARs/QASs explicitly
- Status must be "Proposed"
- ALWAYS use markdown not AsciiDoc
</constraints>

<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences
- Title: short and action-oriented (e.g., "Identify Parameters for Estimation of Technical Risks")
- Context: list assumptions and referenced QARs/QASs with relevant numbers in table format
- Decision: describe which parameters will be estimated later, but do not calculate them
- Consequences: note what kind of risks will be analyzed once estimates are done
</formatting>

<example>
# Identify Parameters for Estimation of Technical Risks

## Date
2025-09-01

## Status
Proposed

## Context
| Assumption       | Value    |
|------------------|----------|
| User growth      | +1M/year |
| Peak multiplier  | ×3       |
| Cache miss ratio | 10%      |

## Decision
Parameters for estimation: users, links, DB size, write/read RPS, bandwidth, storage.

## Consequences
These parameters will guide later sizing estimates and risk analysis.
</example>

<validation>
- [] Decision section lists parameters without calculations
- [] No projection tables or numeric estimates included
- [] Parameters cover system scale (users, data, throughput, storage)
- [] Consequences mention future risk analysis without specifics
</validation>
