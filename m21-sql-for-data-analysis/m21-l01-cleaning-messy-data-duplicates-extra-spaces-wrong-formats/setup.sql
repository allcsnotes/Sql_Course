-- M21-L01 setup (DB update 14): messy_signups and clean_signups
-- Re-runnable: drops and rebuilds both tables. Run it to rebuild the database state
-- after this lesson. To follow the lesson step by step, use cleaning_messy_data.sql instead.

DROP TABLE IF EXISTS clean_signups;
DROP TABLE IF EXISTS messy_signups;

-- a messy import: extra spaces, mixed case, two date formats, repeats
CREATE TABLE messy_signups (id int, name text, email text, city text, signed_on text);
INSERT INTO messy_signups VALUES
 (1, '  asha  ', 'Asha@Example.com',   'pune',    '2026-03-01'),
 (2, 'LUKAS',    'lukas@example.com ', 'Mumbai ', '02/03/2026'),
 (3, 'priya',    'priya@example.com',  ' mumbai', '2026-03-05'),
 (4, 'Asha',     'asha@example.com',   'Pune',    '01/03/2026'),
 (5, 'rahul ',   'RAHUL@EXAMPLE.COM',  'Delhi',   '2026-03-09'),
 (6, 'Kabir',    'kabir@example.com',  'delhi',   '25/03/2026'),
 (7, 'Priya',    ' PRIYA@example.com', 'Mumbai',  '2026-03-05');

-- the clean copy (5 rows); the messy table stays untouched
CREATE TABLE clean_signups AS
WITH fixed AS (
  SELECT id, INITCAP(TRIM(name)) AS name, LOWER(TRIM(email)) AS email,
         INITCAP(TRIM(city)) AS city,
         CASE WHEN signed_on LIKE '%/%' THEN TO_DATE(signed_on, 'DD/MM/YYYY')
              ELSE TO_DATE(signed_on, 'YYYY-MM-DD') END AS signed_date,
         ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY id) AS copy_no
  FROM messy_signups)
SELECT id, name, email, city, signed_date FROM fixed WHERE copy_no = 1;
