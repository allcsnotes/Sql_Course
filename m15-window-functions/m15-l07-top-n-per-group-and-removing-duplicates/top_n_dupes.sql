-- M15-L07 Top N per group and removing duplicates (chai_corner)
-- Runs on the Chai Corner database (sales table, and the newsletter table
-- from M15-L06's setup.sql). Run one query at a time.

-- Step 1: TOP N: the 2 best selling items in each branch
WITH cups AS (
  SELECT branch, item, SUM(qty) AS sold
  FROM sales GROUP BY 1, 2
), ranked AS (
  SELECT branch, item, sold,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC) AS rn
  FROM cups
)
SELECT branch, item, sold, rn FROM ranked
WHERE rn <= 2 ORDER BY branch, rn;
-- 6 rows: Delhi Masala Chai 235, Cutting Chai 226; Mumbai 456, 393; Pune 691, 675

-- Step 2: look at the newsletter: asha and ravi joined twice
SELECT id, email, joined_on
FROM newsletter
ORDER BY email, id;
-- 6 rows: 1 asha, 3 asha, 6 kabir, 4 meena, 2 ravi, 5 ravi

-- Step 3: number each email: copy 2 is the extra one
SELECT id, email, joined_on,
  ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS copy
FROM newsletter
ORDER BY email, id;
-- 6 rows: copy 1, 2, 1, 1, 1, 2 (ids 3 and 5 are the copies)

-- Step 4: DELETE the copies, keep the first sign-up of each email
DELETE FROM newsletter
WHERE id IN (
  SELECT id FROM (
    SELECT id,
      ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS copy
    FROM newsletter
  ) c
  WHERE copy > 1
);
-- DELETE 2 (DBeaver: Updated Rows 2)

SELECT id, email, joined_on
FROM newsletter
ORDER BY email, id;
-- 4 rows: 1 asha 2026-03-01, 6 kabir, 4 meena, 2 ravi 2026-03-02

-- Mistake 1: rn in the same WHERE
WITH cups AS (
  SELECT branch, item, SUM(qty) AS sold
  FROM sales GROUP BY 1, 2
)
SELECT branch, item, sold,
  ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC) AS rn
FROM cups
WHERE rn <= 2;
-- ERROR 42703: column "rn" does not exist

-- Mistake 2: no PARTITION BY gives the top 2 overall (both Pune)
WITH cups AS (
  SELECT branch, item, SUM(qty) AS sold
  FROM sales GROUP BY 1, 2
), ranked AS (
  SELECT branch, item, sold,
    ROW_NUMBER() OVER (ORDER BY sold DESC) AS rn
  FROM cups
)
SELECT branch, item, sold, rn FROM ranked
WHERE rn <= 2 ORDER BY rn;
-- 2 rows: Pune Masala Chai 691 1, Pune Cutting Chai 675 2

-- Mistake 3: DISTINCT only hides copies in the result, the table keeps them
SELECT DISTINCT email
FROM newsletter
ORDER BY email;
-- 4 rows: asha, kabir, meena, ravi (in the video this ran before the DELETE: the table still had 6 rows)

-- Your task: the best selling item in each branch
WITH cups AS (
  SELECT branch, item, SUM(qty) AS sold
  FROM sales GROUP BY 1, 2
), ranked AS (
  SELECT branch, item, sold,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC) AS rn
  FROM cups
)
SELECT branch, item, sold FROM ranked WHERE rn = 1 ORDER BY branch;
-- 3 rows: Delhi Masala Chai 235, Mumbai Masala Chai 456, Pune Masala Chai 691
