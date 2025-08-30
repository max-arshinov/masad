---
mode: 'agent'
description: 'ADR: back-of-the-envelope estimates to identify technical risks'
---

Perform **back-of-the-envelope calculations** to validate further design choices, 
then document the result as an **Architecture Decision Record (ADR)**.

Use `10_quality_requirements.adoc` to identify relevant **Quality Attribute Requirements (QARs)**
and **Quality Attribute Scenarios (QASs)**

## Steps

1. List **key assumptions** (traffic, users, data volume, request rates, growth, etc.).
2. Make **simple estimates** (throughput, storage, latency, cost, network bandwidth, number of nodes).
    - Use orders of magnitude, not exact precision.
    - Show the math in small steps so assumptions are transparent.
3. State the **confidence level** (e.g., rough, conservative, optimistic).
4. Summarize implications (bottlenecks, feasibility, costs).
5. **Don't make any decisions yet**; just gather data to inform future decisions!