-- M18-L01 setup: DB update 9, the big_customers practice table
-- 100,000 customers with an email, a random join date and a long notes column,
-- plus the three indexes this lesson leaves behind.
-- Safe to run again: it drops and rebuilds big_customers.
--
-- COLLATE "C" on email: the video's database uses collation C, so a plain index
-- also serves LIKE 'prefix%'. Writing it on the column makes that work on any database.
-- The join dates are random: setseed() gives the same rows on every rebuild,
-- but not the exact rows of the video, so counts and timings differ slightly.

DROP TABLE IF EXISTS big_customers;

SELECT setseed(0.42);

CREATE TABLE big_customers AS
SELECT g AS customer_id,
  ('user' || g || '@mail.com') COLLATE "C" AS email,
  DATE '2024-01-01' + (random() * 730)::int AS joined_on,
  repeat('note ', 40) AS notes
FROM generate_series(1, 100000) AS g;

CREATE INDEX idx_cust_email
ON big_customers (email);

CREATE INDEX idx_cust_lower
ON big_customers (lower(email));

CREATE INDEX idx_cust_joined
ON big_customers (joined_on);

VACUUM ANALYZE big_customers;
