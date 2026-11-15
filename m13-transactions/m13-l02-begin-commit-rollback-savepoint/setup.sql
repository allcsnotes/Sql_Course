-- M13-L02 setup: the wallet balances after this lesson's task (Asha 400, Rahul 300).
-- Only needed if you skipped the lesson. Safe to run more than once.

UPDATE wallets SET balance = 400 WHERE wallet_id = 1;
UPDATE wallets SET balance = 300 WHERE wallet_id = 2;
