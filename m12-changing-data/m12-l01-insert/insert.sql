-- Module 12, Lesson 1: INSERT, one row, many rows, and RETURNING
-- Chai Corner database (PostgreSQL 18)
-- The feedback table was created empty in M11-L01 (the task).

-- Step 1: the feedback table is empty, ready for rows
SELECT * FROM feedback;
-- 5 column headers, no rows

-- Step 2: INSERT, add one row, values in column order
INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (1, 4, 5, 'Best masala chai in Pune', '2026-04-20');
-- Updated Rows 1

-- Step 3: many rows in one INSERT, a comma between each row
INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (2, 7, 4, 'Samosa was hot and fresh', '2026-04-21'),
       (3, 12, 3, 'Chai came a bit late', '2026-04-22'),
       (4, 16, 5, 'Loved the Kulhad Chai', '2026-04-23');
-- Updated Rows 3

-- Check: four rows are in the table now
SELECT * FROM feedback;
-- 4 rows: ids 1, 2, 3, 4

-- Step 4: RETURNING, get the new row back right away
INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (5, 9, 4, 'Friendly staff', '2026-04-24')
RETURNING feedback_id, rating, comment;
-- 1 row: 5 | 4 | Friendly staff

-- Step 5: skip a column, it gets NULL (or its DEFAULT)
INSERT INTO feedback (feedback_id, customer_id, rating)
VALUES (6, 2, 3)
RETURNING *;
-- 1 row: 6 | 2 | 3 | [NULL] | [NULL]

-- Three mistakes (each one fails, nothing is saved):
-- 1. three values for two columns
INSERT INTO feedback (feedback_id, rating)
VALUES (7, 4, 'Nice chai');
-- ERROR 42601: INSERT has more expressions than target columns

-- 2. no column list, values in the wrong order
INSERT INTO feedback
VALUES (7, 'Great tea', 3, 5, '2026-04-25');
-- ERROR 22P02: invalid input syntax for type integer: "Great tea"

-- 3. an id that is already taken
INSERT INTO feedback (feedback_id, customer_id, rating)
VALUES (1, 3, 4);
-- ERROR 23505: duplicate key value violates unique constraint "feedback_pkey"
--              Key (feedback_id)=(1) already exists.

-- Your task: two rows in one INSERT, return their ids (answer in README.md)
