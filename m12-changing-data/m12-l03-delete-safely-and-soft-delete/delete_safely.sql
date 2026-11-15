-- Module 12, Lesson 3: DELETE safely, and soft delete
-- Chai Corner database (PostgreSQL 18)

-- Step 1: the feedback table, 8 rows
SELECT feedback_id, customer_id, rating, comment
FROM feedback
ORDER BY feedback_id;
-- 8 rows; row 6 (customer 2, rating 3) has comment [NULL]

-- Step 2: SELECT the rows you plan to delete
SELECT feedback_id, customer_id, rating, comment
FROM feedback
WHERE comment IS NULL;
-- 1 row: 6 | 2 | 3 | [NULL]

-- Step 3: same WHERE, now DELETE (and see what went)
DELETE FROM feedback
WHERE comment IS NULL
RETURNING feedback_id, customer_id, rating;
-- 1 row: 6 | 2 | 3   (save this output: it is your only record of that row)

-- Step 4: soft delete, add a flag instead of removing rows
ALTER TABLE feedback
ADD COLUMN hidden boolean NOT NULL DEFAULT false;

-- Step 5: hide a row instead of deleting it
UPDATE feedback
SET hidden = true
WHERE feedback_id = 3
RETURNING feedback_id, comment, hidden;
-- 1 row: 3 | Chai came a bit late | true

-- Step 6: everyday reads skip hidden rows
SELECT feedback_id, rating, comment
FROM feedback
WHERE hidden = false
ORDER BY feedback_id;
-- 6 rows: 1, 2, 4, 5, 7, 8 (row 3 is missing from the list, but safe)

-- Step 7: changed your mind? Bring it back
UPDATE feedback
SET hidden = false
WHERE feedback_id = 3
RETURNING feedback_id, comment, hidden;
-- 1 row: 3 | Chai came a bit late | false

-- Mistake 1: = NULL never matches anything
DELETE FROM feedback
WHERE comment = NULL;
-- Updated Rows 0

-- Mistake 2: deleting a row other tables point to
DELETE FROM suppliers
WHERE supplier_id = 1;
-- ERROR 23503: update or delete on table "suppliers" violates foreign key constraint "restocks_supplier_id_fkey" on table "restocks"
--              Key (supplier_id)=(1) is still referenced from table "restocks".

-- Your task: hide feedback 5, then count the visible feedback (answer in README.md)

-- Mistake 3 (run it after the task): forgetting the hidden filter
SELECT count(*) FROM feedback;
-- 7, but only 6 are visible
