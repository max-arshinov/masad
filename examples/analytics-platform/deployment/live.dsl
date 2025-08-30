primaryRegion = deploymentNode "Primary Region" "" "AWS us-east-1" {
    cdn = deploymentNode "CDN" "" "CloudFront" {
        cdnInstance = infrastructureNode "CDN Instance" "" "CloudFront"
    }
    
    loadBalancer = deploymentNode "Load Balancer" "" "ALB" {
        albInstance = infrastructureNode "ALB Instance" "" "ALB"
    }
    
    webTier = deploymentNode "Web Tier" "" "ECS Fargate" {
        webAppContainer = containerInstance analyticsPlatform.webApp
        ingestionApiContainer = containerInstance analyticsPlatform.ingestionApi
        readApiContainer = containerInstance analyticsPlatform.readApi
    }
    
    processingTier = deploymentNode "Processing Tier" "" "ECS Fargate" {
        writersContainer = containerInstance analyticsPlatform.writers
    }
    
    kafkaCluster = deploymentNode "Kafka Cluster" "" "MSK" {
        kafkaBroker = containerInstance analyticsPlatform.eventStream
    }
    
    clickhouseCluster = deploymentNode "ClickHouse Cluster" "" "EC2" {
        clickhouseNode = containerInstance analyticsPlatform.db
    }
    
    cacheCluster = deploymentNode "Redis Cluster" "" "ElastiCache" {
        redisNode = containerInstance analyticsPlatform.cache
    }
    
    objectStorage = deploymentNode "Object Storage" "" "S3" {
        s3Bucket = infrastructureNode "S3 Bucket" "" "S3"
    }
}

