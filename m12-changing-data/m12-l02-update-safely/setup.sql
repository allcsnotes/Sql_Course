-- M12-L02 setup: the changes this lesson (and its task) makes to deliveries.
-- Only needed if you skipped the lesson. Safe to run more than once.

UPDATE deliveries SET status = 'delivered', delivered_on = '2026-04-25', paid = true
WHERE delivery_id = 2;

UPDATE deliveries SET paid = true
WHERE delivery_id = 3;

UPDATE deliveries SET quantity = 45, status = 'delivered', delivered_on = '2026-04-26'
WHERE delivery_id = 1;
