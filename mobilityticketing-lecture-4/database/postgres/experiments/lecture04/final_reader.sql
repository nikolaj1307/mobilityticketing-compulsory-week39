-- TODO: Join products through product_id and include the product code.
-- Do not use tickets.product_code: this query must survive its removal.
select t.id, t.product_id, t.price, t.currency, p.code
from tickets t
join products p on t.product_id = p.id
order by t.id;
