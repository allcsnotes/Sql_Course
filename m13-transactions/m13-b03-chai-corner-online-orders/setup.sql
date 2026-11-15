-- M13-B03 setup: the three online-order tables this build creates, with the rows
-- they hold after the build and its task. Only needed if you skipped the build.
-- Safe to run more than once. (Dates and times are the ones from the video.)

CREATE TABLE IF NOT EXISTS online_customers (
  customer_id int PRIMARY KEY,
  name        varchar(40) NOT NULL,
  phone       varchar(15) NOT NULL UNIQUE,
  joined_on   date NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS online_orders (
  order_id    int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES online_customers (customer_id),
  status      varchar(20) NOT NULL DEFAULT 'placed'
              CHECK (status IN ('placed', 'preparing', 'delivered', 'cancelled')),
  placed_at   timestamp NOT NULL DEFAULT now(),
  total       numeric(8,2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE IF NOT EXISTS online_order_items (
  order_id int REFERENCES online_orders (order_id) ON DELETE CASCADE,
  item_id  int REFERENCES menu_items (item_id),
  qty      int NOT NULL CHECK (qty > 0),
  price    numeric(6,2) NOT NULL CHECK (price >= 0),
  PRIMARY KEY (order_id, item_id)
);

INSERT INTO online_customers (customer_id, name, phone, joined_on)
VALUES (1, 'Meera', '90000 11111', '2026-11-14'),
       (2, 'Arjun', '90000 22222', '2026-11-14'),
       (3, 'Sana',  '90000 33333', '2026-11-14')
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO online_orders (order_id, customer_id, status, placed_at, total)
VALUES (1, 1, 'placed', '2026-11-14 11:53:09', 85.00),
       (2, 2, 'placed', '2026-11-14 11:55:49', 140.00)
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO online_order_items (order_id, item_id, qty, price)
VALUES (1, 7, 2, 30), (1, 8, 1, 25),
       (2, 2, 1, 80), (2, 6, 1, 60)
ON CONFLICT (order_id, item_id) DO NOTHING;
