-- M05-L03 · The three beginner mistakes.

-- Mistake 1: writing the day first. PostgreSQL reads the first number as the month.
SELECT '14-11-2026'::date AS day_first;
-- SQL Error [22008]: ERROR: date/time field value out of range: "14-11-2026"
-- Hint: Perhaps you need a different "DateStyle" setting.

-- Mistake 2 (worse): a day that also fits as a month. No error at all!
SELECT '05-11-2026'::date AS meant_5_november;
-- 2026-05-11   (the eleventh of May, not the fifth of November)
-- Fix for both: always write year, month, day: '2026-11-05'

-- Mistake 3: forgetting the quotes. 2022-01-01 is a sum of numbers (2020).
SELECT city FROM branches WHERE opened_on > 2022-01-01;
-- SQL Error [42883]: ERROR: operator does not exist: date > integer
-- Fix: WHERE opened_on > '2022-01-01'
