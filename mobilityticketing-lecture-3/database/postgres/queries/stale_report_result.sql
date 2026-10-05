-- 1. First create materialized view inside base_revenue.sql.
-- 2. Then insert new payment from script below.
-- 3. Then go back to base_revenue.sql and run "SELECT * FROM mobility.public.base_revenue_mv;". The new payment shouldn't be show.
-- 4. Use either "REFRESH MATERIALIZED VIEW base_revenue_mv;" or create a trigger to refresh the materialized view on payments table changes.


insert into payments (
    id, user_id, ticket_id, external_payment_reference,
    amount, currency, status, created_utc
) values
      ('PAYMENT-3', 'USER-1', 'TICKET-1', 'gateway-capture-0001', 56.00, 'DKK', 'Captured', '2026-04-29 07:40:00+00')
    on conflict do nothing;

