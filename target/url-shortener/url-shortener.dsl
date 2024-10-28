!constant WEB_LANG "Go"
!docs ./docs/src

group DBs {
    linkDb = container "Links" "Stores links." "ScyllaDB" "Database"
    userDb = container "Users" "Stores user info." "PostgreSQL" "Database"
}

group API {    
    readApi = container "Read API" "Redirects short URLs to long ones." ${WEB_LANG} {
        cache = component "In-Memory LRU Cache" "In-Memory"
        urlController = component "UrlController"
        urlController -> cache "Reads URLs from and writes to"
        urlController -> linkDb "Reads URLs from"
    }
    
    authApi = container "Auth & Identity Management" "Provides authentication, user management, and fine-grained authorization." "KeyCloak"
    authApi -> authProviders "Authenticates with" "OAUTH2"
    authApi -> userDb "Auth & Identity management"
    
    writeApi = container "Write API" "Creates short URLs." ${WEB_LANG} {
        urlController = component "UrlController"
        urlController -> linkDb "Saves new links to the db"
    }   
}

readApi.urlController -> hitCounter.writeApi "Sends visit statistics"

web = container "Web App" "Provides the URL shortener functionality to users via their web browsers."
web -> authApi "Authenticates the user" "HTTPS"
web -> writeApi.urlController "Sends JSON requests" "HTTPS"
