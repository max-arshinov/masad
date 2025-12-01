# 2. Identify Parameters for Estimation of Technical Risks

Date: 2025-09-03

## Status

Proposed

## Context

We need to establish parameters and assumptions for back-of-the-envelope estimation to assess technical risks for the analytics platform. The system tracks events from websites (page views, button clicks, etc.) and provides analytics reports with various breakdowns.

Key assumptions and requirements extracted from system documentation:

| Parameter               | Value                                           | Source             |
|-------------------------|-------------------------------------------------|--------------------|
| Event ingestion volume  | 100 billion events/day                          | Quality Goals      |
| Report response time    | ≤ 1.5 seconds                                   | Quality Goals      |
| Query time window limit | ≤ 3 months                                      | Quality Goals      |
| Data processing delay   | 50-100 minutes acceptable                       | Quality Goals      |
| Data retention          | "forever" per website                           | Quality Goals      |
| Peak traffic multiplier | 3x daily average                                | Industry standard  |
| Concurrent users        | 10,000 analysts                                 | Typical enterprise |
| Average event size      | 2 KB per event                                  | Web analytics norm |
| Read/write ratio        | Write heavy + a few heavy (aggregated) requests | Analytics pattern  |
| Geographic distribution | 3 regions (US, EU, APAC)                        | Global deployment  |

Quality Attribute Requirements referenced:
- Performance: Sub-1.5s query response times
- Scalability: 100B events/day ingestion capacity
- Availability: Near real-time processing with acceptable delays
- Durability: Permanent data retention

## Decision

The following parameters will be estimated in subsequent analysis:

**Scale Parameters:**
- Number of concurrent website visitors
- Number of tenant websites
- Average events per visitor session
- Peak traffic multipliers (daily, seasonal)

**Data Parameters:**
- Event payload size (bytes)
- Total daily data volume (TB/day)
- Storage growth rate (TB/month, TB/year)
- Compression ratios

**Performance Parameters:**
- Write throughput (events/second, MB/second)
- Read throughput (queries/second)
- Peak read/write ratios
- Database sizing requirements

**Infrastructure Parameters:**
- Bandwidth requirements (ingress/egress)
- Compute resource needs (CPU, memory)
- Storage capacity planning
- Network latency budgets

## Consequences

These parameters will guide:
- Infrastructure sizing and cost estimation
- Performance bottleneck identification
- Scalability risk assessment
- Technology stack evaluation
- Operational complexity analysis

Risk areas to be quantified include storage costs, query performance under load, ingestion pipeline capacity, and data processing latency compliance.
