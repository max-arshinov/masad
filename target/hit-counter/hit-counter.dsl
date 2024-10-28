!docs ./docs/src
description "Web analytics tool to collect data about website visitors and their sessions"

readApi = container "Read API"
writeApi = container "Write API"

analyticsDb = container "Analytics" "ClickHouse" "" "DB"
readApi -> analyticsDb "" "Kafka -> Kafka Engine" Async
writeApi -> analyticsDb "Reads data from"

spa = container "SPA"
spa -> readApi "Reads data from"