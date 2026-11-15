-- Module 11, Lesson 2: Constraints (NOT NULL, UNIQUE, CHECK, DEFAULT)
-- Database: chai_corner. Run one statement at a time, in this order.

-- Step 1: rules that guard each delivery
CREATE TABLE deliveries (
  delivery_id int PRIMARY KEY,
  supplier_id int NOT NULL,
  item        varchar(40) NOT NULL,
  qty         int CHECK (qty > 0),
  bill_no     varchar(20) UNIQUE,
  status      varchar(20) DEFAULT 'ordered'
);
-- Updated Rows 0

-- Step 2: a good delivery, every rule is kept
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no)
VALUES (1, 2, 'milk', 40, 'PD-101');
-- Updated Rows 1

-- Step 3: we never gave a status. Look what is there
SELECT * FROM deliveries;
-- 1 row: 1 | 2 | milk | 40 | PD-101 | ordered   (DEFAULT filled the status)

-- Step 4: each of these is stopped by a rule (run them to see the errors)
-- NOT NULL: the item is missing
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no) VALUES (2, 1, NULL, 10, 'NT-201');
-- ERROR 23502: null value in column "item" of relation "deliveries" violates not-null constraint

-- CHECK: zero packets is not a delivery
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no) VALUES (2, 1, 'tea leaves', 0, 'NT-201');
-- ERROR 23514: new row for relation "deliveries" violates check constraint "deliveries_qty_check"

-- UNIQUE: this bill number is already used
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no) VALUES (2, 3, 'samosa', 50, 'PD-101');
-- ERROR 23505: duplicate key value violates unique constraint "deliveries_bill_no_key"
--              Key (bill_no)=(PD-101) already exists.

-- Step 5: fixed, every rule is kept
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no, status)
VALUES (2, 1, 'tea leaves', 10, 'NT-201', 'ordered'),
       (3, 3, 'samosa', 50, 'SS-301', 'delivered');
-- Updated Rows 2

SELECT * FROM deliveries;
-- 3 rows:
--  1 | 2 | milk       | 40 | PD-101 | ordered
--  2 | 1 | tea leaves | 10 | NT-201 | ordered
--  3 | 3 | samosa     | 50 | SS-301 | delivered

-- The three mistakes from the video are in README.md.

-- Your task: a table of promo codes (answer in README.md). Later lessons use it.
