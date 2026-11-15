-- M05-L05 · The three beginner mistakes.

-- Mistake 1: text that is not a number cannot become a number.
SELECT 'abc'::integer AS price;
-- SQL Error [22P02]: ERROR: invalid input syntax for type integer: "abc"

-- Mistake 2: '3.7' also fails as an integer ...
SELECT '3.7'::integer AS whole_number;
-- SQL Error [22P02]: ERROR: invalid input syntax for type integer: "3.7"
-- ... so cast it to numeric first, then to integer. It rounds.
SELECT '3.7'::numeric::integer AS whole_number;
-- 4

-- Mistake 3: inside CAST, the word AS is required.
SELECT CAST('42' integer) AS price;
-- SQL Error [42601]: ERROR: syntax error at or near "integer"
-- Fix: SELECT CAST('42' AS integer) AS price;
