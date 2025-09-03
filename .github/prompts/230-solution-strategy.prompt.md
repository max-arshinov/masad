---
mode: 'agent'
description: 'Summarize ADRs into Solution Strategy (arc42 §5)'
---

<context>
You are preparing the **Solution Strategy** section (`05_solution_strategy.adoc`) of an arc42 document.  
This section explains the fundamental strategic decisions, approaches, and solution patterns of the system.  
You must summarize all existing ADRs to extract the core architectural strategy.  
</context>

<inputs>
- `./adrs/*.md` — Architecture Decision Records in adr-tools format  
- `./10_quality_requirements.adoc` — for mapping strategic drivers (QARs/QASs)  
</inputs>

<constraints>
- Output must be in **AsciiDoc** format.  
- Only include ADRs with status `Accepted` or `Proposed`.  
- Ignore Deprecated or Superseded ADRs (but mention gaps if important).  
- Do not repeat full ADR content — instead, summarize strategic intent and reasoning.  
</constraints>

<recommendations>
- Group ADRs by **architectural theme** (e.g., persistence, communication, deployment, observability).  
- Highlight **tactics** that address quality requirements.  
- Keep explanations concise and high-level.  
- Use bullet lists and subsections for readability.  
</recommendations>

<instructions>
- Parse all ADRs and extract:
  * Title and ID  
  * Decision summary  
  * Related QARs/QASs  
- Synthesize these into a cohesive strategy narrative for arc42 §5.  
- Organize output into:
  * **Overall approach** (summary of guiding principles)  
  * **Strategic decisions** (grouped by theme)  
  * **Key trade-offs** (what was prioritized, what was accepted as risk)
- Edit `04_solution_strategy.adoc`
</instructions>

<tasks>
1. Load all ADRs in the repository.  
2. Filter out Deprecated or Superseded.  
3. Extract accepted/proposed decisions and their QARs/QASs.  
4. Group them thematically.  
5. Write `05_solution_strategy.adoc` with subsections:  
   - Overall approach  
   - Strategic decisions (by theme)  
   - Key trade-offs  
</tasks>

<formatting>
- Use AsciiDoc headers:  
  * `== Solution Strategy`  
  * `=== Overall Approach`  
  * `=== Strategic Decisions`  
  * `=== Key Trade-offs`  
- Use bullet lists for decisions.  
- Cross-reference ADR IDs where applicable.  
</formatting>

<files>
- Edit `04_solution_strategy.adoc` only, don't moldify other files.
</files>

<output>
- Return only the AsciiDoc section text (not explanations).  
- Include references to ADR IDs in parentheses.  
</output>

<validation>
- All ADRs are considered (except superseded/deprecated).  
- Content structured into the 3 required subsections.  
- Uses AsciiDoc syntax.  
- Summaries stay high-level and strategic, not low-level details.  
- Cross-references ADR IDs consistently.  
</validation>
