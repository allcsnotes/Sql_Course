-- M19-L04 Row-level security: each branch sees only its own data
-- Run as postgres on the Chai Corner database.
-- The demo roles pune and delhi have no password and cannot log in; we act as them with SET ROLE.
-- Run one statement at a time.

-- Step 1: a small table, 6 orders from 3 branches
CREATE TABLE branch_orders (
  order_id int PRIMARY KEY,
  branch   text NOT NULL,
  total    int NOT NULL
);

INSERT INTO branch_orders VALUES
  (1, 'pune', 120),
  (2, 'delhi', 80),
  (3, 'pune', 45),
  (4, 'mumbai', 200),
  (5, 'delhi', 60),
  (6, 'pune', 90);
-- INSERT 0 6

-- Step 2: one role per branch, with access to the table
CREATE ROLE pune;
CREATE ROLE delhi;

GRANT SELECT, INSERT ON branch_orders TO pune, delhi;

-- Step 3: before row-level security, pune sees all 6 rows
SET ROLE pune;

SELECT current_user, *
FROM branch_orders;
-- 6 rows: orders 1 to 6 (pune, delhi, pune, mumbai, delhi, pune)

-- Step 4: turn it on (as postgres)
RESET ROLE;

ALTER TABLE branch_orders
ENABLE ROW LEVEL SECURITY;

-- Step 5: on, but no policy yet, pune sees nothing
SET ROLE pune;

SELECT current_user, *
FROM branch_orders;
-- 0 rows

-- Step 6: the rule, a row is shown only when branch = current_user
RESET ROLE;

CREATE POLICY own_branch
ON branch_orders
USING (branch = current_user);

-- Step 7: pune sees only its own orders
SET ROLE pune;

SELECT current_user, *
FROM branch_orders;
-- 3 rows: 1 pune 120, 3 pune 45, 6 pune 90

-- Step 8: delhi sees only its own orders
RESET ROLE;
SET ROLE delhi;

SELECT current_user, *
FROM branch_orders;
-- 2 rows: 2 delhi 80, 5 delhi 60

-- Step 9: pune adds an order for delhi
RESET ROLE;
SET ROLE pune;

INSERT INTO branch_orders
VALUES (7, 'delhi', 500);
-- ERROR: new row violates row-level security policy for table "branch_orders" (SQLSTATE 42501)

-- Step 10: pune adds its own order, it works
INSERT INTO branch_orders
VALUES (7, 'pune', 50);
-- INSERT 0 1

SELECT current_user, *
FROM branch_orders;
-- 4 rows: 1, 3, 6, 7 (all pune)

-- Step 11: as postgres (owner and superuser), all 7 rows, the rules are skipped
RESET ROLE;

SELECT current_user, *
FROM branch_orders;
-- 7 rows

-- Step 12: your task, as delhi, count the rows
SET ROLE delhi;

SELECT count(*) AS orders
FROM branch_orders;
-- 2

RESET ROLE;
