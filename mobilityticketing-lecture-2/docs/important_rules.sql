-- Rule 1 - Negative product price. 
-- Enforced - CHECK violation.   
-- Boundary - A ticket could have a price of 0, which might not be the intended behavior.

-- Rejected write 
update products
set price = -1
where code = 'SINGLE';

-- Valid write
update products
set price = 10.00
where code = 'SINGLE';


-- Rule 2 - Unique ticket code.
-- Enforced - UNIQUE violation.
-- Boundary - A ticket code could be unique but not valid according to the business rules.

-- Valid write 
    -- Run this first
insert into tickets (
    id, user_id, trip_id, ticket_code, status,
    product_code, valid_from_utc, valid_to_utc, price, currency
) values (
             'TICKET-5', 'USER-2', 'TRIP-M2-20260429-0800',
             'CODE-M2-0006', 'Active', 'SINGLE',
             '2026-04-29 08:00:00+00', '2026-04-29 09:00:00+00', 36, 'DKK'
         );

    -- Run this second
insert into tickets (
    id, user_id, trip_id, ticket_code, status,
    product_code, valid_from_utc, valid_to_utc, price, currency
) values (
             'TICKET-6', 'USER-1', 'TRIP-M2-20260429-0800',
             'CODE-M2-0007', 'Active', 'SINGLE',
             '2026-04-30 08:00:00+00', '2026-04-30 09:00:00+00', 56, 'DKK'
         );

    
-- Rejected write
    -- Run this first
insert into tickets (
    id, user_id, trip_id, ticket_code, status,
    product_code, valid_from_utc, valid_to_utc, price, currency
) values (
             'TICKET-3', 'USER-1', 'TRIP-M2-20260429-0800',
             'CODE-M2-0002', 'Active', 'SINGLE',
             '2026-04-29 08:00:00+00', '2026-04-29 09:00:00+00', 36, 'DKK'
         );

    -- Run this second
insert into tickets (
    id, user_id, trip_id, ticket_code, status,
    product_code, valid_from_utc, valid_to_utc, price, currency
) values (
             'TICKET-4', 'USER-2', 'TRIP-M2-20260429-0800',
             'CODE-M2-0002', 'Active', 'SINGLE',
             '2026-04-30 08:00:00+00', '2026-04-30 09:00:00+00', 56, 'DKK'
         );
