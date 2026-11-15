-- M16-L01 setup: the views this lesson leaves in the Chai Corner database.
-- branch_cups (with the revenue column added at the end) and item_cups (the task).
-- Re-runnable: CREATE OR REPLACE keeps the same columns.
CREATE OR REPLACE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups, COUNT(*) AS sales,
  SUM(qty * price) AS revenue
FROM sales
GROUP BY branch;

CREATE OR REPLACE VIEW item_cups AS
SELECT item, SUM(qty) AS cups
FROM sales
GROUP BY item;

-- Check: 3 rows (Pune, Mumbai, Delhi) and 10 rows (Masala Chai 1382 first)
SELECT * FROM branch_cups ORDER BY revenue DESC;
SELECT * FROM item_cups ORDER BY cups DESC;
