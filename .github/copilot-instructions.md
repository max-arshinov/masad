<global_policy>
# Scope & Tag Semantics
- Any tag whose name starts with "global_" (i.e., `<global_* ...>...</global_*>`) is a **global (repository-wide)** rule.
- Any tag without the `global_` prefix is a **local (prompt-specific)** rule.

# Predefined Tags
- `<context>` — background info and scope
- `<inputs>` — additional files to read if not already in context
- `<constraints>` — strict non-negotiable rules
- `<recommendations>` — preferences, style guidelines
- `<instructions>` — explicit rules for the agent
- `<tasks>` — numbered list of what to do (for multi-step execution only)
- `<files>` - explicit instructions on file-level I/O in the repo: creation, modification, deletion, etc.
- `<formatting>` — guidance on structure, layout, or sections
- `<output>` — precise specification of the required final deliverable
- `<example>` — good output example
- `<validation>` — checklist to ensure prompt quality

# Priority & Conflict Resolution
1) All `global_*` rules have higher priority than local rules.
2) Within global_* or within local scope, the **later tag overrides** earlier ones if there is a conflict.
3) When rules are lists, treat them as **cumulative**; remove exact duplicate lines.
4) Local rules cannot contradict global rules. If they do, prefer the global rule and keep the local as TODO or discard it.

# Missing Info & Consistency
- If required information is missing, write **TODO** explicitly; do not invent facts.
- Use consistent tag names and correct spelling; do not introduce new synonyms for tags.

# Placeholders
- Double curly brackets (e.g.: ``{{Number}}``, ``{{Text}}``, etc...) represent placeholders.
- Placeholders define text that must later be replaced by concrete values in generated outputs.  
</global_policy>

<global_formatting>
- All outputs must be **concise, neutral, professional, and copy-paste ready**.
- Avoid adjectives like *easy* / *hard* — prefer measurable language.
</global_tone>
