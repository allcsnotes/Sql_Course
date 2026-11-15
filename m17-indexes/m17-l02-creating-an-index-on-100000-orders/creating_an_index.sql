-- M17-L02 Creating an index on 100,000 orders
-- Runs on the Chai Corner database. Step 1 creates the big_orders practice table.
-- Run one query at a time (select it, then Ctrl+Enter in DBeaver).
-- big_orders holds random data, so your counts and timings will differ from the video.
-- (setup.sql in this folder builds the same table with a fixed seed, for a rebuild.)

-- Step 1: a big practice table, 100,000 orders, no index yet
CREATE TABLE big_orders AS
SELECT g AS order_id,
  (random() * 4999)::int + 1 AS customer_id,
  (random() * 9)::int + 1 AS branch_id,
  (random() * 900)::int + 100 AS total
FROM generate_series(1, 100000) AS g;
-- SELECT 100000

-- Step 2: how many rows, and how many for one customer?
SELECT COUNT(*) AS all_rows,
       COUNT(*) FILTER (WHERE customer_id = 4242) AS for_4242
FROM big_orders;
-- video: all_rows 100000, for_4242 21 (random data, yours will differ)

-- Step 3: before the index, EXPLAIN ANALYZE runs the query and times it
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242;
-- video: Seq Scan on big_orders, rows=21, Rows Removed by Filter: 99979,
--        Execution Time: 12.278 ms

-- Step 4: create the index: CREATE INDEX name ON table (column);
CREATE INDEX idx_big_customer
ON big_orders (customer_id);
-- video: done in 0.039 s

-- Step 5: after, the same query again
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242;
-- video: Bitmap Heap Scan on big_orders
--          -> Bitmap Index Scan on idx_big_customer, rows=21
--        Execution Time: 0.574 ms (more than 20 times faster)

-- Mistake 1: the same name twice
CREATE INDEX idx_big_customer
ON big_orders (customer_id);
-- ERROR: relation "idx_big_customer" already exists (SQLSTATE 42P07)

-- Mistake 2: an index on customer_id does not help a search on branch_id
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE branch_id = 3;
-- video: Seq Scan, rows=11139, Rows Removed by Filter: 88861, Execution Time: 6.509 ms

-- Mistake 3: no round brackets around the column
CREATE INDEX idx_big_total ON big_orders total;
-- ERROR: syntax error at or near "total" (SQLSTATE 42601)

-- Step 6: your task, index total, then check the plan
CREATE INDEX idx_big_total
ON big_orders (total);

EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE total = 500;
-- video: Bitmap Index Scan on idx_big_total, rows=92, Execution Time: 0.112 ms
