devLaptop = deploymentNode "Developer Laptop" "" "Microsoft Windows 10 or Apple macOS" {
    devBrowser = browserNode "Web" {
        developerSinglePageApplicationInstance = containerInstance internetBankingSystem.spa
    }
    
    devDocker = dockerNode "Web Container" {
        devTomcat = tomcat "Apache Tomcat" {
            developerWebApplicationInstance = containerInstance internetBankingSystem.web
            developerApiApplicationInstance = containerInstance internetBankingSystem.api
        }
    }
    
    devDbDocker = dockerNode "Database Container" "" {
        devDbServer = oracleNode "Database Server" {
            developerDatabaseInstance = containerInstance internetBankingSystem.database
        }
    }
}

deploymentNode "Big Bank plc" "" "Big Bank plc data center" "" {
    deploymentNode "bigbank-dev001" {
        softwareSystemInstance mainframe
    }
}
