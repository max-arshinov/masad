# 1. Seats Locking States

Date: 2024-07-22

## Status

Accepted

## Context

We need to define a set of states for seats in the concert ticket booking application. These states will be used to manage the locking and availability of seats during the booking process.

## Decision

In conjunction with using WebSockets for real-time updates of seat statuses, we will define the following states for seats:

- **Soft Locked**: A user is attempting to purchase a ticket for this seat. The seat is still available for others.
- **Hard Locked**: A user is in the process of paying for this seat. The seat is not available for others.
- **Bought**: The seat has been purchased and is no longer available.

## Consequences

Defining these states will help us manage the availability of seats and prevent double bookings. It will also provide clarity to users regarding the status of seats during the booking process.
