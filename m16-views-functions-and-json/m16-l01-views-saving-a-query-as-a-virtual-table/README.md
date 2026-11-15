# M16-L01 · Views: Saving a Query as a Virtual Table

> Video: Module 16, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a **view** is: a saved query with a name, used just like a table
- Why a view stores no rows, and always gives a fresh answer
- How to create a view, select from it and filter it
- How `CREATE OR REPLACE VIEW` changes a view, and what it cannot do
- Three mistakes: creating twice, dropping a column, and inserting into a view

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads the `sales` table (6,028 rows) and **creates two views**, `branch_cups` and `item_cups`. Later lessons and Build 4 use them.

## Files in this folder

| File | What it is |
|---|---|
| `views.sql` | Every statement from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | The views this lesson leaves in the database (final `branch_cups` and `item_cups`). Safe to run again |

## Follow along

Some queries you type again and again, like the cups sold in each branch. Save the query once, give it a name, and use that name like a table. A saved query like this is called a **view**.

```text
table: stores real rows (sales holds every sale: 6,028 rows)
view:  stores no rows, only the query; each SELECT runs that query again, so the answer is always fresh
```

### 1. Create a view

`CREATE VIEW`, a name (`branch_cups`), the keyword `AS`, then a normal `SELECT`: the cups and the number of sales for each branch.

```sql
CREATE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups, COUNT(*) AS sales
FROM sales
GROUP BY branch;
```

DBeaver says **Updated Rows: 0** (psql prints `CREATE VIEW`): a view copies no data. Only the query is saved.

### 2. Use it like a table

```sql
SELECT * FROM branch_cups
ORDER BY branch;
```

You should see:

| branch | cups | sales |
|---|---|---|
| Delhi | 1269 | 1022 |
| Mumbai | 2439 | 1952 |
| Pune | 3827 | 3054 |

Filter it too:

```sql
SELECT branch, cups
FROM branch_cups
WHERE cups > 2000
ORDER BY cups DESC;
```

| branch | cups |
|---|---|
| Pune | 3827 |
| Mumbai | 2439 |

The long query hides behind one short name.

### 3. Add a column with CREATE OR REPLACE

```sql
CREATE OR REPLACE VIEW branch_cups AS
SELECT branch, SUM(qty) AS cups, COUNT(*) AS sales,
  SUM(qty * price) AS revenue
FROM sales
GROUP BY branch;

SELECT * FROM branch_cups
ORDER BY revenue DESC;
```

You should see:

| branch | cups | sales | revenue |
|---|---|---|---|
| Pune | 3827 | 3054 | 138705 |
| Mumbai | 2439 | 1952 | 87545 |
| Delhi | 1269 | 1022 | 45015 |

The new `revenue` column is there. Pune has the most revenue.

## Common mistakes

All three were run for real in the video.

1. **Running `CREATE VIEW` twice.**

   ```text
   ERROR: relation "branch_cups" already exists   (SQLSTATE 42P07)
   ```

   Fix: use `CREATE OR REPLACE VIEW`; the new query replaces the old one.

2. **Removing a column with `OR REPLACE`.**

   ```sql
   CREATE OR REPLACE VIEW branch_cups AS
   SELECT branch, SUM(qty) AS cups
   FROM sales
   GROUP BY branch;
   ```

   ```text
   ERROR: cannot drop columns from view   (SQLSTATE 42P16)
   ```

   Fix: you can only add new columns at the end. To remove one, `DROP VIEW branch_cups;` and create it again.

3. **Inserting rows into this view.**

   ```sql
   INSERT INTO branch_cups (branch, cups)
   VALUES ('Goa', 50);
   ```

   ```text
   ERROR: cannot insert into view "branch_cups"   (SQLSTATE 55000)
   DETAIL: Views containing GROUP BY are not automatically updatable.
   ```

   Fix: insert into the real table, `sales`, and the view will show the new rows.

## Try it yourself

1. Make a view of the cups sold for each item, and find the top seller. (The video's task.)
2. Select only the items from `item_cups` that sold fewer than 600 cups.
3. Why does `SELECT * FROM branch_cups` always match the `sales` table, even after new sales are added?

## Answers

1. ```sql
   CREATE VIEW item_cups AS
   SELECT item, SUM(qty) AS cups
   FROM sales
   GROUP BY item;

   SELECT * FROM item_cups
   ORDER BY cups DESC;
   ```

   10 rows; the top seller is Masala Chai with 1382 cups (then Cutting Chai 1294, Vada Pav 815).

2. `SELECT * FROM item_cups WHERE cups < 600 ORDER BY cups;` gives Veg Sandwich 297, Cold Coffee 503, Maggi 516, Filter Coffee 541.

3. A view stores only the query. Each `SELECT` runs it again on the current `sales` rows.

## Next

[M16-L02 · Materialized Views: Saving the Result for Speed](../m16-l02-materialized-views-saving-the-result-for-speed/)
