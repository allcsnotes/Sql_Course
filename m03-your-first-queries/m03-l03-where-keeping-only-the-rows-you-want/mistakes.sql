-- M03-L03 · three beginner mistakes with text

-- Mistake 1: forgetting the quotes
SELECT * FROM branches WHERE city = Pune;
-- ERROR:  column "pune" does not exist

-- Mistake 2: small letters. No error, but zero rows
SELECT * FROM branches WHERE city = 'pune';
-- 0 rows

-- Mistake 3: double quotes are for column names
SELECT * FROM branches WHERE city = "Pune";
-- ERROR:  column "Pune" does not exist
