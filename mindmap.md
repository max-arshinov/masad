---
title: Software Architecture<br/>Building Blocks
markmap:
  colorFreezeLevel: 1
---


## Datastores
- **DB Engines**
  - RDBMS
  - NoSQL
  - NewSQL
  - HTAP
- **Distributed File Systems**
  - HDFS
  - CephFS
- **Object Stores**
  - S3
  - GCS
- **Caches / In-Memory Stores**
  - Redis
  - Memcached
- **Search Engines**
  - Elasticsearch
  - Solr
  - OpenSearch
- **Graph Engines**
  - Neo4j
  - JanusGraph
- **Time Series DBs**
  - InfluxDB
  - Timescale

## Data Movement & Integration
- **Message Brokers**
  - Queues (RabbitMQ, SQS…)
  - Logs (Kafka, Pulsar…)
- **Stream Processors**
  - Flink
  - Kafka Streams
  - Spark Streaming
- **Batch Processors / ETL**
  - Airflow
  - DBT
- **Change Data Capture (CDC)**

## Networking & Delivery
- **Load Balancers / API Gateways**
  - NGINX
  - Envoy
  - Kong
  - APIM
- **Service Mesh**
  - Istio
  - Linkerd
- **CDN**

## Compute / Execution
- **Application Runtimes**
  - JVM
  - CLR
  - Node.js
- **Containers & Orchestration**
  - Docker
  - Kubernetes
  - Nomad
- **Serverless / FaaS**
  - AWS Lambda
  - Azure Functions
- **Batch Job Runtimes**
  - Hadoop YARN
  - Kubernetes Jobs

## Observability
- **Logging**
  - ELK
  - Loki
Tracing (Jaeger, Zipkin, OpenTelemetry…)

Alerting (Alertmanager, PagerDuty…)

Security & Governance

Identity & Access (OAuth2, OIDC, Keycloak, Cognito…)

Secrets Management (Vault, KMS…)

Policy / Compliance (OPA, Kyv