-- M13-L01 setup: the wallets table this lesson creates, with the balances after its task.
-- Only needed if you skipped the lesson. Safe to run more than once.

CREATE TABLE IF NOT EXISTS wallets (
  wallet_id int PRIMARY KEY,
  owner     varchar(20) NOT NULL,
  balance   numeric(8,2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO wallets (wallet_id, owner, balance)
VALUES (1, 'Asha', 450),
       (2, 'Rahul', 250)
ON CONFLICT (wallet_id) DO UPDATE SET owner = EXCLUDED.owner, balance = EXCLUDED.balance;
