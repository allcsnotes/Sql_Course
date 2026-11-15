-- Module 13, Lesson 4: Two people at once, isolation levels, locks and deadlocks
-- Chai Corner database (PostgreSQL 18). Start: Asha 300, Rahul 400 (after M13-L03).
--
-- You need TWO connections. Open two terminal windows and run in each:
--     psql -U postgres -d chai_corner
-- (or two DBeaver SQL editors). Do NOT run this file in one go: type each line
-- into the window it is marked for, in this order.

-- ===== 1. READ COMMITTED (the default) =====
-- [W1]
SHOW transaction_isolation;                                     -- read committed
BEGIN;
SELECT owner, balance FROM wallets WHERE wallet_id = 1;         -- Asha 300.00
-- [W2] (no BEGIN: saved at once)
UPDATE wallets SET balance = balance + 50 WHERE wallet_id = 1;  -- UPDATE 1
-- [W1] same transaction, read again
SELECT owner, balance FROM wallets WHERE wallet_id = 1;         -- Asha 350.00
COMMIT;

-- ===== 2. REPEATABLE READ: a frozen picture =====
-- [W1]
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT owner, balance FROM wallets WHERE wallet_id = 1;         -- Asha 350.00
-- [W2]
UPDATE wallets SET balance = balance - 50 WHERE wallet_id = 1;  -- saved: real balance now 300
-- [W1]
SELECT owner, balance FROM wallets WHERE wallet_id = 1;         -- still 350.00
COMMIT;
SELECT owner, balance FROM wallets WHERE wallet_id = 1;         -- 300.00

-- ===== 3. LOCKS: window 2 waits until window 1 commits =====
-- [W1]
BEGIN;
UPDATE wallets SET balance = balance - 10 WHERE wallet_id = 1;  -- row 1 is now locked
-- [W2]
UPDATE wallets SET balance = balance + 10 WHERE wallet_id = 1;  -- waits (nothing comes back)
-- [W1]
COMMIT;                                                         -- lock released
-- [W2] finishes at once: UPDATE 1 (in the video, execute time 22 s: all spent waiting)
-- Asha is back to 300 (-10 then +10)

-- ===== 4. DEADLOCK: two windows, opposite order =====
-- [W1]
BEGIN;
UPDATE wallets SET balance = balance - 10 WHERE wallet_id = 1;  -- W1 locks row 1
-- [W2]
BEGIN;
UPDATE wallets SET balance = balance - 10 WHERE wallet_id = 2;  -- W2 locks row 2
-- [W1]
UPDATE wallets SET balance = balance + 10 WHERE wallet_id = 2;  -- W1 waits for W2
-- [W2]
UPDATE wallets SET balance = balance + 10 WHERE wallet_id = 1;  -- W2 waits for W1: a circle
-- after about 1 second, in one of the windows (here W2):
-- ERROR 40P01: deadlock detected
-- the other window (W1) carries on: UPDATE 1
-- [W1] and [W2]
ROLLBACK;

-- [either window]
SELECT owner, balance, (SELECT sum(balance) FROM wallets) AS total
FROM wallets ORDER BY wallet_id;                                -- Asha 300.00, Rahul 400.00, total 700.00
