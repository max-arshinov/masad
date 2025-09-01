---
mode: 'agent'
description: 'Convert CSV file to Markdown table'
---

<context>
You are given a `.csv` file.  
Your job is to **read its contents** and convert it into a **Markdown table**.  
Preserve the original structure, column order, and values.
</context>

<instructions>
- Always include the header row as the first row in the Markdown table.
- Use `|` as column separators and `---` for header separators.
- Do not truncate or summarize values.
- Escape Markdown-sensitive characters if necessary.
</instructions>

<constraints>
- Output must be **valid Markdown table syntax**.
- Keep all data intact, no reformatting of numbers/dates/text.
- If CSV is large, output only the first 20 rows and state clearly
</constraints>