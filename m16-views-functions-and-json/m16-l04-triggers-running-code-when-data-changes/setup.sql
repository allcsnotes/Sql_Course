-- M16-L04 setup: what this lesson leaves in the Chai Corner database.
-- The price_log table, the log_price() trigger function, the price_change
-- trigger on menu_items (final version, with WHEN), and the 3 log rows the
-- lesson's price changes produced. Masala Chai ends back at 30.
-- Re-runnable: it starts again from a clean price_log.
-- changed_on is the date you run this (the video shows the day it was recorded).
DROP TRIGGER IF EXISTS price_change ON menu_items;
DROP TABLE IF EXISTS price_log;
UPDATE menu_items SET price = 30 WHERE name = 'Masala Chai';

CREATE TABLE price_log (
  item_id int,
  old_price numeric,
  new_price numeric,
  changed_on date DEFAULT CURRENT_DATE
);

CREATE OR REPLACE FUNCTION log_price()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO price_log (item_id, old_price, new_price)
  VALUES (OLD.item_id, OLD.price, NEW.price);
  RETURN NEW;
END;
$$;

-- First version of the trigger (no WHEN), as in the lesson
CREATE TRIGGER price_change
AFTER UPDATE OF price ON menu_items
FOR EACH ROW
EXECUTE FUNCTION log_price();

UPDATE menu_items SET price = 35 WHERE name = 'Masala Chai';   -- logs 7, 30, 35
UPDATE menu_items SET price = 35 WHERE name = 'Masala Chai';   -- logs 7, 35, 35 (mistake 2)

-- The fixed trigger: only log a real change
CREATE OR REPLACE TRIGGER price_change
AFTER UPDATE OF price ON menu_items
FOR EACH ROW
WHEN (OLD.price <> NEW.price)
EXECUTE FUNCTION log_price();

UPDATE menu_items SET price = 30 WHERE name = 'Masala Chai';   -- logs 7, 35, 30 (the task)
UPDATE menu_items SET price = 30 WHERE name = 'Masala Chai';   -- no new row

-- Check: 3 rows (7 30 35, 7 35 35, 7 35 30); Masala Chai is 30
SELECT * FROM price_log;
SELECT name, price FROM menu_items WHERE name = 'Masala Chai';
