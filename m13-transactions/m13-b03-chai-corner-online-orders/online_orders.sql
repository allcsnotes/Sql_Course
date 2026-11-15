-- Build 3: Chai Corner online orders, from zero
-- Chai Corner database (PostgreSQL 18). It already has menu_items.
-- Run one block at a time, in this order.

-- ===== Stage 1: the menu we will sell online =====
SELECT item_id, name, price
FROM menu_items
ORDER BY item_id;
-- 12 rows; we use 2 Cold Coffee 80, 6 Maggi 60, 7 Masala Chai 30, 8 Samosa 25

-- ===== Stage 2: create the tables, with rules =====
-- Table 1: people who order online
CREATE TABLE online_customers (
  customer_id int PRIMARY KEY,
  name        varchar(40) NOT NULL,
  phone       varchar(15) NOT NULL UNIQUE,
  joined_on   date NOT NULL DEFAULT CURRENT_DATE
);

-- Table 2: one row per order
CREATE TABLE online_orders (
  order_id    int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES online_customers (customer_id),
  status      varchar(20) NOT NULL DEFAULT 'placed'
              CHECK (status IN ('placed', 'preparing', 'delivered', 'cancelled')),
  placed_at   timestamp NOT NULL DEFAULT now(),
  total       numeric(8,2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

-- Table 3: what is inside each order
CREATE TABLE online_order_items (
  order_id int REFERENCES online_orders (order_id) ON DELETE CASCADE,
  item_id  int REFERENCES menu_items (item_id),
  qty      int NOT NULL CHECK (qty > 0),
  price    numeric(6,2) NOT NULL CHECK (price >= 0),
  PRIMARY KEY (order_id, item_id)
);
-- each CREATE: Updated Rows 0

-- ===== Stage 3: load data, three online customers =====
INSERT INTO online_customers (customer_id, name, phone)
VALUES (1, 'Meera', '90000 11111'),
       (2, 'Arjun', '90000 22222'),
       (3, 'Sana',  '90000 33333');
-- Updated Rows 3

SELECT * FROM online_customers;
-- 3 rows; joined_on = today's date (the video: 2026-11-14), filled by the DEFAULT

-- ===== Stage 4: order 1, Meera buys 2 Masala Chai and 1 Samosa =====
BEGIN;
INSERT INTO online_orders (order_id, customer_id) VALUES (1, 1);   -- 1 row
INSERT INTO online_order_items (order_id, item_id, qty, price)
VALUES (1, 7, 2, 30), (1, 8, 1, 25);                                -- 2 rows
UPDATE online_orders
SET total = (SELECT SUM(qty * price) FROM online_order_items WHERE order_id = 1)
WHERE order_id = 1;                                                 -- 1 row
COMMIT;

-- The receipt for order 1
SELECT o.order_id, c.name AS customer, m.name AS item,
       i.qty, i.price, o.total, o.status
FROM online_orders o
JOIN online_customers c   ON c.customer_id = o.customer_id
JOIN online_order_items i ON i.order_id = o.order_id
JOIN menu_items m         ON m.item_id = i.item_id
WHERE o.order_id = 1;
-- 1 | Meera | Masala Chai | 2 | 30.00 | 85.00 | placed
-- 1 | Meera | Samosa      | 1 | 25.00 | 85.00 | placed

-- ===== Stage 5: order 2 goes wrong in the middle =====
-- Order 2: Arjun, but one quantity is 0 by mistake
BEGIN;
INSERT INTO online_orders (order_id, customer_id) VALUES (2, 2);
INSERT INTO online_order_items (order_id, item_id, qty, price)
VALUES (2, 2, 1, 80), (2, 6, 0, 60);
-- ERROR 23514: new row for relation "online_order_items" violates check constraint "online_order_items_qty_check"
--              Failing row contains (2, 6, 0, 60.00).
ROLLBACK;
SELECT order_id, customer_id, total FROM online_orders;
-- only order 1: 1 | 1 | 85.00

-- ===== Three mistakes the rules catch =====
-- Mistake 1: a status the rules do not allow
UPDATE online_orders SET status = 'done' WHERE order_id = 1;
-- ERROR 23514: new row for relation "online_orders" violates check constraint "online_orders_status_check"

-- Mistake 2: a phone number that is already used
INSERT INTO online_customers (customer_id, name, phone)
VALUES (4, 'Tanvi', '90000 11111');
-- ERROR 23505: duplicate key value violates unique constraint "online_customers_phone_key"
--              Key (phone)=(90000 11111) already exists.

-- Mistake 3: deleting a customer who has placed an order
DELETE FROM online_customers WHERE customer_id = 1;
-- ERROR 23503: update or delete on table "online_customers" violates foreign key constraint "online_orders_customer_id_fkey" on table "online_orders"

-- Your task: order 2, Arjun buys 1 Cold Coffee and 1 Maggi (answer in README.md)
