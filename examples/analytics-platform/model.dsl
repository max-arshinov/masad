analyticsPlatform = softwareSystem "Analytics Platform" "Tracks events from websites and provides analytics reports." {
    webApp = webApp "Analytics Dashboard" "SPA for exploring reports and analytics." "React"
    ingestionApi = api "Ingestion API" "Receives and validates events from SDKs." "Go"
    readApi = api "Read API" "Serves analytics queries and reports." "Go"
    eventStream = kafka "Event Stream" "Buffers events for reliable processing." "Kafka"
    writers = api "Writers" "Consume events and write to database." "Go"
    db = datastore "Analytics Database" "Stores events and pre-aggregations." "ClickHouse"
    cache = cache "Query Cache" "Caches query results for performance." "Redis"
}

websiteVisitor = person "Website Visitor" "Generates page views and events while browsing tenant sites."
analystMarketer = person "Analyst/Marketer" "Explores reports, segmentation, and attribution analysis."
websiteOwner = person "Website Owner" "Integrates SDK and configures tracking for their websites."

websiteVisitor --sdk-> analyticsPlatform.ingestionApi "Generates events via"
analystMarketer --https-> analyticsPlatform.webApp "Views reports and analytics from"
websiteOwner --https-> analyticsPlatform.webApp "Integrates SDK and configures"

analyticsPlatform.webApp --https-> analyticsPlatform.readApi "Fetches analytics data from"
analyticsPlatform.ingestionApi --kafka-> analyticsPlatform.eventStream "Publishes events to"
analyticsPlatform.writers --kafka-> analyticsPlatform.eventStream "Consumes events from"
analyticsPlatform.writers --sql-> analyticsPlatform.db "Writes batched events to"
analyticsPlatform.readApi --sql-> analyticsPlatform.db "Queries analytics data from"
analyticsPlatform.readApi --tcp-> analyticsPlatform.cache "Reads from and writes to"
