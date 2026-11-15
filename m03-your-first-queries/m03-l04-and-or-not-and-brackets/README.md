# M03-L04 · AND, OR, NOT and Brackets

> Video: Module 3, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- How `AND` keeps a row only when **both** tests pass
- How `OR` keeps a row when **one or more** tests pass
- How `NOT` flips a test
- Why `AND` runs before `OR`, and how brackets fix the order
- Three beginner mistakes: a missing column, AND instead of OR, half an OR

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- A DBeaver SQL editor on `chai_corner`, or psql with `\c chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The six queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes, with the real errors and the fixes |

## Follow along

Last lesson each query had one test. Real questions often need two: which items cost between ₹30 and ₹40? That is two tests at once.

### 1. AND: both tests must pass

```sql
SELECT name, price FROM menu_items WHERE price >= 30 AND price <= 40;
```

Bun Maska costs 35: is it 30 or more? Yes. Is it 40 or less? Yes. Both yes, so it is kept. Cold Coffee costs 80: the first test is yes, the second is no. **One no is enough to drop the row.**

You should see five rows, every price between 30 and 40:

| name | price |
|---|---|
| Bun Maska | 35 |
| Filter Coffee | 40 |
| Ginger Chai | 30 |
| Masala Chai | 30 |
| Vada Pav | 30 |

### 2. OR: one test is enough

A customer wants a Samosa or a Maggi:

```sql
SELECT name, price FROM menu_items WHERE name = 'Samosa' OR name = 'Maggi';
```

| name | price |
|---|---|
| Maggi | 60 |
| Samosa | 25 |

`OR` works with numbers too. The very cheap and the very costly:

```sql
SELECT name, price FROM menu_items WHERE price < 25 OR price > 60;
```

| name | price |
|---|---|
| Cold Coffee | 80 |
| Cutting Chai | 20 |
| Veg Sandwich | 70 |

### 3. NOT flips a test

Yes becomes no, and no becomes yes. Write `NOT` before the test:

```sql
SELECT name, price FROM menu_items WHERE NOT price > 40;
```

It keeps every row where `price > 40` is a no. Seven rows, all ₹40 or less: Bun Maska, Cutting Chai, Filter Coffee, Ginger Chai, Masala Chai, Samosa, Vada Pav.

### 4. Why brackets matter

We want Samosa or Maggi, but only if it costs more than 30:

```sql
SELECT name, price FROM menu_items WHERE name = 'Samosa' OR name = 'Maggi' AND price > 30;
```

| name | price |
|---|---|
| Maggi | 60 |
| Samosa | 25 |

Two rows! But Samosa costs 25. Why is it here? Because PostgreSQL does **AND first, OR second**, just like times comes before plus in maths. It read the query as:

```text
name = 'Samosa'   OR   (name = 'Maggi' AND price > 30)
```

The fix is brackets. Brackets always run first:

```sql
SELECT name, price FROM menu_items WHERE (name = 'Samosa' OR name = 'Maggi') AND price > 30;
```

| name | price |
|---|---|
| Maggi | 60 |

Only Maggi. **When you mix AND and OR, always use brackets.**

## Common mistakes

- **Leaving out the column** (`WHERE price > 30 AND < 50`):
  ```text
  ERROR: syntax error at or near "<"
  ```
  Each test needs its own column: `price > 30 AND price < 50`.
- **AND when you mean OR** (`WHERE name = 'Samosa' AND name = 'Maggi'`): no error, but **0 rows**. One item cannot have two names at once.
- **Half an OR** (`WHERE price = 30 OR 40`):
  ```text
  ERROR: argument of OR must be type boolean, not type integer
  ```
  40 on its own is not a test. Write `price = 30 OR price = 40`.

## Try it yourself

1. The video's task: show every item that costs exactly 30, or more than 60. How many rows come back?
2. Show the items that cost less than 30 or more than 60, but not Cutting Chai. Use brackets.
3. Rewrite `WHERE NOT price > 40` without the word `NOT`.

## Answers

1. ```sql
   SELECT name, price FROM menu_items WHERE price = 30 OR price > 60;
   ```
   **5 rows**: Cold Coffee 80, Ginger Chai 30, Masala Chai 30, Vada Pav 30, Veg Sandwich 70.
2. ```sql
   SELECT name, price FROM menu_items
   WHERE (price < 30 OR price > 60)
     AND name <> 'Cutting Chai';
   ```
   3 rows: Cold Coffee 80, Samosa 25, Veg Sandwich 70.
3. `WHERE price <= 40`. Same 7 rows.

## Next

[M03-L05 · IN, BETWEEN, LIKE and ILIKE](../m03-l05-in-between-like-and-ilike/)
