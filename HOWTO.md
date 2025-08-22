# How to work with the template

1. Fill all sections in "Introduction and Goals" and "Architecture Constraints" (01_introduction_and_goals.adoc, 02_architecture_constraints.adoc).
You absolutely need the requirements to validate your design decisions.
All template sections contain tips and examples. Follow them if you're not sure what to write.
2. If you have enough time, fill "Quality Requirements" (10_quality_requirements.adoc) and summarize the most important ones in "Quality Goals" (a subsection in 01_introduction_and_goals.adoc).
3. Fill "Risks and Technical Debts" (11_technical_risks.adoc).
4. Use ADD 3.0 to create the architecture model. Start the design with the most risky parts. On each iteration, update
your model and ADRs accordingly. Use comparison tables to evaluate different design options in your ADRs.
5. Embed your C4 Landscape (if needed) and Context diagrams in the "System Scope and Context/Business Context" section (03_system_scope_and_context.adoc).
6. Embed your most important C4 Container diagram in the "System Scope and Context/Technical Context" section (03_system_scope_and_context.adoc).
7. Consider embedding other C4 Container and Component diagrams in the "Building Block View" section (05_building_block_view.adoc).
8. Embed your Dynamic diagrams in the "Runtime View" section (06_runtime_view.adoc).
9. Embed your Deployment diagrams in the "Deployment View" section (07_deployment_view.adoc).
10. If you have to repeat yourself, consider putting shared information into "Concepts" (08_concepts.adoc).
11. Summarize your design decisions in "Solution Strategy" (04_solution_strategy.adoc).
12. Fill out "Glossary" if you have many domain-specific terms (12_glossary.adoc).
13. Delete the documentation sections you didn't use.
