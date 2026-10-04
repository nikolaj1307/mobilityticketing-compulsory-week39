-- Copy this file to 021_daily_revenue_trigger.sql and apply it.
-- This is deliberately incomplete. Document the behaviour before extending it.

create table daily_revenue_by_operator (
    operator_id text not null references operators(id),
    revenue_date date not null,
    captured_amount numeric not null default 0,
    captured_payments bigint not null default 0,
    primary key (operator_id, revenue_date)
);
-- Initial backfill:
-- Populate the summary with all existing captured payments.
insert into daily_revenue_by_operator (
    operator_id,
    revenue_date,
    captured_amount,
    captured_payments
)
select
    r.operator_id,
    p.created_utc::date,
    sum(p.amount),
    count(*)
from payments p
         join tickets t on t.id = p.ticket_id
         join trips tr on tr.id = t.trip_id
         join routes r on r.id = tr.route_id
where p.status = 'Captured'
group by
    r.operator_id,
    p.created_utc::date;



create or replace function update_daily_revenue()
    returns trigger
    language plpgsql
as $$
declare
    old_operator_id text;
    new_operator_id text;
begin

    -- INSERT
    if TG_OP = 'INSERT' then

        if NEW.status = 'Captured' then

            select r.operator_id
            into new_operator_id
            from tickets t
                     join trips tr on tr.id = t.trip_id
                     join routes r on r.id = tr.route_id
            where t.id = NEW.ticket_id;

            insert into daily_revenue_by_operator (
                operator_id,
                revenue_date,
                captured_amount,
                captured_payments
            )
            values (
                       new_operator_id,
                       NEW.created_utc::date,
                       NEW.amount,
                       1
                   )
            on conflict (operator_id, revenue_date)
                do update set
                              captured_amount =
                                  daily_revenue_by_operator.captured_amount
                                      + excluded.captured_amount,
                              captured_payments =
                                  daily_revenue_by_operator.captured_payments
                                      + excluded.captured_payments;

        end if;

        return NEW;
    end if;


    -- DELETE
    if TG_OP = 'DELETE' then

        if OLD.status = 'Captured' then

            select r.operator_id
            into old_operator_id
            from tickets t
                     join trips tr on tr.id = t.trip_id
                     join routes r on r.id = tr.route_id
            where t.id = OLD.ticket_id;

            update daily_revenue_by_operator
            set
                captured_amount = captured_amount - OLD.amount,
                captured_payments = captured_payments - 1
            where operator_id = old_operator_id
              and revenue_date = OLD.created_utc::date;

        end if;

        return OLD;
    end if;


    -- UPDATE
    if TG_OP = 'UPDATE' then

        -- Remove the OLD contribution if it was captured
        if OLD.status = 'Captured' then

            select r.operator_id
            into old_operator_id
            from tickets t
                     join trips tr on tr.id = t.trip_id
                     join routes r on r.id = tr.route_id
            where t.id = OLD.ticket_id;

            update daily_revenue_by_operator
            set
                captured_amount = captured_amount - OLD.amount,
                captured_payments = captured_payments - 1
            where operator_id = old_operator_id
              and revenue_date = OLD.created_utc::date;

        end if;


        -- Add the NEW contribution if it is captured
        if NEW.status = 'Captured' then

            select r.operator_id
            into new_operator_id
            from tickets t
                     join trips tr on tr.id = t.trip_id
                     join routes r on r.id = tr.route_id
            where t.id = NEW.ticket_id;

            insert into daily_revenue_by_operator (
                operator_id,
                revenue_date,
                captured_amount,
                captured_payments
            )
            values (
                       new_operator_id,
                       NEW.created_utc::date,
                       NEW.amount,
                       1
                   )
            on conflict (operator_id, revenue_date)
                do update set
                              captured_amount =
                                  daily_revenue_by_operator.captured_amount
                                      + excluded.captured_amount,
                              captured_payments =
                                  daily_revenue_by_operator.captured_payments
                                      + excluded.captured_payments;

        end if;

        return NEW;
    end if;

    return NEW;
end;
$$;

create or replace trigger payments_daily_revenue_after_change
after insert or update or delete on payments
for each row
execute function update_daily_revenue();

-- TODO: analyse corrections, refunds, deletes, initial backfill, and duplicate delivery.
    -- Correction: The data is correct when using insert, but does not handle update or deletions of payments. 
    -- Refunds: Since it dosen't handle update, then refund wont be reflected in the daily revenue.
    -- Deletes: Since it dosen't handle deletions, then deletion of payments wont be reflected in the daily revenue.
    -- Initial backfill: The trigger will not backfill the daily revenue for existing payments.
    -- Duplicate delivery: Primary key constraint will prevent duplicate entries.
    
-- Do not add more trigger branches before documenting the behaviour.
