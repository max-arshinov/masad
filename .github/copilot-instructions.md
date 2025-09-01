<global_policy>
# Scope & Tag Semantics
- Any tag whose name starts with "global_" (i.e., `<global_* ...>...</global_*>`) is a **global (repository-wide)** rule.
- Any tag without the `global_` prefix is a **local (prompt-specific)** rule.

# Priority & Conflict Resolution
1) All `global_*` rules have higher priority than local rules.
2) Within global_* or within local scope, the **later tag overrides** earlier ones if there is a conflict.
3) When rules are lists, treat them as **cumulative**; remove exact duplicate lines.
4) Local rules cannot contradict global rules. If they do, prefer the global rule and keep the local as TODO or discard it.

# Missing Info & Consistency
- If required information is missing, write **TODO** explicitly; do not invent facts.
- Use consistent tag names and correct spelling; do not introduce new synonyms for tags.
</global_policy>

<global_tone>
- Concise, neutral, professional.
- Avoid adjectives like *easy* / *hard* — prefer measurable language.
- Do not include methodology explanations inside ADRs — keep them here.
</global_tone>
