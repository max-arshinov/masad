---
applyTo: "**/adrs/**.md"
---

# ADR Format

Use **plain text, adr-tools style**:

```text
# <Number>. <Title>
Date: YYYY-MM-DD

## Status
<Proposed | Accepted | Deprecated | Superseded by ADR N>

## Context
<Context and forces, including drivers and QA IDs>

## Decision
<Chosen option and rationale>

## Consequences
<Positive and negative consequences>
```

- **Title** must be short and action-oriented.
- Explicitly note **superseded ADR numbers** when applicable.
- Always link ADRs to **QA IDs** for traceability.
- Always use **comparison tables** when evaluating options.
---

## Comparison Tables

Before making a decision, build a table:

| Tool / Criteria | QA1          | QA2          | QA3          | QA4          |
|-----------------|--------------|--------------|--------------|--------------|
| Tool 1          | 🟥 <Comment> | 🟨 <Comment> | 🟩 <Comment> | 🟩 <Comment> |
| Tool 2          | 🟨 <Comment> | 🟩 <Comment> | 🟨 <Comment> | 🟩 <Comment> |

- Use:
    - 🟥 = weak
    - 🟨 = medium
    - 🟩 = strong
    - 🌟 = excellent (optional)
- Always add a **Summary row** highlighting the recommended option.

---
