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

    user -> ticketingWebsite.spa "Enter payment information and confirm purchase"
    ticketingWebsite.spa -> ticketingWebsite.web "Request payment"
    ticketingWebsite.web -> paymentService "Request payment"
    paymentService -> ticketingWebsite.web "Payment confirmation"
    ticketingWebsite.web -> ticketingWebsite.database "Create purchase record"
    ticketingWebsite.web -> ticketingWebsite.webSocketServer "Send payment confirmation to unlock seats"

    ticketingWebsite.web -> ticketingWebsite.spa "Success payment response"
    ticketingWebsite.spa -> user "Notify user with success payment"

    autoLayout
}
