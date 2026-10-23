-- Query 1: upcoming trips
select
    t.id,
    t.scheduled_departure_utc,
    t.status
from trips t
where t.route_id = 'LINE-M2'
  and t.scheduled_departure_utc >= current_timestamp
order by t.scheduled_departure_utc
limit 20;

-- Query 2: ordered route stops
-- TODO: join route_stops to stops and order by stop_sequence.
select
    rs.route_id,
    rs.stop_sequence,
    s.id as stop_id,
    s.name as stop_name
from route_stops rs
join stops s on s.id = rs.stop_id
where rs.route_id = 'LINE-M2'
order by rs.stop_sequence;

-- Query 3: routes and trip count, including routes with zero trips
-- TODO: preserve routes with no matching trips for the supplied service date.
select
    r.id,
    r.short_name,
    count(t.id) as trip_count
from routes r
left join trips t
    on t.route_id = r.id
    and t.service_date = '2026-08-26'
group by r.id, r.short_name
order by r.id;
