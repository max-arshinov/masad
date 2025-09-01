---
mode: 'agent'
description: 'Generate Quality Tree and Quality Scenarios for arc42 section 10'
---

<context>
You are creating quality requirements documentation for arc42 section `10_quality_requirements.adoc`.
Quality scenarios use the standard architecture evaluation format with measurable criteria.
</context>

<inputs>
- `./10_quality_requirements.adoc`
- `./01_introduction_and_goals.adoc`
</inputs>

<instructions>
- Create a Quality Tree table listing all quality attributes with IDs, scenarios, and fit criteria
- Generate detailed Quality Scenario tables for each Quality Tree entry
- Use consistent ID referencing between Quality Tree and individual scenarios
- Apply quantitative, realistic measurements for all fit criteria and response measures
</instructions>

<constraints>
- Quality Tree columns: ID, Quality Attribute, Scenario, Fit Criteria, Priority
- Quality Scenario columns: Source, Stimulus, Environment, Artifact, Response, Response Measure  
- Use `====` headings for each scenario matching the Quality Tree ID
- ID format: `X-n` where X = attribute prefix (P=Performance, A=Availability, S=Security, etc.)
- All fit criteria must be quantitative (latency, throughput, error rate, MTTR, etc.)
- Scenario names must be concise and descriptive
- Priority levels: High/Medium/Low only
- Output ONLY AsciiDoc format, no Markdown
</constraints>

<formatting>
- Quality Tree: AsciiDoc table with `|===` delimiters
- Quality Scenarios: individual tables under `==== <ID>` headings
- Use `===Quality Tree` table caption
- Maintain consistent spacing and alignment
</formatting>

<output>
Return complete AsciiDoc content ready for inclusion in arc42 documentation.
No explanations, comments, or introductory text.
</output>

<example>
=== Quality Tree
|===
|ID |Quality Attribute |Scenario |Fit Criteria |Priority

|P-1 |Performance |High request throughput |System handles 10k req/sec |High
|A-1 |Availability |System recovery |MTTR < 5 min |High
|S-1 |Security |Login protection |99.9% of brute force attempts blocked |Medium
|===

=== Quality Secenarios

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
- Every Quality Tree entry has a corresponding scenario section
- All fit criteria and response measures are quantitative
- AsciiDoc syntax is valid (no Markdown elements)
- ID references are consistent between Quality Tree and scenarios
- Section headings use correct AsciiDoc format (`====`)
</validation>
