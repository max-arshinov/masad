# 10. Design Pre-Aggregation Strategy

Date: 2025-09-03

## Status

Proposed

## Context

Iteration goal: Design pre-aggregation strategy for ClickHouse to achieve sub-1.5s query response times for 3-month analytics reports while processing 100B+ events/day. Must balance storage overhead with query performance for common analytics patterns.

Business drivers: Analytics platform serves reports with breakdowns by time periods (hours, days, weeks, months), dimensions (geolocation, traffic source, browser, device, UTM tags), and metrics (visitors, unique visitors, page views, events).

Relevant QAs (IDs): P-1 Performance (Report response time ≤1.5s), P-3 Performance (100K concurrent users), S-2 Scalability (Storage capacity), R-2 Reliability (Query consistency).

## Decision

### Compare **Aggregation Approaches**

| Approach              | Query Performance    | Storage Overhead    | Freshness          | Maintenance Effort | Flexibility        | Consistency        |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Real-time Only**    | 🟥 slow scans       | 🟩 minimal         | 🌟 immediate       | 🟩 none           | 🌟 full queries    | 🌟 always current |
| **Materialized Views**| 🟩 pre-computed     | 🟨 moderate         | 🟨 refresh cycles  | 🟨 view mgmt       | 🟨 predefined      | 🟩 refresh-based  |
| **Pre-aggregated Tables**| 🌟 optimized     | 🟥 high storage     | 🟨 batch windows   | 🟥 complex ETL     | 🟨 fixed dimensions| 🟨 batch consistency|
| **Hybrid Strategy**   | 🟩 balanced         | 🟨 managed          | 🟩 near real-time  | 🟨 moderate        | 🟩 multi-level     | 🟩 eventual       |

### Compare **Aggregation Granularities**

| Granularity           | Storage Multiplier   | Query Speed         | Drill-down Support | Update Complexity  | Cache Efficiency   | Business Value     |
|-----------------------|----------------------|---------------------|--------------------|--------------------|--------------------|--------------------|
| **Raw Events Only**   | 🟩 1x baseline      | 🟥 full scans      | 🌟 unlimited       | 🟩 simple inserts  | 🟥 poor           | 🟨 flexible       |
| **Hourly Aggregates** | 🟩 ~0.01x           | 🟩 fast            | 🟩 good granularity| 🟨 hourly updates  | 🟩 effective      | 🟩 operational    |
| **Daily Aggregates**  | 🟩 ~0.0003x         | 🌟 very fast       | 🟨 day-level only  | 🟩 daily batch     | 🟩 excellent      | 🟩 strategic      |
| **Multi-level**       | 🟨 combined overhead | 🌟 optimal routing  | 🟩 adaptive        | 🟥 complex logic   | 🌟 layered        | 🌟 comprehensive  |

**Decision:** Implement **multi-level pre-aggregation strategy** with three tiers:

**Tier 1 - Real-time (Raw Events):**
- Store all events in partitioned ClickHouse tables for up to 7 days
- Enable drill-down queries and ad-hoc analysis for recent data

**Tier 2 - Hourly Aggregates:**
- Pre-aggregate events by hour + website + dimensions (geo, source, browser, device)
- Covers 90% of dashboard queries for 3-month time windows
- ~365x storage reduction vs raw events

**Tier 3 - Daily Aggregates:**
- Pre-aggregate hourly data into daily summaries for historical analysis
- Optimized for trend analysis and long-term reporting
- ~8760x storage reduction vs raw events

Supersedes: none.

## Consequences

- ✅ Sub-1.5s response times for 95% of queries through appropriate aggregation tier routing (P-1).
- ✅ Reduced concurrent load on raw data through pre-computed aggregates (P-3).
- ✅ 100x+ storage efficiency for historical data while maintaining query flexibility (S-2).
- ✅ Consistent aggregation logic across time windows and dimensions (R-2).
- ✅ Graceful degradation: recent data queries fall back to real-time processing.
- ⚠️ ETL complexity for maintaining hourly/daily aggregation pipelines.
- ⚠️ Query router logic needed to select optimal aggregation tier.
- Follow-ups: ADR-011 (caching for query routing), ADR-012 (replica topology), aggregation pipeline implementation.
