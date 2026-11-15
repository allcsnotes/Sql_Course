-- M18-L04 setup: DB update 11, the tune_orders table
-- 1,000,000 orders, 10 for each of the 100,000 customers, with a random amount,
-- plus the index this lesson leaves behind (idx_tune_customer).
-- Safe to run again: it drops and rebuilds tune_orders.
-- The amounts are random: setseed() gives the same rows on every rebuild,
-- but not the exact amounts of the video, so the top 5 and timings differ.

DROP TABLE IF EXISTS tune_orders;

SELECT setseed(0.42);

CREATE TABLE tune_orders AS
SELECT g AS order_id,
  (g % 100000) + 1 AS customer_id,
  round((random() * 900 + 100)::numeric, 2) AS amount,
  date '2025-01-01' + (g % 500) AS ordered_on
FROM generate_series(1, 1000000) AS g;

CREATE INDEX idx_tune_customer
ON tune_orders (customer_id);

ANALYZE tune_orders;
