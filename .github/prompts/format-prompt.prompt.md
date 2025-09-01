---
mode: 'agent'
description: 'Format a prompt into the standard meta-prompt structure'
---

<context>
You are validating and improving prompts written for architecture/system design tasks.  
All prompts must follow the **standard meta-prompt format**:

1. YAML-like header:
    ---
    mode: 'agent'
    description: '<short purpose>'
    ---

2. Body must include **clear sections** (as applicable):

   ### Required Sections
   - `<context>` — background info and scope  
   - `<instructions>` — explicit rules for the agent  
   - `<constraints>` — strict non-negotiable rules  
   - `<recommendations>` — preferences, style guidelines  
   - `<formatting>` — required output format  
   - `<inputs>` — when external files are relevant  
   - `<tasks>` — numbered list of what to do  
   - `<validation>` — checklist to ensure prompt quality
   - `<example>` — good and bad input/output examples
   - Optional emoji coding rules (🟥/🟨/🟩/🌟, etc.)  

   ### Validation
   - Ensure all mandatory sections are present  
   - If missing, add them
   - Confirm `<instructions>` clearly direct the agent  
   - Check for consistency of section markers (always use `<...>`)  
   - If emoji ratings are referenced, include the emoji key  

   ### Example
   ```
---
mode: 'agent'
description: 'Generate arc42 Technical Risks section'
---

<context>
We are documenting the `11_technical_risks.adoc` section of an arc42 architecture document.  
The goal is to capture potential technical risks, their impact, likelihood, and mitigations.  
</context>

<inputs>
- `10_quality_requirements.adoc` — list of quality attributes and scenarios  
- Known project decisions from ADRs (`adrs/*.md`)  
</inputs>

<constraints>
- Output must be in **AsciiDoc** format (not Markdown).  
- Risk table must have all required columns: ID, Risk, Related QAs, Likelihood, Impact, Mitigations, Triggers.  
- Impact and Likelihood must use emoji codes: 🟩 Low, 🟨 Medium, 🟥 High.  
</constraints>

<recommendations>
- Keep descriptions concise and professional.  
- Use short identifiers (e.g., RISK-001).  
- Focus on measurable mitigations (not vague ideas).  
</recommendations>

<instructions>
- Fill out the **Technical Risk Register** table in AsciiDoc.  
- Add a **Technical Debts** subsection below the table as a bullet list.  
</instructions>

<tasks>
1. Extract relevant risks from QAs and ADRs.  
2. Build the AsciiDoc table with required columns.  
3. Append the Technical Debts subsection.  
</tasks>

<formatting>
- Use `=== Technical Risk Register` for the table heading.  
- Use `=== Technical Debts` for the debt list.  
- Table format:  
  ```
  [options="header"]
  |===
  |ID |Risk |Related QAs |Likelihood |Impact |Mitigations |Triggers
  |===
  ```
</formatting>

<output>
- Must return **AsciiDoc** text only.  
- Do not include explanations outside the document body.  
</output>

<example>
=== Technical Risk Register

[options="header"]
|===
|ID |Risk |Related QAs |Likelihood |Impact |Mitigations |Triggers

|RISK-001 |Database latency under high load |P-1, S-1 |🟨 Medium |🟥 High |Introduce caching layer; perform load testing |P95 latency > 200ms
|RISK-002 |Team lacks runbook for failures |O-3 |🟩 Low |🟨 Medium |Create on-call runbook and automation scripts |On-call engineer escalates without clear steps
|===

=== Technical Debts
- Missing runbooks for database recovery
- No automated chaos testing in CI/CD  
</example>

<validation>
- YAML header present with mode + description  
- Context and Inputs sections defined  
- Constraints clearly separate from Recommendations  
- Risk table includes all required columns  
- Emojis used for Impact and Likelihood  
- Output in AsciiDoc only, no Markdown  
- Example provided as reference  
</validation>
   ```

3. Use **consistent section headings** with angle brackets (`<instructions>`).

4. All outputs must be **concise, professional, and copy-paste ready**.

</context>

<instructions>
- If the input prompt already follows the format, only polish grammar and consistency.  
- If it does **not** follow the format, **rewrite it into the full structure** above.  
- Preserve all user intent, domain specifics, and details.  
- Add missing sections (e.g., constraints, formatting, emoji rules) when relevant.  
- Ensure the **description** in the header is short and action-oriented.  
- Never drop technical detail, only reorganize and clarify.  
</instructions>

<constraints>
- Do not invent new requirements.  
- Always return a single improved prompt in the specified format.  
- Never output explanations outside the formatted prompt.  
</constraints>

<recommendations>
- Prefer brevity in section titles.  
- Use emoji color codes where risks, trade-offs, or comparisons are present.  
- Keep tone directive (for agents), not narrative.  
</recommendations>

<validation>
- Check if header exists (`--- mode: ... description: ... ---`)  
- Ensure all mandatory sections are present or added  
- Verify consistency of section markers (<context>, <instructions>, etc.)  
- Confirm constraints and recommendations are split correctly.
- Confirm formatting rules are explicit if output structure is required  
- Ensure description is concise and action-oriented.
- Ensure promt doesn't repeat content from `adr.instructions.md`, `arc42.instructions.md`, `structurizr.instructions.md`, or copilot-instructions.md
</validation>