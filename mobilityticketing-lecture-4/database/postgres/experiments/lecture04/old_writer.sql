-- Change both values for each new ticket, including your late-write test.
\set ticket_id 'LAB04-OLD-1'
\set ticket_code 'LAB04-CODE-OLD-1'

insert into tickets
    (id, user_id, trip_id, ticket_code, status, product_code,
     valid_from_utc, valid_to_utc, price, currency)
select 'LAB04-OLD-4', user_id, trip_id, 'LAB04-CODE-OLD-4', status, product_code,
       valid_from_utc, valid_to_utc, price, currency
from tickets
where id = 'TICKET-1';
