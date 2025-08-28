---
mode: 'agent'
model: GPT-5
description: 'ADR: back-of-the-envelope estimates to identify technical risks'
---

Perform **back-of-the-envelope calculations** to validate a design choice, 
then document the result as an **Architecture Decision Record (ADR)**.

Use `10_quality_requirements.adoc` to identify relevant **Quality Attribute Requirements (QARs)**
and **Quality Attribute Scenarios (QASs)**

## Steps

1. Identify the **decision to be validated** (e.g., choice of database, cluster size, storage tiering).
2. List **key assumptions** (traffic, users, data volume, request rates, growth, etc.).
3. Make **simple estimates** (throughput, storage, latency, cost, network bandwidth, number of nodes).
    - Use orders of magnitude, not exact precision.
    - Show the math in small steps so assumptions are transparent.
4. State the **confidence level** (e.g., rough, conservative, optimistic).
5. Summarize implications (bottlenecks, feasibility, costs).  