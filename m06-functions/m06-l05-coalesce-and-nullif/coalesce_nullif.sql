-- M06-L05 · COALESCE and NULLIF
-- Run each query on its own (DBeaver: cursor inside the query, Ctrl+Enter).

-- Step 1: COALESCE gives back the first value that is not NULL.
SELECT name, email,
  COALESCE(email, 'no email') AS contact
FROM customers;
-- 15 rows: Asha asha@example.com, Lukas [NULL] -> no email, ...
-- 'no email' for Lukas, Kabir, Isha and Dev

-- Step 2: many values, checked from left to right.
SELECT COALESCE(NULL, NULL, 'third', 'fourth') AS first_found;
-- third

-- Step 3: NULLIF gives NULL when the two values are equal, else the first value.
SELECT NULLIF(5, 5) AS same, NULLIF(5, 3) AS different;
-- [NULL] | 5

-- Step 4: safe division. 100 / 0 stops the query, 100 / NULL is just NULL.
SELECT 100 / NULLIF(0, 0) AS safe_divide;
-- [NULL]

-- Step 5: want a number instead? Wrap it in COALESCE with 0 as the backup.
SELECT COALESCE(100 / NULLIF(0, 0), 0) AS result;
-- 0
