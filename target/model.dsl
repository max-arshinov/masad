properties {
    "structurizr.groupSeparator" "/"
}

clickStat = softwareSystem "Web Analytics" {
    api = container "API"
    analyticsDb = container "Analytics" "ClickHouse" "" "DB"
}

urlShortener = softwareSystem "URL Shortener" "Creates an alias with shorter length. If you click the alias, it redirects you to the original URL." {
    !docs ./url-shortener/docs/src
    cache = container "Cache" "Redis"
    linkDb = container "Links" "DynamoDB" "" "Database"
    userDb = container "Users" "PostgreSQL" "" "Database"
        
    readApi = container "Read API" {
        buffer = component "Buffer" "In-Memory"
    }
    
    broker = container "Broker" "NATS" ""
    
    authApi = container "Auth" "KeyCloak"
    authApi -> userDb
    
    readApi -> cache "Get long link"
    readApi -> broker
    
    writeApi = container "Write API"
    writeApi -> linkDb
    writeApi -> cache
    
    statService = container "Stat Background Service"
    statService -> broker
    statService -> clickStat.api
    
    statApi = container "Statistics API"
    statApi -> clickStat
    
    web = container "Web App"
    web -> authApi
    web -> writeApi
    web -> statApi
}

urlShortener -> clickStat "Sends statistics"

anotherWebsite = softwareSystem "Another Website"

user = person "User"
user -> urlShortener.web "SignUp/SignIn, Create short URL, See Statistics" "HTTPS"
user -> urlShortener.readApi "Go to long url" "HTTPS"
user -> anotherWebsite "Redirected to" "HTTPS"

