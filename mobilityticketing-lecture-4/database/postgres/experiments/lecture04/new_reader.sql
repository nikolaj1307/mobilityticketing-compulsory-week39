-- TODO: Extend this query to return a resolved_product_id.
-- Join by product_id when present; otherwise look up the product by code.
-- Before backfill, your query should still resolve every original ticket.
SELECT
    t.id,
    t.product_code,
    t.product_id,
    COALESCE(t.product_id, p.id) AS resolved_product_id,
    t.price,
    t.currency
FROM tickets t
         LEFT JOIN products p
                   ON p.code = t.product_code
ORDER BY t.id;