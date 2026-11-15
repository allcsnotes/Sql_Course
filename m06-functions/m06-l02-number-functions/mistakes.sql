-- M06-L02 · The three beginner mistakes.

-- Mistake 1: you can never divide by zero. The whole query stops.
SELECT 100 / 0 AS per_order;
-- SQL Error [22012]: ERROR: division by zero
-- (M06-L05 shows a neat fix with NULLIF.)

-- Mistake 2: whole number division hides inside bigger sums.
SELECT 5 / 2 * 2 AS back_again, 5.0 / 2 * 2 AS with_decimal;
-- 4 | 5.0000000000000000

-- Mistake 3: ROUND with places needs numeric, not double precision.
SELECT ROUND(4.567::double precision, 2) AS rounded;
-- SQL Error [42883]: ERROR: function round(double precision, integer) does not exist
-- Fix: cast it to numeric first.
SELECT ROUND(4.567::double precision::numeric, 2) AS rounded;
-- 4.57
