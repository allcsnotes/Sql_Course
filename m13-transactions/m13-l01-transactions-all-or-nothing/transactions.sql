-- Module 13, Lesson 1: Transactions, all or nothing
-- Chai Corner database (PostgreSQL 18). Run one statement at a time, in this order.

-- Step 1: two customer wallets for this module
CREATE TABLE wallets (
  wallet_id int PRIMARY KEY,
  owner     varchar(20) NOT NULL,
  balance   numeric(8,2) NOT NULL CHECK (balance >= 0)
);

-- Asha has 500, Rahul has 200
INSERT INTO wallets (wallet_id, owner, balance)
VALUES (1, 'Asha', 500),
       (2, 'Rahul', 200)
RETURNING wallet_id, owner, balance;
-- 1 | Asha | 500.00,  2 | Rahul | 200.00

-- Step 2: without a transaction, step 1 works, step 2 fails (typo), 100 vanishes
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
-- Updated Rows 1
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 2;
-- ERROR 42703: column "balanse" of relation "wallets" does not exist
SELECT owner, balance,
       (SELECT sum(balance) FROM wallets) AS total
FROM wallets
ORDER BY wallet_id;
-- Asha 400.00, Rahul 200.00, total 600.00 (100 rupees vanished)

-- Step 3: put the 100 back
UPDATE wallets SET balance = 500 WHERE wallet_id = 1;

-- Step 4: all or nothing, wrap both steps
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 2;
COMMIT;
SELECT owner, balance,
       (SELECT sum(balance) FROM wallets) AS total
FROM wallets
ORDER BY wallet_id;
-- Asha 400.00, Rahul 300.00, total 700.00

-- Step 5: when it fails inside a transaction
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
-- Updated Rows 1 (only inside the transaction)
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 2;
-- ERROR 42703: column "balanse" of relation "wallets" does not exist
SELECT * FROM wallets;
-- ERROR 25P02: current transaction is aborted, commands ignored until end of transaction block
ROLLBACK;
SELECT owner, balance,
       (SELECT sum(balance) FROM wallets) AS total
FROM wallets
ORDER BY wallet_id;
-- still Asha 400.00, Rahul 300.00, total 700.00

-- Mistake 3: sending more than you have
UPDATE wallets SET balance = balance - 1000 WHERE wallet_id = 1;
-- ERROR 23514: new row for relation "wallets" violates check constraint "wallets_balance_check"
--              Failing row contains (1, Asha, -600.00).

-- Your task: in a transaction, send 50 from Rahul to Asha, then commit (answer in README.md)
