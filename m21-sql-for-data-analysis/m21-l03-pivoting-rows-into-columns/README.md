# M21-L03 · Pivoting Rows into Columns

> Video: Module 21, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What "long" and "wide" results are, and why a wide grid is easier to read
- Pivoting with `SUM(CASE WHEN ... THEN qty ELSE 0 END)`: one column per category
- The shorter way with `SUM(qty) FILTER (WHERE ...)`, plus a total column
- Months as columns, using `date_trunc` from the last lesson
- Three pivot mistakes: a `CASE` without `SUM`, a value spelled differently, and a new category that is quietly left out

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses the `sales` table (branch, category, qty, sold_at). It makes no changes to the database.

## Files in this folder

| File | What it is |
|------|------------|
| `pivoting.sql` | Every query from the video, in order, with the real results as comments |

## Follow along

### 1. The idea

- **Long:** one row for every branch and category. Nine rows.
- **Wide:** one row per branch, and one column per category. Three rows, easy to read.

To build each column, add up only the rows that belong to it. That's all a pivot is. Pivoting means turning rows into columns.

### 2. The long version

```sql
SELECT branch, category, SUM(qty) AS cups
FROM sales
GROUP BY branch, category
ORDER BY branch, category;
```

You should see 9 rows (3 branches × 3 categories):

| branch | category | cups |
|--------|----------|------|
| Delhi | Chai | 559 |
| Delhi | Coffee | 176 |
| Delhi | Snack | 534 |
| Mumbai | Chai | 1093 |
| Mumbai | Coffee | 348 |
| Mumbai | Snack | 998 |
| Pune | Chai | 1730 |
| Pune | Coffee | 520 |
| Pune | Snack | 1577 |

To compare Pune with Delhi on chai, your eyes have to jump between rows: 1730 and 559.

### 3. Turn it with CASE

`GROUP BY branch` alone, so each branch is one row. For the chai column: when the category is Chai, take the cups, otherwise take zero. `SUM` adds them up. Copy that line for Coffee and Snack:

```sql
SELECT branch,
       SUM(CASE WHEN category = 'Chai'   THEN qty ELSE 0 END) AS chai,
       SUM(CASE WHEN category = 'Coffee' THEN qty ELSE 0 END) AS coffee,
       SUM(CASE WHEN category = 'Snack'  THEN qty ELSE 0 END) AS snack
FROM sales
GROUP BY branch
ORDER BY branch;
```

You should see:

| branch | chai | coffee | snack |
|--------|------|--------|-------|
| Delhi | 559 | 176 | 534 |
| Mumbai | 1093 | 348 | 998 |
| Pune | 1730 | 520 | 1577 |

Three rows, and every number sits where you expect it.

### 4. The shorter way: FILTER

`SUM(qty) FILTER (WHERE category = 'Chai')` reads almost like English and gives exactly the same numbers. Add a plain `SUM` at the end for a total column:

```sql
SELECT branch,
       SUM(qty) FILTER (WHERE category = 'Chai')   AS chai,
       SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee,
       SUM(qty) FILTER (WHERE category = 'Snack')  AS snack,
       SUM(qty) AS total
FROM sales
GROUP BY branch
ORDER BY branch;
```

You should see:

| branch | chai | coffee | snack | total |
|--------|------|--------|-------|-------|
| Delhi | 559 | 176 | 534 | 1269 |
| Mumbai | 1093 | 348 | 998 | 2439 |
| Pune | 1730 | 520 | 1577 | 3827 |

Pune sold 3,827 in all.

### 5. Months as columns

Columns don't have to be categories. Each column here keeps one month, with `date_trunc` from [M21-L02](../m21-l02-date-reports-filling-missing-days-week-and-month-buckets/):

```sql
SELECT category,
       SUM(qty) FILTER (WHERE date_trunc('month', sold_at) = '2026-01-01') AS jan,
       SUM(qty) FILTER (WHERE date_trunc('month', sold_at) = '2026-02-01') AS feb,
       SUM(qty) FILTER (WHERE date_trunc('month', sold_at) = '2026-03-01') AS mar
FROM sales
GROUP BY category
ORDER BY category;
```

You should see:

| category | jan | feb | mar |
|----------|-----|-----|-----|
| Chai | 394 | 1077 | 1911 |
| Coffee | 127 | 341 | 576 |
| Snack | 417 | 1006 | 1686 |

Each row now shows a trend from January to March. Chai grew from 394 to 1,911.

## Common mistakes

- **`CASE` without `SUM` around it.**

  ```sql
  SELECT branch, CASE WHEN category = 'Chai' THEN qty ELSE 0 END AS chai
  FROM sales GROUP BY branch;
  ```

  ```text
  SQL Error [42803]: ERROR: column "sales.category" must appear in the GROUP BY clause or be used in an aggregate function
  ```

  Wrap every `CASE` in `SUM`.
- **A value spelled differently**, like `'chai'` with a small c:

  ```sql
  SELECT branch,
         SUM(qty) FILTER (WHERE category = 'chai') AS chai
  FROM sales
  GROUP BY branch
  ORDER BY branch;
  ```

  You get Delhi, Mumbai and Pune with `NULL` in the chai column. No error, just an empty column. Copy values exactly as they are stored.
- **A new category appears next month**, and the pivot quietly leaves it out. The columns are fixed, so check the long list too.

## Try it yourself

1. Pivot the other way: one row per category, and one column per branch. How many rows?
2. Add a `total` column to the months pivot. What is the total for Chai?
3. Rewrite the months pivot with `SUM(CASE ...)` instead of `FILTER`. Do the numbers change?

## Answers

1. Three rows.
   ```sql
   SELECT category,
          SUM(qty) FILTER (WHERE branch = 'Pune')   AS pune,
          SUM(qty) FILTER (WHERE branch = 'Mumbai') AS mumbai,
          SUM(qty) FILTER (WHERE branch = 'Delhi')  AS delhi
   FROM sales
   GROUP BY category
   ORDER BY category;
   ```
   | category | pune | mumbai | delhi |
   |----------|------|--------|-------|
   | Chai | 1730 | 1093 | 559 |
   | Coffee | 520 | 348 | 176 |
   | Snack | 1577 | 998 | 534 |
2. Add `SUM(qty) AS total`: Chai is 3,382 (394 + 1,077 + 1,911).
3. No. With `ELSE 0` an empty month would show 0 instead of `NULL`, but every month has sales here, so the numbers are the same.

## Next

[M21-L04 · From SQL to a Chart: Exporting to Google Sheets](../m21-l04-from-sql-to-a-chart-exporting-to-google-sheets/)
