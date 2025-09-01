# Estimate System Growth and Technical Risks

Date: 2025-09-01

## Status

Proposed

## Context

This ADR continues the technical risk estimation for the URL shortener service. Following the parameters established in ADR-002, we project system growth, storage, throughput, and bandwidth requirements over a 5-year horizon. The calculations are based on:

- 1M new users/year growth rate
- 100 links per user per year
- 10 requests per link per day
- 3x peak traffic multiplier
- 3-year data retention period

## Decision

Using the established parameters, the following projections show system capacity requirements:

### Projection Table

| Year | # of users   | User DB size (GB) | # of short links | Link DB size (GB) | RPS Write | RPS Read      | Peak RPS Read | Stat Size (TB) | Bandwidth (GB/S) |
|------|--------------|-------------------|------------------|-------------------|-----------|---------------|---------------|----------------|------------------|
| 1    | 1,000,000.00 | 0.93 🟩           | 100,000,000.00   | 9.59 🟩           | 3.17 🟩   | 11,575.00 🟨  | 34,725.00 🟨  | 0.36 🟩        | 0.04 🟩          |
| 2    | 2,000,000.00 | 1.86 🟩           | 300,000,000.00   | 28.78 🟨          | 6.34 🟩   | 34,723.00 🟨  | 104,169.00 🟥 | 1.07 🟩        | 0.12 🟩          |
| 3    | 3,000,000.00 | 2.79 🟩           | 600,000,000.00   | 57.56 🟨          | 9.51 🟩   | 69,445.00 🟥  | 208,335.00 🟥 | 2.13 🟨        | 0.23 🟩          |
| 4    | 4,000,000.00 | 3.73 🟩           | 900,000,000.00   | 86.33 🟥          | 12.68 🟩  | 104,167.00 🟥 | 312,501.00 🟥 | 3.20 🟨        | 0.35 🟩          |
| 5    | 5,000,000.00 | 4.66 🟩           | 1,200,000,000.00 | 115.11 🟥         | 15.85 🟩  | 138,889.00 🟥 | 416,667.00 🟥 | 4.27 🟨        | 0.47 🟩          |

**Legend:** 🟩 Low · 🟨 Medium · 🟥 High

## Consequences

**Storage Requirements:**
- User database remains manageable with single-node capacity throughout 5-year horizon
- Link database grows to moderate risk levels by year 3, requiring partitioning strategies
- Statistics storage reaches medium tier by year 3, requiring archive/compression

**Throughput Requirements:**
- Write RPS remains in low tier throughout projection period
- Read RPS escalates to high tier by year 3, requiring robust caching infrastructure
- Peak read traffic reaches high-risk levels early, demanding horizontal scaling

**Operational Complexity:**
- Year 1-2: Single database instance viable with proper indexing
- Year 3+: Caching layer becomes critical for read performance
- Year 4+: Database partitioning and read replicas likely required
- Peak traffic handling requires load balancing and auto-scaling

**Risk Assessment:**
- Bandwidth requirements remain low throughout projection
- Primary risk factors emerge in read throughput and peak traffic handling
- Database size growth predictable and manageable with standard scaling approaches
- No immediate concerns for write throughput capacity
