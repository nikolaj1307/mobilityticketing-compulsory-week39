-- Copy this file to 011_ticketing_integrity.sql and complete it from your integrity map.
-- Keep the starter DDL unchanged.

begin;

alter table trips
    alter column capacity set not null,
alter column reserved_seats set not null,
    add constraint trips_capacity_non_negative
        check (capacity >= 0),
    add constraint trips_reserved_seats_valid
        check (reserved_seats between 0 and capacity);

alter table tickets
    add constraint tickets_user_fk
        foreign key (user_id) references users(id),
    add constraint tickets_trip_fk
        foreign key (trip_id) references trips(id),
    add constraint tickets_product_fk
        foreign key (product_code) references products(code),
    add constraint user_id_not_null
        check (user_id is not null),
    add constraint trip_id_not_null
        check (trip_id is not null),
    add constraint ticket_valid_from_is_less_than_valid_to
        check (valid_from_utc <= valid_to_utc),
    add constraint ticket_price_non_negative
        check (price >= 0),
    add constraint ticket_currency_not_null
        check (currency is not null),
    add constraint ticket_status_check
        check (status in ('Pending', 'Active', 'Validated', 'Cancelled', 'Expired')),
    add constraint ticket_code_unique
        unique (ticket_code),
    add constraint ticket_code_not_null
        check (ticket_code is not null),
    add constraint ticket_id_code_unique
        unique (id, ticket_code);

alter table products
    add constraint product_price_non_negative
        check (price >= 0),
    add constraint product_currency_not_null
        check (currency is not null),
    add constraint product_name_not_null
        check (name is not null);

alter table users
    add constraint user_email_not_null
        check (email is not null),
    add constraint user_full_name_not_null
        check (full_name is not null),
    add constraint user_email_unique
        unique (email);

alter table payments
    add constraint payments_user_fk
        foreign key (user_id) references users(id),
    add constraint payments_ticket_fk
        foreign key (ticket_id) references tickets(id),
    add constraint payment_amount_non_negative
        check (amount >= 0),
    add constraint user_id_not_null
        check (user_id is not null),
    add constraint ticket_id_not_null
        check (ticket_id is not null),
    add constraint payment_currency_not_null
        check (currency is not null),
    add constraint payment_status_check
        check (status in ('Confirmed', 'Rejected', 'Refunded', 'Captured')),
    add constraint payment_external_reference_unique
        unique (external_payment_reference);

    
alter table validations
    add constraint validations_ticket_id_code_fk
        foreign key (ticket_id, ticket_code)
            references tickets(id, ticket_code),
    add constraint validations_ticket_id_not_null
        check (ticket_id is not null),
    add constraint validations_ticket_code_not_null
        check (ticket_code is not null),
    add constraint validations_result_check
        check (result in ('Accepted', 'Rejected'));        
    
-- TODO: product reference, ticket-code identity, status, price,
-- currency, validity window and remaining foreign keys.
-- Decide how duplicated validations.ticket_code should be protected.
-- Tickets can be validated multiple times, so validations.ticket_code is not unique.
-- Name every constraint so tests and later migrations can identify it.

commit;
