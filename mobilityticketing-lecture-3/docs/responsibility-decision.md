## Responsibility matrix 

    - | Concern                    | Normal query / function | Materialized view           | Trigger-maintained summary            |
            | -------------------------- |---------------------|-----------------------------|---------------------------------------|
      | **Correctness**            | Always uses current data | Correct only after refresh | Usually current if triggers are correct |
      | **Freshness**              | Always fresh        | Can become stale            | Updated automatically                 |
      | **Write cost**             | Low                 | Low                         | Higher                                |
      | **Read cost**              | Higher              | Low                         | Very low                              |
      | **Hidden side effects**    | Few                 | Few                         | More                                  |
      | **Rebuildability**         | Easy               | Easy — refresh/recreate     | More complicated                      |
      | **Operational complexity** | Low               | Medium                      | High                                |

## Decision
We recommend using a materialized view for daily revenue reporting, while keeping payments as the source of truth. This provides fast reads without adding extra complexity or side effects to every payment transaction.

The materialized view can become stale, so it should be refreshed periodically or when fresh data is required. If it becomes incorrect, it can easily be rebuilt from the payments table.

This is simpler and easier to recover than a trigger-maintained summary.