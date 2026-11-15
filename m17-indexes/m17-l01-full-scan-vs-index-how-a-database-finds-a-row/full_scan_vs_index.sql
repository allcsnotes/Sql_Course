-- M17-L01 Full scan vs index: how a database finds a row
-- Runs on the Chai Corner database (orders has 3,900 rows). Nothing here changes data.
-- Run one query at a time (select it, then Ctrl+Enter in DBeaver).

-- Step 1: which indexes does orders have? (the primary key made one)
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders';
-- 1 row: orders_pkey | CREATE UNIQUE INDEX orders_pkey ON public.orders USING btree (order_id)

-- Step 2: an indexed column, so PostgreSQL jumps straight to the row
EXPLAIN
SELECT * FROM orders
WHERE order_id = 1234;
-- Index Scan using orders_pkey on orders  (cost=0.28..8.30 rows=1 width=20)
--   Index Cond: (order_id = 1234)

-- Step 3: no index on customer_id, so it reads every row
EXPLAIN
SELECT * FROM orders
WHERE customer_id = 7;
-- Seq Scan on orders  (cost=0.00..73.75 rows=267 width=20)
--   Filter: (customer_id = 7)

-- Step 4: ranges use the sorted tree too
EXPLAIN
SELECT * FROM orders
WHERE order_id BETWEEN 100 AND 105;
-- Index Scan using orders_pkey on orders  (cost=0.28..8.40 rows=6 width=20)
--   Index Cond: ((order_id >= 100) AND (order_id <= 105))

-- Step 5: three mistakes that hide the index (all give a Seq Scan)
EXPLAIN SELECT * FROM orders WHERE order_id + 1 = 1235;
-- Seq Scan on orders  (cost=0.00..83.50 rows=20 width=20)
--   Filter: ((order_id + 1) = 1235)

EXPLAIN SELECT * FROM orders WHERE order_id = 1234 OR customer_id = 7;
-- Seq Scan on orders  (cost=0.00..83.50 rows=268 width=20)
--   Filter: ((order_id = 1234) OR (customer_id = 7))

EXPLAIN SELECT * FROM orders WHERE order_id::text = '1234';
-- Seq Scan on orders  (cost=0.00..93.25 rows=20 width=20)
--   Filter: ((order_id)::text = '1234'::text)

-- Step 6: your task, which scan?
EXPLAIN
SELECT * FROM orders
WHERE order_id = 50 AND customer_id = 7;
-- Index Scan using orders_pkey on orders  (cost=0.28..8.30 rows=1 width=20)
--   Index Cond: (order_id = 50)
--   Filter: (customer_id = 7)
