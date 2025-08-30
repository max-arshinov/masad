
---

## 1. Methodology

- Follow **Attribute-Driven Design (ADD 3.0)**.
- Capture **only one key decision per ADR**.
- Each ADR must identify:
    - Business drivers
    - Quality attributes (referenced by ID from the quality tree)
    - Architectural tactics addressing these attributes
    - Final design decision

---

## 2. Workflow

1. Extract **business drivers**.
2. Extract **quality attributes** (ADD 3.0 style).
3. If more than 3 critical QAs → build a **quality tree** with IDs.
4. If technology/tool selection is involved → build a **comparison table**.
5. Write **one ADR per decision** in adr-tools format.
6. Each ADR must reference:
    - Related drivers
    - Related QAs (by ID, e.g. P-1, A-2, C-2)
    - Related ADRs (if superseding or related)

---


## 3. Tone & Style

- Concise, neutral, professional.
- Avoid adjectives like *easy* / *hard* — prefer measurable language.
- Do not include methodology explanations inside ADRs — keep them here.

---
# arc42 Workflow

This file provides a step-by-step guide for filling in an arc42 template.  
Keep it concise and use as a companion to `copilot-instructions.md`.

---

## How to Work with the Template

1. **Introduction and Goals**  
   - File: `01_introduction_and_goals.adoc`  
   - Fill out business context, stakeholders, and quality goals.  
   - Requirements are essential to validate design decisions.

2. **Architecture Constraints**  
   - File: `02_architecture_constraints.adoc`  
   - Capture technical, organizational, or regulatory constraints.

3. **Quality Requirements**  
   - File: `10_quality_requirements.adoc`  
   - Create a quality tree and assign IDs (e.g., P-1, A-2).  
   - Summarize the most important ones as "Quality Goals" in `01_introduction_and_goals.adoc`.

4. **Risks and Technical Debts**  
   - File: `11_technical_risks.adoc`
   - Perform back-of-the-envelope calculations for key quality attributes and identify risks.
   - Capture known risks and open issues.

5. **System Scope and Context**  
   - File: `03_system_scope_and_context.adoc`  
   - Add **C4 Landscape + Context diagrams** (business + technical).

6. **Solution Strategy**  
   - File: `04_solution_strategy.adoc`  
   - Summarize key design principles and trade-offs.  
   - Reference major ADRs here.

7. **Building Block View**  
   - File: `05_building_block_view.adoc`  
   - Add **C4 Container + Component diagrams** where useful.

8. **Runtime View**  
   - File: `06_runtime_view.adoc`  
   - Use dynamic diagrams to show runtime interactions.

9. **Deployment View**  
   - File: `07_deployment_view.adoc`  
   - Add C4 Deployment diagrams.

10. **Concepts**  
    - File: `08_concepts.adoc`  
    - Put shared or repeated information here to avoid duplication.

11. **Glossary**  
    - File: `12_glossary.adoc`  
    - Define domain-specific terms.

12. **Cleanup**  
    - Delete unused sections to keep documentation concise.

---

## Design Process

- Apply **ADD 3.0** iteratively: design the riskiest parts first.  
- Update the model and ADRs after each iteration.  
- Use **comparison tables** in ADRs to evaluate options.  
- Maintain **traceability**: ADRs ↔ QA IDs ↔ architecture sections.

---
