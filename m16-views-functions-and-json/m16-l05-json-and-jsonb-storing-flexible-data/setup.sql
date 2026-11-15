-- M16-L05 setup: what this lesson leaves in the Chai Corner database.
-- The app_orders table with a JSONB details column and 3 orders.
-- Re-runnable: it drops and recreates the table.
DROP TABLE IF EXISTS app_orders;

CREATE TABLE app_orders (
  order_no int,
  details jsonb
);

INSERT INTO app_orders VALUES
(1, '{"item": "Masala Chai", "qty": 2, "extras": ["ginger"]}'),
(2, '{"item": "Cold Coffee", "qty": 1}'),
(3, '{"item": "Samosa", "qty": 3, "extras": ["chutney", "onion"]}');

-- Check: 3 rows
SELECT order_no, details FROM app_orders;
