# Implementation lab: Change product identity without breaking tickets

## Scenario

The transport operator wants to rename product codes without breaking existing tickets. Your job is to give each product an ID that stays the same when its code changes. You cannot update every application instance at once, so your migration needs to support old code that still reads and writes `product_code`.

For this exercise, keep product codes unique and do not rename or reuse them while old and new code run together. Assign each product ID once. Keep every ticket linked to the same product, with its original price and currency.

## Before you start

Create a branch, then run these commands from the repository root to start your lab database:

```bash
git switch -c product-identity-lab
docker compose up -d
docker compose ps
docker compose exec -T postgres psql -U mobility -d mobility -v ON_ERROR_STOP=1 < database/postgres/experiments/lecture04/baseline.sql
```

Check that you have three tickets covering two products and that every ticket refers to an existing product. Save the ticket IDs, product codes, prices and currencies so you can compare them later. Leave `database/postgres/init/` unchanged.

If you are continuing in your own repository, use your earlier migrations and load at least three valid tickets covering two products. Check whether your reporting views or functions from lecture 3 use the columns you will change.

Copy each `.sql.example` file you need to `.sql` and complete its TODOs. Some examples contain runnable queries; others need your SQL before they can run.

Before running a migration, check its nullable columns, keys, backfill and any statements that remove data. If you already use an ORM, inspect its generated SQL too.

Run your scripts from the repository root, for example:

```bash
docker compose exec -T postgres psql -U mobility -d mobility -v ON_ERROR_STOP=1 < database/postgres/migrations/030_expand_product_identity.sql
```

Use the same command pattern for each file. Run each DDL migration once, in order. The backfill should be safe to repeat. If a statement fails inside a transaction, roll it back before continuing.

## Tasks

1. Try removing the old reference before updating the application code. Before running it, predict what will happen. Explain how you could lose the link between tickets and products, and show which old query or insert breaks. Roll back or reset your lab database before continuing.
   - I first removed `tickets.product_code`, which caused the old insert and query to fail because they relied on that column to link tickets to products. Without `product_code`, the application could not find the correct product for existing tickets, leading to broken references and potential data integrity issues.
   - Adding product_id NOT NULL also cannot work safely because existing tickets have no product ID yet. This demonstrates why the new column must be added as nullable and only then made NOT NULL.
2. Complete `030_expand_product_identity.sql.example`. Add a stored UUID to each product and a unique constraint on that column. Add a nullable `tickets.product_id` with a foreign key to the product ID. Keep `product_code`. Use a short lock timeout and explain what you would need to consider with a much larger table.
   - Will it lock/block normal traffic?
   - Should the backfill happen in batches?
3. Write an insert and a query that use only `product_code`, as the old application would. Show that both still work after you add the new columns.
   ```sql
   insert into tickets (
     id, user_id, trip_id, ticket_code, status, product_code,
     valid_from_utc, valid_to_utc, price, currency
     )
     values ('TICKET-4', 'USER-1', 'TRIP-M2-20260429-0800', 'CODE-M2-0004', 'Active', 'SINGLE',
     '2026-04-29 07:45:00+00', '2026-04-29 10:00:00+00', 56.00, 'DKK');
   ```
4. Write a new insert that accepts a product ID and looks up the code from that product. Store both references and the agreed purchase price. If the caller supplies a conflicting product code, either reject it or ignore it and use the code you looked up.
   ```sql
   insert into tickets (
    id,
    user_id,
    trip_id,
    ticket_code,
    status,
    product_id,
    product_code,
    valid_from_utc,
    valid_to_utc,
    price,
    currency
   )
   select
   'TICKET-5',
   'USER-1',
   'TRIP-M2-20260429-0800',
   'CODE-M2-0005',
   'Active',
   p.id,
   p.code,
   '2026-04-29 07:45:00+00',
   '2026-04-29 10:00:00+00',
   80.00,
   'DKK'
   from products p
   where p.id = '612dd72e-b96c-4abb-bec4-31eeaf9b0e1f';
   ```
5. Write a query that finds a ticket's product by `product_id`, using `product_code` only when `product_id` is null. Test it before you fill in the IDs on existing tickets.
   ```sql 
   select
    t.id as ticket_id,
    coalesce(p_id.id, p_code.id) as product_id,
    coalesce(p_id.code, p_code.code) as product_code,
    t.price,
    t.currency
    from tickets t
    left join products p_id
    on p_id.id = t.product_id
    left join products p_code
    on t.product_id is null
    and p_code.code = t.product_code
    order by t.id;
    ```
6. Complete `031_backfill_ticket_product.sql.example`. Fill in `product_id` only where it is null. Run the backfill twice and check that the second run changes zero rows. Then insert another ticket using the old writer and run the backfill again. It should fill in the new ticket's reference without changing any IDs you already assigned.
   7. Write checks for null product IDs, missing products, and code/ID pairs that point to different products. Compare the original tickets, prices and currencies with your starting data. Separately, try writing a mismatched pair directly in SQL and record whether the database rejects it.
      ```sql
      -- 1. Check for null product IDs
      select t.*
      from tickets t
      left join products p
      on p.id = t.product_id
      where p.id is null;
      
      -- 2. Check for tickets pointing to a missing product
      select t.*
      from tickets t
      left join products p
      on p.id = t.product_id
      where p.id is null;
      
      -- 3. Check for mismatched product_code / product_id
      select
      t.id as ticket_id,
      t.product_id,
      t.product_code,
      p.code as actual_product_code
      from tickets t
      join products p
      on p.id = t.product_id
      where t.product_code is distinct from p.code;
      
      -- 4. Compare original ticket data
      select
      id,
      product_code,
      price,
      currency
      from tickets
      order by id;
      ```
8. Complete `032_require_ticket_product.sql.example`. First, try making `product_id` required while one ticket still has a null reference. Capture the failure. Once you meet the conditions below, validate the foreign key and make the column required. Show that the old writer now fails.
   - ERROR: null value in column "product_id" of relation "tickets" violates not-null constraint
9. Write an insert and a query that use only `product_id`. Check for views and functions that still use `tickets.product_code`, then try dropping that column in your lab database without `CASCADE`. Keep `products.code` for the catalogue.
   ```sql
   alter table tickets
   drop column product_code;
   ```
## Before you require the new reference


Before making `product_id` required, make sure no old-only writers are still running and that the new readers and writers are in place. Run the backfill one last time and check for missing or mismatched references. Explain whether you could still return to the old application version and what that would involve. You cannot tell which versions are running just by looking at the repository.

Before dropping `tickets.product_code`, switch to readers and writers that use only the ID and check for database objects that still need the code. Explain whether you would keep the old column for a while and why. A UUID default does not stop someone from updating an ID, so explain how your application code or database permissions would prevent that.

## What to record

Keep your SQL, commands and important results in `docs/evidence/lecture04/README.md`. Show the failures as well as the successful runs, and check that the original tickets still have the same products, prices and currencies.

Add a small table showing which inserts and queries work before expansion, after expansion, once the ID is required, and after the old column is removed. Note any query that runs but misses tickets.

Finish with your rollout decision: when would you stop the old writers, and could you still return to the old application version? Support your answer with a result from your tests.
