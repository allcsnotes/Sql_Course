# M09-L06 · CROSS JOIN: Every Combination

> Video: Module 9, Lesson 6. Watch it first, then follow along here.

## What you'll learn

- What a `CROSS JOIN` does: pairs every row on the left with every row on the right (no `ON`)
- How `VALUES` lets you type a tiny table right inside a query
- How to build a price list: every chai in every cup size
- Why the row count multiplies, and why you cross join only small tables
- Three traps: the comma join, `JOIN` without `ON`, and `CROSS JOIN` with `ON`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`, `order_items`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/) and update 5 (`staff`) from [M09-L03](../m09-l03-full-outer-join-everything-from-both-sides/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `cross_join.sql` | Every query of the video, in order, with the result or error as a comment |

## Follow along

### 1. Every combination

Three chai items, three cup sizes: how many price tags do you need? Nine. A cross join has no `ON`: Cutting Chai meets Small, Regular and Large, then Ginger Chai does the same, then Masala Chai. 3 rows × 3 rows = 9 rows.

### 2. Writing a cross join

Start from `menu_items`, then cross join a tiny list of sizes. `VALUES` types a small table inside the query; `AS sizes(size, extra)` names it and its two columns. `WHERE` keeps only the chai items:

```sql
SELECT menu_items.name, sizes.size
FROM menu_items
CROSS JOIN (VALUES ('Small', 0), ('Regular', 10), ('Large', 20))
           AS sizes(size, extra)
WHERE menu_items.category = 'Chai'
ORDER BY menu_items.name, sizes.extra;
```

You should see 9 rows:

| name | size |
|---|---|
| Cutting Chai | Small |
| Cutting Chai | Regular |
| Cutting Chai | Large |
| Ginger Chai | Small |
| Ginger Chai | Regular |
| Ginger Chai | Large |
| Masala Chai | Small |
| Masala Chai | Regular |
| Masala Chai | Large |

### 3. A price list

Each size adds an extra amount: ₹0, ₹10 or ₹20. Add the extra to the menu price:

```sql
SELECT menu_items.name, sizes.size,
       menu_items.price + sizes.extra AS price
FROM menu_items
CROSS JOIN (VALUES ('Small', 0), ('Regular', 10), ('Large', 20))
           AS sizes(size, extra)
WHERE menu_items.category = 'Chai'
ORDER BY menu_items.name, sizes.extra;
```

| name | size | price |
|---|---|---|
| Cutting Chai | Small | 20 |
| Cutting Chai | Regular | 30 |
| Cutting Chai | Large | 40 |
| Ginger Chai | Small | 30 |
| Ginger Chai | Regular | 40 |
| Ginger Chai | Large | 50 |
| Masala Chai | Small | 30 |
| Masala Chai | Regular | 40 |
| Masala Chai | Large | 50 |

A full price list, from one query.

### 4. Rows multiply

```sql
SELECT COUNT(*) AS combos FROM branches CROSS JOIN menu_items;
```

`combos` is 100: 10 branches × 10 menu items.

```sql
SELECT COUNT(*) AS combos FROM orders CROSS JOIN order_items;
```

`combos` is 16590000: 3,000 orders × 5,530 order items, almost 17 million rows. Cross join only small tables. (Here `COUNT(*)` only counts them; showing them would be very slow.)

## Common mistakes

**1. A comma between two tables, and no `WHERE`.**

```sql
SELECT COUNT(*) AS combos
FROM branches, menu_items;
```

`combos` is 100: a hidden cross join. When you want matches, use `JOIN` with `ON`.

**2. A normal `JOIN` with no `ON`.**

```sql
SELECT branches.city, menu_items.name
FROM branches
JOIN menu_items;
```

```text
SQL Error [42601]: ERROR: syntax error at end of input
  Position: 68
```

A normal join needs its `ON`. (In psql the same mistake says `syntax error at or near ";"`.)

**3. A cross join with an `ON`.**

```sql
SELECT branches.city, menu_items.name
FROM branches
CROSS JOIN menu_items ON menu_items.item_id = branches.branch_id;
```

```text
SQL Error [42601]: ERROR: syntax error at or near "ON"
  Position: 75
```

A cross join never takes an `ON`.

## Try it yourself

1. How many rows do you get when you cross join `staff` with the chai items? Guess first, then run it.
2. Add a fourth size, `('Kulhad', 15)`, to the price list. How many rows now, and what does a Kulhad Masala Chai cost?
3. How many rows would `customers CROSS JOIN branches` give? Work it out before you run it.

## Next

[M09-L07 · JOIN Mistakes: Duplicates, Wrong Totals, Forgotten ON](../m09-l07-join-mistakes-duplicates-wrong-totals-forgotten-on/)

## Answers

1. 30 (10 staff × 3 chai items):
   ```sql
   SELECT COUNT(*) AS combos
   FROM staff
   CROSS JOIN menu_items
   WHERE menu_items.category = 'Chai';
   ```
2. 12 rows (3 × 4). Kulhad Masala Chai: 30 + 15 = ₹45.
3. 150: 15 customers × 10 branches.
