--User defined function--
CREATE FUNCTION base_revenue()
    RETURNS TABLE (
    operator_id text,
    revenue_date date,
    captured_amount numeric,
    captured_payments int
    )
    LANGUAGE sql
AS $$
SELECT
    r.operator_id,
    p.created_utc::date AS revenue_date,
    SUM(p.amount) AS captured_amount,
    COUNT(*)::int AS captured_payments
FROM payments p
         JOIN tickets t ON t.id = p.ticket_id
         JOIN trips tr ON tr.id = t.trip_id
         JOIN routes r ON r.id = tr.route_id
WHERE p.status = 'Captured'
GROUP BY
    r.operator_id,
    p.created_utc::date
ORDER BY
    r.operator_id,
    p.created_utc::date;
$$;

SELECT mobility.public.base_revenue();



--Materialized view--
CREATE MATERIALIZED VIEW base_revenue_mv AS
SELECT
    r.operator_id,
    p.created_utc::date AS revenue_date,
    SUM(p.amount) AS captured_amount,
    COUNT(*)::int AS captured_payments
FROM payments p
         JOIN tickets t ON t.id = p.ticket_id
         JOIN trips tr ON tr.id = t.trip_id
         JOIN routes r ON r.id = tr.route_id
WHERE p.status = 'Captured'
GROUP BY
    r.operator_id,
    p.created_utc::date
ORDER BY
    r.operator_id,
    p.created_utc::date;

SELECT * FROM mobility.public.base_revenue_mv;

REFRESH MATERIALIZED VIEW base_revenue_mv;



--Trigger to refresh the materialized view on payments table changes--
CREATE OR REPLACE FUNCTION update_base_revenue_mv()
    RETURNS TRIGGER AS
$$
BEGIN
    REFRESH MATERIALIZED VIEW base_revenue_mv;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_base_revenue_mv
AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH STATEMENT 
EXECUTE FUNCTION update_base_revenue_mv ();


