-- setup.sql for B01 · The Café Sales Report (Chai Corner update 3).
-- Safe to run again: it drops and rebuilds the sales table with the same rows.
DROP TABLE IF EXISTS sales;
-- Chai Corner update 3 (Build 1): a sales table for three branches.
-- One row = one item sold. January to March 2026. Fictional data.
-- Run the whole file at once (DBeaver: Execute SQL Script, Alt+X).
-- setseed makes random() give the same numbers for everyone.
SELECT setseed(0.42);
CREATE TABLE sales AS
WITH o AS (
  SELECT g AS order_id,
    (ARRAY['Pune','Pune','Pune','Mumbai','Mumbai','Delhi'])[1 + floor(random()*6)::int] AS branch,
    DATE '2026-01-01' + floor(sqrt(random())*90)::int
      + make_interval(hours => (ARRAY[7,8,8,9,9,9,10,11,12,13,14,15,16,17,17,18,18,18,19,20,21])[1 + floor(random()*21)::int],
                      mins => floor(random()*60)::int) AS sold_at,
    1 + floor(random()*3)::int AS lines
  FROM generate_series(1, 3000) g
)
SELECT row_number() OVER (ORDER BY o.order_id, l.n)::int AS sale_id,
       o.order_id, o.branch, m.name AS item, m.category, l.qty, m.price, o.sold_at
FROM o
CROSS JOIN LATERAL (
  SELECT n, (ARRAY[7,7,7,7,7,3,3,3,3,3,5,5,5,4,4,2,2,1,1,1,9,9,9,8,8,8,6,6,10])[1 + floor(random()*29)::int] AS item_id,
         1 + (random() < 0.25)::int AS qty
  FROM generate_series(1, o.lines) n
) l
JOIN menu_items m ON m.item_id = l.item_id;
ALTER TABLE sales ADD PRIMARY KEY (sale_id);
-- Result: SELECT 6028 (6028 rows, 3000 orders, 1 January to 31 March 2026).
