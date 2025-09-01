---
mode: 'agent'
description: 'QA Coverage Review'
---

<context>
You are filling out **Section 10.4 “Traceability of Quality Requirements to Architectural Decisions”**  
of an arc42 document.  

Your job is to verify that ADRs cover all Quality Attribute Requirements (QARs) and Quality Attribute Scenarios (QASs),  
identify gaps, conflicts, duplicates, and propose actionable next steps.

Inputs:
- Quality tree & scenarios → `10_quality_requirements.adoc` (IDs like P-1, A-2, S-1…)
- ADRs → `adrs/*.md` (adr-tools format; consider Status and Superseded)
- Risks → `11_technical_risks.adoc` (for cross-checking residual risks)
  </context>

<instructions>
1. Extract QA set  
   - List all QA IDs and short scenario names.  
   - Include their Priority (High/Medium/Low).  

2. Scan ADRs for coverage
    - For each ADR: capture ADR ID, Title, Status, and QA IDs it addresses.
    - Ignore Deprecated ADRs.
    - Superseded ADRs: check if their successor(s) still cover the same QAs.
        - If not → mark a **gap created by supersession**.

3. Build a Coverage Matrix (QA → ADRs)
    - Rows = QA IDs (sorted by Priority, then ID).
    - Columns = ADR IDs.
    - Mark:
        * Accepted ADRs = “covers”
        * Proposed ADRs = “partial”
    - Use only IDs/short phrases, no long text.
    - If >20 QAs → group Medium/Low into aggregated rows.

4. Analyze coverage
    - **Gap:** QA not covered by any Accepted ADR.
    - **Weak:** QA only covered by Proposed ADR(s).
    - **Conflict:** QA addressed by ADRs with incompatible trade-offs (list ADR pairs).
    - **Duplicate:** QA addressed by multiple Accepted ADRs with overlapping scope.

5. Risk alignment
    - For each High-priority QA: check if a related risk exists in `11_technical_risks.adoc`.
    - Mark whether mitigation is present or missing.
    - If QA has no related risk, note as “no mapped risk.”

6. Actionable recommendations
    - List needed ADRs or updates (one-liners).
    - Suggest where a **comparison table** is required to resolve conflicts.  
      </instructions>

<constraints>
- Follow arc42 Section 10.4 format.  
- Use Markdown tables for Coverage Matrix and Risk Alignment.  
- Keep tables concise (IDs, short phrases only).  
- Superseded ADRs: always ensure successors cover same QAs.  
</constraints>

<formatting>
Final output must include the following sections:

1. **Section Header**
    - “Section 10.4 – Traceability of Quality Requirements to Architectural Decisions”
    - Link back to §9 (ADRs) and §11 (Risks)

2. **Summary**
    - High-priority QAs total, Covered, Gaps, Weak coverage

3. **Coverage Matrix**  
   | QA ID | Priority | Covered by (Accepted ADRs) | Partially covered (Proposed ADRs) |

4. **Gaps & Weak Coverage**
    - List all gaps and weak coverage cases

5. **Conflicts / Duplicates**
    - List ADR conflicts and duplicates

6. **Risk Alignment (High-priority QAs)**  
   | QA ID | Related Risk IDs | Mitigation present? | Note |

7. **Recommended Actions**
    - List ADRs to create, update, or consolidate

8. **Notes**
    - Superseded ADRs handled as historical; successors must appear in the matrix
    - Aggregation rule for >20 QAs
    - Only IDs in tables, prose outside
      </formatting>

<example>
# Section 10.4 – Traceability of Quality Requirements to Architectural Decisions

## Summary
High-priority QAs total: 5; Covered: 3; Gaps: 1; Weak coverage: 1

## Coverage Matrix
| QA ID | Priority | Covered by (Accepted ADRs) | Partially covered (Proposed ADRs) |
|-------|----------|----------------------------|-----------------------------------|
| P-1   | High     | ADR-003, ADR-007           | ADR-012                           |
| A-2   | High     | —                          | ADR-011                           |
| S-1   | High     | —                          | ADR-010                           |
| C-2   | High     | —                          | ADR-015                           |

## Gaps & Weak Coverage
- Gap: C-2 (High) — No Accepted ADR; Proposed: ADR-015
- Weak: S-1 (High) — Only ADR-010 (Proposed)

## Conflicts / Duplicates
- Conflict: P-1 → ADR-003 (cache TTL 30s) vs ADR-007 (strong read-through)
- Duplicate: A-1 → ADR-004 and ADR-009 overlap on failover tactics

## Risk Alignment
| QA ID | Related Risk IDs       | Mitigation present? | Note                  |
|-------|------------------------|---------------------|-----------------------|
| S-1   | RISK-INGEST-THROUGHPUT | Yes                 | OK                    |
| P-1   | RISK-QUERY-LATENCY     | No                  | Missing mitigation    |

## Recommended Actions
- Create: ADR-NEW for C-2 strong consistency path (with comparison table)
- Update: ADR-007 to reconcile with ADR-003 on P-1
- Add: risk mitigation ADR for P-1 → link to RISK-QUERY-LATENCY

## Notes
- Superseded ADRs tracked historically; successors must cover same QAs
- Medium/Low QAs aggregated if >20 total
- Tables use IDs only; explanations go in sections
  </example>

<validation>
- Verify every QA appears in the matrix.  
- Verify gaps and weak coverage are explicitly listed.  
- Verify conflicts and duplicates are identified.  
- Verify risk alignment covers all High-priority QAs.  
- Verify recommended actions are concise and actionable.  
</validation>

<output>
Return ONLY the final Section 10.4 report in Markdown.  
Do NOT add explanations, comments, or preambles.  
</output>
