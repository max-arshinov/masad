dynamic ticketingWebsite "BuyTicket" "" {
    user -> ticketingWebsite.spa "View available seats"
    ticketingWebsite.webSocketServer -> user "Send selected seats"
    user -> ticketingWebsite.spa "Select the seat(s)"
    ticketingWebsite.spa -> ticketingWebsite.webSocketServer "Send selected seats"
    ticketingWebsite.spa -> ticketingWebsite.web "Send Buy Ticket Request"
    ticketingWebsite.spa -> user "Send Buy Ticket Response" 
    autoLayout
}

