---
mode: 'agent'
description: 'ADR: identify parameters and assumptions before estimation'
---

<context>
You are preparing the groundwork for a back-of-the-envelope estimation ADR.  
Your task is to extract and document **assumptions, parameters, and relevant quality attributes**,  
but you MUST NOT perform any calculations yet.
</context>

<instructions>
- Create a new ADR draft in adr-tools style.
- Identify and list:
  * all key assumptions (e.g., user growth, actions per user, peak multipliers),
  * relevant Quality Attribute Requirements (QARs) and Scenarios (QASs),
  * significant system parameters that will later require numeric estimation  
    (e.g., # of users, DB size, write/read RPS, peak RPS, storage, bandwidth).
- Extract all important numbers per relevant QARs/QASs.
</instructions>

<constraints>
- List important QARs/QASs and numbers that further will be used in the back-of-the-envelope calcualtions.
- Do NOT perform any numeric calculations.
- Do NOT include projection tables — only list parameters that will appear there later.
- Ensure Context section references QARs/QASs explicitly.
</constraints>

<formatting>
- ADR sections: Title, Date, Status, Context, Decision, Consequences.
- Title: short and action-oriented (e.g., "Identify Parameters for Estimation of Technical Risks").
- Status: "Proposed".
- Context: list assumptions and referenced QARs/QASs with relevant numbers in the table format.
- Decision: describe which parameters will be estimated later, but do not calculate them.
- Consequences: note what kind of risks will be analyzed once estimates are done.
</formatting>

<output>
Return ONLY ADR text in adr-tools format.  
No explanations. No calculations. No comments.
</output>
