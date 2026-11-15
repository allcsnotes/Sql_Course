-- M18-L04 A full tuning walkthrough: from 3 seconds to 1 millisecond
-- Runs on the Chai Corner database: big_customers (from M18-L01/L02) and a new table, tune_orders.
-- Run one query at a time. The amounts are random: your top 5 and your timings will differ.
-- (setup.sql in this folder builds tune_orders with a fixed seed, for a rebuild.)

-- Step 0: the test table, 1,000,000 orders, 10 for each customer
CREATE TABLE tune_orders AS
SELECT g AS order_id,
  (g % 100000) + 1 AS customer_id,
  round((random() * 900 + 100)::numeric, 2) AS amount,
  date '2025-01-01' + (g % 500) AS ordered_on
FROM generate_series(1, 1000000) AS g;
-- video: SELECT 1000000 in 1.556 s

ANALYZE tune_orders;

-- Step 1: version 1 of the report, a subquery per customer
SELECT c.customer_id, c.email,
  (SELECT SUM(o.amount) FROM tune_orders o
   WHERE o.customer_id = c.customer_id) AS spent
FROM big_customers c
WHERE c.customer_id <= 130
ORDER BY spent DESC
LIMIT 5;
-- video: 14 user14@mail.com 7726.74 | 126 user126@mail.com 7360.33 | 97 user97@mail.com 7149.16
--        43 user43@mail.com 7109.51 | 2 user2@mail.com 7105.07

-- Step 2: measure. Seq Scan on tune_orders with loops=130
EXPLAIN (ANALYZE, COSTS OFF)
SELECT c.customer_id, c.email,
  (SELECT SUM(o.amount) FROM tune_orders o
   WHERE o.customer_id = c.customer_id) AS spent
FROM big_customers c
WHERE c.customer_id <= 130
ORDER BY spent DESC
LIMIT 5;
-- video: SubPlan 1 -> Seq Scan on tune_orders o (rows=10, loops=130),
--        Rows Removed by Filter: 999990, Execution Time: 2937.810 ms

-- Step 3: fix 1, JOIN once and GROUP BY
EXPLAIN (ANALYZE, COSTS OFF)
SELECT c.customer_id, c.email, SUM(o.amount) AS spent
FROM big_customers c
JOIN tune_orders o ON o.customer_id = c.customer_id
WHERE c.customer_id <= 130
GROUP BY c.customer_id, c.email
ORDER BY spent DESC
LIMIT 5;
-- video: Hash Join with one Parallel Seq Scan on tune_orders o, Execution Time: 110.846 ms

-- Step 4: fix 2, an index on customer_id
CREATE INDEX idx_tune_customer
ON tune_orders (customer_id);
-- video: done in 0.341 s

-- Step 5: measure again (the same EXPLAIN as step 3)
EXPLAIN (ANALYZE, COSTS OFF)
SELECT c.customer_id, c.email, SUM(o.amount) AS spent
FROM big_customers c
JOIN tune_orders o ON o.customer_id = c.customer_id
WHERE c.customer_id <= 130
GROUP BY c.customer_id, c.email
ORDER BY spent DESC
LIMIT 5;
-- video: Nested Loop, Index Scan using idx_tune_customer on tune_orders o (rows=10, loops=130),
--        Execution Time: 1.223 ms

-- Step 6: check the answer, the same 5 rows as step 1
SELECT c.customer_id, c.email, SUM(o.amount) AS spent
FROM big_customers c
JOIN tune_orders o ON o.customer_id = c.customer_id
WHERE c.customer_id <= 130
GROUP BY c.customer_id, c.email
ORDER BY spent DESC
LIMIT 5;
-- video: 14, 126, 97, 43, 2 (7726.74, 7360.33, 7149.16, 7109.51, 7105.07)
