# M03-L03 · WHERE: Keeping Only the Rows You Want

> Video: Module 3, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- How `WHERE` keeps only the rows that pass a test
- The order the database works in: `FROM`, then `WHERE`, then `SELECT`
- The six comparison signs: `=`, `<>`, `<`, `>`, `<=`, `>=`
- How to filter text and dates (single quotes, dates as year-month-day)
- Three beginner mistakes with text: no quotes, wrong capitals, double quotes

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- A DBeaver SQL editor on `chai_corner`, or psql with `\c chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The six queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three text mistakes, with the real errors |

## Follow along

So far every query gave back all ten rows. Often you only want some of them, like a customer asking: which items cost more than ₹40?

### 1. Your first WHERE

After `FROM menu_items`, write `WHERE`, the column, a sign and a value:

```sql
SELECT name, price FROM menu_items WHERE price > 40;
```

The database checks every row, one by one: is the price greater than 40? Bun Maska costs 35: no, dropped. Cold Coffee costs 80: yes, kept. You should see three rows:

| name | price |
|---|---|
| Cold Coffee | 80 |
| Maggi | 60 |
| Veg Sandwich | 70 |

Think of `WHERE` as a filter:

```text
FROM menu_items   ->  WHERE price > 40   ->  SELECT name, price
(pick the table)      (keep rows that pass)   (pick the columns)
```

### 2. The six comparison signs

Equals is just **one** `=` sign:

```sql
SELECT name, price FROM menu_items WHERE price = 30;
```

| name | price |
|---|---|
| Ginger Chai | 30 |
| Masala Chai | 30 |
| Vada Pav | 30 |

Less than or equal is `<` then `=`:

```sql
SELECT name, price FROM menu_items WHERE price <= 30;
```

Five rows: Cutting Chai (20) and Samosa (25) are cheaper, so they join the three at ₹30.

Not equal is `<` then `>`:

```sql
SELECT name, price FROM menu_items WHERE price <> 30;
```

The other seven rows: Bun Maska, Cold Coffee, Cutting Chai, Filter Coffee, Maggi, Samosa, Veg Sandwich. Three plus seven makes all ten.

| Sign | Meaning |
|---|---|
| `=` | equals |
| `<>` | not equal |
| `<` | less than |
| `>` | greater than |
| `<=` | less than or equal |
| `>=` | greater than or equal |

### 3. Filtering text

Find the Pune branch:

```sql
SELECT * FROM branches WHERE city = 'Pune';
```

| branch_id | city | opened_on |
|---|---|---|
| 1 | Pune | 2019-04-12 |

One row: branch 1, opened in April 2019. The rule: **numbers go in as they are; text always goes inside single quotes.**

### 4. Filtering dates

Which branches opened in 2022 or later?

```sql
SELECT * FROM branches WHERE opened_on >= '2022-01-01';
```

Write dates as year, month, day: `'2022-01-01'`, in single quotes. You should see four rows:

| branch_id | city | opened_on |
|---|---|---|
| 7 | Kolkata | 2022-03-14 |
| 8 | Jaipur | 2022-11-05 |
| 9 | Ahmedabad | 2023-06-19 |
| 10 | Kochi | 2024-01-29 |

For dates, greater simply means later.

## Common mistakes

- **Forgetting the quotes** (`WHERE city = Pune`):
  ```text
  ERROR: column "pune" does not exist
  ```
  Without quotes, PostgreSQL thinks Pune is the name of a column.
- **Small letters** (`WHERE city = 'pune'`): no error, but **0 rows**. Text must match exactly, and a capital P is not a small p.
- **Double quotes** (`WHERE city = "Pune"`):
  ```text
  ERROR: column "Pune" does not exist
  ```
  In SQL, double quotes are for column names. Single quotes are for text.

## Try it yourself

1. The video's task: show the name and price of every item that costs less than 30. How many rows come back?
2. Show every customer who joined before 2025 (before `'2025-01-01'`).
3. Show the menu item called Samosa, with all its columns.

## Answers

1. ```sql
   SELECT name, price FROM menu_items WHERE price < 30;
   ```
   **2 rows**: Cutting Chai 20, Samosa 25.
2. ```sql
   SELECT * FROM customers WHERE joined_on < '2025-01-01';
   ```
   3 rows: Asha (2024-11-11), Lukas (2024-11-14), Priya (2024-12-02).
3. ```sql
   SELECT * FROM menu_items WHERE name = 'Samosa';
   ```
   1 row: 8, Samosa, 25.

## Next

[M03-L04 · AND, OR, NOT and Brackets](../m03-l04-and-or-not-and-brackets/)
