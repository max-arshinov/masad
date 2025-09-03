---
mode: 'agent'
description: 'Convert a CSV to Markdown table'
---

<context>
- You are given a `.csv` file.  
- Your job is to **read its contents** and convert it into a **Markdown table**.  
- Preserve the original structure, column order, and values.

<instructions>
- Create a new .md file using the converted Markdown table.
- Preserve the name of the original file, changing only the extension to `.md`.
</instructions>

<files>
- Create a single new .md file with the table
</files>

<output>
- Return only the Markdown table without any extra explanations.
</output>

<example>
| Year | # of users          | DB size (GB)     | RPS Write      | RPS Read          | Peak RPS Read   | Bandwidth (GB/s) | {{Other important metrics...}} |
|------|---------------------|------------------|----------------|-------------------|-----------------|------------------|--------------------------------|
| 1    | {{number of users}} | <low number}}    | {{low number}} | {{medium number}} | {{high number}} | <low number}}    | ...                            |
| 2    | {{number of users}} | <medium number}} | {{low number}} | {{high number}}   | {{high number}} | <low number}}    | ...                            |
| 3    | {{number of users}} | <high number}}   | {{low number}} | {{high number}}   | {{high number}} | <low number}}    | ...                            |
</example>