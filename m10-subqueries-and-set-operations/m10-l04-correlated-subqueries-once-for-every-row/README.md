# M10-L04 · Correlated Subqueries: Once for Every Row

> Video: Module 10, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- A **correlated subquery**: a subquery that uses a column from the outer row, so it runs once for every row
- Comparing each menu item with the average of **its own** category
- The same idea in `SELECT`, to show each row's own average
- A faster way to get the same answer: `JOIN` a derived table, so the averages are worked out once
- Three mistakes: a link with no table names, a link that still leaves many rows, and using the inner name outside the brackets

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need `menu_items.category` (update 2) and `orders` (update 4, from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/)).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `correlated_subqueries.sql` | Every query of the video, in order, with the result or error as a comment |

## Follow along

### 1. The average of each category, by hand

```sql
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category
ORDER BY category;
```

| category | avg_price |
|---|---|
| Chai | 26.67 |
| Coffee | 60.00 |
| Snack | 44.00 |

The question: which items cost more than the average of **their own** category? Masala Chai (₹30) should be compared with 26.67, not with the whole menu's 42. One fixed number cannot do that.

### 2. A correlated subquery

```sql
SELECT name, category, price
FROM menu_items m
WHERE price > (SELECT AVG(price)
               FROM menu_items i
               WHERE i.category = m.category)
ORDER BY category, price DESC;
```

- The outer table is named `m`, the inner one `i`. Same table, two names.
- `WHERE i.category = m.category` is the **link**. `m.category` comes from the outer row being checked right now.
- So the subquery runs again for every row: for Masala Chai it averages the Chai items, for Cold Coffee the Coffee items.

You should see:

| name | category | price |
|---|---|---|
| Ginger Chai | Chai | 30 |
| Masala Chai | Chai | 30 |
| Cold Coffee | Coffee | 80 |
| Veg Sandwich | Snack | 70 |
| Maggi | Snack | 60 |

Five items. (Ginger Chai and Masala Chai tie at ₹30, so they can swap places.)

### 3. In SELECT: each row's own average

The same subquery in the column list shows the number each row was compared with:

```sql
SELECT name, category, price,
       (SELECT ROUND(AVG(price), 2)
        FROM menu_items i
        WHERE i.category = m.category) AS cat_avg
FROM menu_items m
ORDER BY category, price DESC;
```

| name | category | price | cat_avg |
|---|---|---|---|
| Masala Chai | Chai | 30 | 26.67 |
| Ginger Chai | Chai | 30 | 26.67 |
| Cutting Chai | Chai | 20 | 26.67 |
| Cold Coffee | Coffee | 80 | 60.00 |
| Filter Coffee | Coffee | 40 | 60.00 |
| Veg Sandwich | Snack | 70 | 44.00 |
| Maggi | Snack | 60 | 44.00 |
| Bun Maska | Snack | 35 | 44.00 |
| Vada Pav | Snack | 30 | 44.00 |
| Samosa | Snack | 25 | 44.00 |

Each category gets its own average.

### 4. The same answer, with the averages worked out once

A correlated subquery runs once for every row. On 10 rows that is fine; on a million rows it can be slow. You can work out every category average **once** in a derived table ([M10-L03](../m10-l03-subqueries-in-select-and-from-derived-tables/)) and join it:

```sql
SELECT m.name, m.category, m.price
FROM menu_items m
JOIN (SELECT category, AVG(price) AS avg_price
      FROM menu_items
      GROUP BY category) AS c ON c.category = m.category
WHERE m.price > c.avg_price
ORDER BY m.category, m.price DESC;
```

Same five items, and each average is worked out only once.

## Common mistakes

**1. No table names in the link.**

```sql
SELECT name, category, price
FROM menu_items m
WHERE price > (SELECT AVG(price)
               FROM menu_items
               WHERE category = category)
ORDER BY category, price DESC;
```

No error, but the wrong answer: 3 rows (Cold Coffee, Veg Sandwich, Maggi). Inside the brackets, both `category` words mean the inner table, so `category = category` is always true. The subquery averages the whole menu (42), and the link is gone. Always write `i.category = m.category`.

**2. The link still leaves many rows.**

```sql
SELECT name, category,
       (SELECT price
        FROM menu_items i
        WHERE i.category = m.category) AS cat_price
FROM menu_items m;
```

```text
SQL Error [21000]: ERROR: more than one row returned by a subquery used as an expression
```

Each category has several items, so the subquery gives back several prices. In `SELECT` it must give back one value: use `AVG`, `MAX`, `COUNT` and so on.

**3. The inner name used outside the brackets.**

```sql
SELECT i.name, category, price
FROM menu_items m
WHERE price > (SELECT AVG(price)
               FROM menu_items i
               WHERE i.category = m.category);
```

```text
SQL Error [42P01]: ERROR: missing FROM-clause entry for table "i"
```

The inner query can see the outer name `m`, but the outer query cannot see the inner name `i`. Use `m.name` (or just `name`).

## Try it yourself

1. Who placed the most orders? For each customer, count their orders with a correlated `COUNT(*)` in `SELECT`. Show the top 3. Guess first, then run it.
2. Which items cost **less** than the average of their own category? Change one sign.
3. For each branch, count its orders with a correlated subquery. Which four branches come first?

## Next

[M10-L05 · UNION, INTERSECT and EXCEPT](../m10-l05-union-intersect-and-except/)

## Answers

1. Tara 218, Vikram 209, Ananya 205:
   ```sql
   SELECT name,
          (SELECT COUNT(*)
           FROM orders o
           WHERE o.customer_id = c.customer_id) AS order_count
   FROM customers c
   ORDER BY order_count DESC
   LIMIT 3;
   ```
   Ananya and Lukas both have 205 orders, so your third row may show Lukas instead. Add `, name` to the `ORDER BY` to fix the order.
2. Change `>` to `<`: 5 items. Cutting Chai 20, Filter Coffee 40, Samosa 25, Vada Pav 30, Bun Maska 35.
3. Pune 1522, Mumbai 976, Delhi 502, then Bengaluru with 0 (the other seven branches all have 0, so any of them can come fourth):
   ```sql
   SELECT b.city,
          (SELECT COUNT(*)
           FROM orders o
           WHERE o.branch_id = b.branch_id) AS order_count
   FROM branches b
   ORDER BY order_count DESC
   LIMIT 4;
   ```
