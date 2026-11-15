-- Chai Corner update 1 (Module 3, Lesson 6): customers get an email column.
-- Four customers did not give an email, so theirs stays empty (NULL).
-- Safe to run more than once.
ALTER TABLE customers ADD COLUMN IF NOT EXISTS email varchar(60);
UPDATE customers SET email = lower(name) || '@example.com' WHERE customer_id NOT IN (2, 5, 8, 13);
-- Keep the rows stored in customer_id order, so SELECT * shows 1 to 15 as in the video.
CLUSTER customers USING customers_pkey;
