-- M17-L04 EXPLAIN and EXPLAIN ANALYZE: reading a query plan
-- Runs on the Chai Corner database, table big_orders from M17-L02 (indexes from M17-L03).
-- Run one query at a time. big_orders is random data: your numbers will differ.
-- Careful: the EXPLAIN ANALYZE DELETE in mistake 1 really deletes order 100000.

-- Step 1: EXPLAIN shows the plan and runs nothing (a guess)
EXPLAIN
SELECT * FROM big_orders
WHERE branch_id = 3;
-- video: Seq Scan on big_orders  (cost=0.00..1826.00 rows=11140 width=16)
--          Filter: (branch_id = 3)

-- Step 2: EXPLAIN ANALYZE really runs it and adds the real numbers
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE branch_id = 3;
-- video: actual time=0.054..5.940 rows=11139, Rows Removed by Filter: 88861,
--        Planning Time: 0.038 ms, Execution Time: 6.218 ms

-- Step 3: a plan with steps, read it from the bottom up
EXPLAIN ANALYZE
SELECT branch_id, COUNT(*) AS orders
FROM big_orders
GROUP BY branch_id
ORDER BY orders DESC;
-- video: Sort (top) <- HashAggregate <- Seq Scan on big_orders (bottom),
--        Execution Time: 21.926 ms

-- Words: cost = guess of the work (lower is better), rows = rows expected,
-- width = bytes in one row, actual time = real ms (start..end), loops = times the step ran

-- Mistake 1: EXPLAIN ANALYZE really runs a DELETE, the row is gone
EXPLAIN ANALYZE
DELETE FROM big_orders
WHERE order_id = 100000;

SELECT COUNT(*) AS all_rows FROM big_orders;
-- 99999

-- Fix: plain EXPLAIN only plans, it deletes nothing
EXPLAIN
DELETE FROM big_orders
WHERE order_id = 99999;
-- Delete on big_orders -> Seq Scan on big_orders, Filter: (order_id = 99999)

-- Mistake 2: trusting one run. The GROUP BY in step 3 took 21.926 ms, then 15.453 ms.
-- Mistake 3: reading top down. The top line finishes last: start at the bottom.

-- Step 4: your task
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE total = 500 AND branch_id = 3;
-- video: Bitmap Index Scan on idx_big_total finds 92 rows,
--        Filter: (branch_id = 3), Rows Removed by Filter: 80, 12 rows left, 0.359 ms
