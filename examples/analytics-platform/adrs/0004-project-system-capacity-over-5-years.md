# 4. Project System Capacity Over 5 Years

Date: 2025-09-03

## Status

Proposed

## Context

Based on the parameters established in ADR-0002, we project system growth over 5 years with 10% annual growth in event volume. The analytics platform must handle massive write loads while maintaining sub-1.5s query response times for reports spanning up to 3 months of data.

Key assumptions:
- Starting volume: 100 billion events/day
- Annual growth rate: 10%
- Peak traffic multiplier: 3x daily average
- Analytics users: 100,000 concurrent users scaling proportionally
- Event processing requires both real-time and aggregated analytics patterns

## Decision

### Projection Table

| Year | Events/Day (B) | Events/Year (T) | Event DB Size (TB) | Analytics Users | Write RPS    | Peak Write RPS | Read RPS (Real-Time) | Peak Read RPS (Real-Time) | Read RPS (Aggregated) | Peak Read RPS (Aggregated) | Write Bandwidth (GB/s) | Read Bandwidth (GB/s) | Total Bandwidth (GB/s) |
|------|----------------|-----------------|--------------------|-----------------|--------------|----------------|----------------------|---------------------------|-----------------------|----------------------------|------------------------|-----------------------|------------------------|
| 1    | 100 🟥         | 36.5 🟥         | 16.21 🟩           | 100,000 🟥      | 1,157,407 🟥 | 3,472,222 🟥   | 150 🟩               | 450 🟩                    | 150 🟩                | 450 🟩                     | 0.54 🟩                | 0.42 🟩               | 0.96 🟩                |
| 2    | 110 🟥         | 40.2 🟥         | 17.83 🟩           | 110,000 🟥      | 1,273,148 🟥 | 3,819,444 🟥   | 165 🟩               | 495 🟩                    | 165 🟩                | 495 🟩                     | 0.59 🟩                | 0.46 🟩               | 1.05 🟩                |
| 3    | 121 🟥         | 44.2 🟥         | 19.61 🟩           | 121,000 🟥      | 1,400,463 🟥 | 4,201,389 🟥   | 182 🟩               | 545 🟩                    | 182 🟩                | 545 🟩                     | 0.65 🟩                | 0.51 🟩               | 1.16 🟩                |
| 4    | 133 🟥         | 48.6 🟥         | 21.57 🟩           | 133,100 🟥      | 1,540,509 🟥 | 4,621,528 🟥   | 200 🟩               | 599 🟩                    | 200 🟩                | 599 🟩                     | 0.72 🟩                | 0.56 🟩               | 1.28 🟩                |
| 5    | 146 🟥         | 53.4 🟥         | 23.73 🟩           | 146,410 🟥      | 1,694,560 🟥 | 5,083,681 🟥   | 220 🟩               | 659 🟩                    | 220 🟩                | 659 🟩                     | 0.79 🟩                | 0.61 🟩               | 1.40 🟩                |

**Legend:** 🟩 Low · 🟨 Medium · 🟥 High

## Consequences

**Critical Scale Challenges:**
- 🟥 **Write throughput**: 1.1M+ sustained writes/sec places system in "Mind-blowing" scaling tier, requiring distributed write architecture with horizontal partitioning
- 🟥 **Peak ingestion**: 3-5M events/sec during traffic spikes demands auto-scaling capabilities and overflow handling
- 🟥 **User concurrency**: 100K+ concurrent analysts requires sophisticated connection pooling and query optimization
- 🟥 **Event volume**: 100B+ events/day sustained growth creates massive operational complexity

**Infrastructure Requirements:**
- 🟩 **Storage growth**: 16-24 TB/year manageable with modern storage systems but requires capacity planning
- 🟩 **Network bandwidth**: Sub-2 GB/s total bandwidth stays within "Minuscule" tier, network not a bottleneck
- 🟩 **Read patterns**: Real-time and aggregated reads remain in manageable ranges with proper caching

**Operational Risks:**
- Write RPS scaling requires distributed database architecture (sharding, replication)
- Peak traffic multipliers demand elastic infrastructure with rapid scale-out capabilities
- Query performance at scale needs pre-aggregation strategies and materialized views
- Data pipeline reliability becomes critical with processing delays capped at 50-100 minutes
- Cost optimization essential due to massive write volumes and "forever" retention requirements
