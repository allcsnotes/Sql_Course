# M13-L04 · Isolation Levels, Locks and Deadlocks

> Video: Module 13, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- **Isolation levels**: what your transaction can see while others change data
- `READ COMMITTED` (the Postgres default): every new read sees the latest saved data
- `REPEATABLE READ`: one frozen picture for the whole transaction
- **Locks**: a changed row makes others wait until you commit or roll back
- **Deadlocks**: a circle of waiting, how Postgres breaks it, and the fix (same order every time)

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `wallets` after [M13-L03](../m13-l03-acid-in-plain-words/): Asha 300, Rahul 400.
- **Two connections at once.** The video uses two DBeaver SQL editors. With psql, open two terminal windows side by side and run this in each:

  ```bash
  psql -U postgres -d chai_corner
  ```

  psql asks for the password you chose when installing. Below, **W1** means window 1 and **W2** means window 2.
- Nothing in this lesson changes the database for good: the balances end at 300 and 400. There is no `setup.sql`.

## Files in this folder

| File | What it is |
|---|---|
| `two_people.sql` | Every statement from the video, each marked `[W1]` or `[W2]`, in the order to type them, with the real results |

## Follow along

Until now one person used the database at a time. In real life many people use it together. When two of them touch the same data at the same moment, Postgres has three tools: isolation levels, locks and deadlock detection.

### 1. READ COMMITTED: you see the latest saved data

**W1:**

```sql
SHOW transaction_isolation;
```

You should see: `read committed`. This is the default in Postgres.

| Order | Window | Statement | Result |
|---|---|---|---|
| 1 | W1 | `BEGIN;` | |
| 2 | W1 | `SELECT owner, balance FROM wallets WHERE wallet_id = 1;` | Asha 300.00 |
| 3 | W2 | `UPDATE wallets SET balance = balance + 50 WHERE wallet_id = 1;` | saved at once (no `BEGIN`) |
| 4 | W1 | the same `SELECT` again | Asha **350.00** |
| 5 | W1 | `COMMIT;` | |

With read committed, every new read sees the latest saved data, even inside one transaction.

### 2. REPEATABLE READ: a frozen picture

Sometimes you need numbers that do not move while you work, for example while you build a report.

| Order | Window | Statement | Result |
|---|---|---|---|
| 1 | W1 | `BEGIN ISOLATION LEVEL REPEATABLE READ;` | |
| 2 | W1 | `SELECT owner, balance FROM wallets WHERE wallet_id = 1;` | Asha 350.00 |
| 3 | W2 | `UPDATE wallets SET balance = balance - 50 WHERE wallet_id = 1;` | saved: the real balance is now 300 |
| 4 | W1 | the same `SELECT` again | still **350.00** |
| 5 | W1 | `COMMIT;` then the `SELECT` again | **300.00** |

Window 1 works on a frozen picture until it commits.

### 3. Locks: one row, two writers

| Order | Window | Statement | What happens |
|---|---|---|---|
| 1 | W1 | `BEGIN;` | |
| 2 | W1 | `UPDATE wallets SET balance = balance - 10 WHERE wallet_id = 1;` | no commit yet, so Postgres keeps a **lock** on Asha's row |
| 3 | W2 | `UPDATE wallets SET balance = balance + 10 WHERE wallet_id = 1;` | it cannot change the row: it **waits** (DBeaver's bottom bar shows 0%; psql shows nothing) |
| 4 | W1 | `COMMIT;` | the lock is released |
| 5 | W2 | | finishes at once: `UPDATE 1` |

In the video, window 2's execute time was 22 seconds: all that time, it was waiting. Asha is back to 300 (−10, then +10).

### 4. A deadlock

| Order | Window | Statement | What happens |
|---|---|---|---|
| 1 | W1 | `BEGIN;` then `UPDATE wallets SET balance = balance - 10 WHERE wallet_id = 1;` | W1 locks Asha's row |
| 2 | W2 | `BEGIN;` then `UPDATE wallets SET balance = balance - 10 WHERE wallet_id = 2;` | W2 locks Rahul's row |
| 3 | W1 | `UPDATE wallets SET balance = balance + 10 WHERE wallet_id = 2;` | W1 waits for W2 |
| 4 | W2 | `UPDATE wallets SET balance = balance + 10 WHERE wallet_id = 1;` | W2 waits for W1: nobody can move |

Postgres notices this in about one second and stops one of them with an error:

```text
ERROR: deadlock detected   (SQLSTATE 40P01)
  Detail: Process ... waits for ShareLock on transaction ...; blocked by process ....
```

The other window carries on (`UPDATE 1`). Then `ROLLBACK;` in both windows, and check:

```sql
SELECT owner, balance, (SELECT sum(balance) FROM wallets) AS total
FROM wallets ORDER BY wallet_id;
```

| owner | balance | total |
|---|---|---|
| Asha | 300.00 | 700.00 |
| Rahul | 400.00 | 700.00 |

### 5. The deadlock as a picture

```text
W1  holds row 1  ---- wants ---->  row 2
W2  holds row 2  ---- wants ---->  row 1
(each waits for the other: a circle)
```

Window 1 holds row 1 and wants row 2. Window 2 holds row 2 and wants row 1. The arrows make a circle, and a circle of waiting can never end on its own.

The fix is simple: always change rows in the **same order**, for example the smaller `wallet_id` first. Then the second window just waits its turn, and there is no circle.

## Common mistakes

1. **Leaving a transaction open.** Its locks stay, and other people wait. Keep transactions short, and commit soon.
2. **Changing rows in a different order in different places.** That is how deadlocks start. Use one fixed order.
3. **Giving up after a deadlock error.** Nothing is broken. Roll back, and simply run the transaction again.

## Try it yourself

1. Window 1 updates Rahul, then Asha. Window 2 updates Asha, then Rahul, at the same time. What can happen, and how do you fix it? (The video's task.)
2. In W1 run `BEGIN;` and an `UPDATE` on Rahul, but do not commit. In W2 run `SELECT owner, balance FROM wallets;`. Does W2 wait? (Then `ROLLBACK;` in W1.)
3. Which isolation level would you use for a long report that must add up to the same total from start to end?

## Answers

1. A **deadlock**: each window holds one row and waits for the other's. Postgres stops one with `deadlock detected` (40P01). The fix: both change the rows in the same order, for example the smaller `wallet_id` (Asha, 1) first.
2. No. A lock only makes other **writers** of that row wait. Readers do not wait: W2 sees the last saved balance (Rahul 400.00).
3. `REPEATABLE READ`: the whole report reads one frozen picture.

## Next

[M13-B03 · Chai Corner Online Orders](../m13-b03-chai-corner-online-orders/)
