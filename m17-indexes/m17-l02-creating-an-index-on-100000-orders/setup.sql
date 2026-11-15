-- M17-L02 setup: DB update 8, the big_orders practice table
-- 100,000 random orders (no primary key), plus the two indexes this lesson leaves behind.
-- Safe to run again: it drops and rebuilds big_orders.
-- The video used random(); setseed() makes your rebuild give the same rows every time.
-- They are not the exact rows of the video, so counts and timings differ slightly.

DROP TABLE IF EXISTS big_orders;

SELECT setseed(0.42);

CREATE TABLE big_orders AS
SELECT g AS order_id,
  (random() * 4999)::int + 1 AS customer_id,
  (random() * 9)::int + 1 AS branch_id,
  (random() * 900)::int + 100 AS total
FROM generate_series(1, 100000) AS g;

CREATE INDEX idx_big_customer
ON big_orders (customer_id);

CREATE INDEX idx_big_total
ON big_orders (total);

ANALYZE big_orders;
