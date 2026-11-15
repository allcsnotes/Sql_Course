# M07-L01 · COUNT, SUM, AVG, MIN, MAX

> Video: Module 7, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- Aggregate functions squeeze many rows into one number
- `COUNT(*)` counts the rows and `SUM` adds up a column
- `AVG` gives the average; wrap it in `ROUND`
- `MIN` and `MAX` give the smallest and the biggest, even for dates
- `WHERE` runs first, so the functions only see the rows it keeps
- Three beginner mistakes: a plain column next to `MAX`, `AVG` inside `WHERE`, and `SUM` on text

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). Step 4 needs the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `aggregates.sql` | The seven queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and their fixes |

## Follow along

Chai Corner has ten items on its menu. How many items are there? What do they cost in total? Which one is the cheapest? Each question needs one answer, not ten rows. Five functions do this job. They are called **aggregate functions**: they squeeze many rows into one number.

The ten prices are 35, 80, 20, 40, 30, 60, 30, 25, 30 and 70.

### 1. COUNT and SUM

`COUNT(*)` counts the rows:

```sql
SELECT COUNT(*) AS total_items FROM menu_items;
```

You should see `10`. Only one row comes back, with one number in it.

`SUM` adds up a column:

```sql
SELECT SUM(price) AS menu_total FROM menu_items;
```

You should see `420`: 35 + 80 + 20 and so on.

### 2. AVG, the average

`AVG` adds up the prices, then divides by how many there are:

```sql
SELECT AVG(price) AS average_price_of_one_item FROM menu_items;
```

You should see `42.0000000000000000`. 420 divided by 10 is 42, but PostgreSQL shows sixteen zeros after the point. Wrap it in `ROUND` with two places:

```sql
SELECT ROUND(AVG(price), 2) AS average_price FROM menu_items;
```

You should see `42.00`.

### 3. MIN and MAX

`MIN` gives the smallest value and `MAX` the biggest:

```sql
SELECT MIN(price) AS cheapest, MAX(price) AS dearest FROM menu_items;
```

You should see:

| cheapest | dearest |
|---------:|--------:|
| 20 | 80 |

The cheapest item costs ₹20 and the dearest ₹80. They work on dates too:

```sql
SELECT MIN(joined_on) AS first_joined, MAX(joined_on) AS last_joined FROM customers;
```

You should see:

| first_joined | last_joined |
|--------------|-------------|
| 2024-11-11 | 2026-06-10 |

The smallest date is the first customer who joined (Asha). The biggest is the newest customer (Kiran).

### 4. Add a WHERE filter

```sql
SELECT COUNT(*) AS chai_items, ROUND(AVG(price), 2) AS avg_chai FROM menu_items WHERE category = 'Chai';
```

You should see:

| chai_items | avg_chai |
|-----------:|---------:|
| 3 | 26.67 |

`WHERE` runs first. It keeps only the three Chai items (20, 30, 30). Then `COUNT` and `AVG` work on just those three rows.

## Common mistakes

The queries are in `mistakes.sql`.

**1. A plain column next to MAX.** There are ten names, but only one row comes back, so PostgreSQL refuses:

```sql
SELECT name, MAX(price) AS top_price FROM menu_items;
```

```text
SQL Error [42803]: ERROR: column "menu_items.name" must appear in the GROUP BY clause or be used in an aggregate function
```

To get the top item, sort by price and take one row:

```sql
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 1;
```

You should see `Cold Coffee | 80`.

**2. AVG inside a WHERE filter.** The filter checks one row at a time, so it cannot see the average yet:

```sql
SELECT name, price FROM menu_items WHERE price > AVG(price);
```

```text
SQL Error [42803]: ERROR: aggregate functions are not allowed in WHERE
```

Find the average first (42), then filter with that number:

```sql
SELECT name, price FROM menu_items WHERE price > 42;
```

You should see Cold Coffee 80, Maggi 60 and Veg Sandwich 70. Later in the course you will learn to do both in one query.

**3. SUM on text.** You cannot add up names:

```sql
SELECT SUM(name) AS total_names FROM menu_items;
```

```text
SQL Error [42883]: ERROR: function sum(character varying) does not exist
```

`SUM` and `AVG` need numbers. To count the rows, use `COUNT(*)`.

## Try it yourself

1. Find the gap between the dearest item and the cheapest item. Guess first, then run it.
2. How many Snack items are there, and what do they cost in total?
3. Which date did the first customer of 2025 join on?

## Answers

1. The task from the video:

   ```sql
   SELECT MAX(price) - MIN(price) AS price_gap FROM menu_items;
   ```

   It gives `60` (80 minus 20).
2. `SELECT COUNT(*), SUM(price) FROM menu_items WHERE category = 'Snack';` gives 5 and 220.
3. `SELECT MIN(joined_on) FROM customers WHERE joined_on >= '2025-01-01';` gives 2025-01-09 (Rahul).

## Next

[M07-L02 · COUNT(*), COUNT(column) and COUNT(DISTINCT)](../m07-l02-count-star-column-and-distinct/)
