---
mode: 'agent'
description: 'Add containers to the Structurizr model'
---

<context>
When given a system description, identity the main technical decisions (technologies, frameworks, databases) 
and define their interactions with users, each other, and other systems.
</context>

<inputs>
- ./docs/src/04_solution_strategy.adoc
- ./adrs/*.md
</inputs>

<instructions>
Edit `model.dsl`, add containers and relationships to the target `softwareSystem`.
</instructions>

<constraints>
- Prefer one of the following container "archetypes":
    - webApp
    - api
    - datastore
    - broker
    - kafka
    - mobile
    - react
    -cache
- NO components, or deployment nodes
- NO views or styling commands
- use !identifiers hierarchical: `softwareSystem.containerName` not `containerName` alone when outside the `softwareSystem` definition
</constraints>

<formatting>
- Elements (`container` and the archetypes listed above) = singular nouns.
- Relationships = verb phrases ("Creates order", "Uploads file to").
- Use quoted names and short descriptions (≤15 words).
- One entity per line.
- ALWAYS use `lowerCamelCase` for variable names.
- Output order: `elements` then `relationships`.
</formatting>

<files>
- Edit `model.dsl`, don't create or modify other files.
<files>

<example>
urlShortener = softwareSystem "URL Shortener" "Generates short URLs and redirects." {
    db = datastore "Database" "Stores URL mappings." "PostgreSQL"
    cache = cache "Web Application" "Allows users to create short URLs." "Redis"
    api = api "API" "Handles URL shortening and redirection." "Node.js"
    api --sdk-> cache "Reads from and writes to"
    api --sdk-> db "Reads from and writes to"
}

user --https-> urlShortener.api "Creates short link"
</example>

<validation>
- [] Verify all variable names use lowerCamelCase
- [] Ensure relationship syntax uses `--protocol->` format
- [] Check that descriptions are ≤15 words
</validation>