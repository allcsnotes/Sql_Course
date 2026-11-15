-- Build 6 Capstone: raw CSV -> clean database -> fast queries -> final report
-- Run in the chai_corner database (it needs the menu_items table).
-- Run it with psql from THIS folder, so the relative paths data/... work:
--   psql -U postgres -d chai_corner -f capstone.sql
-- The video used server-side COPY with a full path on its own computer.
-- Here every COPY is psql's \copy, which reads and writes files on YOUR
-- computer, relative to the folder you started psql in. \copy must stay on one line.

-- Step 1: load the raw file. Every column is text for now.
CREATE SCHEMA capstone;
CREATE TABLE capstone.raw_sales (
  sale_id text, sold_at text, kiosk text, item text, qty text);
\copy capstone.raw_sales FROM 'data/kiosk_sales.csv' WITH (FORMAT csv, HEADER)
-- COPY 201500   (DBeaver showed: Updated Rows 201500, about 0.265 s)

-- Step 2: look at the mess. Brackets show hidden spaces.
SELECT '[' || kiosk || ']' AS kiosk, COUNT(*) AS rows
FROM capstone.raw_sales
GROUP BY kiosk
ORDER BY kiosk;
-- 32 rows, e.g. [ K1 ] 381, [ K1] 4838, [K1] 65675, [k1] 4234
-- (the order of the rows depends on your database's collation)

-- Step 3: count every problem
SELECT COUNT(*) AS lines,
  COUNT(DISTINCT sale_id) AS sales,
  COUNT(DISTINCT kiosk) AS kiosks,
  COUNT(DISTINCT item) AS items,
  COUNT(*) FILTER (WHERE qty IS NULL) AS blank,
  COUNT(*) FILTER (WHERE qty !~ '^[0-9]+$') AS bad,
  COUNT(*) FILTER (WHERE sold_at LIKE '__/__/____%') AS dd_mm
FROM capstone.raw_sales;
-- 201500 | 200000 | 32 | 117 | 863 | 425 | 30425

-- Step 4: clean tables with real types and rules
CREATE TABLE capstone.kiosks (kiosk text PRIMARY KEY, place text, city text);
\copy capstone.kiosks FROM 'data/kiosks.csv' WITH (FORMAT csv, HEADER)
-- COPY 4
CREATE TABLE capstone.sales (
  sale_id int PRIMARY KEY,
  sold_at timestamp NOT NULL,
  kiosk   text NOT NULL REFERENCES capstone.kiosks,
  item_id int  NOT NULL REFERENCES menu_items,
  qty     int  NOT NULL CHECK (qty > 0));

-- Step 5: clean every column, and copy it across once
INSERT INTO capstone.sales
SELECT DISTINCT ON (r.sale_id::int) r.sale_id::int,
  CASE WHEN r.sold_at LIKE '__/__/____%'
       THEN to_timestamp(r.sold_at, 'DD/MM/YYYY HH24:MI')::timestamp
       ELSE r.sold_at::timestamp END,
  UPPER(TRIM(r.kiosk)), m.item_id, r.qty::int
FROM capstone.raw_sales r
JOIN menu_items m ON m.name = INITCAP(TRIM(r.item))
WHERE r.qty ~ '^[0-9]+$';
-- INSERT 0 198719   (Updated Rows 198719)

-- Step 6: check what was dropped, and why
-- (a blank qty loads as NULL, and NULL !~ is not true, so check IS NULL first)
SELECT CASE WHEN r.qty IS NULL THEN 'blank qty'
            WHEN r.qty !~ '^[0-9]+$' THEN 'bad qty'
            WHEN m.item_id IS NULL THEN 'unknown item'
            ELSE 'kept' END AS result,
       COUNT(DISTINCT r.sale_id) AS sales
FROM capstone.raw_sales r
LEFT JOIN menu_items m ON m.name = INITCAP(TRIM(r.item))
GROUP BY 1 ORDER BY 2 DESC;
-- kept 198719, blank qty 856, bad qty 425 (= 200,000)

-- Step 7: one kiosk, one day. How fast is it?
EXPLAIN (ANALYZE, COSTS OFF, BUFFERS OFF)
SELECT SUM(qty) AS cups
FROM capstone.sales
WHERE kiosk = 'K4'
  AND sold_at >= '2026-05-20' AND sold_at < '2026-05-21';
-- Parallel Seq Scan, Rows Removed by Filter about 99050 per worker,
-- about 11.6 ms in the video (yours will differ)

-- Step 8: add an index, then time it again
CREATE INDEX idx_sales_kiosk_day ON capstone.sales (kiosk, sold_at);

EXPLAIN (ANALYZE, COSTS OFF, BUFFERS OFF)
SELECT SUM(qty) AS cups
FROM capstone.sales
WHERE kiosk = 'K4'
  AND sold_at >= '2026-05-20' AND sold_at < '2026-05-21';
-- Bitmap Index Scan on idx_sales_kiosk_day, about 0.5 ms in the video

-- Step 9: the final report, saved as a view
CREATE VIEW capstone.may_report AS
SELECT k.city || ' ' || k.place AS kiosk,
       COUNT(*) AS sales, SUM(s.qty) AS cups,
       SUM(s.qty * m.price) AS revenue,
       ROUND(SUM(s.qty * m.price) / 31.0) AS per_day
FROM capstone.sales s
JOIN capstone.kiosks k USING (kiosk)
JOIN menu_items m USING (item_id)
GROUP BY 1;

-- Step 10: read the report, biggest first
SELECT * FROM capstone.may_report
ORDER BY revenue DESC;
-- Pune Station     79395 | 126765 | 4383815 | 141413
-- Mumbai Airport   59730 |  95833 | 3312445 | 106853
-- Delhi Metro      39862 |  63954 | 2210660 |  71312
-- Bengaluru Mall   19732 |  31428 | 1088065 |  35099

-- Step 11: hand the report over as a file (written next to this script)
\copy (SELECT * FROM capstone.may_report ORDER BY revenue DESC) TO 'may_report.csv' WITH (FORMAT csv, HEADER)
-- COPY 4

-- Your task: the top item at each kiosk (by cups)
SELECT DISTINCT ON (s.kiosk) s.kiosk, m.name, SUM(s.qty) AS cups
FROM capstone.sales s
JOIN menu_items m USING (item_id)
GROUP BY s.kiosk, m.name
ORDER BY s.kiosk, cups DESC;
-- Masala Chai at all 4 kiosks (K1 27592, K2 21225, K3 13854, K4 6850)
