# 11. Define Deployment Strategy for Zero Downtime

Date: 2025-09-01

## Status

Proposed

## Context

Iteration 3 goal: Fault Tolerance and High Availability. System must achieve zero downtime deployments while maintaining 99.9% uptime and ensuring seamless user experience during application updates and infrastructure changes.

Business drivers: Continuous delivery, business continuity, competitive advantage through rapid feature delivery, operational efficiency.

Relevant QAs (IDs): A-2 (zero downtime deployments), A-1 (99.9% uptime), P-3 (node failure tolerance).

## Decision

### Table 1 — Compare Deployment Strategies

| Deployment Strategy | Downtime | Rollback Speed | Resource Usage | Risk Level | Complexity | Database Migration Support |
|-------------------|----------|----------------|----------------|------------|------------|---------------------------|
| **Recreation** | 🟥 full downtime | 🟨 redeploy time | 🟩 minimal | 🟥 high | 🟩 simple | 🟥 downtime required |
| **Rolling Update** | 🟩 zero downtime | 🟨 gradual rollback | 🟩 current capacity | 🟨 partial availability | 🟨 orchestration | 🟨 backward compatibility |
| **Blue-Green** | 🌟 instant switch | 🌟 instant rollback | 🟥 double capacity | 🟨 switch risk | 🟨 infrastructure duplication | 🟩 parallel testing |
| **Canary** | 🟩 zero downtime | 🟩 quick rollback | 🟩 incremental | 🟩 low risk | 🟥 complex routing | 🟨 gradual migration |
| **A/B Testing** | 🟩 zero downtime | 🟩 traffic shifting | 🟨 split capacity | 🟩 controlled | 🟥 feature flagging | 🟨 version compatibility |
| **Feature Flags** | 🌟 instant toggle | 🌟 immediate revert | 🟩 no duplication | 🟩 minimal | 🟨 flag management | 🌟 database-independent |

**Shortlist:** Blue-Green and Canary deployments best address A-2 zero downtime with reliable rollback capabilities.

### Table 2 — Compare Infrastructure Platforms for Zero Downtime

| Platform | Deployment Automation | Health Checks | Traffic Routing | Database Migrations | Monitoring Integration | Operational Overhead |
|----------|---------------------|---------------|-----------------|-------------------|---------------------|-------------------|
| **AWS ECS + ALB** | 🟩 service updates | 🟩 target groups | 🟩 weighted routing | 🟨 external tooling | 🟩 CloudWatch | 🟨 ECS complexity |
| **AWS EKS (Kubernetes)** | 🌟 rolling/blue-green | 🌟 liveness/readiness | 🌟 ingress controllers | 🟨 job-based | 🟩 native metrics | 🟥 K8s complexity |
| **AWS CodeDeploy** | 🟩 automated pipelines | 🟩 health validation | 🟩 traffic shifting | 🟨 pre-hooks | 🟩 integrated | 🟩 managed service |
| **AWS Lambda** | 🌟 alias routing | 🟩 function monitoring | 🌟 weighted aliases | 🟥 not applicable | 🟩 CloudWatch | 🟩 serverless |
| **Docker Swarm** | 🟨 service updates | 🟨 basic checks | 🟨 load balancing | 🟨 external | 🟨 limited | 🟩 simple |
| **Nomad** | 🟩 job updates | 🟩 health checks | 🟨 consul integration | 🟨 external | 🟨 third-party | 🟨 HashiCorp stack |

**Decision:** Implement hybrid zero downtime deployment using AWS EKS with Blue-Green pattern for application tier and Feature Flags for business logic:

**Application Tier (Blue-Green on EKS):**
- Kubernetes deployments with rolling updates for minor changes
- Blue-Green deployment for major releases using separate namespaces
- AWS Application Load Balancer for traffic switching
- Health checks with 30-second readiness probes
- Automated rollback on health check failures

**Database Migrations:**
- Backward-compatible schema changes using migration scripts
- Feature flags to decouple code deployment from schema activation
- Zero-downtime migrations using online schema change tools (pt-online-schema-change)
- Separate migration pipeline with validation gates

**Traffic Management:**
- Kubernetes Ingress with weighted routing for canary deployments
- Feature flags using AWS AppConfig for instant rollback capability
- Circuit breakers for automatic fallback to previous version
- Real-time monitoring with automatic traffic shifting

**Deployment Pipeline:**
1. Pre-deployment: Schema migration validation
2. Blue environment deployment with smoke tests
3. Gradual traffic shift (5% → 25% → 50% → 100%)
4. Post-deployment monitoring with automated rollback triggers
5. Green environment cleanup after successful deployment

Supersedes: none.

## Consequences

- ✅ Achieves A-2 with true zero downtime through traffic shifting
- ✅ Maintains A-1 uptime during deployments with instant rollback
- ✅ Addresses P-3 through health check validation and gradual traffic shifting
- ✅ Enables rapid feature delivery with reduced deployment risk
- ⚠️ Increased infrastructure complexity with dual environment management
- ⚠️ Database migration constraints requiring backward compatibility
- Follow-ups: ADR on database migration automation, feature flag management strategy, deployment pipeline monitoring and alerting
