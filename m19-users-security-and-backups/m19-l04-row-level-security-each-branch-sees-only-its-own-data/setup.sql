-- M19-L04 setup: DB update 12, branch_orders with row-level security
-- 7 orders (pune 1, 3, 6, 7; delhi 2, 5; mumbai 4), demo roles pune and delhi
-- (no password, cannot log in), and the policy own_branch.
-- Run as postgres. Safe to run again: it drops and rebuilds branch_orders.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pune') THEN
    CREATE ROLE pune;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'delhi') THEN
    CREATE ROLE delhi;
  END IF;
END
$$;

DROP TABLE IF EXISTS branch_orders;

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
  (6, 'pune', 90),
  (7, 'pune', 50);

GRANT SELECT, INSERT ON branch_orders TO pune, delhi;

ALTER TABLE branch_orders
ENABLE ROW LEVEL SECURITY;

CREATE POLICY own_branch
ON branch_orders
USING (branch = current_user);
