# Compulsory Assignment - review guide

## Where to find the work

### Lecture 1
- [Model & workload map](mobilityticketing-lecture-1/docs)
- [Queries](mobilityticketing-lecture-1/database/postgres/003_queries.sql)

### Lecture 2
- [Constraints](mobilityticketing-lecture-2/database/postgres/migrations/011_ticketing_integrity.sql)
- [Constraint tests](mobilityticketing-lecture-2/database/postgres/experiments/constraints_should_fail.sql)

### Lecture 3
- [Reporting experiment and comparison](mobilityticketing-lecture-3/docs/responsibility-decision.md)

### Lecture 4
- [Migration stages and verification](mobilityticketing-lecture-4/database/postgres/migrations)

## Two decisions worth discussing

### Decision 1 — Primary key for `route_stops`

#### What did we choose?

We chose `(route_id, stop_sequence)` as the primary key of `route_stops`.

#### What was the alternative?

An alternative would be to use `stop_id` as part of the primary key, or to assume that a stop can only appear once on a route.

#### Why does our choice fit MobilityTicketing?

This choice allows the same stop to occur more than once on a route. This is important for MobilityTicketing because a route may be circular and therefore visit the same stop multiple times, for example at both the beginning and end of a route.

The functional dependency:

`(route_id, stop_sequence) -> stop_id`

also ensures that each sequence position on a route identifies exactly one stop.

#### Evidence

- [Dossier](mobilityticketing-lecture-1/docs/dossier.md)


### Decision 2 — Daily revenue reporting

#### What did we choose?

We chose to use a materialized view for daily revenue reporting, while keeping the `payments` table as the source of truth.

#### What was the alternative?

The alternative was to maintain a summary table using database triggers whenever a payment is inserted or changed.

#### Why does our choice fit MobilityTicketing?

A materialized view provides fast reads for daily revenue reports without adding extra complexity or side effects to every payment transaction.

Keeping `payments` as the source of truth also makes the system easier to recover. If the materialized view becomes incorrect, it can be rebuilt from the underlying `payments` table.

#### Evidence

- [Stale result](mobilityticketing-lecture-3/database/postgres/queries/stale_report_result.sql)


## One limitation or open question

#### What does our implementation NOT guarantee?

The materialized view does not guarantee that daily revenue data is always up to date.

#### Why is this a limitation?

A materialized view stores a previously calculated result, so it can become stale when new payments are added or existing payments change. The reported revenue may therefore differ temporarily from the current data in the `payments` table.

#### Evidence

The materialized-view decision states that the view can become stale and should be refreshed periodically or whenever fresh data is required.

#### What would we investigate/change next?

We would investigate an appropriate refresh strategy. For example, the view could be refreshed on a fixed schedule for normal reporting, with an option to perform an immediate refresh when up-to-date revenue information is required.
