deploymentNode "Developer Laptop" "" "Microsoft Windows 10 or Apple macOS" {
    deploymentNode "Web" "" "Chrome, Firefox, Safari, or Edge" {
        developerSinglePageApplicationInstance = containerInstance internetBankingSystem.spa
    }
    
    deploymentNode "Docker Container - Web Server" "" "Docker" {
        deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
            developerWebApplicationInstance = containerInstance internetBankingSystem.web
            developerApiApplicationInstance = containerInstance internetBankingSystem.api
        }
    }
    
    deploymentNode "Docker Container - Database Server" "" "Docker" {
        deploymentNode "Database Server" "" "Oracle 12c" {
            developerDatabaseInstance = containerInstance internetBankingSystem.database
        }
    }
}

deploymentNode "Big Bank plc" "" "Big Bank plc data center" "" {
    deploymentNode "bigbank-dev001" "" "" "" {
        softwareSystemInstance mainframe
    }
}
