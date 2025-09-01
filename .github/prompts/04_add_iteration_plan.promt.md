---
mode: 'agent'
description: 'ADD Iteration Plan Draft'
---

<context>
You are performing **Attribute-Driven Design (ADD 3.0)**.  
Your task is to create an **iteration plan draft** for architecture design based on the project's  
- Quality Attribute Requirements (QARs) and Quality Attribute Scenarios (QASs) documented in `10_quality_requirements.adoc`  
- Risks documented in `11_technical_risks.adoc`.  

This draft serves as preparation before creating ADRs.
</context>

<instructions>
- Read and extract:
    * Business drivers (if present in the arc42 documentation).
    * Quality Attributes (QAs) with IDs, priorities, and scenario descriptions.
    * Relevant risks (technical, organizational, external).
- Build an **ADD iteration plan** that specifies:
    * Iteration goal (which QAs or risks to address).
    * Architectural drivers (business + QAs + risks).
    * Candidate architectural tactics.
    * Key design decisions expected.
- Suggest which ADRs should be created in this iteration (1 decision = 1 ADR).
</instructions>

<constraints>
- Do NOT write final ADRs — only a **plan draft** for an iteration.
- Use a structured format for readability.
- Keep it concise, professional, and neutral.
- Link explicitly to QAR/QAS IDs and risk IDs for traceability.
- No speculative technologies — keep it requirement/tactic level.
</constraints>

<formatting>
- Output must include these sections:
  1. **Iteration Goal**
  2. **Architectural Drivers** (business drivers, QAs, risks with IDs)
  3. **Quality Tree (if >3 QAs)** — table or tree structure
  4. **Candidate Tactics**
  5. **Planned ADRs**
</formatting>

<formatting>
Output table must include these columns:

| Section                  | Content                              | Traceability                  |
|--------------------------|--------------------------------------|-------------------------------|
| Iteration Goal           | <summary of the goal>                | <related QAR/QAS/Risk IDs>    |
| Architectural Drivers    | <business drivers, QA IDs, risk IDs> | <list of IDs>                 |
| Quality Tree (if >3 QAs) | <mini-tree or table representation>  | <covered QA IDs>              |
| Candidate Tactics        | <list of tactics>                    | <QA/Risk IDs addressed>       |
| Planned ADRs             | <list of ADR titles to create>       | <QA/Risk IDs each ADR covers> |
</formatting>

<example>
# ADD Iteration Plan Draft — Iteration 2

| Section                   | Content                                                                                                                                                                                                            | Traceability                                                             |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| **Iteration Goal**        | Ensure **scalability and availability** of the event ingestion pipeline under peak load.                                                                                                                           | P-1, A-2, S-1                                                            |
| **Architectural Drivers** | **Business drivers:** Support 100B events/day with <10 min latency. <br> **QAs:** high-throughput ingestion, high availability, elastic scalability. <br> **Risks:** storage engine may not scale, vendor lock-in. | P-1, A-2, S-1, R-3, R-7                                                  |
| **Quality Tree**          | - Performance → P-1 (Throughput, High) <br> - Availability → A-2 (Failover, High) <br> - Scalability → S-1 (Linear scaling, High)                                                                                  | P-1, A-2, S-1                                                            |
| **Candidate Tactics**     | - Sharding/partitioning. <br> - Replication with leader election. <br> - Load balancing with back-pressure. <br> - Cloud-agnostic deployment (Kubernetes).                                                         | P-1, A-2, S-1, R-7                                                       |
| **Planned ADRs**          | - ADR: Select primary ingestion storage. <br> - ADR: Define replication & failover strategy. <br> - ADR: Define cloud-agnostic deployment baseline.                                                                | ADR-Storage → P-1, S-1, R-3 <br> ADR-Failover → A-2 <br> ADR-Cloud → R-7 |
</example>

<validation>
- Verify table includes all required sections.
- Verify every row has traceability references (QAR/QAS IDs, Risk IDs).
- Verify no ADRs are written yet — only listed as planned.
- Verify tactics align with iteration goal and referenced IDs.
</validation>

<output>
Return ONLY the **iteration plan draft** as a markdown table with 3 columns.  
No explanations. No comments. No introductions.
</output>