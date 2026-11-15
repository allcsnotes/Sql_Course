# M13-L02 · BEGIN, COMMIT, ROLLBACK, SAVEPOINT

> Video: Module 13, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- `ROLLBACK` on purpose, when you change your mind
- Inside a transaction you see your own changes before they are saved
- `SAVEPOINT name`: a checkpoint inside a transaction, and `ROLLBACK TO SAVEPOINT name` to undo only the steps after it
- How a savepoint rescues a transaction after an error
- **Auto commit**, and three savepoint mistakes

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `wallets` from [M13-L01](../m13-l01-transactions-all-or-nothing/), after its task: Asha 450, Rahul 250.
- DBeaver in its normal **Auto** commit mode, or `psql`.

## Files in this folder

| File | What it is |
|---|---|
| `rollback_savepoint.sql` | Every statement from the video in order, with the real result or error as a comment |
| `setup.sql` | The wallet balances after the task (Asha 400, Rahul 300). Run it only if you skipped the lesson |

## Follow along

In the last lesson, `BEGIN` started a transaction and `COMMIT` saved it. Now two more tools: `ROLLBACK` used on purpose, and savepoints.

### 1. ROLLBACK on purpose

We start at Asha 450, Rahul 250. Begin, then a mistake: Rahul's balance is set to zero.

```sql
BEGIN;
UPDATE wallets SET balance = 0 WHERE wallet_id = 2;
SELECT owner, balance FROM wallets ORDER BY wallet_id;
```

| owner | balance |
|---|---|
| Asha | 450.00 |
| Rahul | 0.00 |

Inside the transaction you see your own change. Now:

```sql
ROLLBACK;
SELECT owner, balance FROM wallets ORDER BY wallet_id;
```

Rahul is back to 250.00. Nothing was saved.

### 2. A savepoint: undo only the last step

```sql
BEGIN;
UPDATE wallets SET balance = balance - 50 WHERE wallet_id = 1;
SAVEPOINT after_step1;
UPDATE wallets SET balance = balance + 500 WHERE wallet_id = 2;
ROLLBACK TO SAVEPOINT after_step1;
UPDATE wallets SET balance = balance + 50 WHERE wallet_id = 2;
COMMIT;
```

1. Step 1: Asha sends 50.
2. `SAVEPOINT after_step1` marks a checkpoint, with a name.
3. Step 2 has a mistake: 500 instead of 50.
4. `ROLLBACK TO SAVEPOINT after_step1` undoes only the wrong step. Step 1 stays.
5. The correct step 2, then `COMMIT`.

```sql
SELECT owner, balance FROM wallets ORDER BY wallet_id;
```

| owner | balance |
|---|---|
| Asha | 400.00 |
| Rahul | 300.00 |

The total is still ₹700.

### 3. A savepoint rescues you from an error

```sql
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
SAVEPOINT before_step2;
UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 2;
```

```text
ERROR: column "balanse" of relation "wallets" does not exist   (SQLSTATE 42703)
```

Without a savepoint, the whole transaction would now be blocked. Roll back to the savepoint instead, and the transaction works again:

```sql
ROLLBACK TO SAVEPOINT before_step2;
UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 2;
COMMIT;
```

The fixed step 2 says `Updated Rows 1`. Now Asha has 300.00 and Rahul 400.00. Total: ₹700.

### 4. Auto commit

See the word **Auto** in DBeaver's toolbar? That is auto commit. Without `BEGIN`, every statement is saved on its own, the moment it runs. `BEGIN` turns that off until `COMMIT` or `ROLLBACK`. psql works the same way.

## Common mistakes

All three were run for real in the video.

1. **`COMMIT` after an error.**

   ```sql
   BEGIN;
   UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 2;
   UPDATE wallets SET balanse = balance + 100 WHERE wallet_id = 1;
   COMMIT;
   ```

   The second update fails. `COMMIT` looks fine, but Postgres rolls back instead (psql even prints `ROLLBACK`). Rahul still has 400.00: nothing was saved.

2. **A savepoint name that does not exist.**

   ```sql
   BEGIN;
   ROLLBACK TO SAVEPOINT step_one;
   ```

   ```text
   ERROR: savepoint "step_one" does not exist   (SQLSTATE 3B001)
   ```

   Use the exact name. (End this one with `ROLLBACK;`.)

3. **A savepoint set after the damage.**

   ```sql
   BEGIN;
   UPDATE wallets SET balance = 0 WHERE wallet_id = 1;
   SAVEPOINT too_late;
   ROLLBACK TO SAVEPOINT too_late;
   SELECT owner, balance FROM wallets ORDER BY wallet_id;
   ```

   Rolling back to it changes nothing: Asha still shows 0.00. Set the savepoint **before** the risky step. End with `ROLLBACK;` and Asha is back to 300.00.

## Try it yourself

1. In one transaction, Rahul sends Asha ₹100. Set a savepoint, then give Asha ₹1000 by mistake. Roll back to the savepoint, give her ₹100, and commit. What are the two balances? (The video's task. The next lesson starts from these balances.)
2. What does `ROLLBACK` (without `TO SAVEPOINT`) undo when a transaction has two savepoints?
3. You are in auto commit mode and run one `UPDATE`. Can you still undo it with `ROLLBACK`?

## Answers

1. ```sql
   BEGIN;
   UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 2;
   SAVEPOINT paid;
   UPDATE wallets SET balance = balance + 1000 WHERE wallet_id = 1;
   ROLLBACK TO SAVEPOINT paid;
   UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 1;
   COMMIT;
   ```

   Asha 400.00, Rahul 300.00 (total 700).

2. Everything since `BEGIN`, including the steps before both savepoints.
3. No. In auto commit the `UPDATE` was saved the moment it ran; there is no open transaction to roll back.

## Next

[M13-L03 · ACID in Plain Words](../m13-l03-acid-in-plain-words/)
