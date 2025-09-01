---
mode: 'agent'
description: 'Format a promt into the standard meta-prompt structure'
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

   ### <validation>
   - ✅ Ensure all mandatory sections are present  
   - ✅ If missing, add `<constraints>` and `<recomendations` by default  
   - ✅ Confirm `<instructions>` clearly direct the agent  
   - ✅ Check for consistency of section markers (use `<...>` OR `## ...`, not mixed randomly)  
   - ✅ If emoji ratings are referenced, include the emoji key  

   ### <example>
   **Bad input (missing sections):**
   ```
Write a risk register with risks, impact, and mitigations.
   ```

   **Corrected output:**
   ```
   ---
mode: 'agent'
description: 'Technical Risk Register'
   ---

   <context>
   You are filling out the `11_technical_risks.adoc` section of an arc42 document.  
   </context>

   <instructions>
   - Create a Technical Risk Register in AsciiDoc table format.  
   - Include ID, Risk, Related QAs, Likelihood, Impact, Mitigations, and Triggers.  
   </instructions>

   <constraints>
   - Follow AsciiDoc table syntax.  
   - Use explicit column headers.  
   </constraints>

   <recommendations>
   - Be concise and professional.  
   - Use emoji codes for Impact/Likelihood: 🟩 Low, 🟨 Medium, 🟥 High.  
   </recommendations>

   <formatting>
   - Section: `=== Technical Risk Register`  
   </formatting>
   ```
   </example>

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
- ✅ Check if header exists (`--- mode: ... description: ... ---`)  
- ✅ Ensure all mandatory sections are present or added  
- ✅ Verify consistency of section markers (<context>, <instructions>, etc.)  
- ✅ Confirm constraints and recommendations are split correctly.
- ✅ Confirm formatting rules are explicit if output structure is required  
- ✅ Ensure description is concise and action-oriented.
- ✅ Ensure promt doesn't repeat content from `adr.instructions.md`, `arc42.instructions.md`, `structurizr.instructions.md`, or copilot-instructions.md
</validation>