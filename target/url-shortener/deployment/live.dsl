!constant OS "Linux"
!constant WEB_INSTANCE_COUNT 4

liveDc = deploymentNode "Account" "" "Hetzner" {
    liveWebNode = deploymentNode "Web" "" ${OS} "" ${WEB_INSTANCE_COUNT} {
        liveWebInstance = containerInstance urlShortener.web
    }
    
    liveAuthNode = deploymentNode "Auth & IM" "" ${OS} "" {
        liveAuthInstance = containerInstance urlShortener.authApi
    }    
    
    liveWriteNode = deploymentNode "Write API" "" ${OS} "" ${WEB_INSTANCE_COUNT} {
        liveWriteInstance = containerInstance urlShortener.writeApi
    }

    liveReadNode = deploymentNode "Read API" "" ${OS} "" ${WEB_INSTANCE_COUNT} {
        liveReadNode = containerInstance urlShortener.readApi
    }
    
    liveLinkDbNode = deploymentNode "Link DB" "" ${OS} "" 3 {
        liveLinkDbInstance = containerInstance urlShortener.linkDb
    }
    
    liveUserDbNode = deploymentNode "User DB" "" ${OS} "" {
        liveUserDbInstance = containerInstance urlShortener.userDb
    }

}