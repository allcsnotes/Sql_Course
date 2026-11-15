-- M10-L02 IN, EXISTS, NOT EXISTS, and the NOT IN + NULL trap (Chai Corner, fictional data)
-- Needs Chai Corner update 5 (the staff table) from M09-L03.

-- Step 1: what the subquery gives back: a list (3 staff have NULL branch_id)
SELECT name, branch_id
FROM staff
ORDER BY staff_id;
-- 10 rows: Meera NULL, Imran NULL, Pooja 1, Sameer 2, Kavya 3, Ravi 1, Nisha 1, Aman 2, Leela 3, Farhan NULL

-- Step 2: which branches have staff? IN with a list from a subquery
SELECT branch_id, city
FROM branches
WHERE branch_id IN (SELECT branch_id FROM staff)
ORDER BY branch_id;
-- 3 rows: 1 Pune, 2 Mumbai, 3 Delhi

-- Step 3: EXISTS: is there at least one staff row for this branch?
SELECT branch_id, city
FROM branches
WHERE EXISTS (SELECT 1 FROM staff
              WHERE staff.branch_id = branches.branch_id)
ORDER BY branch_id;
-- 3 rows: 1 Pune, 2 Mumbai, 3 Delhi

-- Step 4: NOT EXISTS: branches with no staff at all
SELECT branch_id, city
FROM branches
WHERE NOT EXISTS (SELECT 1 FROM staff
                  WHERE staff.branch_id = branches.branch_id)
ORDER BY branch_id;
-- 7 rows: 4 Bengaluru, 5 Chennai, 6 Hyderabad, 7 Kolkata, 8 Jaipur, 9 Ahmedabad, 10 Kochi

-- Step 5: the trap: NOT IN, when the list has a NULL
SELECT branch_id, city
FROM branches
WHERE branch_id NOT IN (SELECT branch_id FROM staff)
ORDER BY branch_id;
-- 0 rows!

-- Fix: keep the NULLs out of the list
SELECT branch_id, city
FROM branches
WHERE branch_id NOT IN (SELECT branch_id FROM staff
                        WHERE branch_id IS NOT NULL)
ORDER BY branch_id;
-- 7 rows: the same 7 branches as step 4

-- Mistake: EXISTS with no link to the outer row
SELECT branch_id, city
FROM branches
WHERE EXISTS (SELECT 1 FROM staff)
ORDER BY branch_id;
-- 10 rows: all branches

-- Your task: which staff manage nobody?
SELECT name, role
FROM staff
WHERE NOT EXISTS (SELECT 1 FROM staff AS team
                  WHERE team.manager_id = staff.staff_id)
ORDER BY staff_id;
-- 5 rows: Ravi Barista, Nisha Barista, Aman Barista, Leela Cashier, Farhan Trainee
