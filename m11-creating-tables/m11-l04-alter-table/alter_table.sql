-- Module 11, Lesson 4: ALTER TABLE, change a table after it is made
-- Chai Corner database (PostgreSQL 18)

-- Step 1: deliveries before we change anything
SELECT * FROM deliveries;
-- 3 rows, 6 columns: 1 milk 40 PD-101 ordered, 2 tea leaves 10 NT-201 ordered, 3 samosa 50 SS-301 delivered

-- Step 2: add a new column, the day it arrived
ALTER TABLE deliveries
  ADD COLUMN delivered_on date;

-- Old rows get NULL in the new column
SELECT delivery_id, item, status, delivered_on
FROM deliveries;
-- 3 rows, delivered_on is [NULL] in all three

-- Step 3: with a DEFAULT, old rows get the default
ALTER TABLE deliveries
  ADD COLUMN paid boolean NOT NULL DEFAULT false;

-- Every old row got false (DBeaver shows false as an empty box)
SELECT delivery_id, item, status, paid
FROM deliveries;
-- 3 rows, paid = false in all three

-- Step 4: rename a column, qty becomes quantity
ALTER TABLE deliveries
  RENAME COLUMN qty TO quantity;

-- Step 5: change a type, longer bill numbers (it was varchar(20))
ALTER TABLE deliveries
  ALTER COLUMN bill_no TYPE varchar(40);

-- Step 6: add the missing foreign key to an old table
ALTER TABLE deliveries
  ADD FOREIGN KEY (supplier_id)
  REFERENCES suppliers (supplier_id);

-- Step 7: the table after all our changes
SELECT delivery_id, item, quantity, bill_no, paid
FROM deliveries;
-- 1 | milk       | 40 | PD-101 | false
-- 2 | tea leaves | 10 | NT-201 | false
-- 3 | samosa     | 50 | SS-301 | false

-- Three mistakes (each one fails):
-- 1. NOT NULL with no default, on a table that has rows
ALTER TABLE deliveries ADD COLUMN driver varchar(30) NOT NULL;
-- ERROR 23502: column "driver" of relation "deliveries" contains null values

-- 2. Text cannot just become a number
ALTER TABLE deliveries ALTER COLUMN item TYPE int;
-- ERROR 42804: column "item" cannot be cast automatically to type integer
-- HINT: You might need to specify "USING item::integer".

-- 3. The new name is already taken
ALTER TABLE deliveries RENAME COLUMN item TO status;
-- ERROR 42701: column "status" of relation "deliveries" already exists

-- Your task: track if a restock has arrived (answer in README.md)
