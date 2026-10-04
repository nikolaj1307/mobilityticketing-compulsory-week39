# Lecture 1 – Introduction to Databases

## Modelling choice

The primary key of `route_stops` is:

(route_id, stop_sequence)

This allows the same stop to occur more than once on a route.
For example, a circular route may begin and end at the same stop.

## Assumption

We assume that a route may visit the same stop multiple times (circular routes).

## Functional dependency

(route_id, stop_sequence) -> stop_id

For a given route, each sequence position identifies exactly one stop.

This prevents multiple stops from occupying the same position on
the same route.

