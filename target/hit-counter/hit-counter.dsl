!docs ./docs/src

api = container "API"
analyticsDb = container "Analytics" "ClickHouse" "" "DB"
api -> analyticsDb "" "Kafka -> Kafka Engine" Async
