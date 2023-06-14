supportStaff = person "Customer Service Staff" "Customer service staff within the bank." "Bank Staff"
customer = person "Personal Banking Customer" "A customer of the bank, with personal bank accounts." "Customer"
customer -> supportStaff "Asks questions to" "Telephone"

group "Big Bank plc" {
    mainframe = softwaresystem "Mainframe Banking System" "Stores all of the core banking information about customers, accounts, transactions, etc." "Existing"
    supportStaff -> mainframe "Uses"

    email = softwaresystem "E-mail System" "The internal Microsoft Exchange e-mail system." "Existing"
    email -> customer "Sends e-mails to"

    atm = softwaresystem "ATM" "Allows customers to withdraw cash." "Existing"
    atm -> mainframe "Uses"

    customer -> atm "Withdraws cash using"

    internetBankingSystem = softwaresystem "Internet Banking System" "Allows customers to view information about their bank accounts, and make payments." {
        !include internet-banking-system/ibs.dsl
    }
    internetBankingSystem -> mainframe "Gets account information from, and makes payments using"
    internetBankingSystem -> email "Sends e-mail using"
    customer -> internetBankingSystem "Views account balances, and makes payments using"
}


backoffice = person "Back Office Staff" "Administration and support staff within the bank." "Bank Staff"
backoffice -> mainframe "Uses"