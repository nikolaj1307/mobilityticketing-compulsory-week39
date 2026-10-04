# 1. Extract at least ten domain invariants from the scenario and schema. 

## Directly enforceable with a column or table constraint;
- Tickets needs a foreign key to users [FOREIGN KEY (user_id) REFERENCES users(id)]
- Tickets needs a foreign key to trips [FOREIGN KEY (trip_id) REFERENCES trips(id)]
- Products needs a check constraint for price [CHECK (price >= 0)]
- Tickets need a check constraint for validity period [CHECK (valid_to_utc > valid_from_utc)]
- Columns that must not be null [NOT NULL]

## Enforceable with a unique or exclusion rule;
- Product code must be unique [UNIQUE (code)]

## Dependent on more than one row or an external system;
- Disabled users can't purchase tickets
- External payment provider must be successful before ticket is issued

## Currently ambiguous and requiring a domain decision.
- Should tickets status be defined as different states (e.g., active, used, expired)?
- Should payments status be defined as different states (e.g., pending, completed, failed)?
