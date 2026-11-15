-- Chai Corner update 6 (Build 2): the month of April 2026.
-- 4 new customers join, 2 new menu items are added (one is never ordered),
-- and Kabir, Neha and Tara stop coming. Fictional data.
-- Run the whole file at once (DBeaver: Execute SQL Script, Alt+X).
-- setseed makes random() give the same numbers for everyone.
SELECT setseed(0.44);
INSERT INTO customers (customer_id, name, joined_on, email) VALUES
 (16, 'Zoya', '2026-04-03', 'zoya@example.com'),
 (17, 'Manav', '2026-04-08', 'manav@example.com'),
 (18, 'Riya', '2026-04-15', 'riya@example.com'),
 (19, 'Kunal', '2026-04-22', 'kunal@example.com');
INSERT INTO menu_items (item_id, name, price, category) VALUES
 (11, 'Kulhad Chai', 40, 'Chai'),
 (12, 'Paneer Roll', 90, 'Snack');
-- april is a TEMP table: a helper that disappears when you disconnect.
CREATE TEMP TABLE april AS
SELECT 3000 + g AS order_id,
  (ARRAY[1,2,3,4,6,7,8,9,11,12,13,15,1,2,3,4,6,7,8,9,11,12,13,15,16,17,18,19])[1 + floor(random()*28)::int] AS customer_id,
  (ARRAY[1,1,1,2,2,3])[1 + floor(random()*6)::int] AS branch_id,
  random() AS r_day, random() AS r_hour, random() AS r_min,
  1 + floor(random()*3)::int AS lines
FROM generate_series(1, 900) g;
INSERT INTO orders (order_id, customer_id, branch_id, ordered_at)
SELECT a.order_id, a.customer_id, a.branch_id,
  CASE WHEN a.customer_id >= 16 THEN c.joined_on ELSE DATE '2026-04-01' END
    + floor(a.r_day * (DATE '2026-05-01' - CASE WHEN a.customer_id >= 16 THEN c.joined_on ELSE DATE '2026-04-01' END))::int
    + make_interval(hours => (ARRAY[7,8,8,9,9,9,10,11,12,13,14,15,16,17,17,18,18,18,19,20,21])[1 + floor(a.r_hour*21)::int],
                    mins => floor(a.r_min*60)::int)
FROM april a JOIN customers c ON c.customer_id = a.customer_id
ORDER BY a.order_id;
INSERT INTO order_items (order_id, item_id, qty)
SELECT order_id, item_id, SUM(qty)
FROM (
  SELECT a.order_id, n,
    (ARRAY[7,7,7,7,11,11,11,3,3,3,3,5,5,5,4,4,2,2,1,1,1,9,9,9,8,8,8,6,6,10])[1 + floor(random()*30)::int] AS item_id,
    1 + (random() < 0.25)::int AS qty
  FROM april a CROSS JOIN LATERAL generate_series(1, a.lines) n
) x
GROUP BY order_id, item_id
ORDER BY order_id, item_id;
