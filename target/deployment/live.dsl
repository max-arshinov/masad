deploymentNode "Customer's mobile device" "" "Apple iOS or Android" {
    liveMobileAppInstance = containerInstance internetBankingSystem.mobile
}

deploymentNode "Customer's computer" "" "Microsoft Windows or Apple macOS" {
    deploymentNode "Web" "" "Chrome, Firefox, Safari, or Edge" {
        liveSinglePageApplicationInstance = containerInstance internetBankingSystem.spa
    }
}

deploymentNode "Big Bank plc" "" "Big Bank plc data center" {
    deploymentNode "bigbank-web***" "" "Ubuntu 16.04 LTS" "" 4 {
        deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
            liveWebApplicationInstance = containerInstance internetBankingSystem.web
        }
    }
    
    deploymentNode "bigbank-api***" "" "Ubuntu 16.04 LTS" "" 8 {
        deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
            liveApiApplicationInstance = containerInstance internetBankingSystem.api
        }
    }

    bigbankdb01 = deploymentNode "bigbank-db01" "" "Ubuntu 16.04 LTS" {
        primaryDatabaseServer = deploymentNode "Oracle - Primary" "" "Oracle 12c" {
            livePrimaryDatabaseInstance = containerInstance internetBankingSystem.database
        }
    }
    
    deploymentNode "bigbank-db02" "" "Ubuntu 16.04 LTS" "Failover" {
        secondaryDatabaseServer = deploymentNode "Oracle - Secondary" "" "Oracle 12c" "Failover" {
            liveSecondaryDatabaseInstance = containerInstance internetBankingSystem.database "Failover"
        }
        
        bigbankdb01.primaryDatabaseServer -> secondaryDatabaseServer "Replicates data to"
    }
    
    deploymentNode "bigbank-prod001" "" "" "" {
        softwareSystemInstance mainframe
    }
}