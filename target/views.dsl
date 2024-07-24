dynamic ticketingWebsite "ViewSeatsState" "Seats state are:\n- Available\n- Soft locked\n- Locked" {
    user -> ticketingWebsite.spa "View available seats"
    ticketingWebsite.spa -> ticketingWebsite.web "HTTP request for available seats"
    ticketingWebsite.web -> ticketingWebsite.database "Request available seats (Not bought seats)"
    ticketingWebsite.database -> ticketingWebsite.web "Send available seats"
    ticketingWebsite.spa -> ticketingWebsite.webSocketServer "Open web socket connection"
    ticketingWebsite.spa -> ticketingWebsite.webSocketServer "Request soft locked seats and locked (for payment) seats"
    ticketingWebsite.webSocketServer -> ticketingWebsite.spa "Send available seats"
    ticketingWebsite.spa -> user "Display state of seats"

    autoLayout
}

dynamic ticketingWebsite "SelectSeats" "" {
    user -> ticketingWebsite.spa "Select the seat(s)"
    ticketingWebsite.spa -> ticketingWebsite.webSocketServer "Open WebSocket connection"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to select seats"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Send selected seats"
    // ticketingWebsite.webSocketServer -> ticketingWebsite.spa "Notify other users about seat selection"
    // ticketingWebsite.spa -> user "Confirm seat soft lock"

    autoLayout
}

dynamic ticketingWebsite "PayTicket" "" {
    user -> ticketingWebsite.spa "Go to payment step"
    ticketingWebsite.spa -> ticketingWebsite.webSocketServer "Hard lock selected seats"
    ticketingWebsite.webSocketServer -> ticketingWebsite.spa "Notify all users with those selected seats"
    ticketingWebsite.spa -> user "Notify user with seat locks and ask for change the selected seats"
    ticketingWebsite.spa -> user "Redirect to payment gateway for payment"

    user -> paymentService "Pay for the ticket"    
    paymentService -> ticketingWebsite.web "Payment confirmation"
    ticketingWebsite.web -> ticketingWebsite.database "Create purchase record"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Send payment confirmation to unlock seats"

    ticketingWebsite.web -> ticketingWebsite.spa "Success payment response"
    ticketingWebsite.spa -> user "Notify user with success payment"

    autoLayout
}

dynamic ticketingWebsite "CancelTicket" "" {
    user -> ticketingWebsite.spa "Go to cancel ticket step"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to cancel ticket"
    ticketingWebsite.web -> ticketingWebsite.database "Cancel ticket and unlock seats"
    ticketingWebsite.web -> ticketingWebsite.spa "Notify user with success cancel ticket"
    autoLayout
}

dynamic ticketingWebsite "ViewTickets" "" {
    user -> ticketingWebsite.spa "Go to view tickets step"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to view tickets"
    ticketingWebsite.web -> ticketingWebsite.database "Get tickets"
    ticketingWebsite.web -> ticketingWebsite.spa "Display tickets"
    ticketingWebsite.spa -> user "Display tickets"
    autoLayout
}

dynamic ticketingWebsite "AddConcert" "" {
    businessOwner -> ticketingWebsite.spa "Go to add concert step"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to add concert"
    ticketingWebsite.web -> ticketingWebsite.database "Add concert"
    ticketingWebsite.web -> ticketingWebsite.spa "Notify business owner with success add concert"
    autoLayout
}

dynamic ticketingWebsite "CancelConcert" "" {
    businessOwner -> ticketingWebsite.spa "Go to cancel concert step"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to cancel concert"
    ticketingWebsite.web -> ticketingWebsite.database "Get all tickets for the concert"
    ticketingWebsite.web -> user "Notify user with all tickets for the concert of canceling" "email"
    ticketingWebsite.web -> ticketingWebsite.database "Cancel all tickets for the concert"
    ticketingWebsite.web -> ticketingWebsite.database "Cancel concert"
    ticketingWebsite.web -> ticketingWebsite.spa "Notify business owner with success cancel concert"
    autoLayout
}

dynamic ticketingWebsite "ViewConcerts" "" {
    user -> ticketingWebsite.spa "Go to view concerts step"
    ticketingWebsite.spa -> ticketingWebsite.web "Request to view concerts"
    ticketingWebsite.web -> ticketingWebsite.database "Get concerts"
    ticketingWebsite.web -> ticketingWebsite.spa "Display concerts with seats state"
    ticketingWebsite.spa -> user "Display concerts"
    autoLayout
}
