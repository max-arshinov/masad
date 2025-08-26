deploymentNode "Dev Cloud" "" "Public Cloud" {
    deploymentNode "CDN / Edge" "" "CDN" {
    }
    deploymentNode "API Gateway" "" "Managed API Gateway" {
    }
    deploymentNode "Kubernetes Cluster" "" "Kubernetes" {
        deploymentNode "Namespace: analytics-dev" "" "Kubernetes Namespace" {
            deploymentNode "Web App Pods" "" "Kubernetes Pods" {
                containerInstance system.web
            }
            deploymentNode "Ingestion API Pods" "" "Kubernetes Pods" {
                containerInstance system.ingestionApi
            }
            deploymentNode "Analytics Query API Pods" "" "Kubernetes Pods" {
                containerInstance system.queryApi
            }
            deploymentNode "Ingestion Consumer Pods" "" "Kubernetes Pods" {
                containerInstance system.ingestionConsumer
            }
        }
    }
    deploymentNode "Managed Kafka (Dev)" "" "Apache Kafka" {
        containerInstance system.kafka
    }
    deploymentNode "Schema Registry (Dev)" "" "Confluent Schema Registry" {
        containerInstance system.schemaRegistry
    }
    deploymentNode "ClickHouse Cluster (Dev)" "" "ClickHouse" {
        deploymentNode "Server" "" "ClickHouse Server" {
            containerInstance system.db
        }
    }
    deploymentNode "Object Storage (Dev)" "" "S3-compatible" {
        containerInstance system.objectStore
    }
}

