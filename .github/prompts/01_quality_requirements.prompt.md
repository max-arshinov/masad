---
mode: 'agent'
model: GPT-5
description: 'Create a Quality Tree and Quality Scenarios for the given system.'
---

You are filling out the `10_quality_requirements.adoc` section of an arc42 document.  
Follow these rules:

1. Create a **Quality Tree** as a table with the following columns:
    - ID (short code, e.g., P-1, A-2, S-1)
    - Quality Attribute (e.g., Performance, Availability, Scalability)
    - Scenario (short name)
    - Fit Criteria (measurable)
    - Priority (High/Medium/Low)

2. For each entry in the Quality Tree, write a **Quality Scenario** in AsciiDoc table format with the following columns:
    - Source
    - Stimulus
    - Environment
    - Artifact
    - Response
    - Response Measure

3. Use realistic, **quantitative fit criteria** (latency, throughput, error rate, MTTR, etc.).
4. Ensure each scenario references its **ID** consistently.
5. Use `====` headings for each scenario, matching the ID.

Generate the output in **AsciiDoc format**, not Markdown.