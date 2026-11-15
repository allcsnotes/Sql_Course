# M10-L01 · A Query Inside a Query: Subquery in WHERE

> Video: Module 10, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a **subquery** is: a query in brackets, inside another query
- How the database runs the subquery first and the outer query uses its answer
- Subqueries with `AVG`, `MAX`, and one that reads a different table (no join needed)
- The three rules: brackets, one row, one column
- The errors you get when you break them (`21000`, `42601`)

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `subquery_where.sql` | Every query of the video, in order, with the result or error as a comment |

## Follow along

### 1. Two steps, by hand

Which menu items cost more than the average price? Step one, ask for the average:

```sql
-- The average price on the menu
SELECT ROUND(AVG(price), 2) AS avg_price
FROM menu_items;
```

| avg_price |
|---|
| 42.00 |

Step two, type that number into `WHERE`:

```sql
SELECT name, price
FROM menu_items
WHERE price > 42
ORDER BY price DESC;
```

| name | price |
|---|---|
| Cold Coffee | 80 |
| Veg Sandwich | 70 |
| Maggi | 60 |

It works. But if a price changes tomorrow, 42 is out of date and you must do both steps again.

### 2. One query that does both steps

Instead of typing 42, put the first query inside brackets, right where the number was:

```sql
SELECT name, price
FROM menu_items
WHERE price > (SELECT AVG(price) FROM menu_items)
ORDER BY price DESC;
```

The inner query is the **subquery**. The database runs it first, and it gives back one number: 42. Then the outer query uses that number. You should see the same three items (Cold Coffee 80, Veg Sandwich 70, Maggi 60), and the query stays right when prices change.

### 3. More uses

Which item costs the most? Compare each price with the highest price:

```sql
SELECT name, price
FROM menu_items
WHERE price = (SELECT MAX(price) FROM menu_items);
```

| name | price |
|---|---|
| Cold Coffee | 80 |

A subquery can also read a different table. Here it looks up the Pune branch number in `branches`, so we can count Pune orders without any join:

```sql
SELECT COUNT(*) AS pune_orders
FROM orders
WHERE branch_id = (SELECT branch_id FROM branches WHERE city = 'Pune');
```

| pune_orders |
|---|
| 1522 |

## Common mistakes

**1. The subquery gives back many rows.** It returns every branch, not just one, but `=` needs a single value:

```sql
SELECT COUNT(*) AS orders
FROM orders
WHERE branch_id = (SELECT branch_id FROM branches);
```

```text
SQL Error [21000]: ERROR: more than one row returned by a subquery used as an expression
```

Add a `WHERE` inside the subquery so only one row comes back. For a whole list, use `IN` (next lesson).

**2. The subquery gives back two columns.** A price can only be compared with one value:

```sql
SELECT name, price
FROM menu_items
WHERE price > (SELECT AVG(price), MAX(price) FROM menu_items);
```

```text
SQL Error [42601]: ERROR: subquery must return only one column
  Position: 100
```

**3. The brackets are missing.** The database finds a second `SELECT` in the middle:

```sql
SELECT name, price
FROM menu_items
WHERE price > SELECT AVG(price) FROM menu_items;
```

```text
SQL Error [42601]: ERROR: syntax error at or near "SELECT"
  Position: 89
```

**The three rules for every subquery:** always put it inside brackets; next to `=` or `>` it must give back one row; and one column. One row and one column means one single value.

(The `Position` numbers count from the start of the text DBeaver sent, including the comment line in the video's file, so yours may differ.)

## Try it yourself

1. Which items cost less than the average price? Write it with a subquery, and count the items. Guess first, then run it.
2. Which item is the cheapest? Use a subquery with `MIN`.
3. How many Mumbai orders are there? Use a subquery on `branches`, no join.

## Next

[M10-L02 · IN, EXISTS, NOT EXISTS and the NOT IN + NULL Trap](../m10-l02-in-exists-not-exists-and-the-not-in-null-trap/)

## Answers

1. 7 items:
   ```sql
   SELECT name, price
   FROM menu_items
   WHERE price < (SELECT AVG(price) FROM menu_items)
   ORDER BY price;
   ```
   Cutting Chai 20, Samosa 25, Ginger Chai 30, Masala Chai 30, Vada Pav 30, Bun Maska 35, Filter Coffee 40.
2. `SELECT name, price FROM menu_items WHERE price = (SELECT MIN(price) FROM menu_items);` gives Cutting Chai, 20.
3. 976: `SELECT COUNT(*) FROM orders WHERE branch_id = (SELECT branch_id FROM branches WHERE city = 'Mumbai');`
