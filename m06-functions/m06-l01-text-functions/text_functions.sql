-- M06-L01 · Text Functions
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: UPPER and LOWER change the case. The name in the table does not change.
SELECT name, UPPER(name) AS upper_name, LOWER(name) AS lower_name FROM menu_items ORDER BY price LIMIT 3;
-- 3 rows: Cutting Chai | CUTTING CHAI | cutting chai
--         Samosa       | SAMOSA       | samosa
--         Ginger Chai  | GINGER CHAI  | ginger chai

-- Step 2: LENGTH counts characters (spaces too). TRIM removes spaces at the start and end.
SELECT LENGTH('  Chai  ') AS len_before, TRIM('  Chai  ') AS clean, LENGTH(TRIM('  Chai  ')) AS len_after;
-- 8 | Chai | 4

-- Step 3: SUBSTRING takes a piece. FROM 1 = start at the first letter, FOR 3 = take three.
SELECT name, SUBSTRING(name FROM 1 FOR 3) AS short_code FROM menu_items ORDER BY price LIMIT 3;
-- 3 rows: Cutting Chai Cut, Samosa Sam, Ginger Chai Gin

-- Step 4: the two bars || join texts into one label.
SELECT name || ' (' || category || ')' AS label FROM menu_items ORDER BY price LIMIT 3;
-- 3 rows: Cutting Chai (Chai), Samosa (Snack), Ginger Chai (Chai)
