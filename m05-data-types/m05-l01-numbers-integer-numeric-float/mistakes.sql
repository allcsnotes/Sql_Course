-- M05-L01 · The three beginner mistakes. Each of the first two is meant to fail.

-- Mistake 1: a number too big for integer (integer stops at 2147483647).
SELECT 2147483647 + 1;
-- SQL Error [22003]: ERROR: integer out of range
-- Fix: use bigint for bigger numbers.

-- Mistake 2: a numeric that is too small. numeric(6,2) holds up to 9999.99.
SELECT 12345.67::numeric(6,2);
-- SQL Error [22003]: ERROR: numeric field overflow
-- Detail: A field with precision 6, scale 2 must round to an absolute value less than 10^4.
-- Fix: make the type bigger, for example numeric(10,2).

-- Mistake 3: dividing whole numbers drops the part after the point.
SELECT 7 / 2;
-- 3
SELECT 7 / 2.0 AS divided_with_decimal;
-- 3.5000000000000000
