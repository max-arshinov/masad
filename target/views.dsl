systemlandscape "SystemLandscape" {
    include *
    autoLayout
}

systemcontext internetBankingSystem "SystemContext" {
    include *
    animation {
        internetBankingSystem
        customer
        mainframe
        email
    }
    autoLayout
    description "The system context diagram for the Internet Banking System."
    properties {
        structurizr.groups false
    }
}

container internetBankingSystem "Containers" {
    include *
    animation {
        customer mainframe email
        internetBankingSystem.web
        internetBankingSystem.spa
        internetBankingSystem.mobile
        internetBankingSystem.api
        internetBankingSystem.database
    }
    autoLayout
    description "The container diagram for the Internet Banking System."
}

component internetBankingSystem.api "Components" {
    include *
    animation {
        internetBankingSystem.spa internetBankingSystem.mobile internetBankingSystem.database email mainframe
        internetBankingSystem.api.signinController internetBankingSystem.api.securityComponent
        internetBankingSystem.api.accountsSummaryController internetBankingSystem.api.mainframeBankingSystemFacade
        internetBankingSystem.api.resetPasswordController internetBankingSystem.api.emailComponent
    }
    autoLayout
    description "The component diagram for the API Application."
}

#this is only available on the Structurizr cloud service/on-premises installation/Lite
#image mainframe "MainframeBankingSystemFacade" {
#    image https://raw.githubusercontent.com/structurizr/examples/main/dsl/big-bank-plc/internet-banking-system/mainframe-banking-system-facade.png
#    title "[Code] Mainframe Banking System Facade"
#}

dynamic internetBankingSystem.api "SignIn" "Summarises how the sign in feature works in the single-page application." {
    internetBankingSystem.spa -> internetBankingSystem.api.signinController "Submits credentials to"
    internetBankingSystem.api.signinController -> internetBankingSystem.api.securityComponent "Validates credentials using"
    internetBankingSystem.api.securityComponent -> internetBankingSystem.database "select * from users where username = ?"
    internetBankingSystem.database -> internetBankingSystem.api.securityComponent "Returns user data to"
    internetBankingSystem.api.securityComponent -> internetBankingSystem.api.signinController "Returns true if the hashed password matches"
    internetBankingSystem.api.signinController -> internetBankingSystem.spa "Sends back an authentication token to"
    autoLayout
    description "Summarises how the sign in feature works in the single-page application."
}

deployment internetBankingSystem "Development" "DevelopmentDeployment" {
    include *
    animation {
        devEnv.devLaptop.devBrowser.developerSinglePageApplicationInstance
        devEnv.devLaptop.devDocker.devTomcat.developerWebApplicationInstance devEnv.devLaptop.devDocker.devTomcat.developerApiApplicationInstance
        devEnv.devLaptop.devDbDocker.devDbServer.developerDatabaseInstance
    }
    autoLayout
    description "An example development deployment scenario for the Internet Banking System."
}

deployment internetBankingSystem "Live" "LiveDeployment" {
    include *
    animation {
        liveEnv.liveCustomerComputer.liveWebBrowser.liveSinglePageApplicationInstance
        liveEnv.liveCustomerDevice.liveMobileAppInstance
        liveEnv.liveDc.liveApiNode.liveWebServer.liveApiApplicationInstance
        liveEnv.liveDc.liveDbNode.primaryDatabaseServer.livePrimaryDatabaseInstance
        liveEnv.liveDc.liveFailover.secondaryDatabaseServer.liveSecondaryDatabaseInstance
    }
    autoLayout
    description "An example live deployment scenario for the Internet Banking System."
}