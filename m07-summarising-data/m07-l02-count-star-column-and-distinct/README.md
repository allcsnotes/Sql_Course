# M07-L02 · COUNT(*), COUNT(column) and COUNT(DISTINCT)

> Video: Module 7, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- `COUNT(*)` counts every row, no matter what is inside
- `COUNT(column)` skips the NULLs
- `COUNT(DISTINCT column)` counts each different value once
- Three beginner mistakes: `COUNT(DISTINCT *)`, `SUM` of no rows is NULL, and counting the wrong thing

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need the `email` column from [M03-L06](../../m03-your-first-queries/m03-l06-null-the-unknown-value/) and the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `three_counts.sql` | The five queries from the video, in order, with their real results |
| `mistakes.sql` | The beginner mistakes and the fix for mistake 2 |

## Follow along

Count the customers and you get 15. Count their emails and you get 11. Count the categories and you might get 10, or 3. Why do the counts not match? There are three ways to count, and each one answers a different question.

### 1. COUNT(*)

`COUNT(*)` counts every row, no matter what is inside:

```sql
SELECT COUNT(*) AS all_rows FROM customers;
```

You should see `15`. Even a row with NULLs in it still counts.

### 2. COUNT of a column

Put a column name inside, and `COUNT` skips the NULLs:

```sql
SELECT COUNT(email) AS with_email FROM customers;
```

You should see `11`, not 15: four customers have no email.

Put both side by side, and take one from the other:

```sql
SELECT COUNT(*) AS all_rows, COUNT(email) AS with_email, COUNT(*) - COUNT(email) AS missing FROM customers;
```

You should see:

| all_rows | with_email | missing |
|---------:|-----------:|--------:|
| 15 | 11 | 4 |

15 rows, 11 emails, so 4 emails are missing.

### 3. COUNT DISTINCT

`DISTINCT` counts each different value only once:

```sql
SELECT COUNT(category) AS all_values, COUNT(DISTINCT category) AS different_values FROM menu_items;
```

You should see:

| all_values | different_values |
|-----------:|-----------------:|
| 10 | 3 |

The menu has ten category values, but only three different ones: Chai, Coffee and Snack.

Prices work the same way:

```sql
SELECT COUNT(price) AS all_prices, COUNT(DISTINCT price) AS different_prices FROM menu_items;
```

You should see:

| all_prices | different_prices |
|-----------:|-----------------:|
| 10 | 8 |

There are ten prices, but 30 appears three times, so there are only eight different prices.

| Count | What it counts | customers / menu |
|-------|----------------|------------------|
| `COUNT(*)` | every row | 15 customers |
| `COUNT(email)` | values that are not NULL | 11 emails |
| `COUNT(DISTINCT category)` | different values | 3 categories |

## Common mistakes

The queries are in `mistakes.sql`.

**1. DISTINCT with a star.** You cannot write `COUNT(DISTINCT *)`:

```sql
SELECT COUNT(DISTINCT *) AS different_rows FROM menu_items;
```

```text
SQL Error [42601]: ERROR: syntax error at or near "*"
  Position: 23
```

Name one column instead.

**2. Counting nothing.** When no rows match, `COUNT` gives 0 but `SUM` gives NULL:

```sql
SELECT COUNT(*) AS how_many, SUM(price) AS total FROM menu_items WHERE price > 100;
```

| how_many | total |
|---------:|-------|
| 0 | [NULL] |

Wrap the sum in `COALESCE`, with 0 as the backup:

```sql
SELECT COUNT(*) AS how_many, COALESCE(SUM(price), 0) AS total FROM menu_items WHERE price > 100;
```

You should see `0 | 0`.

**3. Counting the wrong thing.** To count customers, use `COUNT(*)`. `COUNT(email)` only counts the customers who have an email (11, not 15).

## Try it yourself

1. In how many different years did customers join? Use `COUNT(DISTINCT ...)` with `EXTRACT`. Guess first, then run it.
2. How many customers who joined in 2025 have an email?
3. How many different cities are in `branches`?

## Answers

1. The task from the video:

   ```sql
   SELECT COUNT(DISTINCT EXTRACT(YEAR FROM joined_on)) AS join_years FROM customers;
   ```

   It gives `3` (2024, 2025 and 2026). In the video DBeaver underlines `joined_on` in red, but the query runs fine.
2. `SELECT COUNT(email) FROM customers WHERE EXTRACT(YEAR FROM joined_on) = 2025;` gives 7.
3. `SELECT COUNT(DISTINCT city) FROM branches;` gives 10.

## Next

[M07-L03 · GROUP BY: Making Piles](../m07-l03-group-by-making-piles/)
