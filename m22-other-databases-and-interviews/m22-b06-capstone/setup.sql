-- DB update 19 (Build 6 Capstone): the capstone schema.
-- Builds the same end state as the video: capstone.raw_sales (201,500 text rows),
-- capstone.kiosks (4 rows), capstone.sales (198,719 clean rows), the index
-- idx_sales_kiosk_day and the view capstone.may_report.
-- Re-runnable: it drops the capstone schema first.
-- Needs menu_items (from the base Chai Corner database).
-- Run with psql from THIS folder (the \copy paths are relative to where psql starts):
--   psql -U postgres -d chai_corner -f setup.sql

SET client_min_messages = warning;
DROP SCHEMA IF EXISTS capstone CASCADE;
CREATE SCHEMA capstone;

CREATE TABLE capstone.raw_sales (
  sale_id text, sold_at text, kiosk text, item text, qty text);
\copy capstone.raw_sales FROM 'data/kiosk_sales.csv' WITH (FORMAT csv, HEADER)

CREATE TABLE capstone.kiosks (kiosk text PRIMARY KEY, place text, city text);
\copy capstone.kiosks FROM 'data/kiosks.csv' WITH (FORMAT csv, HEADER)

CREATE TABLE capstone.sales (
  sale_id int PRIMARY KEY,
  sold_at timestamp NOT NULL,
  kiosk   text NOT NULL REFERENCES capstone.kiosks,
  item_id int  NOT NULL REFERENCES menu_items,
  qty     int  NOT NULL CHECK (qty > 0));

INSERT INTO capstone.sales
SELECT DISTINCT ON (r.sale_id::int) r.sale_id::int,
  CASE WHEN r.sold_at LIKE '__/__/____%'
       THEN to_timestamp(r.sold_at, 'DD/MM/YYYY HH24:MI')::timestamp
       ELSE r.sold_at::timestamp END,
  UPPER(TRIM(r.kiosk)), m.item_id, r.qty::int
FROM capstone.raw_sales r
JOIN menu_items m ON m.name = INITCAP(TRIM(r.item))
WHERE r.qty ~ '^[0-9]+$';

CREATE INDEX idx_sales_kiosk_day ON capstone.sales (kiosk, sold_at);

CREATE VIEW capstone.may_report AS
SELECT k.city || ' ' || k.place AS kiosk,
       COUNT(*) AS sales, SUM(s.qty) AS cups,
       SUM(s.qty * m.price) AS revenue,
       ROUND(SUM(s.qty * m.price) / 31.0) AS per_day
FROM capstone.sales s
JOIN capstone.kiosks k USING (kiosk)
JOIN menu_items m USING (item_id)
GROUP BY 1;
