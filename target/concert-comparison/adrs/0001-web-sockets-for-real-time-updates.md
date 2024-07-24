# 1. Web Sockets for Real-Time Updates

Date: 2024-07-22

## Status

Accepted

## Context

We need to record the architectural decisions made on this project.

## Decision

We will use WebSockets for real-time updates of seat statuses in the concert ticket booking application.

## Consequences

Using WebSockets will allow us to provide real-time updates to users regarding the status of seats. The statuses include:

- **Soft Locked**: A user is attempting to purchase a ticket for this seat. The seat is still available for others.
- **Hard Locked**: A user is in the process of paying for this seat. The seat is not available for others.
- **Bought**: The seat has been purchased and is no longer available.

Implementing WebSockets ensures that all users have up-to-date information on seat availability, enhancing the user experience by preventing confusion and potential booking conflicts.
