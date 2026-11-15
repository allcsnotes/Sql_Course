-- M18-L02 setup: a primary key on big_customers (customer_id)
-- Safe to run again: it drops the key first if it is already there.

ALTER TABLE big_customers
DROP CONSTRAINT IF EXISTS big_customers_pkey;

ALTER TABLE big_customers
ADD PRIMARY KEY (customer_id);
