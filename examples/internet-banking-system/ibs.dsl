database = oracle "Database" "Stores user registration information, hashed authentication credentials, access logs, etc."

api = springMvc "API Application" "Provides Internet banking functionality via a JSON/HTTPS API." {
    emailComponent = springBean "E-mail Component" "Sends e-mails to users."
    emailComponent -> email "Sends e-mail using"

    mainframeBankingSystemFacade = springBean "Mainframe Banking System Facade" "A facade onto the mainframe banking system."
    mainframeBankingSystemFacade --https-> mainframe "Makes API calls to"

    accountsSummaryController = controller "Accounts Summary Controller" "Provides customers with a summary of their bank accounts."
    accountsSummaryController -> mainframeBankingSystemFacade
        
    securityComponent = springBean "Security Component" "Provides functionality related to signing in, changing passwords, etc."
    securityComponent --sql-> database "Reads from and writes to"
        
    signinController = controller "Sign In Controller" "Allows users to sign in to the Internet Banking System."
    signinController -> securityComponent
        
    resetPasswordController = controller "Reset Password Controller" "Allows users to reset their passwords with a single use URL."
    resetPasswordController -> securityComponent
    resetPasswordController -> emailComponent
}

mobileApp = mobile "Mobile" "Provides a limited subset of the Internet banking functionality to customers via their mobile device." "Xamarin"
mobileApp --hj-> api.signinController "Makes API calls to"
mobileApp --hj-> api.accountsSummaryController "Makes API calls to"
mobileApp --hj-> api.resetPasswordController "Makes API calls to" 
customer -> mobileApp "Views account balances, and makes payments using"

spa = angular "Single-Page Application" "Provides all of the Internet banking functionality to customers via their web browser."
spa --hj-> api.signinController "Makes API calls to"
spa --hj-> api.accountsSummaryController "Makes API calls to"
spa --hj-> api.resetPasswordController "Makes API calls to"
customer -> spa "Views account balances, and makes payments using"

web = springMvc "Web Application" "Delivers the static content and the Internet banking single page application."
web -> spa "Delivers to the customer's web browser"
customer --https-> web "Visits bigbank.com/ib using"
