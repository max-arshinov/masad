ticketingWebsite = softwaresystem "A Concert ticketing website"{
    spa = container "Single Page Application" "React"
    web = container "Web Server" "Node.js"
    webSocketServer = container "Web Socket Server" "Node.js"
    database = container "Database" "PostgreSQL"
    spa -> web "HTTP"
    web -> database 
    spa -> webSocketServer "HTTP"
}

user = person "User"
user -> ticketingWebsite.spa "Buy Ticket" "https"
user -> ticketingWebsite.webSocketServer "See Seat Availability" "https"


