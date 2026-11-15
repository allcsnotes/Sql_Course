-- M06-L03 · The three beginner mistakes.

-- Mistake 1: adding '1 month' as plain text, without the word INTERVAL.
SELECT CURRENT_DATE + '1 month' AS next_month;
-- SQL Error [42725]: ERROR: operator is not unique: date + unknown
-- Fix: put INTERVAL before the text.
SELECT CURRENT_DATE + INTERVAL '1 month' AS next_month;
-- video (on 2026-11-14): 2026-12-14 00:00:00

-- Mistake 2: month ends are tricky. No error, so check dates near the end of a month.
SELECT '2026-01-31'::date + INTERVAL '1 month' AS one_month_later;
-- 2026-02-28 00:00:00

-- Mistake 3: EXTRACT(MONTH ...) = 1 finds January in EVERY year, so Dev (2026) sneaks in.
-- For one exact month, compare DATE_TRUNC with the first day of that month.
SELECT name FROM customers WHERE DATE_TRUNC('month', joined_on) = '2025-01-01';
-- 2 rows: Rahul, Kabir
