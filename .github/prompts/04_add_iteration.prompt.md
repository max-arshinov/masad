---
mode: 'agent'
description: 'ADR Iteration'
---

<instructions>
- Capture exactly **one key decision per ADR**.
- Extract and document:
  * Quality attributes (referenced by ID from the quality tree `10_quality_requirements.adoc`)
  * Architectural tactics addressing these attributes
  * Final design decision
- If more than 3 critical QAs → build a **quality tree** with IDs.
- If tool/technology selection is involved → build a **comparison table**.
- Explicitly link ADRs to **QA IDs** and superseded ADRs.
</instructions>

<constraints>
- Follow ADR format (adr-tools style).
- Title must be short and action-oriented.
- Always use **comparison tables** when evaluating options.
- Use rating emojis in tables:
  * 🟥 = weak
  * 🟨 = medium
  * 🟩 = strong
  * 🌟 = excellent (optional)
- Keep explanations concise, neutral, and professional.
- Do not explain ADD methodology inside ADRs — keep it here.
</constraints>

<example>
# 10. Select DB Model and Product for Org Hierarchies, RBAC, and Plans
Date: 2025-09-01

## Status
Proposed

## Context
- Iteration goal: choose **DB model** and **concrete DB** to store:
    * client organizations with hierarchical departments,
    * users/employees, roles/permissions (RBAC, ABAC where needed),
    * pricing/tariff plans and tenant quotas for a large multi-tenant SaaS.
- Business drivers: correctness and security of access control, strong consistency for billing/entitlements, good developer productivity, and cost efficiency.
- Relevant QAs (IDs):  
  P-1 Throughput (read/write), A-1 Availability, C-1 Cost Efficiency, S-1 Scalability (horizontal), D-1 Developer Productivity, I-1 Integrity & ACID, Sec-1 Fine-grained Access Control, MT-1 Multi-tenancy Isolation.

## Decision
### Table 1 — Compare **DB Models** against key criteria

| DB Model                      | Modeling Hierarchies | Data Flexibility  | Complex Relational Ops     | Scalability & Perf   | Security/Access    | Consistency/Integrity | Transactions (ACID) | Multi-Tenancy   |
|-------------------------------|----------------------|-------------------|----------------------------|----------------------|--------------------|-----------------------|---------------------|-----------------|
| Relational (row-oriented)     | 🟩 via joins/FKs     | 🟩 (JSON/columns) | 🌟 rich joins, constraints | 🟨 vert.+ext. horiz. | 🌟 mature RBAC/RLS | 🌟 strong (ACID)      | 🌟 full ACID        | 🟩 schema/RLS   |
| Relational (column-oriented)  | 🟨                   | 🟥 rigid          | 🟨                         | 🟩 analytics scale   | 🟨                 | 🟩                    | 🟨 limited          | 🟨              |
| Document (e.g., MongoDB)      | 🟩 nested docs       | 🌟 flexible       | 🟨 limited joins           | 🟩 horiz.            | 🟨 custom models   | 🟨 eventual (tunable) | 🟨 single-doc ACID  | 🟨 via sharding |
| Graph (e.g., Neo4j)           | 🌟 native            | 🟩                | 🟩 path queries            | 🟨 horiz. is hard    | 🟨                 | 🟩                    | 🟩                  | 🟨              |
| Wide-column (e.g., Cassandra) | 🟨 limited           | 🟩 semi-flexible  | 🟥 complex queries         | 🌟 horiz.            | 🟨 basic           | 🟥 eventual           | 🟥 limited          | 🟨 keyspaces    |
| Search (e.g., Elasticsearch)  | 🟨                   | 🟩 semi-flexible  | 🟥 relational              | 🟩 horiz. queries    | 🟨                 | 🟥 eventual           | 🟥 none             | 🟨 indices      |
| NewSQL (e.g., CockroachDB)    | 🟩 relational model  | 🟩                | 🌟 rich joins              | 🟩 horiz.            | 🟩 RBAC            | 🌟 strong (ACID)      | 🌟 full ACID        | 🟩 built-in     |

**Shortlist by model:** **Relational (row-oriented)** and **NewSQL** best satisfy Sec-1, I-1, MT-1 and complex relational needs (RBAC, billing, entitlements).

### Table 2 — Compare **Concrete Databases** (from the shortlist)

| Database               | Hierarchies       | Relational Ops               | Scalability             | Maintainability   | Security/Access         | Consistency | ACID | Multi-Tenancy     |
|------------------------|-------------------|------------------------------|-------------------------|-------------------|-------------------------|-------------|------|-------------------|
| **PostgreSQL**         | 🟩 via CTEs/ltree | 🌟 (joins, constraints, RLS) | 🟨 vert.+extensions     | 🟩 mature tooling | 🌟 RBAC + RLS/Row-Level | 🌟          | 🌟   | 🟩 schemas + RLS  |
| **CockroachDB**        | 🟩                | 🌟                           | 🟩 horiz., resilient    | 🟨 ops complexity | 🟩 RBAC                 | 🌟          | 🌟   | 🟩 multi-tenant   |
| **Amazon Aurora (PG)** | 🟩                | 🌟                           | 🟩 managed read scaling | 🌟 managed        | 🌟 (AWS IAM + PG)       | 🌟          | 🌟   | 🟩 (schemas + SR) |
| **MongoDB**            | 🟩 (docs)         | 🟨                           | 🟩                      | 🟩                | 🟨                      | 🟨          | 🟨   | 🟨                |
| **Neo4j**              | 🌟                | 🟨                           | 🟨                      | 🟨                | 🟨                      | 🟩          | 🟩   | 🟨                |

**Decision:** Prefer **PostgreSQL** as the primary operational store for org hierarchies, RBAC (RLS), entitlements, and billing—balancing ACID guarantees, fine-grained access control, and developer productivity. Consider **Aurora PostgreSQL** or **CockroachDB** where managed horizontal scale or multi-region resilience is a hard requirement.  
Supersedes: none.

## Consequences
- ✅ Strong integrity for permissions/billing (I-1, Sec-1), clear tenancy isolation via schemas + RLS (MT-1).
- ⚠️ Horizontal write scaling requires sharding/partitioning or a managed/Distributed PG (Aurora read scaling; CockroachDB for multi-region writes).
- Follow-ups: ADRs on sharding strategy, RLS policy design, tenancy keying, and read replica/caching for hot paths.
  </example>

<validation>
- Verify ADR includes business drivers, QA IDs, one clear decision.
- Verify **both** comparison tables exist (models → products) and use the emoji scale.
- Verify the chosen option is justified by QA trade-offs and consequences.
</validation>

<output>
Return ONLY ADR text in adr-tools format.  
No explanations. No comments. No introductions.
</output>
