dynamic ticketingWebsite "BuyTicket" "" {
    user -> ticketingWebsite.spa "View available seats"
    ticketingWebsite.spa -> ticketingWebsite.web "HTTP request for available seats"
    ticketingWebsite.web -> ticketingWebsite.database "Request available seats (Not bought seats)"
    ticketingWebsite.database -> ticketingWebsite.web "Send available seats"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Request soft locked seats and locked(for payment) seats"
    ticketingWebsite.webSocketServer -> ticketingWebsite.web "Send available seats"
    ticketingWebsite.web -> ticketingWebsite.spa "Send available seats"
    ticketingWebsite.spa -> user "Display available seats"

    user -> ticketingWebsite.spa "Select the seat(s)"
    ticketingWebsite.spa -> ticketingWebsite.webSocketServer "Open WebSocket connection"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to select seats"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Send selected seats" 
    // {
    //     description  "webSocketServer save the seats of every user has selected for notify them if one of them is bought by another user in their session."
    // }
    ticketingWebsite.webSocketServer -> ticketingWebsite.spa "Notify other users about seat selection"
    ticketingWebsite.spa -> user "Confirm seat soft lock"

    user -> ticketingWebsite.spa "Go to payment step"
    ticketingWebsite.spa -> ticketingWebsite.web "HTTP request to lock selected seats"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Lock selected seats"
    ticketingWebsite.webSocketServer -> ticketingWebsite.web "Confirm seat lock"
    ticketingWebsite.webSocketServer -> ticketingWebsite.spa "Notify user with seat lock"
    // {
    //     description = "using the WebSocket connection notify the users that has selected the seat(s) that the seat(s) is locked for payment by other user."
    // }
    ticketingWebsite.spa -> user "Notify user with seat locks and ask for change the selected seats"
    ticketingWebsite.web -> ticketingWebsite.spa "Confirm seat lock"
    ticketingWebsite.spa -> user "Confirm seat lock"

    user -> ticketingWebsite.spa "Enter payment information and confirm purchase"
    ticketingWebsite.spa -> ticketingWebsite.web "HTTP request to payment service"
    ticketingWebsite.web -> paymentService "Request payment"
    paymentService -> ticketingWebsite.web "Payment confirmation"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Send payment confirmation"
    // {
    //     description = "Send the payment confirmation to the webSocketServer to notify the users that the seat(s) is bought by another user."
    // }
    ticketingWebsite.web -> ticketingWebsite.database "Create purchase record"
    // {
    //     description = "Create a record in the database for the purchase, update the seat status to sold."
    // }
    ticketingWebsite.database -> ticketingWebsite.web "Confirm purchase record creation"

    ticketingWebsite.web -> ticketingWebsite.spa "Send Buy Ticket Response"
    ticketingWebsite.spa -> user "Send Buy Ticket Response"

    autoLayout
}
