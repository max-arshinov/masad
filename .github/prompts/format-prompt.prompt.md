---
mode: 'agent'
description: 'Format a prompt into the standard meta-prompt structure'
---

<context>
You are validating and improving prompts written for architecture/system design tasks.  
All prompts must follow the **standard meta-prompt format**:
</context>

<instructions>
- If the input prompt already follows the format, only polish grammar and consistency.  
- If it does **not** follow the format, **rewrite it into the full structure** above.  
- Preserve all user intent, domain specifics, and details.  
- Add missing sections (e.g., constraints, formatting, emoji rules) when relevant.  
- Ensure the **description** in the header is short and action-oriented.  
- Never drop technical detail, only reorganize and clarify.
- Ensure that the required sections are sorted as they list in the `<constraints>`.
- Delete duplicated instructions per section if they already appear in `adr.instructions.md`, `arc42.instructions.md`, `structurizr.instructions.md`, or copilot-instructions.md
</instructions>

<constraints>
- ALWAYS use YAML-like header:
    ```
    ---
    mode: 'agent'
    description: '<short purpose>'
    ---
    ```
- The formatted prompt must include these sections:
    - `<context>` — background info and scope  
    - `<inputs>` — when external files are relevant  
    - `<instructions>` — explicit rules for the agent  
    - `<tasks>` — numbered list of what to do (for multi-step execution only, otherwise omit)
    - `<constraints>` — strict non-negotiable rules  
    - `<recommendations>` — preferences, style guidelines  
    - `<formatting>` — required output format  
    - `<output>` — precise specification of the required final deliverable
    - `<example>` — good output example
    - `<validation>` — checklist to ensure prompt quality
- Do not invent new requirements.  
- Always return a single improved prompt in the specified format.  
- Never output explanations outside the formatted prompt.  
</constraints>

<recommendations>
- Prefer brevity in section titles.  
- Use emoji color codes where risks, trade-offs, or comparisons are present.  
- Keep tone directive (for agents), not narrative.  
</recommendations>

<formatting>
- Use **consistent section headings** with angle brackets (`<instructions>`).
- All outputs must be **concise, professional, and copy-paste ready**.
</formatting>

<validation>
- Check if header exists (`--- mode: ... description: ... ---`)  
- Ensure all mandatory sections are present or added  
- If missing, add them
- Verify consistency of section markers (<context>, <instructions>, etc.)  
- Confirm constraints and recommendations are split correctly.
- Confirm formatting rules are explicit if output structure is required  
- Ensure description is concise and action-oriented.
- Ensure prompt doesn't repeat content from `adr.instructions.md`, `arc42.instructions.md`, `structurizr.instructions.md`, or copilot-instructions.md
- Confirm `<instructions>` clearly direct the agent
- Check for consistency of section markers (always use `<...>`)
- If emoji ratings are referenced, include the emoji key.
</validation>