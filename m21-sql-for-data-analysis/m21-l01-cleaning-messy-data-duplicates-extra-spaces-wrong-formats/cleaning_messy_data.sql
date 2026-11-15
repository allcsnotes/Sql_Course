-- M21-L01 Cleaning messy data: duplicates, extra spaces, wrong formats
-- The queries in the order the video runs them, with the real results.
-- Already ran setup.sql? Run this first:  DROP TABLE clean_signups, messy_signups;

-- Step 1: a messy import: extra spaces, mixed case, two date formats, repeats
CREATE TABLE messy_signups (id int, name text, email text, city text, signed_on text);
INSERT INTO messy_signups VALUES
 (1, '  asha  ', 'Asha@Example.com',   'pune',    '2026-03-01'),
 (2, 'LUKAS',    'lukas@example.com ', 'Mumbai ', '02/03/2026'),
 (3, 'priya',    'priya@example.com',  ' mumbai', '2026-03-05'),
 (4, 'Asha',     'asha@example.com',   'Pune',    '01/03/2026'),
 (5, 'rahul ',   'RAHUL@EXAMPLE.COM',  'Delhi',   '2026-03-09'),
 (6, 'Kabir',    'kabir@example.com',  'delhi',   '25/03/2026'),
 (7, 'Priya',    ' PRIYA@example.com', 'Mumbai',  '2026-03-05');
-- INSERT 0 7

-- Step 2: brackets make the hidden spaces visible
SELECT id, '[' || name || ']' AS name, '[' || email || ']' AS email,
       '[' || city || ']' AS city, signed_on
FROM messy_signups ORDER BY id;
-- 7 rows: [  asha  ], [lukas@example.com ], [Mumbai ], [ mumbai], [rahul ], [ PRIYA@example.com] ...

-- Step 3: how many people signed up, really?
SELECT COUNT(*) AS all_rows, COUNT(DISTINCT email) AS raw_emails,
       COUNT(DISTINCT LOWER(TRIM(email))) AS real_people
FROM messy_signups;
-- 1 row: all_rows 7, raw_emails 7, real_people 5

-- Step 4: fix spaces and capital letters
SELECT id, INITCAP(TRIM(name)) AS name, LOWER(TRIM(email)) AS email, INITCAP(TRIM(city)) AS city
FROM messy_signups ORDER BY id;
-- 7 rows: Asha, Lukas, Priya, Asha, Rahul, Kabir, Priya (Asha twice with asha@example.com)

-- Step 5: turn the text into real dates, the quick way
SELECT id, signed_on, signed_on::date AS signed_date
FROM messy_signups ORDER BY id;
-- ERROR [22008]: date/time field value out of range: "25/03/2026"
-- Hint: Perhaps you need a different "DateStyle" setting.

-- Step 6: skip Kabir's row: now it runs... but look closely
SELECT id, signed_on, signed_on::date AS signed_date
FROM messy_signups WHERE id <> 6 ORDER BY id;
-- 6 rows, and two are silently wrong: 02/03/2026 -> 2026-02-03, 01/03/2026 -> 2026-01-03

-- Step 7: tell SQL which format each row uses
SELECT id, signed_on,
       CASE WHEN signed_on LIKE '%/%' THEN TO_DATE(signed_on, 'DD/MM/YYYY')
            ELSE TO_DATE(signed_on, 'YYYY-MM-DD') END AS signed_date
FROM messy_signups ORDER BY id;
-- 7 rows: 02/03/2026 -> 2026-03-02, 01/03/2026 -> 2026-03-01, 25/03/2026 -> 2026-03-25

-- Step 8: number the copies of each person: 1 = first, 2 = repeat
SELECT id, LOWER(TRIM(email)) AS email,
       ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY id) AS copy_no
FROM messy_signups ORDER BY email, copy_no;
-- 7 rows: id 4 (asha) and id 7 (priya) have copy_no 2

-- Step 9: build a clean copy; the messy table stays untouched
CREATE TABLE clean_signups AS
WITH fixed AS (
  SELECT id, INITCAP(TRIM(name)) AS name, LOWER(TRIM(email)) AS email,
         INITCAP(TRIM(city)) AS city,
         CASE WHEN signed_on LIKE '%/%' THEN TO_DATE(signed_on, 'DD/MM/YYYY')
              ELSE TO_DATE(signed_on, 'YYYY-MM-DD') END AS signed_date,
         ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY id) AS copy_no
  FROM messy_signups)
SELECT id, name, email, city, signed_date FROM fixed WHERE copy_no = 1;
-- Updated Rows 5

-- Step 10: the result
SELECT * FROM clean_signups ORDER BY id;
-- 5 rows: 1 Asha Pune 2026-03-01, 2 Lukas Mumbai 2026-03-02, 3 Priya Mumbai 2026-03-05,
--         5 Rahul Delhi 2026-03-09, 6 Kabir Delhi 2026-03-25

-- Task: ' Ravi@Example.com' and 'ravi@example.com ' -> after TRIM and LOWER, 1 person
SELECT COUNT(DISTINCT LOWER(TRIM(e))) AS people
FROM (VALUES (' Ravi@Example.com'), ('ravi@example.com ')) AS t(e);
-- 1
