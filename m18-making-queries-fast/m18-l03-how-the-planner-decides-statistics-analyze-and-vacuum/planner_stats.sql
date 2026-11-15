-- M18-L03 How the planner decides: statistics, ANALYZE and VACUUM
-- Runs on the Chai Corner database. Step 1 creates the plan_demo test table (100,000 rows).
-- Autovacuum is turned off ONLY for this demo table. In a real database, leave it on.
-- Run one query at a time. The rows are not random, but ANALYZE reads a random sample,
-- so the fresh estimate in step 5 can be a little different for you.
-- The pg_stat_user_tables counters can lag about a second behind: wait a moment if they show 0.

-- Step 1: a test table, every 100th row is Pune, the rest are Delhi
CREATE TABLE plan_demo (id int, city text)
WITH (autovacuum_enabled = false);

INSERT INTO plan_demo
SELECT g, CASE WHEN g % 100 = 0 THEN 'Pune' ELSE 'Delhi' END
FROM generate_series(1, 100000) AS g;
-- INSERT 0 100000

-- Step 2: stale statistics, the planner guesses 344 rows, the real count is 99,000
EXPLAIN (ANALYZE, TIMING OFF)
SELECT * FROM plan_demo
WHERE city = 'Delhi';
-- Seq Scan on plan_demo  (cost=0.00..1399.84 rows=344 width=36) (actual rows=99000.00 loops=1)
--   Filter: (city = 'Delhi'::text)
--   Rows Removed by Filter: 1000

-- Step 3: why, the table was never analyzed
SELECT relname, n_live_tup, n_dead_tup, last_analyze
FROM pg_stat_user_tables
WHERE relname = 'plan_demo';
-- 1 row: plan_demo | 100000 | 0 | NULL

-- Step 4: refresh the statistics
ANALYZE plan_demo;
-- video: done in 0.054 s

-- Step 5: same query, now the guess is close
EXPLAIN (ANALYZE, TIMING OFF)
SELECT * FROM plan_demo
WHERE city = 'Delhi';
-- video: Seq Scan on plan_demo  (cost=0.00..1791.00 rows=98960 width=9) (actual rows=99000.00 loops=1)

-- Step 6: the statistics themselves
SELECT attname, most_common_vals, most_common_freqs
FROM pg_stats
WHERE tablename = 'plan_demo' AND attname = 'city';
-- video: city | {Delhi,Pune} | {0.9896,0.0104}

-- Step 7: size on disk
SELECT pg_size_pretty(pg_relation_size('plan_demo')) AS size;
-- 4328 kB

-- Step 8: update every row, each update writes a new row and leaves the old one dead
UPDATE plan_demo
SET city = upper(city)
WHERE id > 0;
-- UPDATE 100000

-- Step 9: live rows, dead rows and size
SELECT n_live_tup, n_dead_tup,
  pg_size_pretty(pg_relation_size('plan_demo')) AS size
FROM pg_stat_user_tables
WHERE relname = 'plan_demo';
-- 1 row: 100000 | 100000 | 8656 kB

-- Step 10: clear the dead rows
VACUUM plan_demo;

-- Step 11: dead rows gone, but the size stays (the space is reused, not given back)
SELECT n_live_tup, n_dead_tup,
  pg_size_pretty(pg_relation_size('plan_demo')) AS size
FROM pg_stat_user_tables
WHERE relname = 'plan_demo';
-- 1 row: 100000 | 0 | 8656 kB

-- Step 12: VACUUM FULL rewrites the table (and locks it while it runs)
VACUUM FULL plan_demo;
SELECT pg_size_pretty(pg_relation_size('plan_demo')) AS size;
-- 4328 kB

-- In a real database, leave autovacuum on.
