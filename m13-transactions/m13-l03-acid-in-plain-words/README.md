# M13-L03 · ACID in Plain Words

> Video: Module 13, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- The four promises Postgres makes about every transaction, called **ACID**
- **A**tomic: all or nothing
- **C**onsistent: the rules of your tables always hold
- **I**solated: others see your change only after `COMMIT` (shown with two windows)
- **D**urable: after `COMMIT`, the change is saved for good

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `wallets` after [M13-L02](../m13-l02-begin-commit-rollback-savepoint/)'s task: Asha 400, Rahul 300.
- For the isolation part you need **two connections at once**: two SQL editor tabs in DBeaver (SQL Editor > New SQL script, twice: each script gets its own connection), or two terminal windows each running `psql -U postgres -d chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `acid.sql` | The statements from the video, marked Window 1 / Window 2, with the real results as comments |
| `setup.sql` | The wallet balances after this lesson (Asha 300, Rahul 400). Run it only if you skipped the lesson |

## Follow along

### A · Atomic

Atomic means one piece that cannot be split. In [M13-L01](../m13-l01-transactions-all-or-nothing/), step 1 took ₹100 from Asha, then step 2 failed because of a typo. We rolled back and looked again: Asha still had 400, and the total was still 700. A transfer happens fully, or not at all. Never half.

### C · Consistent

The rules of your table always hold. `wallets` has a rule: a balance can never go below zero. Asha tries to send ₹1000:

```sql
UPDATE wallets SET balance = balance - 1000 WHERE wallet_id = 1;
```

```text
ERROR: new row for relation "wallets" violates check constraint "wallets_balance_check"   (SQLSTATE 23514)
  Detail: Failing row contains (1, Asha, -600.00).
```

(The video shows this from M13-L01, when Asha had 400. Run it at the end of this lesson, with Asha at 300, and the failing row shows -700.00.) Every transaction takes the data from one valid state to another valid state. Broken data is never saved.

### I · Isolated

Two people can work at the same time without seeing each other's unfinished work. Open two windows.

**Window 1:**

```sql
BEGIN;
UPDATE wallets SET balance = balance - 100 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance + 100 WHERE wallet_id = 2;
```

No commit yet. **Window 2** is a different connection:

```sql
SELECT owner, balance FROM wallets ORDER BY wallet_id;
```

| owner | balance |
|---|---|
| Asha | 400.00 |
| Rahul | 300.00 |

It still sees the old values. Now **Window 1**:

```sql
COMMIT;
```

**Window 2** looks again (same `SELECT`):

| owner | balance |
|---|---|
| Asha | 300.00 |
| Rahul | 400.00 |

Others see your change only after the commit.

### D · Durable

Once `COMMIT` finishes, the change is saved for good. Try to undo it:

```sql
ROLLBACK;
```

```text
WARNING: there is no transaction in progress
```

Nothing is undone. Look again:

```sql
SELECT owner, balance,
       (SELECT sum(balance) FROM wallets) AS total
FROM wallets
ORDER BY wallet_id;
```

| owner | balance | total |
|---|---|---|
| Asha | 300.00 | 700.00 |
| Rahul | 400.00 | 700.00 |

Postgres writes every commit safely to disk, so it survives even a crash or a power cut.

| Letter | Promise | In one line |
|---|---|---|
| A | Atomic | all or nothing |
| C | Consistent | the rules always hold |
| I | Isolated | others see your change only after commit |
| D | Durable | after commit, saved for good |

## Common mistakes

1. **Two updates without `BEGIN`.** Each one saves on its own, so a failure in the middle leaves half a transfer. Wrap them in `BEGIN` and `COMMIT`.
2. **Expecting others to see your change early.** Until you commit, other windows still see the old values.
3. **Hoping `ROLLBACK` can undo a commit.** It cannot (`there is no transaction in progress`). Check your numbers before you commit.

## Try it yourself

1. Window 2 cannot see the change from Window 1 before the commit. Which ACID letter is that? (The video's task.)
2. Which letter protects you when the power goes off one second after `COMMIT` finishes?
3. In Window 1, `BEGIN` and take ₹50 from Rahul, then `ROLLBACK`. What did Window 2 see during and after?

## Answers

1. **I**, isolated.
2. **D**, durable: the commit is already safely on disk.
3. Rahul at 400.00 both times. Window 2 never saw the uncommitted change (isolated), and the rollback threw it away (atomic).

## Next

[M13-L04 · Isolation Levels, Locks and Deadlocks](../m13-l04-isolation-levels-locks-and-deadlocks/)
