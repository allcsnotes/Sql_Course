-- M17-L03 Multi-column indexes: why column order matters
-- Runs on the Chai Corner database, table big_orders from M17-L02.
-- Run one query at a time. big_orders is random data: your counts and timings will differ.

-- Step 1: start clean, remove last lesson's one-column index
DROP INDEX idx_big_customer;
-- DROP INDEX

-- Step 2: one index, two columns: customer_id first, then branch_id
CREATE INDEX idx_big_cust_branch
ON big_orders (customer_id, branch_id);
-- video: done in 0.054 s

-- Step 3: search both columns, the index is used
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242 AND branch_id = 3;
-- video: Bitmap Index Scan on idx_big_cust_branch, rows=4, Execution Time: 0.294 ms

-- Step 4: only the first column, still uses the index
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242;
-- video: Bitmap Index Scan on idx_big_cust_branch, rows=21, Execution Time: 0.672 ms

-- Step 5: only the second column, the index cannot help
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE branch_id = 3;
-- video: Seq Scan, rows=11139, Rows Removed by Filter: 88861, Execution Time: 6.147 ms

-- Mistake 1: searching only the second column (step 5 above): Seq Scan

-- Mistake 2: OR instead of AND
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242 OR branch_id = 3;
-- video: Seq Scan, rows=11156, Rows Removed by Filter: 88844, Execution Time: 6.218 ms

-- Mistake 3: a missing comma between the columns
CREATE INDEX idx_big_cb2
ON big_orders (customer_id branch_id);
-- ERROR: operator class "branch_id" does not exist for access method "btree" (SQLSTATE 42704)

-- Step 6: your task, swap the order inside WHERE
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE branch_id = 3 AND customer_id = 4242;
-- video: still Bitmap Index Scan on idx_big_cust_branch, rows=4, Execution Time: 0.029 ms
-- Only the column order inside the index matters, not inside WHERE.
