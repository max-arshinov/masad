---
mode: 'agent'
description: 'Add deployment to the Structurizr model'
---

<context>
When given a system description, identity the main technical decisions (technologies, frameworks, databases) 
and define their interactions with users, each other, and other systems.
</context>

<instructions>
- Edit `deployment/live.dsl`. Add all required `deploymentNode` and other deployment-related elements.
- Make sure to add `instances <NUMBER OF INSTANCES>` to any nodes that should be clustered or load balanced.
</instructions>

<constraints>
- Focus ONLY on deployment elements.
- DO NOT change `model.dsl` or `views.dsl`.
- DO NOT add views or styling commands.
- Use `!identifiers hierarchical`: e.g. `softwareSystem.containerName`, not just `containerName`.
- Only add a single primary region (no failover or disaster recovery).
- DO NOT add any new relationships.
</constraints>

<formatting>
- Elements (`deploymentNode` and others) = singular nouns.
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

deploymentNode "bigbank-prod001" {
    softwareSystemInstance mainframe
}
</example>

<validation>
- Verify all variable names use lowerCamelCase.
- Verify no new relationships were added.
- Verify only deployment elements are included.
- Veryfy that clastered/load balanced nodes have `instances <NUMBER OF INSTANCES>`.
</validation>