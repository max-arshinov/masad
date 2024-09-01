urlShortener = softwareSystem "URL Shortener" "Creates an alias with shorter length. If you click the alias, it redirects you to the original URL." {
    !docs ./url-shortener/docs/src
    cache = container "Cache" "Redis"
    linkDb = container "Links" "DynamoDB" "" "DB"
    analyticsDb = container "Analytics" "ClickHouse" "" "DB"
    
    readApi = container "Read API" {
        buffer = component "Buffer" "In-Memory"
    }
    readApi -> cache "Get long link"
    readApi -> analyticsDb
    
    writeApi = container "Write API"
    writeApi -> linkDb
    writeApi -> cache        
}

anotherWebsite = softwareSystem "Another Website"

user = person "User"
user -> urlShortener.writeApi "Create short URL"
user -> urlShortener.readApi "Go to long url"
user -> anotherWebsite "Redirected to"

