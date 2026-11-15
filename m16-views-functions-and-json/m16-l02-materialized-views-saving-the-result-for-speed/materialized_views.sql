-- M16-L02 Materialized views: saving the result for speed (chai_corner)
-- Runs on the Chai Corner database (sales, the branch_cups view from M16-L01,
-- and the newsletter table). Run one statement at a time.

-- Step 1: create a materialized view: the query runs once and the rows are saved
CREATE MATERIALIZED VIEW branch_cups_mv AS
SELECT branch, SUM(qty) AS cups
FROM sales
GROUP BY branch;
-- DBeaver: Updated Rows 3 (psql: SELECT 3)

SELECT * FROM branch_cups_mv
ORDER BY branch;
-- 3 rows: Delhi 1269, Mumbai 2439, Pune 3827

-- Step 2: is it faster?
EXPLAIN ANALYZE
SELECT * FROM branch_cups;
-- normal view: Seq Scan on sales, rows=6028; video: Execution Time 2.237 ms (yours will differ)

EXPLAIN ANALYZE
SELECT * FROM branch_cups_mv;
-- materialized view: Seq Scan on branch_cups_mv, rows=3; video: Execution Time 0.170 ms

-- Step 3: stale and refresh
CREATE MATERIALIZED VIEW signups_mv AS
SELECT COUNT(*) AS people FROM newsletter;

SELECT * FROM signups_mv;
-- 1 row: people 4

INSERT INTO newsletter (email, joined_on)
VALUES ('zoya@mail.com', '2026-03-10');

SELECT * FROM signups_mv;
-- still 4 (stale)

REFRESH MATERIALIZED VIEW signups_mv;

SELECT * FROM signups_mv;
-- 1 row: people 5

-- Mistake 1: inserting rows into a materialized view
INSERT INTO branch_cups_mv (branch, cups) VALUES ('Goa', 500);
-- ERROR 42809: cannot change materialized view "branch_cups_mv"

-- Mistake 2: CONCURRENTLY needs a unique index
REFRESH MATERIALIZED VIEW CONCURRENTLY branch_cups_mv;
-- ERROR 55000: cannot refresh materialized view "public.branch_cups_mv" concurrently

CREATE UNIQUE INDEX ON branch_cups_mv (branch);
REFRESH MATERIALIZED VIEW CONCURRENTLY branch_cups_mv;
-- works now

-- Mistake 3: DROP VIEW on a materialized view
DROP VIEW signups_mv;
-- ERROR 42809: "signups_mv" is not a view
-- HINT: Use DROP MATERIALIZED VIEW to remove a materialized view.
-- (the course keeps signups_mv, so the right command is not run here)

-- Your task: a materialized view of cups for each item, top three
CREATE MATERIALIZED VIEW item_cups_mv AS
SELECT item, SUM(qty) AS cups
FROM sales
GROUP BY item;

SELECT * FROM item_cups_mv
ORDER BY cups DESC
LIMIT 3;
-- 3 rows: Masala Chai 1382, Cutting Chai 1294, Vada Pav 815
