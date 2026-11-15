-- M22-L03 · Classic interview problems 1 (PostgreSQL, chai_corner)
-- Run setup.sql first (it adds staff.salary).

-- Step 1: every salary, high to low
SELECT name, role, salary FROM staff ORDER BY salary DESC;
-- 10 rows: Meera 90000, Imran 60000, Pooja 45000, Sameer 45000, Kavya 42000,
--          Ravi 22000, Nisha 22000, Aman 20000, Leela 20000, Farhan 12000

-- Step 2: second highest salary, the MAX below the MAX
SELECT MAX(salary) AS second_highest
FROM staff
WHERE salary < (SELECT MAX(salary) FROM staff);
-- 1 row: 60000

-- Step 3: the OFFSET trap. "4th highest?" returns a 45000 row because of the tie: WRONG
SELECT name, salary FROM staff ORDER BY salary DESC LIMIT 1 OFFSET 3;
-- 1 row: Pooja 45000 (which of the tied rows you get is not fixed)

-- Step 4: Nth highest salary with DENSE_RANK (ties share a rank)
WITH ranked AS (
  SELECT name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
  FROM staff
)
SELECT name, salary, rnk FROM ranked WHERE rnk = 4;
-- 1 row: Kavya 42000 4

-- Step 5: duplicates, salaries that appear more than once
SELECT salary, COUNT(*) AS people
FROM staff
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;
-- 3 rows: 45000 2, 22000 2, 20000 2

-- Step 6: who shares a salary with someone?
SELECT name, salary
FROM staff
WHERE salary IN (
SELECT salary FROM staff
GROUP BY salary
HAVING COUNT(*) > 1
)
ORDER BY salary DESC, name;
-- 6 rows: Pooja 45000, Sameer 45000, Nisha 22000, Ravi 22000, Aman 20000, Leela 20000

-- Step 7: the Nth row. OFFSET is N - 1, always with ORDER BY
SELECT staff_id, name FROM staff ORDER BY staff_id LIMIT 1 OFFSET 2;
-- 1 row: 3 Pooja

-- Your task: the 3rd highest salary
WITH ranked AS (
  SELECT name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
  FROM staff
)
SELECT name, salary, rnk FROM ranked WHERE rnk = 3;
-- 2 rows: Pooja 45000 3, Sameer 45000 3
