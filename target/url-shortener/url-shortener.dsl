!docs ./docs/src

cache = container "Cache" "Redis"
linkDb = container "Links" "DynamoDB" "" "Database"
userDb = container "Users" "PostgreSQL" "" "Database"
    
readApi = container "Read API" {
    buffer = component "Buffer" "In-Memory"
}

broker = container "Broker" "NATS" ""

authApi = container "Auth" "KeyCloak"
authApi -> authProviders "OAUTH2"
authApi -> userDb

readApi -> cache "Get long link"
readApi -> broker

writeApi = container "Write API"
writeApi -> linkDb
writeApi -> cache

statService = container "Stat Background Service"
statService -> broker
statService -> hitCounter.api

statApi = container "Statistics API"
statApi -> hitCounter

web = container "Web App"
web -> authApi
web -> writeApi
web -> statApi
