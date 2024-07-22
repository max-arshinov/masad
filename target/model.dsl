ticketingWebsite = softwaresystem "A Concert ticketing website"{
    !docs concert-comparison/docs/src
    !adrs concert-comparison/adrs

    spa = container "Single Page Application" "React"
    web = container "Web Server" "Node.js"
    webSocketServer = container "Web Socket Server" "Node.js" {
        description "A server that allows users to see the availability of seats in real time. Sends updates to the SPA when a seat is taken and when a seat is released."
    }
    database = container "Database" "PostgreSQL"
    spa -> web "HTTP"
    web -> database 
    web -> webSocketServer
    spa -> webSocketServer "web socket"
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

user -> ticketingWebsite.spa "Buy Ticket" "https"
user -> ticketingWebsite.webSocketServer "See Seat Availability" "https"
ticketingWebsite.web -> paymentService "Pay for Ticket" "https"



