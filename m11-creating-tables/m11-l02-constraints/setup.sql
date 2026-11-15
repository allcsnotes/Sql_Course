-- M11-L02 setup: the tables this lesson adds to the Chai Corner database.
-- Only needed if you skipped the lesson. Run it right after M11-L01's state.

CREATE TABLE IF NOT EXISTS deliveries (
  delivery_id int PRIMARY KEY,
  supplier_id int NOT NULL,
  item        varchar(40) NOT NULL,
  qty         int CHECK (qty > 0),
  bill_no     varchar(20) UNIQUE,
  status      varchar(20) DEFAULT 'ordered'
);

INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no, status)
VALUES (1, 2, 'milk', 40, 'PD-101', 'ordered'),
       (2, 1, 'tea leaves', 10, 'NT-201', 'ordered'),
       (3, 3, 'samosa', 50, 'SS-301', 'delivered')
ON CONFLICT (delivery_id) DO NOTHING;

-- The table from the lesson's task (empty for now, rows come in M12-L04)
CREATE TABLE IF NOT EXISTS promo_codes (
  code     varchar(20) UNIQUE NOT NULL,
  discount int CHECK (discount BETWEEN 1 AND 50),
  uses     int DEFAULT 0
);
