# M16-L02 · Materialized Views: Saving the Result for Speed

> Video: Module 16, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- What a **materialized view** is: a view that saves its result rows, not just the query
- How to create one and read it like a table
- How to measure the speed difference with `EXPLAIN ANALYZE`
- Why the saved rows go **stale**, and how `REFRESH MATERIALIZED VIEW` fixes it
- Three mistakes: inserting into it, `CONCURRENTLY` without a unique index, and `DROP VIEW`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the `branch_cups` view from [M16-L01](../m16-l01-views-saving-a-query-as-a-virtual-table/) and the `newsletter` table (4 sign-ups after [M15-L07](../../m15-window-functions/m15-l07-top-n-per-group-and-removing-duplicates/)).
- This lesson **changes the database**: three materialized views, a unique index, and one new newsletter sign-up (Zoya).

## Files in this folder

| File | What it is |
|---|---|
| `materialized_views.sql` | Every statement from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | What this lesson leaves in the database: `branch_cups_mv` (+ unique index), `signups_mv`, `item_cups_mv`, Zoya's sign-up. Safe to run again |

## Follow along

A view runs its query every time you use it. On a big table, that can be slow. So run the query once, save the rows it gives back, and read those saved rows fast.

```text
normal view:       stores only the query -> every SELECT reads all 6,028 sales again
materialized view: runs the query once, stores the answer (3 rows) -> every SELECT reads 3 rows
```

### 1. Create a materialized view

`CREATE MATERIALIZED VIEW`, a name (`branch_cups_mv`), `AS`, and the same kind of `SELECT` as before.

```sql
CREATE MATERIALIZED VIEW branch_cups_mv AS
SELECT branch, SUM(qty) AS cups
FROM sales
GROUP BY branch;
```

This time DBeaver says **Updated Rows: 3** (psql prints `SELECT 3`): the three answer rows are really saved.

```sql
SELECT * FROM branch_cups_mv
ORDER BY branch;
```

| branch | cups |
|---|---|
| Delhi | 1269 |
| Mumbai | 2439 |
| Pune | 3827 |

### 2. Is it really faster?

`EXPLAIN ANALYZE` runs a query and shows how it worked.

```sql
EXPLAIN ANALYZE
SELECT * FROM branch_cups;
```

On the normal view, PostgreSQL scans all 6,028 sales (`Seq Scan on sales ... rows=6028`). In the video it took about **2.2 ms** (`Execution Time: 2.237 ms`).

```sql
EXPLAIN ANALYZE
SELECT * FROM branch_cups_mv;
```

The materialized view only reads the 3 saved rows (`Seq Scan on branch_cups_mv ... rows=3`), in **0.17 ms**: more than ten times faster. Your timings will differ, but the gap is the point.

### 3. Stale, then refresh

The saved rows do not update by themselves. A small one, `signups_mv`, counts the people on the newsletter:

```sql
CREATE MATERIALIZED VIEW signups_mv AS
SELECT COUNT(*) AS people FROM newsletter;

SELECT * FROM signups_mv;
```

It says `4`. Now add one more person, Zoya, and select again:

```sql
INSERT INTO newsletter (email, joined_on)
VALUES ('zoya@mail.com', '2026-03-10');

SELECT * FROM signups_mv;
```

Still `4`. The saved result is old: it is **stale**. Refresh it:

```sql
REFRESH MATERIALIZED VIEW signups_mv;

SELECT * FROM signups_mv;
```

Now it says `5`. `REFRESH` runs the query again and saves the new answer.

## Common mistakes

All three were run for real in the video.

1. **Inserting rows into it.**

   ```sql
   INSERT INTO branch_cups_mv (branch, cups) VALUES ('Goa', 500);
   ```

   ```text
   ERROR: cannot change materialized view "branch_cups_mv"   (SQLSTATE 42809)
   ```

   Fix: put the row in the real table, then refresh.

2. **`REFRESH ... CONCURRENTLY` without a unique index.** `CONCURRENTLY` lets people keep reading while it updates.

   ```sql
   REFRESH MATERIALIZED VIEW CONCURRENTLY branch_cups_mv;
   ```

   ```text
   ERROR: cannot refresh materialized view "public.branch_cups_mv" concurrently   (SQLSTATE 55000)
   HINT: Create a unique index with no WHERE clause on one or more columns of the materialized view.
   ```

   Fix: create a unique index on `branch`, and then it works:

   ```sql
   CREATE UNIQUE INDEX ON branch_cups_mv (branch);
   REFRESH MATERIALIZED VIEW CONCURRENTLY branch_cups_mv;
   ```

3. **Using `DROP VIEW`.**

   ```sql
   DROP VIEW signups_mv;
   ```

   ```text
   ERROR: "signups_mv" is not a view   (SQLSTATE 42809)
   HINT: Use DROP MATERIALIZED VIEW to remove a materialized view.
   ```

   Fix: `DROP MATERIALIZED VIEW signups_mv;` (do not run it here: the course keeps `signups_mv`).

## Try it yourself

1. Make a materialized view of the cups for each item, and show the top three. (The video's task.)
2. Add a sale to `sales` in a transaction, compare `branch_cups` and `branch_cups_mv`, then `ROLLBACK`. Which one changed?
3. Run `EXPLAIN ANALYZE` on `item_cups` (the view) and on `item_cups_mv`. How many rows does each read?

## Answers

1. ```sql
   CREATE MATERIALIZED VIEW item_cups_mv AS
   SELECT item, SUM(qty) AS cups
   FROM sales
   GROUP BY item;

   SELECT * FROM item_cups_mv
   ORDER BY cups DESC
   LIMIT 3;
   ```

   | item | cups |
   |---|---|
   | Masala Chai | 1382 |
   | Cutting Chai | 1294 |
   | Vada Pav | 815 |

2. Only the normal view `branch_cups` changes; `branch_cups_mv` keeps its saved rows until you refresh it.

3. The view scans all 6,028 sales rows; the materialized view reads its 10 saved rows.

## Next

[M16-L03 · Writing Your Own Functions and Procedures](../m16-l03-writing-your-own-functions-and-procedures/)
