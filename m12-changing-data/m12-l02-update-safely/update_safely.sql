-- Module 12, Lesson 2: UPDATE safely, write the SELECT first, then the UPDATE
-- Chai Corner database (PostgreSQL 18)

-- Step 1: before you change anything, look at the rows
SELECT delivery_id, item, quantity, status, delivered_on, paid
FROM deliveries
ORDER BY delivery_id;
-- 1 | milk       | 40 | ordered   | [NULL] | false
-- 2 | tea leaves | 10 | ordered   | [NULL] | false
-- 3 | samosa     | 50 | delivered | [NULL] | false

-- Step 2: SELECT with the WHERE you plan to use
SELECT delivery_id, item, status, delivered_on
FROM deliveries
WHERE delivery_id = 2;
-- 1 row: 2 | tea leaves | ordered | [NULL]

-- Step 3: same WHERE, now UPDATE
UPDATE deliveries
SET status = 'delivered', delivered_on = '2026-04-25'
WHERE delivery_id = 2;
-- Updated Rows 1

-- Step 4: check the change
SELECT delivery_id, item, status, delivered_on
FROM deliveries
ORDER BY delivery_id;
-- 1 | milk       | ordered   | [NULL]
-- 2 | tea leaves | delivered | 2026-04-25
-- 3 | samosa     | delivered | [NULL]

-- Step 5: use the old value, 5 more cartons of milk
UPDATE deliveries
SET quantity = quantity + 5
WHERE item = 'milk'
RETURNING delivery_id, item, quantity;
-- 1 row: 1 | milk | 45

-- Step 6: one UPDATE, many rows, pay every delivered order
UPDATE deliveries
SET paid = true
WHERE status = 'delivered'
RETURNING delivery_id, item, status, paid;
-- 2 rows: 3 | samosa | delivered | true,  2 | tea leaves | delivered | true

-- Three mistakes:
-- 1. UPDATE with no WHERE (on a practice copy!)
CREATE TABLE practice AS SELECT * FROM deliveries;
UPDATE practice SET status = 'cancelled';
-- DBeaver asks first ("Execute dangerous queries"), then: Updated Rows 3
DROP TABLE practice;

-- 2. AND between columns instead of a comma
UPDATE deliveries
SET status = 'delivered' AND paid = true
WHERE delivery_id = 1;
-- ERROR 22P02: invalid input syntax for type boolean: "delivered"

-- 3. a value the table's rules do not allow
UPDATE deliveries
SET quantity = 0
WHERE delivery_id = 1;
-- ERROR 23514: new row for relation "deliveries" violates check constraint "deliveries_qty_check"
--              Failing row contains (1, 2, milk, 0, PD-101, ordered, null, f).

-- Your task: the milk arrived on April 26 (answer in README.md)
