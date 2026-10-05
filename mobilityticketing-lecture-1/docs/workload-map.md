# Workload Map

## Workload Queries

### Query 1: Upcoming Trips

**Purpose:**  
Show the next 20 scheduled trips for a specific route after a supplied timestamp.

**Argumentation:**  
This query represents a common lookup where users need to see the next departures for a specific route. It filters by `route_id` and `scheduled_departure_utc`, sorts the results by departure time, and limits the result to the next 20 trips.

This is expected to be a frequent read operation because checking upcoming departures is a typical user action.


### Query 2: Ordered Route Stops

**Purpose:**  
Show the stops belonging to a specific route in the correct order.

**Argumentation:**  
This query joins `route_stops` with `stops` because `route_stops` contains the relationship and sequence, while `stops` contains information about each stop.

The query filters by `route_id` and orders by `stop_sequence` to ensure that the stops are returned in the correct travelling order.

This is primarily a read operation and would typically be used when displaying information about a route.


### Query 3: Routes and Trip Count

**Purpose:**  
Show all routes and the number of scheduled trips on a supplied service date, including routes with no trips.

**Argumentation:**  
This query represents an aggregation/reporting workload. It uses a `LEFT JOIN` to ensure that every route is included, even when there are no trips for the supplied date.

The `service_date` condition is placed inside the `JOIN` condition rather than the `WHERE` clause. This is important because placing it in the `WHERE` clause would remove routes without matching trips.

`COUNT(t.id)` counts the matching trips while still returning `0` for routes without trips.
