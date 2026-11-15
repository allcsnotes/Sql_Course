# M13-L01 · Transactions: All or Nothing

> Video: Module 13, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- Why a money transfer is really two steps, and what goes wrong when only one of them happens
- A **transaction**: a group of steps that is saved all together, or not at all
- `BEGIN` starts it, `COMMIT` saves every step together, `ROLLBACK` undoes every step since `BEGIN`
- After an error, Postgres blocks the rest of the transaction until you roll back
- How a `CHECK` rule and a transaction work together

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (the video keeps DBeaver in its normal **Auto** commit mode and types `BEGIN` itself), or `psql`.
- This lesson creates the `wallets` table used in all of Module 13.

## Files in this folder

| File | What it is |
|---|---|
| `transactions.sql` | Every statement from the video in order, with the real result or error as a comment |
| `setup.sql` | `wallets` with the balances after the task (Asha 450, Rahul 250). Run it only if you skipped the lesson |

## Follow along

You send ₹100 to a friend. Behind the scenes there are two steps: take 100 from you, and add 100 to your friend. If the first step works and the second fails, the money simply disappears. A transaction makes sure that can never happen.

### 1. Meet the wallets

```sql
CREATE TABLE wallets (
  wallet_id int PRIMARY KEY,
  owner     varchar(20) NOT NULL,
  balance   numeric(8,2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO wallets (wallet_id, owner, balance)
VALUES (1, 'Asha', 500),
       (2, 'Rahul', 200)
RETURNING wallet_id, owner, balance;
```

You should see:

| wallet_id | owner | balance |
|---|---|---|
| 1 | Asha | 500.00 |
| 2 | Rahul | 200.00 |

The `CHECK` rule says a balance can never go below zero. ₹700 in total.

### 2. Without a transaction: money vanishes

Asha sends Rahul ₹100. Step 1 takes it from Asha:

```sql
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
```

You should see: `Updated Rows 1`. Step 2 should give it to Rahul, but there is a typo, `balanse`:

```sql
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 2;
```

```text
ERROR: column "balanse" of relation "wallets" does not exist   (SQLSTATE 42703)
```

Look at the wallets:

```sql
SELECT owner, balance,
       (SELECT sum(balance) FROM wallets) AS total
FROM wallets
ORDER BY wallet_id;
```

| owner | balance | total |
|---|---|---|
| Asha | 400.00 | 600.00 |
| Rahul | 200.00 | 600.00 |

₹100 just vanished. Put Asha back:

```sql
UPDATE wallets SET balance = 500 WHERE wallet_id = 1;
```

### 3. With a transaction: COMMIT

Wrap both steps. `BEGIN` starts the transaction:

```sql
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 2;
COMMIT;
```

Each update says `Updated Rows 1`, but nothing is saved for good until `COMMIT`, which saves both changes together, as one. Run the `SELECT` from step 2 again:

| owner | balance | total |
|---|---|---|
| Asha | 400.00 | 700.00 |
| Rahul | 300.00 | 700.00 |

The total is still ₹700.

### 4. When it fails inside a transaction: ROLLBACK

The same transfer again, with the typo, inside a transaction:

```sql
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 2;
```

Step 1 works, but only inside the transaction. Step 2 fails with the same typo error. After an error, Postgres blocks the rest of the transaction. Even a simple select is refused:

```sql
SELECT * FROM wallets;
```

```text
ERROR: current transaction is aborted, commands ignored until end of transaction block   (SQLSTATE 25P02)
```

`ROLLBACK` throws away every change since `BEGIN`:

```sql
ROLLBACK;
```

Run the `SELECT` with the total again: Asha 400.00, Rahul 300.00, total 700.00. Not a single rupee lost.

## Common mistakes

1. **Forgetting `BEGIN`.** Each update then saves on its own, so a failure in the middle leaves money missing (step 2).
2. **Carrying on after an error.** Postgres ignores every command (25P02) until you roll back. Roll back, fix it, and run it again.
3. **Sending more than you have.** Asha has 400:

   ```sql
   UPDATE wallets SET balance = balance - 1000 WHERE wallet_id = 1;
   ```

   ```text
   ERROR: new row for relation "wallets" violates check constraint "wallets_balance_check"   (SQLSTATE 23514)
     Detail: Failing row contains (1, Asha, -600.00).
   ```

   The check rule refuses a balance of -600, so inside a transfer that transaction must roll back too.

## Try it yourself

1. In a transaction, send ₹50 from Rahul to Asha, then commit. What are the two balances, and the total? (The video's task. The next lesson starts from these balances.)
2. Start a transaction, take ₹10 from Asha, then `ROLLBACK`. What is Asha's balance?
3. Why does the `SELECT` in step 4 fail even though it has no mistake in it?

## Answers

1. ```sql
   BEGIN;
   UPDATE wallets SET balance = balance - 50 WHERE wallet_id = 2;
   UPDATE wallets SET balance = balance + 50 WHERE wallet_id = 1;
   COMMIT;
   ```

   Asha 450.00, Rahul 250.00, total 700.00.

2. Still 450.00: `ROLLBACK` undid the change.
3. After any error inside a transaction, Postgres refuses every command until the transaction ends with `ROLLBACK`.

## Next

[M13-L02 · BEGIN, COMMIT, ROLLBACK, SAVEPOINT](../m13-l02-begin-commit-rollback-savepoint/)
