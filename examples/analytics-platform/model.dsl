analyticsPlatform = softwareSystem "Analytics Platform" "Tracks website/app events (page views, clicks, etc.) and provides reports, segmentation, and attribution." {
    !adrs adrs
    !docs docs/src

    web = container "Analytics Web App" "Dashboards, reporting, and segmentation UI for tenants and internal users." "Next.js (React, TypeScript)" {
    }

    ingestionApi = container "Ingestion API" "Receives batched/compressed events from SDKs and buffers to Kafka." "Go (chi), JSON/HTTPS" {
    }

    queryApi = container "Analytics Query API" "Serves analytics queries and exports; reads from ClickHouse." "Go (chi), JSON/HTTPS" {
    }

    ingestionConsumer = container "Ingestion Consumer" "Consumes events from Kafka, validates/enriches, and writes batched inserts to ClickHouse." "Go (librdkafka)" {
    }

    kafka = container "Event Streaming" "Durable event log for ingestion and reprocessing." "Apache Kafka" {
        tag "Broker"
    }

    schemaRegistry = container "Schema Registry" "Manages Avro/Protobuf schemas and compatibility for events." "Confluent Schema Registry" {
        tag "Broker"
    }

    db = datastore "ClickHouse" "Columnar analytics database for hot/warm data, rollups, and sketches (HLL/TDigest)." "ClickHouse" {
    }

    objectStore = datastore "Object Storage" "Cold archives, backfills, and tiered storage (e.g., S3-compatible)." "S3-compatible" {
    }

    web --hj-> queryApi "Queries analytics and exports"
    ingestionApi --hj-> kafka "Publishes events"
    ingestionApi --https-> schemaRegistry "Validates event schemas"
    ingestionConsumer -> kafka "Consumes events"
    ingestionConsumer -> db "Writes batched inserts"
    ingestionConsumer --https-> schemaRegistry "Reads schemas"
    queryApi -> db "Reads analytics data"
    db -> objectStore "Tiering/archives"
}

executive = person "Executive Sponsor & Leadership" "Stakeholders who need ROI visibility, roadmap alignment, budget control, and risk oversight." "Business"
executive --https-> analyticsPlatform "Reviews ROI dashboards and roadmap"

analyst = person "Product/Marketing/Analytics User" "Users who need accurate and timely reports, segmentation, and UTM/source attribution." "User"
analyst --https-> analyticsPlatform "Explores reports and creates segments"

tenantOwner = person "Client Website/App Owner (Tenant)" "Customers integrating the SDK; need easy integration, low overhead, configurable tracking, and SLAs." "Tenant"
tenantOwner --https-> analyticsPlatform "Configures tracking and views site analytics"

engineer = person "Data/Platform Engineering & Backend Developer" "Engineers who need reliable ingestion, scalable storage/queries, clear schemas/APIs, and observability." "Engineering"
engineer --https-> analyticsPlatform "Operates platform and manages schemas/APIs"

privacy = person "Security/Legal/Privacy (DPO)" "Ensures GDPR/CCPA compliance, consent/retention controls, and auditing." "Compliance"
privacy --https-> analyticsPlatform "Manages consent, retention, and audits"
