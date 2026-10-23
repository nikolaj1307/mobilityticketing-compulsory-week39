-- TODO: Adapt your new writer to use product_id without tickets.product_code.
-- Keep id, user_id, trip_id, ticket_code, status, validity dates, price and
-- currency in the insert. Use a fresh ticket ID and ticket code.
-- Test after removing the old column. If you try it while that column still
-- exists, check whether its NOT NULL constraint allows the insert.

insert into tickets (
    id,
    user_id,
    trip_id,
    ticket_code,
    status,
    product_id,
    valid_from_utc,
    valid_to_utc,
    price,
    currency
)
select
    'LAB04-ID-ONLY-1',
    'USER-1',
    'TRIP-M2-20260429-1200',
    'LAB04-CODE-ID-ONLY-1',
    'Active',
    p.id,
    '2026-04-29 12:00:00+00',
    '2026-04-29 14:00:00+00',
    36.00,
    'DKK'
from products p
where p.code = 'SINGLE';

select
    id,
    product_id,
    price,
    currency
from tickets
where id = 'LAB04-ID-ONLY-1';