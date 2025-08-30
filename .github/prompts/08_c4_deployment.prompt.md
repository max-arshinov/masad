---
mode: 'agent'
description: 'Add deployment to the Structurizr model'
---

<context>
When given a system description, identity the main technical decisions (technologies, frameworks, databases) 
and define their interactions with users, each other, and other systems.
</context>

<instructions>
Edit `deployment/live.dsl`, add all required `deploymentNode` and other elements.
</instructions>

<constraints>
- Only focus on deployment elements
- DON'T change `model.dsl` or `views.dsl`
- NO views or styling commands
- use `!identifiers hierarchical`: `softwareSystem.containerName` not `containerName` alone
- Only add a single primary region, don't add failover or DR
- DON'T add new relationships
</constraints>

<formatting>
- Elements (`deploymentNode`) = singular nouns.
- One entity per line.
- ALWAYS use `lowerCamelCase` for variable names.
- Don't add descriptions or tags
</formatting>

<example>
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
</example>

<validation>
- Verify all variable names use lowerCamelCase
- Make sure you didn't add any new relationships
</validation>