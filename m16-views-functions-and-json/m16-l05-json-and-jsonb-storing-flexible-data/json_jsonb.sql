-- M16-L05 JSON and JSONB: storing flexible data (chai_corner)
-- Runs on the Chai Corner database. Run one statement at a time.
-- This lesson creates the app_orders table.

-- Step 1: a table with a JSONB column
CREATE TABLE app_orders (
  order_no int,
  details jsonb
);

-- Step 2: insert three orders: JSON inside single quotes, every key in double quotes
INSERT INTO app_orders VALUES
(1, '{"item": "Masala Chai", "qty": 2, "extras": ["ginger"]}'),
(2, '{"item": "Cold Coffee", "qty": 1}'),
(3, '{"item": "Samosa", "qty": 3, "extras": ["chutney", "onion"]}');

-- Step 3: look at them (JSONB sorts the keys its own way: qty first)
SELECT order_no, details
FROM app_orders;
-- 1 | {"qty": 2, "item": "Masala Chai", "extras": ["ginger"]}
-- 2 | {"qty": 1, "item": "Cold Coffee"}
-- 3 | {"qty": 3, "item": "Samosa", "extras": ["chutney", "onion"]}

-- Step 4: get a value out as text, cast for maths
SELECT order_no,
  details ->> 'item' AS item,
  (details ->> 'qty')::int AS qty
FROM app_orders;
-- 3 rows: 1 Masala Chai 2, 2 Cold Coffee 1, 3 Samosa 3

-- Step 5: contains
SELECT order_no, details ->> 'item' AS item
FROM app_orders
WHERE details @> '{"item": "Samosa"}';
-- 1 row: 3 Samosa

-- Step 6: json keeps the text, jsonb keeps the last repeated key
SELECT
  '{"qty": 2, "item": "Tea", "qty": 5}'::json  AS as_json,
  '{"qty": 2, "item": "Tea", "qty": 5}'::jsonb AS as_jsonb;
-- as_json:  {"qty": 2, "item": "Tea", "qty": 5}
-- as_jsonb: {"qty": 5, "item": "Tea"}

-- Mistake 1: one arrow gives jsonb, not a number
SELECT (details -> 'qty') + 1 AS one_more FROM app_orders;
-- ERROR 42883: operator does not exist: jsonb + integer

-- Mistake 2: keys need double quotes
INSERT INTO app_orders VALUES (4, '{item: "Vada Pav", qty: 2}');
-- ERROR 22P02: invalid input syntax for type json. DETAIL: Token "item" is invalid.

-- Mistake 3: keys are case sensitive: 'Item' gives NULL on every row
SELECT order_no, details ->> 'Item' AS item
FROM app_orders;
-- 3 rows: 1 NULL, 2 NULL, 3 NULL

-- Your task: total quantity across all three orders
SELECT SUM((details ->> 'qty')::int) AS total_qty FROM app_orders;
-- 1 row: total_qty 6
