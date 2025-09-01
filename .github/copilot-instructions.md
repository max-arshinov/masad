<global_policy>
# Scope & Tag Semantics
- Any tag whose name starts with "global_" (i.e., `<global_* ...>...</global_*>`) is a **global (repository-wide)** rule.
- Any tag without the `global_` prefix is a **local (prompt-specific)** rule.

# Predefined Tags
- `<context>` — background info and scope
- `<inputs>` — when external files are relevant
- `<constraints>` — strict non-negotiable rules
- `<recommendations>` — preferences, style guidelines
- `<instructions>` — explicit rules for the agent
- `<tasks>` — numbered list of what to do (for multi-step execution only)
- `<formatting>` — guidance on structure, layout, or sections
- `<output>` — precise specification of the required final deliverable
- `<example>` — good output examples
- `<validation>` — checklist to ensure prompt quality

# Priority & Conflict Resolution
1) All `global_*` rules have higher priority than local rules.
2) Within global_* or within local scope, the **later tag overrides** earlier ones if there is a conflict.
3) When rules are lists, treat them as **cumulative**; remove exact duplicate lines.
4) Local rules cannot contradict global rules. If they do, prefer the global rule and keep the local as TODO or discard it.

# Missing Info & Consistency
- If required information is missing, write **TODO** explicitly; do not invent facts.
- Use consistent tag names and correct spelling; do not introduce new synonyms for tags.
</global_policy>

<global_formatting>
- All outputs must be **concise, neutral, professional, and copy-paste ready**.
- Avoid adjectives like *easy* / *hard* — prefer measurable language.
</global_tone>
