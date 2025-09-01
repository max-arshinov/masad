# 2. Identify Parameters for Estimation of Technical Risks

Date: 2025-09-01

## Status

Proposed

## Context

We need to establish baseline assumptions and parameters for back-of-the-envelope estimation to assess technical risks and capacity requirements for the URL shortener service.

### Key Assumptions

| Assumption                      | Value                                      |
|---------------------------------|--------------------------------------------|
| User growth rate                | 1M new users/year                          |
| Links per user per year         | 100 links                                  |
| Data retention period           | 3 years                                    |
| Average clicks per link per day | 10 requests                                |
| Peak traffic multiplier         | ~3x (estimated from annual to peak second) |
| Node failure tolerance          | 2 simultaneous nodes                       |
| Performance degradation limit   | +0.1 seconds max                           |

### Referenced Quality Attribute Requirements (QARs)

| QAR ID | Quality Attribute | Fit Criteria                              | Priority |
|--------|-------------------|-------------------------------------------|----------|
| P-1    | Performance       | Response time < 0.2 seconds for redirects | High     |
| P-2    | Performance       | Handle 100M links/year creation           | High     |
| P-3    | Performance       | < 0.1s degradation with 2 node failures   | High     |
| A-1    | Availability      | 99.9% uptime during peak hours            | High     |
| A-2    | Availability      | Zero downtime deployments                 | High     |
| S-1    | Scalability       | Support 1M new users/year                 | High     |
| S-2    | Scalability       | Handle 100M new links/year                | High     |
| S-3    | Scalability       | Support 10 requests/day per link          | Medium   |
| R-1    | Reliability       | 3-year minimum data retention             | High     |
| M-1    | Maintainability   | 100% click tracking coverage              | High     |

### Key Quality Scenarios (QAS) Metrics

- Peak link creation: 3,170 links/second (from S-2 scenario)
- Annual redirect volume: 1B redirects/year (from S-3 scenario)
- Average redirect rate: 27K requests/second (from S-3 scenario)
- Concurrent active users: 1M users (from S-1 scenario)

## Decision

The following parameters will be estimated in subsequent back-of-the-envelope calculations:

**User and Traffic Parameters:**
- Total user base growth over time
- Concurrent active users during peak periods
- Peak vs average traffic ratios

**Data Volume Parameters:**
- Total number of links stored
- Database size requirements (3-year retention)
- Growth rate of stored data

**Throughput Parameters:**
- Write RPS (link creation rate)
- Read RPS (redirect request rate)
- Peak RPS for both operations

**Infrastructure Parameters:**
- Required storage capacity
- Network bandwidth requirements
- Memory and compute requirements
- Redundancy and failover capacity

**Performance Parameters:**
- Cache hit/miss ratios
- Database query response times
- Network latency budgets

## Consequences

These parameters will guide subsequent technical risk analysis including:
- Capacity planning and resource sizing
- Database scalability assessment
- Network and storage bottleneck identification
- Failure mode impact analysis
- Cost estimation for infrastructure requirements

The established baseline will enable quantitative evaluation of architectural alternatives and inform decisions about database selection, caching strategies, and horizontal scaling approaches.
