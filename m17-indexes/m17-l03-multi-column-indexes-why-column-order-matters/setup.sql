-- M17-L03 setup: swap the one-column index for a two-column index on big_orders
-- Safe to run again.

DROP INDEX IF EXISTS idx_big_customer;

CREATE INDEX IF NOT EXISTS idx_big_cust_branch
ON big_orders (customer_id, branch_id);
