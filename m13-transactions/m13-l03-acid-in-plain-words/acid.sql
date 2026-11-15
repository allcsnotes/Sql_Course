-- Module 13, Lesson 3: ACID in plain words
-- Chai Corner database (PostgreSQL 18). Start: Asha 400, Rahul 300 (after M13-L02's task).

-- A, atomic: shown in M13-L01 (a failed step 2 plus ROLLBACK left Asha at 400, total 700).

-- I, isolated: open TWO SQL editors (two connections). In psql, open two terminal windows.

-- Window 1:
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 2;
-- (no COMMIT yet)

-- Window 2 (before window 1 commits):
SELECT owner, balance FROM wallets ORDER BY wallet_id;
-- still Asha 400.00, Rahul 300.00

-- Window 1:
COMMIT;

-- Window 2 (after the COMMIT):
SELECT owner, balance FROM wallets ORDER BY wallet_id;
-- now Asha 300.00, Rahul 400.00

-- D, durable: ROLLBACK after COMMIT undoes nothing
ROLLBACK;
-- WARNING: there is no transaction in progress
SELECT owner, balance,
       (SELECT sum(balance) FROM wallets) AS total
FROM wallets
ORDER BY wallet_id;
-- Asha 300.00, Rahul 400.00, total 700.00

-- C, consistent: the CHECK (balance >= 0) rule blocks this
UPDATE wallets SET balance = balance - 1000 WHERE wallet_id = 1;
-- ERROR 23514: new row for relation "wallets" violates check constraint "wallets_balance_check"
--              Failing row contains (1, Asha, -700.00).
-- (The video shows the same error from M13-L01, when Asha had 400: -600.00.)
