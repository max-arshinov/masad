urlShortener = softwareSystem "URL Shortener" "Generates short URLs and redirects users to original links"{
    !docs docs/src
    !adrs adrs
    
    webApp = webApp "Web Application" "User interface for creating short URLs" "React"
    api = api "API Gateway" "Handles URL shortening and redirection" "Node.js"
    database = datastore "Database" "Stores URL mappings and metadata" "PostgreSQL"
    cache = cache "Redis Cache" "Caches frequently accessed URLs" "Redis"
    
    webApp -> api "Creates short URLs and retrieves analytics"
    api -> cache "Reads from and writes to"
    api -> database "Reads from and writes to"
    cache -> database "Cache miss fallback"
}

endUser = person "End User" "Creates short links and clicks on shortened URLs"
systemAdministrator = person "System Administrator" "Monitors system performance and manages deployments"

endUser -> urlShortener.webApp "Creates short links via web interface"
endUser -> urlShortener.api "Clicks shortened URLs for redirection"
endUser -> analyticsPlatform "Generates click data through URL visits" 
systemAdministrator -> urlShortener.api "Monitors performance and deploys updates"
systemAdministrator -> analyticsPlatform "Reviews click statistics and metrics"
urlShortener.api -> analyticsPlatform "Sends click tracking data"
