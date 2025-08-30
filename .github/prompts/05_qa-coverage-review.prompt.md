---
mode: 'agent'
description: 'ADR Iteration'
---

You are filling out the `10_quality_requirements.adoc` section of an arc42 document.  
Follow these rules:


**Goal:** Verify that our ADRs cover all Quality Requirements (QAs) and identify gaps, conflicts, and follow-ups.

## Inputs to read from the repo
- Quality tree & scenarios: `10_quality_requirements.adoc` (IDs like P-1, A-2, S-1…).
- ADRs: `adrs/*.md` (adr-tools format; consider Status and Superseded).
- Risks: `11_technical_risks.adoc` (for cross-checking residual risks).

## Tasks (do all)
1) **Extract QA set**
    - List all QA IDs + short scenario names.
    - Note their Priority (High/Medium/Low).

2) **Scan ADRs for coverage**
    - For each ADR: capture ADR ID/Title/Status and which QA IDs it claims to address.
    - Ignore Deprecated or Superseded ADRs for coverage (but mention if they leave a gap).

3) **Build a coverage matrix (QA → ADRs)**
    - Rows = QA IDs (sorted by Priority, then ID).
    - Columns = ADR IDs that address them.
    - Mark only ADRs with `Status: Accepted` as “covers”; `Proposed` as “partial”.
    - **Do not put long sentences in the table**—only IDs/short phrases.

4) **Analyze and report**
    - **Gaps:** QAs with no Accepted ADRs.
    - **Weak coverage:** QAs covered only by Proposed ADRs.
    - **Conflicts:** QAs addressed by ADRs that make incompatible trade-offs (briefly name the ADR pairs).
    - **Duplication:** Multiple Accepted ADRs solving the same QA with overlapping scope—flag for consolidation.
    - **Risk alignment:** For each High-priority QA, confirm a matching mitigation in `11_technical_risks.adoc`. Flag mismatches.

5) **Actionable recommendations**
    - List needed ADRs or updates (one-liners).
    - Suggest where a **comparison table** is required to resolve conflicts.

## Output format
### arc42 Section
Place the result as **Section 10.4 “Traceability of Quality Requirements to Architectural Decisions”**
- Link back to §9 (Design Decisions / ADRs) and §11 (Risks) where relevant.

### Summary
- High-priority QAs total: <n>; Covered: <n>; Gaps: <n>; Weak coverage: <n>

### Coverage Matrix (QA → ADRs)
| QA ID | Priority | Covered by (Accepted ADR IDs) | Partially covered (Proposed ADR IDs) |
|-------|----------|-------------------------------|--------------------------------------|
| P-1   | High     | ADR-003, ADR-007              | ADR-012                              |
| A-2   | High     | —                             | ADR-011                              |

### Gaps & Weak Coverage
- **Gap:** C-2 (High) — No Accepted ADR; Proposed: ADR-015.
- **Weak:** S-1 (High) — Only ADR-010 (Proposed).

### Conflicts / Duplicates
- **Conflict:** P-1 trade-off differs between ADR-003 (cache with 30s TTL) vs ADR-007 (strong read-through) → needs comparison table + final ADR.
- **Duplicate:** A-1 addressed by ADR-004 and ADR-009 with overlapping failover tactics.

### Risk Alignment (High-priority QAs)
| QA ID | Related Risk IDs       | Mitigation present? | Note                      |
|-------|------------------------|---------------------|---------------------------|
| S-1   | RISK-INGEST-THROUGHPUT | Yes                 | OK                        |
| P-1   | RISK-QUERY-LATENCY     | No                  | Add mitigation ADR/update |

### Recommended Actions
- **Create:** ADR-NEW for C-2 strong consistency path (include comparison table of tactics).
- **Update:** ADR-007 to reconcile with ADR-003 on P-1; produce summary table; supersede one.
- **Add risk mitigation:** Link P-1 to RISK-QUERY-LATENCY with concrete guardrails.

### Notes
- Treat `Superseded` ADRs as historical; ensure successors are in the matrix.
- Keep tables to IDs/short phrases only; put prose in sections above/below tables.
