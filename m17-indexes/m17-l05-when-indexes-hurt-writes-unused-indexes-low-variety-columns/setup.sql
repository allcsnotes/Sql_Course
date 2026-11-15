-- M17-L05 setup: two copies of big_orders (99,999 rows each)
-- copy_plain has no indexes; copy_idx keeps 3 indexes (the video dropped copy_idx_total_idx).
-- Safe to run again: it drops and rebuilds both copies.

DROP TABLE IF EXISTS copy_plain, copy_idx;

CREATE TABLE copy_plain (LIKE big_orders);

CREATE TABLE copy_idx (LIKE big_orders);
CREATE INDEX ON copy_idx (customer_id);
CREATE INDEX ON copy_idx (branch_id);
CREATE INDEX ON copy_idx (customer_id, branch_id);

INSERT INTO copy_plain SELECT * FROM big_orders;
INSERT INTO copy_idx SELECT * FROM big_orders;

ANALYZE copy_plain;
ANALYZE copy_idx;
