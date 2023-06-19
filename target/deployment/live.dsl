liveCustomerDevice = deploymentNode "Customer's mobile device" "" "Apple iOS or Android" {
    liveMobileAppInstance = containerInstance internetBankingSystem.mobile
}

liveCustomerComputer = deploymentNode "Customer's computer" "" "Microsoft Windows or Apple macOS" {
    liveWebBrowser = deploymentNode "Web" "" "Chrome, Firefox, Safari, or Edge" {
        liveSinglePageApplicationInstance = containerInstance internetBankingSystem.spa
    }
}

liveDc = deploymentNode "Big Bank plc" "" "Big Bank plc data center" {
    liveWebNode = deploymentNode "bigbank-web***" "" "Ubuntu 16.04 LTS" "" 4 {
        liveWebServer = deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
            liveWebApplicationInstance = containerInstance internetBankingSystem.web
        }
    }
    
    liveApiNode = deploymentNode "bigbank-api***" "" "Ubuntu 16.04 LTS" "" 8 {
        liveWebServer = deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
            liveApiApplicationInstance = containerInstance internetBankingSystem.api
        }
    }

    liveDbNode = deploymentNode "bigbank-db01" "" "Ubuntu 16.04 LTS" {
        primaryDatabaseServer = deploymentNode "Oracle - Primary" "" "Oracle 12c" {
            livePrimaryDatabaseInstance = containerInstance internetBankingSystem.database
        }
    }
    
    liveFailover = deploymentNode "bigbank-db02" "" "Ubuntu 16.04 LTS" "Failover" {
        secondaryDatabaseServer = deploymentNode "Oracle - Secondary" "" "Oracle 12c" "Failover" {
            liveSecondaryDatabaseInstance = containerInstance internetBankingSystem.database "Failover"
        }
        
        liveDbNode.primaryDatabaseServer -> secondaryDatabaseServer "Replicates data to"
    }
    
    deploymentNode "bigbank-prod001" "" "" "" {
        softwareSystemInstance mainframe
    }
}