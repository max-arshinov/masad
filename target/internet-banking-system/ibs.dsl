!docs docs/src
!adrs adrs

database = container "Database" "Stores user registration information, hashed authentication credentials, access logs, etc." "Oracle Database Schema" "Database"

api = container "API Application" "Provides Internet banking functionality via a JSON/HTTPS API." "Java and Spring MVC" {
    emailComponent = component "E-mail Component" "Sends e-mails to users." "Spring Bean"
    emailComponent -> email "Sends e-mail using"

    mainframeBankingSystemFacade = component "Mainframe Banking System Facade" "A facade onto the mainframe banking system." "Spring Bean"
    mainframeBankingSystemFacade -> mainframe "Makes API calls to" "XML/HTTPS"

    accountsSummaryController = component "Accounts Summary Controller" "Provides customers with a summary of their bank accounts." "Spring MVC Rest Controller"
    accountsSummaryController -> mainframeBankingSystemFacade "Uses"
        
    securityComponent = component "Security Component" "Provides functionality related to signing in, changing passwords, etc." "Spring Bean"
    securityComponent -> database "Reads from and writes to" "SQL/TCP"
        
    signinController = component "Sign In Controller" "Allows users to sign in to the Internet Banking System." "Spring MVC Rest Controller"
    signinController -> securityComponent "Uses"
        
    resetPasswordController = component "Reset Password Controller" "Allows users to reset their passwords with a single use URL." "Spring MVC Rest Controller"
    resetPasswordController -> securityComponent "Uses"
    resetPasswordController -> emailComponent "Uses"
}

mobile = container "Mobile" "Provides a limited subset of the Internet banking functionality to customers via their mobile device." "Xamarin" "Mobile"
mobile -> api.signinController "Makes API calls to" "JSON/HTTPS"
mobile -> api.accountsSummaryController "Makes API calls to" "JSON/HTTPS"
mobile -> api.resetPasswordController "Makes API calls to" "JSON/HTTPS"
customer -> mobile "Views account balances, and makes payments using"

spa = container "Single-Page Application" "Provides all of the Internet banking functionality to customers via their web browser." "JavaScript and Angular" "Web"
spa -> api.signinController "Makes API calls to" "JSON/HTTPS"
spa ->  api.accountsSummaryController "Makes API calls to" "JSON/HTTPS"
spa ->  api.resetPasswordController "Makes API calls to" "JSON/HTTPS"
customer -> spa  "Views account balances, and makes payments using"

web = container "Web Application" "Delivers the static content and the Internet banking single page application." "Java and Spring MVC"
web -> spa "Delivers to the customer's web browser"
customer -> web "Visits bigbank.com/ib using" "HTTPS"
