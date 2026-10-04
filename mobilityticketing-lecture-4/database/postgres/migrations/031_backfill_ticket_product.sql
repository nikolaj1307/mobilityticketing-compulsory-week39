-- Copy to 031_backfill_ticket_product.sql and complete it.
-- Resolve only tickets whose product_id is null.
-- Match the existing product code and preserve assigned IDs and historical prices.
-- The second run must change zero rows.

-- TODO: repeatable UPDATE.

update tickets t
set product_id = p.id
    from products p
where t.product_id is null
  and p.code = t.product_code;



-- Check ticket
select id, product_id, product_code, price, currency
from tickets
order by id;

