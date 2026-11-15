-- Module 13, Lesson 2: BEGIN, COMMIT, ROLLBACK, SAVEPOINT
-- Chai Corner database (PostgreSQL 18). Start: Asha 450, Rahul 250 (after M13-L01's task).
-- Run one statement at a time, in this order.

-- Step 1: change your mind, ROLLBACK on purpose
BEGIN;
UPDATE wallets SET balance = 0 WHERE wallet_id = 2;
SELECT owner, balance FROM wallets ORDER BY wallet_id;   -- inside: Asha 450.00, Rahul 0.00
ROLLBACK;
SELECT owner, balance FROM wallets ORDER BY wallet_id;   -- Asha 450.00, Rahul 250.00 again

-- Step 2: a SAVEPOINT is a checkpoint inside a transaction
BEGIN;
UPDATE wallets SET balance = balance - 50 WHERE wallet_id = 1;
SAVEPOINT after_step1;
UPDATE wallets SET balance = balance + 500 WHERE wallet_id = 2;   -- wrong: 500 instead of 50
ROLLBACK TO SAVEPOINT after_step1;                                 -- only the wrong step is undone
UPDATE wallets SET balance = balance + 50 WHERE wallet_id = 2;
COMMIT;
SELECT owner, balance FROM wallets ORDER BY wallet_id;   -- Asha 400.00, Rahul 300.00 (total 700)

-- Step 3: a SAVEPOINT also rescues you from an error
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
SAVEPOINT before_step2;
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 2;
-- ERROR 42703: column "balanse" of relation "wallets" does not exist
ROLLBACK TO SAVEPOINT before_step2;                                -- the transaction works again
UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 2;   -- Updated Rows 1
COMMIT;
SELECT owner, balance FROM wallets ORDER BY wallet_id;   -- Asha 300.00, Rahul 400.00 (total 700)

-- Mistake 1: COMMIT after an error (it rolls back, nothing saved)
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 2;
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 1;   -- ERROR 42703
COMMIT;                                                            -- psql prints ROLLBACK
SELECT owner, balance FROM wallets ORDER BY wallet_id;   -- Rahul still 400.00

-- Mistake 2: a savepoint name that does not exist
BEGIN;
ROLLBACK TO SAVEPOINT step_one;
-- ERROR 3B001: savepoint "step_one" does not exist
ROLLBACK;

-- Mistake 3: a savepoint set after the damage
BEGIN;
UPDATE wallets SET balance = 0 WHERE wallet_id = 1;
SAVEPOINT too_late;
ROLLBACK TO SAVEPOINT too_late;
SELECT owner, balance FROM wallets ORDER BY wallet_id;   -- Asha still 0.00
ROLLBACK;                                                 -- now Asha is 300.00 again

-- Your task: Rahul sends Asha 100, with a savepoint rescue (answer in README.md)
