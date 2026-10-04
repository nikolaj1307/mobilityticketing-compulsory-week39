# Integrity map

| Invariant                                                         | Affected tables and columns                                                    | Current protection                          | Missing protection or limitation                                                        | Expected failure behaviour                                                              | Evidence                                  |
|-------------------------------------------------------------------|--------------------------------------------------------------------------------|---------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-------------------------------------------|
| Ticket price can't be negative                                    | tickets.price                                                                  | CHECK that price is above or equal to 0     | Doesn't guarantee correct price                                                         | Negative value should be rejected                                                       | Negative value is rejected                |
| Ticket identity must be consistent when we are validating tickets | tickets.id, tickets.ticket_code validations.ticket_id, validations.ticket_code | unique (id, ticket_code) and a composite fk | validations.ticket_code can't be unique because a ticket can be validated multiple times | A validation containing a ticket id and code combination that doesn't exist should fail | Combination that doesn't exist is failing |

## Issue register

### Issue 1 - Ticket price validation

- Evidence: tickets.price is protected by CHECK (price >= 0).
- Problem: The constraint only ensures that the price is not negative.
- Consequence: A ticket could have a price of 0, which might not be the intended behavior.
- Specific improvement: Add a check to ensure that the price is greater than 0.
- Open question: Which ticket prices should be considered valid?

### Issue 2 - Ticket code uniqueness

- Evidence: tickets.ticket_code is protected by UNIQUE (ticket_code).
- Problem: The constraint guarantees uniqueness, but it does not guarantee that the ticket code follows a required format.
- Consequence: A ticket code could be unique but not valid according to the business rules.
- Specific improvement: Implement a check constraint or a trigger to validate the format of the ticket code.
- Open question: Should ticket codes follow a specific format or length?

## State-transition trace

### Ticket purchase

1. User, trip and product must already exist
2. Ticket generates unique ticket.ticket_code, valid from/to time, status is set, trips.resererved_seats updates if ticket includes seats
3. Payment which references the ticket

### Ticket validation

1. A ticket must already exist
2. A validation references the ticket using ticket_id and ticket_code pair.
3. Will be saved as Rejected or Accepted. 

