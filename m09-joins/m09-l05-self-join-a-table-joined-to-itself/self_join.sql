-- M09-L05 Self join: a table joined to itself (Chai Corner staff, fictional data)
-- Needs Chai Corner update 5 (the staff table) from M09-L03.

-- Step 1: the staff table (manager_id holds the staff_id of that person's manager)
SELECT staff_id, name, role, manager_id FROM staff ORDER BY staff_id;
-- 10 rows: 1 Meera Owner NULL, 2 Imran Area Manager 1, 3 Pooja Branch Manager 2,
--          4 Sameer 2, 5 Kavya 2, 6 Ravi Barista 3, 7 Nisha Barista 3, 8 Aman Barista 4,
--          9 Leela Cashier 5, 10 Farhan Trainee 2

-- Step 2: each employee with their manager (9 rows, Meera has no manager)
SELECT emp.name  AS employee,
       boss.name AS manager
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id
ORDER BY emp.staff_id;
-- 9 rows: Imran Meera, Pooja Imran, Sameer Imran, Kavya Imran, Ravi Pooja, Nisha Pooja,
--         Aman Sameer, Leela Kavya, Farhan Imran

-- Step 3: keep everyone with LEFT JOIN (10 rows)
SELECT emp.name  AS employee,
       COALESCE(boss.name, 'no manager') AS manager
FROM staff AS emp
LEFT JOIN staff AS boss ON boss.staff_id = emp.manager_id
ORDER BY emp.staff_id;
-- 10 rows: Meera no manager, then the 9 rows of step 2

-- Step 4: team size of each manager
SELECT boss.name AS manager,
       COUNT(*)  AS team_size
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id
GROUP BY boss.name
ORDER BY team_size DESC, manager;
-- 5 rows: Imran 4, Pooja 2, Kavya 1, Meera 1, Sameer 1

-- Mistake 1: no aliases. FAILS on purpose.
SELECT staff.name, staff.name
FROM staff
JOIN staff ON staff.staff_id = staff.manager_id;
-- SQL Error [42712]: ERROR: table name "staff" specified more than once

-- Mistake 2: just "name". FAILS on purpose.
SELECT name
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id;
-- SQL Error [42702]: ERROR: column reference "name" is ambiguous  Position: 8

-- Mistake 3: the ON flipped. It runs, but it is backwards.
SELECT emp.name  AS employee,
       boss.name AS manager
FROM staff AS emp
JOIN staff AS boss ON boss.manager_id = emp.staff_id
ORDER BY emp.staff_id;
-- 9 rows: Meera Imran, Imran Pooja, Imran Sameer, Imran Kavya, Imran Farhan, Pooja Nisha,
--         Pooja Ravi, Sameer Aman, Kavya Leela  ("Meera's manager is Imran": wrong way round)

-- Your task: Nisha's manager's manager (answer: Imran)
SELECT emp.name  AS employee,
       boss.name AS manager,
       big.name  AS managers_manager
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id
JOIN staff AS big  ON big.staff_id  = boss.manager_id
WHERE emp.name = 'Nisha';
-- 1 row: Nisha Pooja Imran
