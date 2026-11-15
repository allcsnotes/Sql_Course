# M15-L02 · ROW_NUMBER, RANK, DENSE_RANK

> Video: Module 15, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- Three numbering functions that put rows in order: `ROW_NUMBER`, `RANK` and `DENSE_RANK`
- Why they only behave differently when there is a **tie**
- How to put `ORDER BY` inside `OVER ( )` to choose the order
- How to keep only the top rows, by numbering in a CTE first
- Three mistakes: empty brackets, the new column in `WHERE`, and a forgotten `DESC`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads `menu_items` (12 items). It changes nothing.
- [M15-L01](../m15-l01-what-a-window-is/) introduced `OVER ()`.

## Files in this folder

| File | What it is |
|---|---|
| `ranking.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Which menu item is the most expensive? Which one is second? And what happens when two items have the same price? Filter Coffee and Kulhad Chai both cost ₹40, so they tie for fifth place:

| Function | Filter Coffee | Kulhad Chai | Bun Maska (next) |
|---|---|---|---|
| `ROW_NUMBER` | 5 | 6 | 7 (ignores the tie) |
| `RANK` | 5 | 5 | 7 (skips 6, like a race) |
| `DENSE_RANK` | 5 | 5 | 6 (no gaps) |

### 1. ROW_NUMBER

`ROW_NUMBER()`, then `OVER`, and inside the brackets `ORDER BY price DESC`, so the most expensive item comes first.

```sql
SELECT name, price,
  ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
FROM menu_items;
```

You should see Paneer Roll 1, Cold Coffee 2, and so on. Every row gets a different number, even the two items that cost ₹40 (5 and 6).

### 2. RANK

Same query, with `RANK()` instead.

```sql
SELECT name, price,
  RANK() OVER (ORDER BY price DESC) AS rnk
FROM menu_items;
```

Both ₹40 items get 5. The next item, Bun Maska, gets 7: six is skipped because the tie used up two places.

### 3. DENSE_RANK

```sql
SELECT name, price,
  DENSE_RANK() OVER (ORDER BY price DESC) AS drnk
FROM menu_items;
```

The tie still shares 5, but now Bun Maska gets 6. Nothing is skipped, so there are no gaps.

### 4. All three side by side

```sql
SELECT name, price,
  ROW_NUMBER() OVER (ORDER BY price DESC) AS rn,
  RANK()       OVER (ORDER BY price DESC) AS rnk,
  DENSE_RANK() OVER (ORDER BY price DESC) AS drnk
FROM menu_items;
```

You should see:

| name | price | rn | rnk | drnk |
|---|---|---|---|---|
| Paneer Roll | 90 | 1 | 1 | 1 |
| Cold Coffee | 80 | 2 | 2 | 2 |
| Veg Sandwich | 70 | 3 | 3 | 3 |
| Maggi | 60 | 4 | 4 | 4 |
| Filter Coffee | 40 | 5 | 5 | 5 |
| Kulhad Chai | 40 | 6 | 5 | 5 |
| Bun Maska | 35 | 7 | 7 | 6 |
| Vada Pav | 30 | 8 | 8 | 7 |
| Masala Chai | 30 | 9 | 8 | 7 |
| Ginger Chai | 30 | 10 | 8 | 7 |
| Samosa | 25 | 11 | 11 | 8 |
| Cutting Chai | 20 | 12 | 12 | 9 |

The three only differ after a tie. Which tied row gets the lower `ROW_NUMBER` is not fixed (Filter Coffee or Kulhad Chai can swap on your machine); add a second sort column such as `ORDER BY price DESC, name` if it must be stable.

## Common mistakes

All three were run for real in the video.

1. **Leaving the brackets empty.**

   ```sql
   SELECT name, price,
     RANK() OVER () AS rnk
   FROM menu_items;
   ```

   No error, but every row gets rank 1: with no order, every row ties. Fix: put `ORDER BY price DESC` inside the brackets.

2. **Filtering on the new column in `WHERE`.**

   ```sql
   SELECT name, price,
     ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
   FROM menu_items
   WHERE rn <= 3;
   ```

   ```text
   ERROR: column "rn" does not exist   (SQLSTATE 42703)
   ```

   Fix: number the rows in a CTE first, then filter:

   ```sql
   WITH ranked AS (
     SELECT name, price,
       ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
     FROM menu_items
   )
   SELECT * FROM ranked WHERE rn <= 3;
   ```

   | name | price | rn |
   |---|---|---|
   | Paneer Roll | 90 | 1 |
   | Cold Coffee | 80 | 2 |
   | Veg Sandwich | 70 | 3 |

3. **Forgetting `DESC`.** `OVER (ORDER BY price)` sorts cheapest first, so Cutting Chai gets number 1. Fix: add `DESC` to put the biggest first.

## Try it yourself

1. Which items are in the top five price levels? (The video's task.)
2. Show the two cheapest items with `ROW_NUMBER`.
3. Using `RANK`, which items rank 8?

## Answers

1. Use `DENSE_RANK`, so a tie counts as one level: 6 items.

   ```sql
   WITH ranked AS (
     SELECT name, price,
       DENSE_RANK() OVER (ORDER BY price DESC) AS drnk
     FROM menu_items
   )
   SELECT * FROM ranked WHERE drnk <= 5;
   ```

   | name | price | drnk |
   |---|---|---|
   | Paneer Roll | 90 | 1 |
   | Cold Coffee | 80 | 2 |
   | Veg Sandwich | 70 | 3 |
   | Maggi | 60 | 4 |
   | Filter Coffee | 40 | 5 |
   | Kulhad Chai | 40 | 5 |

2. `ROW_NUMBER() OVER (ORDER BY price) AS rn` in a CTE, then `WHERE rn <= 2`: Cutting Chai 20, Samosa 25.

3. The three ₹30 items: Vada Pav, Masala Chai and Ginger Chai.

## Next

[M15-L03 · PARTITION BY](../m15-l03-partition-by/)
