deploymentNode "Dev Cloud" "" "Public Cloud" {
    deploymentNode "CDN / Edge" "" "CDN" {
    }
    deploymentNode "API Gateway" "" "Managed API Gateway" {
    }
    deploymentNode "Kubernetes Cluster" "" "Kubernetes" {
        deploymentNode "Namespace: analytics-dev" "" "Kubernetes Namespace" {
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
    deploymentNode "Managed Kafka (Dev)" "" "Apache Kafka" {
        containerInstance analyticsPlatform.kafka
    }
    deploymentNode "Schema Registry (Dev)" "" "Confluent Schema Registry" {
        containerInstance analyticsPlatform.schemaRegistry
    }
    deploymentNode "ClickHouse Cluster (Dev)" "" "ClickHouse" {
        deploymentNode "Server" "" "ClickHouse Server" {
            containerInstance analyticsPlatform.db
        }
    }
    deploymentNode "Object Storage (Dev)" "" "S3-compatible" {
        containerInstance analyticsPlatform.objectStore
    }
}

