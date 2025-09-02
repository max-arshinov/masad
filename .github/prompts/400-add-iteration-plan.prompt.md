---
mode: 'agent'
description: 'Create ADD iteration plan draft for architecture design'
---

<context>
You are performing **Attribute-Driven Design (ADD 3.0)**.  
Your task is to create an **iteration plan draft** for architecture design based on the project's Quality Attribute Requirements (QARs), Quality Attribute Scenarios (QASs), and identified risks.

This draft serves as preparation before creating ADRs.
</context>

<inputs>
- Quality Attribute Requirements (QARs) and Quality Attribute Scenarios (QASs) documented in `../10_quality_requirements.adoc`  
- Risks documented in `../11_technical_risks.adoc`
- Existing ADRs in `./**.md`
- Business drivers (if present in the arc42 documentation)
</inputs>

<instructions>
- Read and extract:
    * Business drivers (if present in the arc42 documentation)
    * Quality Attributes (QAs) with IDs, priorities, and scenario descriptions
    * Relevant risks (technical, organizational, external)
- Build an **ADD iteration plan** that specifies:
    * Iteration goal (which QAs or risks to address)
    * Architectural drivers (business + QAs + risks)
    * Candidate architectural tactics
    * Key design decisions expected
- Suggest which ADRs should be created in this iteration (1 decision = 1 ADR)
</instructions>

<constraints>
- Do NOT write final ADRs — only a **plan draft** for an iteration
- Link explicitly to QAR/QAS IDs and risk IDs for traceability
- No speculative technologies — keep it requirement/tactic level
- Use structured format for readability
- Keep it concise, professional, and neutral
</constraints>

<formatting>
Output must be a markdown table with 3 columns containing these columns:
1. **Iteration Goal**
2. **Architectural Drivers** (business drivers, QAs, risks with IDs)
3. **Quality Tree (if >3 QAs)** — table or tree structure
4. **Candidate Tactics**
5. **Planned ADRs**

Each row must include traceability references (QAR/QAS IDs, Risk IDs) in the third column.
</formatting>

<files>
- Create a new markdown file one level above the `adrs` folder (e.g., `add-iteration-plan-draft.md`)
- Don't modify or add other files
</files>

<output>
Return ONLY the **iteration plan draft** as a markdown table.
No explanations. No comments. No introductions.
</output>

<validation>
- Verify table includes all required sections
- Verify every row has traceability references (QAR/QAS IDs, Risk IDs)
- Verify no ADRs are written yet — only listed as planned
- Verify tactics align with iteration goal and referenced IDs
- Check header exists with mode and description
- Ensure all mandatory sections are present
- Verify consistency of section markers
</validation>
