-- M05-L01 · Numbers: Integer, Numeric, Float
-- Run each query on its own (DBeaver: put the cursor on the line, Ctrl+Enter).

-- Step 1: Our menu prices are integers. pg_typeof shows the type of any value.
SELECT name, price, pg_typeof(price) FROM menu_items LIMIT 3;
-- 3 rows: Bun Maska 35 integer, Cold Coffee 80 integer, Cutting Chai 20 integer

-- Step 2: Integer division throws away the part after the point.
SELECT 7 / 2;
-- 3

-- Step 3: One side has a decimal point, so the answer is numeric.
SELECT 7 / 2.0 AS divided_with_decimal;
-- 3.5000000000000000

-- Step 4: Numeric is exact.
SELECT 0.1 + 0.2 AS total_using_numeric;
-- 0.3

-- Step 5: numeric(6,2) = 6 digits in total, 2 after the point. 19.999 is rounded.
SELECT 19.999::numeric(6,2) AS rounded_price;
-- 20.00

-- Step 6: Float is stored in binary, so 0.1 + 0.2 is not exactly 0.3.
SELECT 0.1::float + 0.2::float AS total_using_float;
-- 0.30000000000000004

-- Step 7: So close, but not equal.
SELECT 0.1::float + 0.2::float = 0.3::float AS is_it_equal;
-- false (DBeaver shows an empty tick box, psql shows f)
