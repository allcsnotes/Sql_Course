-- M18-L01 The usual slow patterns: SELECT *, functions on columns, leading % in LIKE
-- Runs on the Chai Corner database. Step 1 creates the big_customers practice table.
-- The video's database uses collation C, so a plain index also serves LIKE 'prefix%'.
-- If yours does not, see "Before you start" in the README (or use setup.sql, which adds COLLATE "C").
-- Run one query at a time. Timings on your laptop will differ from the video.

-- Step 1: practice table, 100,000 customers with a long notes column, and an index on email
CREATE TABLE big_customers AS
SELECT g AS customer_id,
  'user' || g || '@mail.com' AS email,
  DATE '2024-01-01' + (random() * 730)::int AS joined_on,
  repeat('note ', 40) AS notes
FROM generate_series(1, 100000) AS g;
-- video: SELECT 100000 in 0.644 s

CREATE INDEX idx_cust_email
ON big_customers (email);

VACUUM ANALYZE big_customers;   -- fresh statistics (lesson 3 explains this)

-- Step 2: SELECT * sends every column back. SERIALIZE measures the data sent.
EXPLAIN (ANALYZE, SERIALIZE)
SELECT * FROM big_customers;
-- video: Serialization: output=24491kB, Execution Time: 30.071 ms

EXPLAIN (ANALYZE, SERIALIZE)
SELECT customer_id, email FROM big_customers;
-- video: Serialization: output=3201kB (about 7 times less), Execution Time: 20.374 ms

-- Step 3: a function on the column hides it from the index
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE lower(email) = 'user4242@mail.com';
-- video: Seq Scan, Rows Removed by Filter: 99999, Execution Time: 15.744 ms

EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email = 'user4242@mail.com';
-- video: Index Scan using idx_cust_email, Execution Time: 0.569 ms

-- Step 4: the fix, index the exact expression
CREATE INDEX idx_cust_lower
ON big_customers (lower(email));

EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE lower(email) = 'user4242@mail.com';
-- video: Bitmap Index Scan on idx_cust_lower, Execution Time: 0.451 ms

-- Step 5: a leading % cannot use the index, a trailing % can
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email LIKE '%4242@mail.com';
-- video: Seq Scan, rows=10, Rows Removed by Filter: 99990, Execution Time: 19.143 ms

EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email LIKE 'user4242@%';
-- video: Index Scan using idx_cust_email, Execution Time: 0.179 ms

-- Mistake 1: the index is on lower(), the query uses upper()
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE upper(email) = 'USER4242@MAIL.COM';
-- video: Seq Scan, Execution Time: 18.708 ms

-- Mistake 2: ILIKE skips the plain index
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email ILIKE 'user4242@%';
-- video: Seq Scan, Execution Time: 18.654 ms

-- Fix: lower(email) with LIKE uses idx_cust_lower
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE lower(email) LIKE 'user4242@%';
-- video: Bitmap Index Scan on idx_cust_lower, Execution Time: 0.065 ms

-- Mistake 3: a function on a date column
CREATE INDEX idx_cust_joined
ON big_customers (joined_on);

EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE date_trunc('month', joined_on) = '2025-03-01';
-- video: Seq Scan, rows=4302, Execution Time: 23.249 ms

-- Fix: write a range instead
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE joined_on >= '2025-03-01'
  AND joined_on < '2025-04-01';
-- video: Bitmap Index Scan on idx_cust_joined, rows=4302, Execution Time: 5.716 ms

-- Step 6: your task, which one uses the index?
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email LIKE 'user77%';
-- video: Index Scan using idx_cust_email, Execution Time: 1.862 ms
-- (LIKE '%77' would be a Seq Scan)
