-- After expansion, use this query to choose a product ID for your test.
select id, code, price, currency from products order by code;


-- TODO: Write a function or parameterized insert that accepts a product ID.
-- Look up its code and store both references on the ticket.
    
-- Use old_writer.sql as a guide to the other required ticket fields.
-- Keep the agreed price as an input; do not copy the current catalogue price.
-- Test an unknown ID and a supplied code belonging to another product.

-- new_writer.sql
-- New writer accepts product_id and stores both
-- product_id and the corresponding product_code.



insert into tickets (
    id,
    user_id,
    trip_id,
    ticket_code,
    status,
    product_code,
    product_id,
    valid_from_utc,
    valid_to_utc,
    price,
    currency
)
select
    'TICKET-4',
    'USER-1',
    'TRIP-M2-20260429-1200',
    'CODE-M2-0002',
    'Active',
    p.code,
    p.id,
    '2026-04-29 00:00:00.00'::timestamp,
    '2026-04-29 01:00:00+00'::timestamp,
    36.00,
    'DKK'
from products p
where p.id = '4ebe1ab1-ad11-4aee-a11c-1809227a3723';

select
    id,
    product_code,
    product_id,
    price,
    currency
from tickets
where id = 'TICKET-4';