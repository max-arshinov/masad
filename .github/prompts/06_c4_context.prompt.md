---
mode: 'agent'
description: 'Add software systems and persons to a Structurizr model'
---

<instructions>
Edit `model.dsl`, add target software systems, persons, and relationships.
</instructions>

<context>
When given a system description, identify the core actors and main system, then define their primary interactions.
</context>

<constraints>
- Use ONLY these three elements: `person`, `softwareSystem`, `relationship`
- NO containers, components, or deployment nodes
- NO views or styling commands
</constraints>

<formatting>
- Elements (`softwareSystem` and `person`) = singular nouns.
- Relationships = verb phrases ("Creates order", "Uploads file to").
- Use quoted names and short descriptions (≤15 words).
- One entity per line.
- ALWAYS use `lowerCamelCase` for variable names.
- Output order: `softwareSystem` first, then `person`, then `relationship`.
</formatting>

<example>
urlShortener = softwareSystem "URL Shortener" "Generates short URLs and redirects."

customer = person "Customer" "End user who creates and opens short links."
administrator = person "Administrator" "Manages policies and abuse reports."

customer --https-> urlShortener "Creates short link"
administrator --https-> urlShortener "Reviews abuse reports"
</example>

<validation>
- Verify all variable names use lowerCamelCase
- Ensure relationship syntax uses "--protocol->" format
- Check that descriptions are ≤15 words
</validation>