-- M17-L04 setup: the video's EXPLAIN ANALYZE DELETE really removed order 100000
-- big_orders now has 99,999 rows. Safe to run again (deletes nothing the second time).

DELETE FROM big_orders
WHERE order_id = 100000;
