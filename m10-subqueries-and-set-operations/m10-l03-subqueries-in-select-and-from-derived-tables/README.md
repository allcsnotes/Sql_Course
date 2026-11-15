# M10-L03 · Subqueries in SELECT and FROM: Derived Tables

> Video: Module 10, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- A subquery in `SELECT`: its one answer becomes a new column on every row
- Doing maths with it: how far each price is from the menu average
- Why `WHERE` cannot see a name made in `SELECT` (`column "order_count" does not exist`)
- A subquery in `FROM` (a **derived table**): a table made on the fly, named with `AS`
- A summary of a summary: the average of per-customer counts

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`, `order_items`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `select_from_subqueries.sql` | Every query of the video, in order, with the result or error as a comment |

## Follow along

### 1. A subquery in SELECT

Put a subquery in the column list, and its answer becomes a new column:

```sql
SELECT name, price,
       (SELECT ROUND(AVG(price)) FROM menu_items) AS menu_avg
FROM menu_items
ORDER BY price DESC;
```

You should see all 10 items with `menu_avg` 42 on every row (Cold Coffee 80 42, Veg Sandwich 70 42, ... Cutting Chai 20 42).

### 2. Maths with it

Price minus the average shows how far each item is from it:

```sql
SELECT name, price,
       price - (SELECT ROUND(AVG(price)) FROM menu_items) AS vs_avg
FROM menu_items
ORDER BY price DESC;
```

| name | price | vs_avg |
|---|---|---|
| Cold Coffee | 80 | 38 |
| Veg Sandwich | 70 | 28 |
| Maggi | 60 | 18 |
| Filter Coffee | 40 | -2 |
| Bun Maska | 35 | -7 |
| Masala Chai | 30 | -12 |
| Ginger Chai | 30 | -12 |
| Vada Pav | 30 | -12 |
| Samosa | 25 | -17 |
| Cutting Chai | 20 | -22 |

Cold Coffee is ₹38 above the average; Cutting Chai is ₹22 below. (The three ₹30 items tie, so their order may differ.)

### 3. The problem

Which customers placed more than 200 orders? Count with `GROUP BY`, then try to filter that count in `WHERE`:

```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders
WHERE order_count > 200
GROUP BY customer_id;
```

```text
SQL Error [42703]: ERROR: column "order_count" does not exist
```

`WHERE` runs before `SELECT` (see [M07-L05](../../m07-summarising-data/m07-l05-the-order-sql-runs-your-query/)), so the new name is not made yet. `HAVING` would work here, but there is another way that works for any step: a subquery in `FROM`.

### 4. A subquery in FROM

Put the whole counting query inside brackets, right after `FROM`, and give it a name with `AS`:

```sql
SELECT customer_id, order_count
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS per_customer
WHERE order_count > 200
ORDER BY order_count DESC;
```

The database runs the inner query first and treats the answer like a real table with two columns: the customer, and how many orders they placed. Now `WHERE` can use `order_count` like any other column:

| customer_id | order_count |
|---|---|
| 14 | 218 |
| 9 | 209 |
| 2 | 205 |
| 6 | 205 |
| 8 | 204 |
| 4 | 203 |

Six customers placed more than 200 orders (2 and 6 tie, so they can swap places).

### 5. A summary of a summary

Inside, count the orders for each customer. Outside, average those counts:

```sql
SELECT ROUND(AVG(order_count), 1) AS avg_orders
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS per_customer;
```

| avg_orders |
|---|
| 200.0 |

A customer places 200 orders, on average.

## Common mistakes

**1. A column the inner query did not keep.** `name` is not in `per_customer`:

```sql
SELECT name, order_count
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id) AS per_customer;
```

```text
SQL Error [42703]: ERROR: column "name" does not exist
```

**2. A subquery in SELECT must give back one value for each row.** A whole column of prices fails:

```sql
SELECT name, price,
       (SELECT price FROM menu_items) AS other_price
FROM menu_items;
```

```text
SQL Error [21000]: ERROR: more than one row returned by a subquery used as an expression
```

**3. Forgetting the name.** New versions of PostgreSQL (16 and later) allow a subquery in `FROM` with no `AS` name, but many databases do not. Always add `AS` and a name.

## Try it yourself

1. How many items are in an average order? Inside, sum the quantity for each order. Outside, take the average. Guess first, then run it.
2. Show each menu item with the price of the most expensive item next to it.
3. Which orders have more than 5 items in them? Use a derived table. How many are there?

## Next

[M10-L04 · Correlated Subqueries: Once for Every Row](../m10-l04-correlated-subqueries-once-for-every-row/)

## Answers

1. 2.51 items:
   ```sql
   SELECT ROUND(AVG(items), 2) AS avg_items
   FROM (SELECT order_id, SUM(qty) AS items
         FROM order_items
         GROUP BY order_id) AS per_order;
   ```
2. `SELECT name, price, (SELECT MAX(price) FROM menu_items) AS top_price FROM menu_items;` (`top_price` is 80 on every row.)
3. 16 orders (the biggest has 6 items):
   ```sql
   SELECT order_id, items
   FROM (SELECT order_id, SUM(qty) AS items
         FROM order_items
         GROUP BY order_id) AS per_order
   WHERE items > 5;
   ```
