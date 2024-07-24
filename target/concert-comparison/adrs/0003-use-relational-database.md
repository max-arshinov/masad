# 3. Use Relational Database

Date: 2024-07-22

## Status

Accepted

## Context

We need to store and manage data related to concerts, venues, seats, and bookings in the concert ticket booking application. This data includes information such as concert details, seat availability, user bookings, and payment transactions.

## Decision

We will use a relational database to store and manage data related to concerts, venues, seats, and bookings in the concert ticket booking application. We will use PostgreSQL as our relational database management system.

After evaluating the requirements, we concluded that this type of database is the most suitable for our application over a NoSQL approach, since our most critical needs are consistency and data integrity.

## Consequences

Using a relational database will provide us with a structured and organized way to store and manage data. It will allow us to define relationships between different entities, ensuring data integrity and consistency.
