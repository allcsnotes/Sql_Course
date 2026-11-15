-- M09-L03 FULL OUTER JOIN: everything from both sides (Chai Corner, fictional data)
-- Run setup.sql (Chai Corner update 5: the staff table) once first.

-- Step 1: the new staff table (branch_id is NULL for head office and the trainee)
SELECT staff_id, name, role, branch_id
FROM staff
ORDER BY staff_id;
-- 10 rows: 1 Meera Owner NULL, 2 Imran Area Manager NULL, 3 Pooja Branch Manager 1,
--          4 Sameer Branch Manager 2, 5 Kavya Branch Manager 3, 6 Ravi Barista 1,
--          7 Nisha Barista 1, 8 Aman Barista 2, 9 Leela Cashier 3, 10 Farhan Trainee NULL

-- Step 2: the inner join keeps only the matches
SELECT branches.city, staff.name
FROM branches
INNER JOIN staff
  ON staff.branch_id = branches.branch_id
ORDER BY branches.branch_id, staff.staff_id;
-- 7 rows: Pune Pooja, Pune Ravi, Pune Nisha, Mumbai Sameer, Mumbai Aman, Delhi Kavya, Delhi Leela

-- Step 3: change INNER to FULL OUTER
SELECT branches.city, staff.name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
ORDER BY branches.branch_id, staff.staff_id;
-- 17 rows: the 7 matches, then Bengaluru, Chennai, Hyderabad, Kolkata, Jaipur, Ahmedabad,
--          Kochi with name NULL, then city NULL for Meera, Imran, Farhan

-- Step 4: only the gaps
SELECT branches.city, staff.name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
WHERE branches.branch_id IS NULL
   OR staff.staff_id IS NULL
ORDER BY branches.branch_id, staff.staff_id;
-- 10 rows: 7 branches with no staff + Meera, Imran, Farhan with no branch

-- Step 5: give NULL a clean label
SELECT COALESCE(branches.city, 'no branch') AS city,
       COALESCE(staff.name, 'nobody yet') AS name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
ORDER BY branches.branch_id, staff.staff_id;
-- 17 rows: ... Bengaluru nobody yet ... Kochi nobody yet, no branch Meera, no branch Imran, no branch Farhan

-- Mistake 1: WHERE on one side removes the NULL rows
SELECT branches.city, staff.name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
WHERE staff.role = 'Barista'
ORDER BY branches.branch_id, staff.staff_id;
-- 3 rows: Pune Ravi, Pune Nisha, Mumbai Aman

-- Your task: how many branches have no staff yet?
SELECT COUNT(*) AS no_staff
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
WHERE staff.staff_id IS NULL;
-- 1 row: 7
