deploymentNode "Live Cloud" "" "Public Cloud (Multi-AZ)" {
    deploymentNode "CDN / Edge" "" "CDN" {
    }
    deploymentNode "API Gateway" "" "Managed API Gateway" {
    }
    deploymentNode "Kubernetes Cluster" "" "Kubernetes" {
        deploymentNode "Namespace: analytics-live" "" "Kubernetes Namespace" {
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
    deploymentNode "Managed Kafka (Live)" "" "Apache Kafka" {
        containerInstance system.kafka
    }
    deploymentNode "Schema Registry (Live)" "" "Confluent Schema Registry" {
        containerInstance system.schemaRegistry
    }
    deploymentNode "ClickHouse Cluster (Live)" "" "ClickHouse" {
        deploymentNode "Primary" "" "ClickHouse Server" {
            containerInstance system.db
        }
        deploymentNode "Replica" "" "ClickHouse Server" {
            containerInstance system.db
        }
    }
    deploymentNode "Object Storage (Live)" "" "S3-compatible" {
        containerInstance system.objectStore
    }
}

