-- Chai Corner update 4 (Module 8, Lesson 3): split the sales table into linked tables.
-- orders: one row per order. order_items: one row per item in an order.
-- Each table points to the others with foreign keys (REFERENCES).
-- Run the whole file at once (DBeaver: Execute SQL Script, Alt+X).
SELECT setseed(0.43);
CREATE TABLE orders (
  order_id    int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers (customer_id),
  branch_id   int NOT NULL REFERENCES branches (branch_id),
  ordered_at  timestamp NOT NULL
);
INSERT INTO orders
SELECT s.order_id, 1 + floor(random() * 15)::int, b.branch_id, MIN(s.sold_at)
FROM sales s JOIN branches b ON b.city = s.branch
GROUP BY s.order_id, b.branch_id
ORDER BY s.order_id;
CREATE TABLE order_items (
  order_id int NOT NULL REFERENCES orders (order_id),
  item_id  int NOT NULL REFERENCES menu_items (item_id),
  qty      int NOT NULL,
  PRIMARY KEY (order_id, item_id)
);
INSERT INTO order_items
SELECT s.order_id, m.item_id, SUM(s.qty)
FROM sales s JOIN menu_items m ON m.name = s.item
GROUP BY s.order_id, m.item_id
ORDER BY s.order_id, m.item_id;
