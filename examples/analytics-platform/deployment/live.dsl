deploymentNode "Live Cloud" "" "Public Cloud (Multi-AZ)" {
    deploymentNode "CDN / Edge" "" "CDN" {
    }
    deploymentNode "API Gateway" "" "Managed API Gateway" {
    }
    deploymentNode "Kubernetes Cluster" "" "Kubernetes" {
        deploymentNode "Namespace: analytics-live" "" "Kubernetes Namespace" {
            deploymentNode "Web App Pods" "" "Kubernetes Pods" {
                containerInstance analyticsPlatform.web
            }
            deploymentNode "Ingestion API Pods" "" "Kubernetes Pods" {
                containerInstance analyticsPlatform.ingestionApi
            }
            deploymentNode "Analytics Query API Pods" "" "Kubernetes Pods" {
                containerInstance analyticsPlatform.queryApi
            }
            deploymentNode "Ingestion Consumer Pods" "" "Kubernetes Pods" {
                containerInstance analyticsPlatform.ingestionConsumer
            }
        }
    }
    deploymentNode "Managed Kafka (Live)" "" "Apache Kafka" {
        containerInstance analyticsPlatform.kafka
    }
    deploymentNode "Schema Registry (Live)" "" "Confluent Schema Registry" {
        containerInstance analyticsPlatform.schemaRegistry
    }
    deploymentNode "ClickHouse Cluster (Live)" "" "ClickHouse" {
        deploymentNode "Primary" "" "ClickHouse Server" {
            containerInstance analyticsPlatform.db
        }
        deploymentNode "Replica" "" "ClickHouse Server" {
            containerInstance analyticsPlatform.db
        }
    }
    deploymentNode "Object Storage (Live)" "" "S3-compatible" {
        containerInstance analyticsPlatform.objectStore
    }
}

