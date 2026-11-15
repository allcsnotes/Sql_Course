-- M22-L02 · Cloud warehouses: real BigQuery sandbox queries (Google public datasets)
-- Run these in the BigQuery editor (Google Cloud console), not in PostgreSQL.
-- Read the estimate under the editor ("This query will process ... when run.") BEFORE you click Run.
-- Bytes and timings are from the video; your timings will differ.

-- Step 1: top 5 baby names of 2020 (estimate 143.71 MB, ran in 247 ms)
SELECT name, SUM(number) AS babies
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
GROUP BY name
ORDER BY babies DESC
LIMIT 5;
-- 5 rows: Liam 19777, Noah 18630, Olivia 17641, Emma 15661, Oliver 14234

-- Step 2: SELECT * reads every column: estimate 185.85 MB (not run)
SELECT *
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020;

-- Step 3: a bigger table. Estimates only, do NOT run these
SELECT *     FROM `bigquery-public-data.stackoverflow.posts_questions`;
-- estimate 37.17 GB
SELECT title FROM `bigquery-public-data.stackoverflow.posts_questions`;
-- estimate 1.21 GB (about 30 times less)

-- Step 4: your task. LIMIT does not reduce the bytes read (estimate only, do NOT run)
SELECT * FROM `bigquery-public-data.stackoverflow.posts_questions` LIMIT 10;
-- estimate still 37.17 GB

-- Step 5: the row count comes from the table's details: 0 B read
SELECT COUNT(*) AS questions
FROM `bigquery-public-data.stackoverflow.posts_questions`;
-- 1 row: 23020127

-- Step 6: questions per year (175.63 MB, 522 ms)
SELECT EXTRACT(YEAR FROM creation_date) AS year,
COUNT(*) AS questions
FROM `bigquery-public-data.stackoverflow.posts_questions`
GROUP BY year
ORDER BY questions DESC
LIMIT 5;
-- 5 rows: 2016 2200802, 2015 2196676, 2014 2137435, 2017 2116212, 2013 2033690
