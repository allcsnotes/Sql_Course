-- M15-L07 setup: the change this lesson makes to the Chai Corner database.
-- Deletes the extra newsletter sign-ups (Asha and Ravi joined twice),
-- keeping the first sign-up of each email. Needs M15-L06's setup.sql first.
-- Re-runnable: a second run finds no copies and deletes 0 rows.
DELETE FROM newsletter
WHERE id IN (
  SELECT id FROM (
    SELECT id,
      ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS copy
    FROM newsletter
  ) c
  WHERE copy > 1
);

-- Check: 4 rows, ids 1, 2, 4, 6
SELECT id, email, joined_on FROM newsletter ORDER BY id;
