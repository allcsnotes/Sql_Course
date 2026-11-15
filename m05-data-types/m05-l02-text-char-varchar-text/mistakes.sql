-- M05-L02 · The three beginner mistakes. The broken queries fail on purpose.

-- Mistake 1: text that is too long for varchar(40) (this name has 48 letters).
-- The end of this line is off screen in the video; the price does not change the error.
INSERT INTO menu_items (item_id, name, price) VALUES (11, 'Special Kashmiri Kahwa with Saffron and Almonds', 90);
-- SQL Error [22001]: ERROR: value too long for type character varying(40)
-- Nothing is saved. Shorten the text, or make the column bigger.

-- Mistake 2: an apostrophe inside text closes the quotes too early.
SELECT 'Asha's Chai' AS shop_name;
-- DBeaver: SQL Error [42601]: Unterminated string literal started at position 19 ...
-- (psql says: ERROR: syntax error at or near "Chai")
-- Fix: write the apostrophe twice.
SELECT 'Asha''s Chai' AS shop_name;
-- Asha's Chai

-- Mistake 3: double quotes mean a column name, not text.
SELECT name FROM menu_items WHERE name = "Maggi";
-- SQL Error [42703]: ERROR: column "Maggi" does not exist
-- Fix: text always goes in single quotes: WHERE name = 'Maggi'
