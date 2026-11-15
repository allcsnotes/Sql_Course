-- M16-L04 Triggers: running code when data changes (chai_corner)
-- Runs on the Chai Corner database (menu_items). Run one statement at a time.
-- This lesson changes Masala Chai's price and back; it ends at 30.

-- Step 1: a table to keep the log
CREATE TABLE price_log (
  item_id int,
  old_price numeric,
  new_price numeric,
  changed_on date DEFAULT CURRENT_DATE
);

-- Step 2: a trigger function: RETURNS trigger, OLD = row before, NEW = row after
CREATE FUNCTION log_price()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO price_log (item_id, old_price, new_price)
  VALUES (OLD.item_id, OLD.price, NEW.price);
  RETURN NEW;
END;
$$;

-- Step 3: connect it to the table (DBeaver: Updated Rows 0)
CREATE TRIGGER price_change
AFTER UPDATE OF price ON menu_items
FOR EACH ROW
EXECUTE FUNCTION log_price();

-- Step 4: watch it fire
UPDATE menu_items
SET price = 35
WHERE name = 'Masala Chai';

SELECT * FROM price_log;
-- 1 row: 7 | 30 | 35 | today (the video: 2026-11-14)

-- Mistake 1: a normal function cannot be a trigger.
-- say_hi() is any ordinary function that RETURNS text, for example:
CREATE FUNCTION say_hi() RETURNS text LANGUAGE sql AS $$ SELECT 'hi'; $$;

CREATE TRIGGER price_change2
AFTER UPDATE OF price ON menu_items
FOR EACH ROW
EXECUTE FUNCTION say_hi();
-- ERROR 42P17: function say_hi must return type trigger

DROP FUNCTION say_hi();   -- tidy up

-- Mistake 2: the same price again still logs a row
UPDATE menu_items
SET price = 35
WHERE name = 'Masala Chai';

SELECT * FROM price_log;
-- 2 rows: 7 30 35, and 7 35 35 (nothing really changed)

-- Fix: WHEN, so it only logs a real change
CREATE OR REPLACE TRIGGER price_change
AFTER UPDATE OF price ON menu_items
FOR EACH ROW
WHEN (OLD.price <> NEW.price)
EXECUTE FUNCTION log_price();

-- Mistake 3: dropping the function first
DROP FUNCTION log_price();
-- ERROR 2BP01: cannot drop function log_price() because other objects depend on it
-- DETAIL: trigger price_change on table menu_items depends on function log_price()
-- Remove the trigger first (DROP TRIGGER price_change ON menu_items;), then the function.
-- (Do not run that here: the course keeps the trigger.)

-- Your task: Masala Chai back to 30, then check the log
UPDATE menu_items
SET price = 30
WHERE name = 'Masala Chai';

SELECT * FROM price_log;
-- 3 rows: 7 30 35, 7 35 35, 7 35 30

-- Proof that WHEN works: 30 again adds no row
UPDATE menu_items
SET price = 30
WHERE name = 'Masala Chai';

SELECT * FROM price_log;
-- still 3 rows
