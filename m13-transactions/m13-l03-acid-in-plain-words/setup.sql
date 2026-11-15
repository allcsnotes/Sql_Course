-- M13-L03 setup: the wallet balances after this lesson (Asha 300, Rahul 400).
-- Only needed if you skipped the lesson. Safe to run more than once.

UPDATE wallets SET balance = 300 WHERE wallet_id = 1;
UPDATE wallets SET balance = 400 WHERE wallet_id = 2;
