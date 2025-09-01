---
mode: 'agent'
description: 'Create a Quality Tree and Quality Scenarios for the given system.'
---

<context>
You are filling out the `10_quality_requirements.adoc` section of an arc42 document.
</context>

<instructions>
Create a Quality Tree and corresponding Quality Scenarios in AsciiDoc format.
</instructions>

<constraints>
- Quality Tree must be a table with the following columns:
  * ID (short code, e.g., P-1, A-2, S-1)
  * Quality Attribute (e.g., Performance, Availability, Scalability)
  * Scenario (short name)
  * Fit Criteria (measurable)
  * Priority (High/Medium/Low)
- For each entry, create a Quality Scenario in AsciiDoc table format with these columns:
  * Source
  * Stimulus
  * Environment
  * Artifact
  * Response
  * Response Measure
- Use `====` headings for each scenario, matching the ID.
- Use **realistic, quantitative fit criteria** (latency, throughput, error rate, MTTR, etc.).
- Each scenario must reference its ID consistently.
- Output ONLY AsciiDoc format, no Markdown.
- Prefer concise scenario names.
- Keep fit criteria measurable, short, and precise.
</constraints>

<formatting>
- Quality Tree = AsciiDoc table with `|===` delimiters.
- Quality Scenarios = one table per scenario under an `==== <ID>` heading.
- IDs = `X-n` where X is an attribute prefix (P=Performance, A=Availability, S=Security, etc.).
</formatting>

<example>
.Quality Tree
|===
|ID |Quality Attribute |Scenario |Fit Criteria |Priority

|P-1 |Performance |High request throughput |System handles 10k req/sec |High
|A-1 |Availability |System recovery |MTTR < 5 min |High
|S-1 |Security |Login protection |99.9% of brute force attempts blocked |Medium
|===

==== P-1
|===
|Source |Stimulus |Environment |Artifact |Response |Response Measure

|External client |Sends requests at high volume |Production |Web application |Handles load |10k requests/sec sustained for 1 hour
|===

==== A-1
|===
|Source |Stimulus |Environment |Artifact |Response |Response Measure

|Operations team |Database node failure |Production |Clustered DB |Automatic failover |Recovery < 5 minutes
|===

==== S-1
|===
|Source |Stimulus |Environment |Artifact |Response |Response Measure

|Attacker |Brute force login attempts |Production |Authentication service |Blocks malicious attempts |>99.9% attempts blocked
|===
</example>

<validation>
- Verify every Quality Tree entry has a matching scenario.
- Verify each scenario uses realistic, quantitative measures.
- Verify AsciiDoc syntax is correct (no Markdown).
</validation>

<output>
Return ONLY AsciiDoc (`.adoc`) content.  
No explanations. No comments. No introductions.
</output>
