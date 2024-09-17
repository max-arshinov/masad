!docs ./docs/src

cache = container "Cache" "Redis"
group DBs {
    linkDb = container "Links" "PostgreSQL" "" "Database"
    userDb = container "Users" "PostgreSQL" "" "Database"
}

broker = container "Broker" "NATS" ""

group API {    
    readApi = container "Read API" {
        buffer = component "Buffer" "In-Memory"
    }
    
    authApi = container "Auth" "KeyCloak"
    authApi -> authProviders "Authenticates with" "OAUTH2"
    authApi -> userDb "Auth & Identity management"
    
    readApi -> cache "Get long link"
    readApi -> broker "Sends redirect statistics"
    
    writeApi = container "Write API"
    writeApi -> linkDb "Saves new links to the db"
    writeApi -> cache "Saves new links to the cache"
}

statService = container "Stat Background Service"
statService -> broker
statService -> hitCounter.api "Sends visit statistics"


web = container "Web App"
web -> authApi "Authenticates the user" "HTTPS"
web -> writeApi "Sends JSON requests" "HTTPS"
