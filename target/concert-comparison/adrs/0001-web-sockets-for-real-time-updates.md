# 1. Web Sockets for Real-Time Updates

Date: 2024-07-22

## Status

Accepted

## Context

We need to handle concurrent seats purchases to prevent double bookings while providing a smooth user experience.

## Decision

We will use WebSockets for real-time updates of seat statuses in the concert ticket booking application.

## Consequences

Using WebSockets will allow us to provide real-time updates to users regarding the status of seats.

Implementing WebSockets ensures that all users have up-to-date information on seat availability, enhancing the user experience by preventing confusion and potential booking conflicts.
