# 0010. Data lifecycle and integrity verification across tiers
Date: 2025-08-29

## Status
Proposed

## Context
- Business drivers: indefinite retention at sustainable cost, dependable access to historical data for compliance and analytics, and predictable query performance on recent (hot) data.
- Related Quality Attributes (from Quality Tree):
  - R-1 Retention: Hot tier ≥3 months; warm/cold indefinite; restore ≤24h; integrity verified.
  - P-1 Performance: Query tails must remain within SLO; warm/cold policies must not degrade hot-path latency.
  - S-1 Scalability: Lifecycle must prevent hot-tier capacity/IO saturation and enable horizontal growth.
- Risks addressed (Section 11): RISK-COLD-RESTORE, RISK-DATA-INTEGRITY, RISK-HOT-STORAGE, RISK-COST-DRIFT.
- Assumptions/constraints: ADR-0003 selected ClickHouse as hot store; ADR-0005 defined ingestion/backfill paths; object storage is available and versioned; multi-region active-active.

## Comparison

### Lifecycle/tiering strategies

| Option / Criteria                                                                                                     | R-1 Retention (indefinite, ≤24h restore, integrity)                                        | P-1 Latency impact (hot path)                                           | Cost efficiency                                   | Operability                                           |
|-----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|---------------------------------------------------|-------------------------------------------------------|
| A) ClickHouse storage policies with TTL → S3/object storage (S3 disks for warm), plus periodic cold archive (Parquet) | 🟩 TTL moves with CH part checksums; cold archive manifests enable ≤24h selective restores | 🟩 Hot stays on NVMe; warm/cold excluded from hot scans by partitioning | 🟩 Warm/cold on object storage; compute decoupled | 🟨 Requires policies, monitoring, and restore tooling |
| B) Keep all data hot on local NVMe (no tiering)                                                                       | 🟥 Capacity/IO limits; integrity OK but cost explodes; restores N/A                        | 🟩 Best latency (all hot)                                               | 🟥 Very high                                      | 🟩 Simple ops; but scaling pressure high              |
| C) Export to data lake (Parquet) and query via federation (Trino/CH external tables)                                  | 🟩 Indefinite; integrity via file checksums; restores = attach external                    | 🟨 Federated queries can add tail; guardrails needed                    | 🟩 Cheap cold; compute on demand                  | 🟨 Extra engines/tooling; governance required         |

### Integrity verification strategies

| Option / Criteria                                                                                                     | Integrity assurance                               | Performance overhead             | Operability                         |
|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------|----------------------------------|-------------------------------------|
| 1) End-to-end SHA-256 per file + manifest index (per tenant/month) with verify-on-move/restore and periodic scrubbing | 🟩 Strong (content-hash, independent of provider) | 🟨 CPU/IO for hashing and scrubs | 🟨 Manage manifests, scrubs, alerts |
| 2) Rely on provider ETag + ClickHouse part checksums only                                                             | 🟨 Medium (weak where ETag≠content-hash)          | 🟩 Low                           | 🟩 Simple; fewer components         |
| 3) Merkle tree per partition (chunk-level) + manifest                                                                 | 🌟 Excellent (detect localized corruption)        | 🟥 Higher complexity/overhead    | 🟥 Complex tooling and ops          |

## Decision
Adopt A) ClickHouse storage policies with TTL to S3/object storage for warm data, plus periodic export of older data to Parquet in a cold archive, combined with 1) end-to-end SHA-256 manifests and verify-on-move/restore with periodic scrubbing.

Architectural tactics and configuration (mapped to QAs):
- Lifecycle tiers (R-1, P-1, S-1):
  - Hot (≤90 days): ReplicatedMergeTree on local NVMe; strict partitioning by tenant/time; guardrails on scanned bytes.
  - Warm (>90 days, ≤12 months): ClickHouse S3/object storage disks via storage policies; TTL moves completed parts; queries default-exclude warm unless explicitly requested.
  - Cold (>12 months): Periodic export to Parquet (partitioned by tenant/year=YYYY/month=MM/day=DD) with metadata manifest; cold bucket uses infrequent-access/archival classes.
- Integrity (R-1):
  - Manifest per tenant/month: list of files with SHA-256, size, compression, schema/version. Stored alongside data with versioning.
  - Verify-on-move: hash verification when moving parts hot→warm (compare CH part checksum and recomputed hash for objects as needed).
  - Verify-on-restore: before attach/load, recompute or validate hashes vs manifest; fail fast on mismatch; track restored set in audit log.
  - Periodic scrubbing: rolling verification (e.g., 30/60/90-day cadence for warm; annual for cold), with error budgets and alerts.
- Restore workflow (R-1):
  - Selective restore: fetch manifest ranges, hydrate to staging tables, INSERT SELECT into targets with quotas; avoid merge thrash via tuned max_threads and block sizes.
  - SLA: ≤24h to make N TB of cold data queryable; precomputed concurrency budgets per env/region; page-by-page hydration for large ranges.
  - Safety: read-only attaches for ad-hoc access; TTL to auto-drop hydrated cold data after window expires.
- Cost and capacity guardrails (S-1, R-1): lifecycle policies with budgets; alerts on hot tier >70% full, compaction backlog, tiering lag; export cost tracking and retrieval fee dashboards.
- Observability & governance (R-1, P-1): per-tenant lifecycle state, restore drill outcomes, checksum error counts; schema/version embedded in manifests; change control for policy updates.

## Consequences
- Positive:
  - Meets R-1 with indefinite retention, end-to-end integrity verification, and ≤24h selective restores.
  - Protects P-1 by keeping hot queries on NVMe and excluding warm/cold by default; explicit opt-in for historical scans.
  - Controls S-1 and cost growth via automated tiering and exports; clear capacity budgets and alerts.
- Negative / Risks:
  - Additional components (exporters, manifest/index, scrub jobs) and operational processes (restore drills) add overhead.
  - Hashing/scrubbing consumes IO/CPU; must be scheduled to avoid impacting hot path.
  - Federation paths (if enabled) require strict guardrails to avoid tail-latency regressions.

Related ADRs: ADR-0003 (Primary analytics database), ADR-0005 (Ingestion/backfill), ADR-0007 (Read tier), ADR-0009 (Autoscaling & multi-region).

