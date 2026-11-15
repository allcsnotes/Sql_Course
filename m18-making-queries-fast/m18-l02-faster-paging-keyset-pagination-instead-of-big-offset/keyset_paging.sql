-- M18-L02 Faster paging: keyset pagination instead of a big OFFSET
-- Runs on the Chai Corner database, table big_customers (100,000 rows) from M18-L01.
-- Run one query at a time. Join dates are random: the tie rows (step 7 on) will differ for you.

-- Step 1: a primary key gives customer_id a sorted index
ALTER TABLE big_customers
ADD PRIMARY KEY (customer_id);
-- ALTER TABLE (index big_customers_pkey)

-- Step 2: page 9,001 with OFFSET
SELECT customer_id, email
FROM big_customers
ORDER BY customer_id
LIMIT 10 OFFSET 90000;
-- 10 rows: 90001 user90001@mail.com ... 90010 user90010@mail.com

-- Step 3: the real work, the Index Scan reads 90,010 rows to show 10
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, email
FROM big_customers
ORDER BY customer_id
LIMIT 10 OFFSET 90000;
-- video: Limit (rows=10) <- Index Scan using big_customers_pkey (rows=90010),
--        Execution Time: 15.061 ms

-- Step 4: page 1 reads only 10 rows
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, email
FROM big_customers
ORDER BY customer_id
LIMIT 10 OFFSET 0;
-- video: Index Scan rows=10, Execution Time: 0.031 ms

-- Step 5: keyset, start after the last ID you showed
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, email
FROM big_customers
WHERE customer_id > 90000
ORDER BY customer_id
LIMIT 10;
-- video: Index Scan, Index Cond: (customer_id > 90000), rows=10, Execution Time: 0.786 ms

-- Step 6: the same page, customers 90,001 to 90,010
SELECT customer_id, email
FROM big_customers
WHERE customer_id > 90000
ORDER BY customer_id
LIMIT 10;
-- 10 rows: 90001 ... 90010

-- Step 7: ties, 72 customers joined on 2024-01-01
SELECT joined_on, COUNT(*) AS customers
FROM big_customers
GROUP BY joined_on
ORDER BY joined_on
LIMIT 5;
-- video: 2024-01-01 72, 2024-01-02 152, 2024-01-03 127, 2024-01-04 152, 2024-01-05 168

-- Step 8: page 1 by join date, with customer_id as the tie breaker
SELECT customer_id, joined_on
FROM big_customers
ORDER BY joined_on, customer_id
LIMIT 10;
-- video: 2190, 3199, 4565, 5067, 5395, 5672, 7564, 9764, 10762, 13958 (all 2024-01-01)

-- Step 9 (wrong): date only, skips the other 62 customers of 2024-01-01
SELECT customer_id, joined_on
FROM big_customers
WHERE joined_on > '2024-01-01'
ORDER BY joined_on, customer_id
LIMIT 10;
-- video: jumps to 2024-01-02 (1734, 2276, 2720, ...)

-- Step 10 (right): compare both columns together
SELECT customer_id, joined_on
FROM big_customers
WHERE (joined_on, customer_id) > ('2024-01-01', 13958)
ORDER BY joined_on, customer_id
LIMIT 10;
-- video: carries on with 2024-01-01: 16145, 16853, 17889, 18742, 20348, 22259, 22791, 22833, 23523, 24614

-- Mistake: newest first with > jumps to the end
SELECT customer_id, email
FROM big_customers
WHERE customer_id > 90000
ORDER BY customer_id DESC
LIMIT 5;
-- 5 rows: 100000, 99999, 99998, 99997, 99996

-- Right: with DESC use <
SELECT customer_id, email
FROM big_customers
WHERE customer_id < 90000
ORDER BY customer_id DESC
LIMIT 5;
-- 5 rows: 89999, 89998, 89997, 89996, 89995

-- Step 11: your task, the 5 customers after customer 50000
SELECT customer_id, email
FROM big_customers
WHERE customer_id > 50000
ORDER BY customer_id
LIMIT 5;
-- 5 rows: 50001 ... 50005
