analyticsPlatform = softwareSystem "Analytics Platform" "Tracks website events and provides analytics dashboards." {
    !adrs adrs
    !docs docs/src
    
    eventBroker = kafka "Event Broker" "Streams tracking events for processing." "Apache Kafka"
    streamProcessor = api "Stream Processor" "Processes events in real-time." "Kafka Streams"
    batchProcessor = api "Batch Processor" "Handles complex analytics processing." "Apache Spark"
    analyticsDatabase = datastore "Analytics Database" "Stores aggregated analytics data." "ClickHouse"
    distributedCache = cache "Distributed Cache" "Caches query results and aggregations." "Redis"
    ingestionApi = api "Ingestion API" "Receives tracking events from websites." "REST API"
    queryApi = api "Query API" "Serves analytics data to dashboards." "GraphQL API"
    dashboardApp = webApp "Dashboard Application" "Provides analytics dashboards." "React"
    configurationApp = webApp "Configuration Application" "Manages tracking configuration." "React"
    
    ingestionApi -> eventBroker "Publishes events to"
    eventBroker -> streamProcessor "Streams events to"
    eventBroker -> batchProcessor "Streams events to"
    streamProcessor -> analyticsDatabase "Writes real-time aggregates to"
    streamProcessor -> distributedCache "Updates cache with"
    batchProcessor -> analyticsDatabase "Writes batch aggregates to"
    queryApi -> analyticsDatabase "Queries data from"
    queryApi -> distributedCache "Reads cached results from"
    dashboardApp -> queryApi "Fetches analytics data from"
    configurationApp -> queryApi "Retrieves configuration from"
}

tenantWebsites = softwareSystem "Tenant Websites" "Client websites generating tracking events."

websiteVisitor = person "Website Visitor" "Generates page views and events while browsing."
analyst = person "Analyst" "Explores reports and performs segmentation analysis."
websiteOwner = person "Website Owner" "Manages analytics configuration and tracking."

websiteVisitor -> tenantWebsites "Browses pages and generates events"
tenantWebsites -> analyticsPlatform.ingestionApi "Sends tracking events via SDK"
analyst -> analyticsPlatform.dashboardApp "Views reports and dashboards"
websiteOwner -> analyticsPlatform.configurationApp "Configures tracking and integration"
