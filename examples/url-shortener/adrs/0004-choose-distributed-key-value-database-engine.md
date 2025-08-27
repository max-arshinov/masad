# 4. Choose distributed key-value database engine

Date: 2025-08-27

## Status
Accepted

## Context
From ADR 0003 we selected the engine type: a distributed key-value / wide-column database as the durable source of truth for slug→URL mappings, with conditional create to ensure uniqueness and native TTL for lifecycle management. The workload is dominated by single-key reads with tight latency (p50 ≤ 0.2s) at high throughput (~35k rps overall), and steady writes with occasional retries on slug collisions. We need horizontal scalability, high availability, native TTL, operability (prefer managed options), and reasonable multi-region capabilities. Portability is valuable to avoid hard vendor lock-in.

Alternatives and criteria:

| Alternative                         | Data model fit | Conditional create/uniqueness | Read latency @ scale | Horizontal scaling | Native TTL | Multi-region topology | Consistency options | Operability/managed | Cost model            | Ecosystem/clients | Portability/lock-in |
|-------------------------------------|----------------|-------------------------------|----------------------|-------------------|-----------|-----------------------|---------------------|---------------------|----------------------|-------------------|---------------------|
| Apache Cassandra                    | ★★★           | ★★★ LWT/IF NOT EXISTS         | ★★                   | ★★★               | ★★★       | ★★ Geo via multi-DC   | ★★ Tunable          | ★★ Managed exists   | ★★ Infra-based       | ★★★               | ★★★                 |
| ScyllaDB (C*-compatible)            | ★★★           | ★★★ LWT/IF NOT EXISTS         | ★★★                  | ★★★               | ★★★       | ★★ Geo via multi-DC   | ★★ Tunable          | ★★ Managed exists   | ★★ Infra-based       | ★★                | ★★★                 |
| Amazon DynamoDB                     | ★★★           | ★★★ ConditionExpression       | ★★★                  | ★★★               | ★★★       | ★★★ Global tables     | ★★ Tunable-ish      | ★★★ Fully managed   | ★ Provisioned/On-demand | ★★              | ★                   |
| Google Cloud Bigtable               | ★★★           | ★★ CheckAndMutateRow          | ★★★                  | ★★★               | ★★        | ★★ Regional + DR      | ★★                  | ★★★ Fully managed   | ★★ Infra-like        | ★★                | ★                   |
| Azure Cosmos DB (Table/NoSQL)       | ★★            | ★★ Unique keys/ETag patterns  | ★★                   | ★★★               | ★★★       | ★★★ Multi-master      | ★★ Tunable          | ★★★ Fully managed   | ★ RU-based           | ★★                | ★                   |
| Apache HBase                        | ★★★           | ★★ Check-and-put              | ★★                   | ★★                | ★★        | ★★                    | ★★                  | ★ Ops-heavy         | ★★ Infra-based       | ★★                | ★★★                 |

Legend: ★ weak, ★★ medium, ★★★ strong (relative within this set and our context).

Notes:
- Cassandra/Scylla support INSERT IF NOT EXISTS (LWT) to guarantee uniqueness for slug; writes are slightly slower but acceptable on low collision rates.
- DynamoDB/Bigtable/Cosmos provide strong managed operability but increase lock-in; all support conditional create semantics suitable for slug uniqueness.

Why Cassandra over ScyllaDB:
- Ecosystem maturity and portability: broader adoption, multiple managed options, and stable drivers across languages reduce lock-in risk and ease hiring/support.
- Operational familiarity: more practitioners and tooling/runbooks lower operational risk for self-managed and hybrid setups.
- Adequate performance for our profile: single-key access with low collision rates keeps LWT overhead acceptable within latency goals.
- Optionality preserved: ScyllaDB remains a compatible drop-in if performance/cost SLOs or ops constraints favor it later.

## Decision
Choose Apache Cassandra as the primary distributed key-value database engine for slug→URL mappings. Use a single-partition primary key on slug (or namespace+slug), INSERT IF NOT EXISTS to enforce uniqueness, and per-record TTL for lifecycle. Allow compatible drop-in (e.g., ScyllaDB) if operational requirements favor it, but target Cassandra APIs and data model as the default.

## Consequences
Positive:
- Strong fit for single-key access with native TTL, tunable consistency, and proven horizontal scalability; broad ecosystem with mature drivers.
- Portability across environments (self-managed and multiple managed offerings) with reasonable cost control and no hard cloud lock-in.
- Conditional create (LWT) fulfills algorithmic uniqueness without global coordination; retries handle rare collisions.

Negative:
- LWT incurs higher write latency and coordination overhead; careful sizing and low collision rates are required to keep p95 within goals.
- Operability is non-trivial for self-managed clusters (repair, compaction, capacity planning); consider managed Cassandra where possible.
- Multi-region strong consistency adds latency; active-active requires careful topology and consistency level choices (e.g., LOCAL_QUORUM).
