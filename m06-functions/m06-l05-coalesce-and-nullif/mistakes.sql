-- M06-L05 · The three beginner mistakes.

-- Mistake 1: the backup has a different type (price is a number, 'free' is text).
SELECT name, COALESCE(price, 'free') AS shown FROM menu_items;
-- SQL Error [22P02]: ERROR: invalid input syntax for type integer: "free"
-- Fix: cast the price to text first.
SELECT name, COALESCE(price::text, 'free') AS shown FROM menu_items;
-- 10 rows: Bun Maska 35, Cold Coffee 80, ... (no price is missing, so no 'free')

-- Mistake 2: the backup comes first. COALESCE stops at the first value that is not NULL.
SELECT name, COALESCE('no email', email) AS contact FROM customers;
-- everyone gets 'no email'. Fix: real column first, backup last.

-- Mistake 3: empty text is not NULL.
SELECT COALESCE('', 'no email') AS plain, COALESCE(NULLIF('', ''), 'no email') AS fixed;
-- (blank) | no email
