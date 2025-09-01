---
mode: 'agent'
description: 'ADR: identify parameters and assumptions before estimation'
---

<context>
You are preparing the groundwork for a back-of-the-envelope estimation ADR.  
Your task is to extract and document **assumptions, parameters, and relevant quality attributes**,  
but you MUST NOT perform any calculations yet.
</context>

<instructions>
- Create a new ADR draft in adr-tools style.
- Identify and list:
  * all key assumptions (e.g., user growth, actions per user, peak multipliers),
  * relevant Quality Attribute Requirements (QARs) and Scenarios (QASs),
  * significant system parameters that will later require numeric estimation  
    (e.g., # of users, DB size, write/read RPS, peak RPS, storage, bandwidth).
- Extract all important numbers per relevant QARs/QASs.
</instructions>

<constraints>
- List important QARs/QASs and numbers that further will be used in the back-of-the-envelope calcualtions.
- Do NOT perform any numeric calculations.
- Do NOT include projection tables — only list parameters that will appear there later.
- Ensure Context section references QARs/QASs explicitly.
</constraints>

<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences.
- Title: short and action-oriented (e.g., "Identify Parameters for Estimation of Technical Risks").
- Status: "Proposed".
- Context: list assumptions and referenced QARs/QASs with relevant numbers in the table format.
- Decision: describe which parameters will be estimated later, but do not calculate them.
- Consequences: note what kind of risks will be analyzed once estimates are done.
- ALWAYS use markdown not AsciiDoc.
</formatting>

<example>
# ADR-0003: Identify Parameters for Estimation of Technical Risks

## Date
2025-09-01

## Status
Proposed

## Context
| Assumption | Value |
|------------|-------|
| User growth | +1M/year |
| Peak multiplier | ×3 |
| Cache miss ratio | 10% |

Referenced QARs: P-1 (latency ≤50 ms), A-1 (99.95% availability), S-1 (abuse resistance).

## Decision
Parameters for estimation: users, links, DB size, write/read RPS, bandwidth, storage.

### Three-year projection table
| Year |     Users |       Links | Avg Write RPS | Peak Write RPS | Avg Read RPS | Peak Read RPS | Backend Avg RPS (10% miss) | Backend Peak RPS (10% miss) | Resp BW Avg (GB/s) | Resp BW Peak (GB/s) | Logical DB Size (GB) | Effective Storage (GB) |
|------|----------:|------------:|--------------:|---------------:|-------------:|--------------:|---------------------------:|----------------------------:|-------------------:|--------------------:|---------------------:|-----------------------:|
| 1    | 1,000,000 | 100,000,000 |         3.171 |          9.513 |   11,574.074 |    34,722.222 |                  1,157.407 |                   3,472.222 |            0.00463 |             0.01389 |               41.024 |                123.072 |
| 2    | 2,000,000 | 200,000,000 |         3.171 |          9.513 |   23,148.148 |    69,444.444 |                  2,314.815 |                   6,944.444 |            0.00926 |             0.02778 |               82.048 |                246.144 |
| 3    | 3,000,000 | 300,000,000 |         3.171 |          9.513 |   34,722.222 |   104,166.667 |                  3,472.222 |                  10,416.667 |            0.01389 |             0.04167 |              123.072 |                369.216 |

## Impact Assessment
| Dimension | Year 1 | Year 2 | Year 3 |
|-----------|--------|--------|--------|
| CPU (RPS) | 🟨     | 🟨     | 🟥     |
| Disk (TB) | 🟩     | 🟩     | 🟩     |
| Network   | 🟩     | 🟩     | 🟩     |

## Consequences
These parameters will guide later sizing estimates and risk analysis.
</example>