# M15-L07 · Top N per Group, and Removing Duplicates

> Video: Module 15, Lesson 7. Watch it first, then follow along here.

## What you'll learn

- How `ROW_NUMBER` with `PARTITION BY` finds the **top N in each group**
- Why you number the rows in a CTE first, then keep `rn <= N`
- How to find duplicate rows: number each email, and copy 2 is the extra one
- How to **delete** the extra copies and keep the first sign-up of each email
- Three mistakes: `rn` in the same `WHERE`, no partition, and `DISTINCT` instead of `DELETE`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- In particular, run [M15-L06's `setup.sql`](../m15-l06-first-value-last-value-and-ntile/setup.sql): it creates the `newsletter` table with 6 sign-ups.
- This lesson **changes data**: it deletes 2 rows from `newsletter`. `setup.sql` here is that same delete, for people rebuilding the database.

## Files in this folder

| File | What it is |
|---|---|
| `top_n_dupes.sql` | Every query from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | The change this lesson leaves in the database: deletes the 2 duplicate sign-ups (safe to run again) |

## Follow along

Which two items sell best in each branch? And how do you clean up people who signed up twice? Number the rows, keep the top ones, and delete the extra copies. One tool does both jobs: `ROW_NUMBER`.

```text
PARTITION BY branch -> counting starts again at 1 in every branch: each branch has its own best seller
PARTITION BY email  -> the first sign-up gets 1, a second copy gets 2: the row to delete
```

### 1. Top two in each branch

A CTE `cups` adds up the cups for each item in each branch. Then `ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC)` counts 1, 2, 3 from each branch's best seller down. Finally, keep only `rn <= 2`.

```sql
WITH cups AS (
  SELECT branch, item, SUM(qty) AS sold
  FROM sales GROUP BY 1, 2
), ranked AS (
  SELECT branch, item, sold,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC) AS rn
  FROM cups
)
SELECT branch, item, sold, rn FROM ranked
WHERE rn <= 2 ORDER BY branch, rn;
```

You should see:

| branch | item | sold | rn |
|---|---|---|---|
| Delhi | Masala Chai | 235 | 1 |
| Delhi | Cutting Chai | 226 | 2 |
| Mumbai | Masala Chai | 456 | 1 |
| Mumbai | Cutting Chai | 393 | 2 |
| Pune | Masala Chai | 691 | 1 |
| Pune | Cutting Chai | 675 | 2 |

Every branch shows its top two: Masala Chai first, then Cutting Chai.

### 2. The duplicate sign-ups

```sql
SELECT id, email, joined_on
FROM newsletter
ORDER BY email, id;
```

You should see 6 sign-ups; Asha and Ravi joined twice:

| id | email | joined_on |
|---|---|---|
| 1 | asha@mail.com | 2026-03-01 |
| 3 | asha@mail.com | 2026-03-04 |
| 6 | kabir@mail.com | 2026-03-08 |
| 4 | meena@mail.com | 2026-03-05 |
| 2 | ravi@mail.com | 2026-03-02 |
| 5 | ravi@mail.com | 2026-03-07 |

### 3. Number the copies

`PARTITION BY email ORDER BY id`: the first sign-up of each email gets 1, any extra copy gets 2.

```sql
SELECT id, email, joined_on,
  ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS copy
FROM newsletter
ORDER BY email, id;
```

You should see `copy` = 1, 2, 1, 1, 1, 2: ids 3 and 5 are the extra copies.

### 4. Delete the extra copies

`DELETE FROM newsletter WHERE id IN (...)`. The subquery numbers the copies and picks every id where `copy > 1`.

```sql
DELETE FROM newsletter
WHERE id IN (
  SELECT id FROM (
    SELECT id,
      ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS copy
    FROM newsletter
  ) c
  WHERE copy > 1
);
```

DBeaver says **Updated Rows: 2** (psql prints `DELETE 2`): the two extra copies. Check:

```sql
SELECT id, email, joined_on
FROM newsletter
ORDER BY email, id;
```

| id | email | joined_on |
|---|---|---|
| 1 | asha@mail.com | 2026-03-01 |
| 6 | kabir@mail.com | 2026-03-08 |
| 4 | meena@mail.com | 2026-03-05 |
| 2 | ravi@mail.com | 2026-03-02 |

Each email appears once. Asha keeps her first sign-up, from 1 March.

## Common mistakes

All three were run for real in the video.

1. **Filtering `rn` in the same query.**

   ```sql
   WITH cups AS (
     SELECT branch, item, SUM(qty) AS sold
     FROM sales GROUP BY 1, 2
   )
   SELECT branch, item, sold,
     ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC) AS rn
   FROM cups
   WHERE rn <= 2;
   ```

   ```text
   ERROR: column "rn" does not exist   (SQLSTATE 42703)
   ```

   Fix: number the rows in a CTE first (`ranked`), then filter outside, as in step 1.

2. **Leaving out the partition.** `ROW_NUMBER() OVER (ORDER BY sold DESC)` in the `ranked` step gives the top two **overall**, both from Pune:

   | branch | item | sold | rn |
   |---|---|---|---|
   | Pune | Masala Chai | 691 | 1 |
   | Pune | Cutting Chai | 675 | 2 |

   Fix: add `PARTITION BY branch`.

3. **Using `DISTINCT` to remove duplicates.**

   ```sql
   SELECT DISTINCT email
   FROM newsletter
   ORDER BY email;
   ```

   It shows 4 emails, but `DISTINCT` only hides the copies in the result: the table still had 6 rows. Use `DELETE` to really remove them.

## Try it yourself

1. Show the best-selling item in each branch. (The video's task.)
2. Show the top **three** items in each branch.
3. Count the rows in `newsletter` now. Then run `setup.sql` again: how many rows does it delete?

## Answers

1. Keep `rn = 1`:

   ```sql
   WITH cups AS (
     SELECT branch, item, SUM(qty) AS sold
     FROM sales GROUP BY 1, 2
   ), ranked AS (
     SELECT branch, item, sold,
       ROW_NUMBER() OVER (PARTITION BY branch ORDER BY sold DESC) AS rn
     FROM cups
   )
   SELECT branch, item, sold FROM ranked WHERE rn = 1 ORDER BY branch;
   ```

   | branch | item | sold |
   |---|---|---|
   | Delhi | Masala Chai | 235 |
   | Mumbai | Masala Chai | 456 |
   | Pune | Masala Chai | 691 |

2. Change `rn <= 2` to `rn <= 3` in step 1: 9 rows, three per branch.

3. 4 rows. Running the delete again removes 0 rows, because there are no copies left.

## Next

[M16-L01 · Views: Saving a Query as a Virtual Table](../../m16-views-functions-and-json/m16-l01-views-saving-a-query-as-a-virtual-table/)
