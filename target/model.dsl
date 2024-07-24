ticketingWebsite = softwaresystem "Cosmic Master Ticket" {
    !docs concert-comparison/docs/src
    !adrs concert-comparison/adrs

    spa = container "Single Page Application" "React"
    web = container "Web Server" "Node.js"
    webSocketServer = container "Web Socket Server" "Node.js" {
        description "A server that allows users to see the availability of seats in real time. Sends updates to the SPA when a seat is taken and when a seat is released."
    }
    database = container "Database" "PostgreSQL" "" "Database"
    spa -> web "HTTP"
    web -> database 
    web -> webSocketServer
    spa -> webSocketServer "Web Socket"
}

user = person "User"{
    description  "A user of the ticketing website"
}
businessOwner = person "Business Owner"{
    description  "Concert organizers and ticketing companies."
}

paymentService = softwaresystem "Payment Service"{
    description  "A payment service that allows users to pay for tickets."
}

user -> ticketingWebsite.spa "Interact with the website" "https"
user -> paymentService "Pay for the ticket" "https"

businessOwner -> ticketingWebsite.spa "Interact with the website" "https"

paymentService -> ticketingWebsite.web "Interact with payment service" "https"

ticketingWebsite.web -> user "Send Emails" "email"
ticketingWebsite.web -> businessOwner "Send Emails" "email"