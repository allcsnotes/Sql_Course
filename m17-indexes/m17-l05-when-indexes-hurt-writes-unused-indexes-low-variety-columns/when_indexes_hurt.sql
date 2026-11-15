-- M17-L05 When indexes hurt: writes, unused indexes, low-variety columns
-- Runs on the Chai Corner database, table big_orders (99,999 rows after M17-L04).
-- Run one query at a time. Timings on your laptop will differ from the video.

-- Step 1: two empty copies of big_orders
CREATE TABLE copy_plain
(LIKE big_orders);

CREATE TABLE copy_idx (LIKE big_orders);
CREATE INDEX ON copy_idx (customer_id);
CREATE INDEX ON copy_idx (branch_id);
CREATE INDEX ON copy_idx (total);
CREATE INDEX ON copy_idx (customer_id, branch_id);
-- CREATE INDEX with no name: PostgreSQL names it table_column_idx, e.g. copy_idx_total_idx

-- Step 2: writes, every index must be updated too
EXPLAIN ANALYZE
INSERT INTO copy_plain
SELECT * FROM big_orders;
-- video: Execution Time: 112.858 ms (no indexes)

EXPLAIN ANALYZE
INSERT INTO copy_idx
SELECT * FROM big_orders;
-- video: Execution Time: 551.724 ms (4 indexes, almost 5 times slower)

-- Step 3: unused indexes, times_used = 0
SELECT indexrelname AS index_name,
       idx_scan AS times_used,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE relname = 'copy_idx';
-- 4 rows: copy_idx_customer_id_idx 0 1112 kB, copy_idx_branch_id_idx 0 672 kB,
--         copy_idx_total_idx 0 1008 kB, copy_idx_customer_id_branch_id_idx 0 2264 kB

-- (The video ran ANALYZE copy_idx here, off screen, so the planner knows the new rows.)
ANALYZE copy_idx;

-- Step 4: few values, branch_id has only 10
EXPLAIN ANALYZE
SELECT * FROM copy_idx
WHERE branch_id <> 3;
-- video: Seq Scan, rows=88860, index skipped, Execution Time: 12.308 ms

EXPLAIN ANALYZE
SELECT * FROM copy_idx
WHERE branch_id = 3;
-- video: Bitmap Index Scan on copy_idx_branch_id_idx, Execution Time: 2.289 ms

-- Step 5: the fix for an unused index
DROP INDEX copy_idx_total_idx;
-- DROP INDEX

-- Step 6: your task, are the big_orders indexes used?
SELECT indexrelname AS index_name,
       idx_scan AS times_used,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE relname = 'big_orders';
-- video: idx_big_total 2 720 kB, idx_big_cust_branch 3 1640 kB. Keep both.
