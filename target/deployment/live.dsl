liveCustomerDevice = deploymentNode "Customer's mobile device" "" "Apple iOS or Android" {
    liveMobileAppInstance = containerInstance internetBankingSystem.mobileApp
}

liveCustomerComputer = deploymentNode "Customer's computer" "" "Microsoft Windows or Apple macOS" {
    liveWebBrowser = browserNode "Web" {
        liveSinglePageApplicationInstance = containerInstance internetBankingSystem.spa
    }
}

liveDc = deploymentNode "Big Bank plc" "" "Big Bank plc data center" {
    liveWebNode = ubuntuNode "bigbank-web***" {
        instances 4
        liveWebServer = tomcat "Apache Tomcat" {
            liveWebApplicationInstance = containerInstance internetBankingSystem.web
        }
    }
    
    liveApiNode = ubuntuNode "bigbank-api***" {
        instances 8
        liveWebServer = tomcat "Apache Tomcat" {
            liveApiApplicationInstance = containerInstance internetBankingSystem.api
        }
    }

    liveDbNode = ubuntuNode "bigbank-db01" {
        primaryDatabaseServer = deploymentNode "Oracle - Primary" "" "Oracle 12c" {
            livePrimaryDatabaseInstance = containerInstance internetBankingSystem.database
        }
    }
    
    liveFailover = ubuntuNode "bigbank-db02" {
        tag "Failover"
        secondaryDatabaseServer = ubuntuNode "Oracle - Secondary" {
            tag "Failover"
            liveSecondaryDatabaseInstance = containerInstance internetBankingSystem.database "Failover"
        }
        
        liveDbNode.primaryDatabaseServer -> secondaryDatabaseServer "Replicates data to"
    }
    
    deploymentNode "bigbank-prod001" "" "" "" {
        softwareSystemInstance mainframe
    }
}