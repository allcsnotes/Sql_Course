-- M16-L01 Views: saving a query as a virtual table (chai_corner)
-- Runs on the Chai Corner database (sales table: 6,028 rows).
-- Run one statement at a time. This lesson creates two views.

-- Step 1: create a view: only the query is saved (DBeaver: Updated Rows 0)
CREATE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups, COUNT(*) AS sales
FROM sales
GROUP BY branch;

-- Step 2: use it like a table
SELECT * FROM branch_cups
ORDER BY branch;
-- 3 rows: Delhi 1269 1022, Mumbai 2439 1952, Pune 3827 3054

-- Step 3: filter it
SELECT branch, cups
FROM branch_cups
WHERE cups > 2000
ORDER BY cups DESC;
-- 2 rows: Pune 3827, Mumbai 2439

-- Step 4: OR REPLACE may add new columns at the end
CREATE OR REPLACE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups, COUNT(*) AS sales,
  SUM(qty * price) AS revenue
FROM sales
GROUP BY branch;

SELECT * FROM branch_cups
ORDER BY revenue DESC;
-- 3 rows: Pune 3827 3054 138705, Mumbai 2439 1952 87545, Delhi 1269 1022 45015

-- Mistake 1: CREATE VIEW twice
CREATE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups, COUNT(*) AS sales
FROM sales
GROUP BY branch;
-- ERROR 42P07: relation "branch_cups" already exists

-- Mistake 2: OR REPLACE that removes a column
CREATE OR REPLACE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups
FROM sales
GROUP BY branch;
-- ERROR 42P16: cannot drop columns from view

-- Mistake 3: inserting into a GROUP BY view
INSERT INTO branch_cups (branch, cups)
VALUES ('Goa', 50);
-- ERROR 55000: cannot insert into view "branch_cups"
-- DETAIL: Views containing GROUP BY are not automatically updatable.

-- Your task: a view of cups for each item, top seller first
CREATE VIEW item_cups AS
SELECT item, SUM(qty) AS cups
FROM sales
GROUP BY item;

SELECT * FROM item_cups
ORDER BY cups DESC;
-- 10 rows: Masala Chai 1382, Cutting Chai 1294, Vada Pav 815 ... Veg Sandwich 297
