primaryRegion = deploymentNode "Primary Region" "" "AWS us-east-1" {
    cdn = deploymentNode "CDN" "" "CloudFront" {
        cdnInstance = infrastructureNode "CDN Instance" "" "CloudFront"
    }
    
    loadBalancer = deploymentNode "Load Balancer" "" "ALB" {
        albInstance = infrastructureNode "ALB Instance" "" "ALB"
    }
    
    webTier = deploymentNode "Web Tier" "" "ECS Fargate" {
        instances 4
        webAppContainer = containerInstance analyticsPlatform.webApp
        ingestionApiContainer = containerInstance analyticsPlatform.ingestionApi
        readApiContainer = containerInstance analyticsPlatform.readApi
    }
    
    processingTier = deploymentNode "Processing Tier" "" "ECS Fargate" {
        instances 8
        writersContainer = containerInstance analyticsPlatform.writers
    }
    
    kafkaCluster = deploymentNode "Kafka Cluster" "" "MSK" {
        instances 3
        kafkaBroker = containerInstance analyticsPlatform.eventStream
    }
    
    clickhouseCluster = deploymentNode "ClickHouse Cluster" "" "EC2" {
        instances 6
        clickhouseNode = containerInstance analyticsPlatform.db
    }
    
    cacheCluster = deploymentNode "Redis Cluster" "" "ElastiCache" {
        instances 3
        redisNode = containerInstance analyticsPlatform.cache
    }
    
    objectStorage = deploymentNode "Object Storage" "" "S3" {
        s3Bucket = infrastructureNode "S3 Bucket" "" "S3"
    }
}

