# M15-L03 · PARTITION BY

> Video: Module 15, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- How `PARTITION BY` gives each group its own window, and still keeps every row
- A separate average for each category, next to every item
- The whole menu and each category, side by side in one query
- Numbering that starts again at 1 in each group
- Three mistakes: `GROUP BY` inside `OVER`, a missing `PARTITION BY`, and splitting by the wrong column

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads `menu_items` (12 items in 3 categories: Chai, Coffee, Snack). It changes nothing.

## Files in this folder

| File | What it is |
|---|---|
| `partition_by.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Is Masala Chai cheap? Next to a Paneer Roll, yes. Next to the other chai, it is just normal. So you want to compare each item with its own category.

```text
OVER ()                        -> one big window, 12 rows share one average
OVER (PARTITION BY category)   -> three windows: Chai, Coffee, Snack
                                  each works out its own average: 30, 60, 51.67
```

### 1. A separate average for each category

`AVG(price)`, then `OVER`, and inside the brackets `PARTITION BY category`.

```sql
SELECT name, category, price,
  ROUND(AVG(price) OVER (PARTITION BY category), 2) AS cat_avg
FROM menu_items ORDER BY category, price DESC;
```

You should see:

| name | category | price | cat_avg |
|---|---|---|---|
| Kulhad Chai | Chai | 40 | 30.00 |
| Masala Chai | Chai | 30 | 30.00 |
| Ginger Chai | Chai | 30 | 30.00 |
| Cutting Chai | Chai | 20 | 30.00 |
| Cold Coffee | Coffee | 80 | 60.00 |
| Filter Coffee | Coffee | 40 | 60.00 |
| Paneer Roll | Snack | 90 | 51.67 |
| Veg Sandwich | Snack | 70 | 51.67 |
| Maggi | Snack | 60 | 51.67 |
| Bun Maska | Snack | 35 | 51.67 |
| Vada Pav | Snack | 30 | 51.67 |
| Samosa | Snack | 25 | 51.67 |

Each row still keeps its own name and price. Nothing is squashed.

### 2. The whole menu and each category, side by side

The first window has empty brackets (all the rows); the second uses `PARTITION BY category`.

```sql
SELECT name, category, price,
  ROUND(AVG(price) OVER (), 2) AS all_avg,
  ROUND(AVG(price) OVER (PARTITION BY category), 2) AS cat_avg
FROM menu_items ORDER BY category, price DESC;
```

You should see `all_avg` = 45.83 on every row, and `cat_avg` = the average of the row's own category (as in step 1). Masala Chai (₹30) is cheap for the whole menu (45.83) but exactly average for chai (30.00).

### 3. Numbering inside each group

`ROW_NUMBER()`, `OVER`, `PARTITION BY category`, then `ORDER BY price DESC`.

```sql
SELECT name, category, price,
  ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
FROM menu_items ORDER BY category, rn;
```

You should see:

| name | category | price | rn |
|---|---|---|---|
| Kulhad Chai | Chai | 40 | 1 |
| Masala Chai | Chai | 30 | 2 |
| Ginger Chai | Chai | 30 | 3 |
| Cutting Chai | Chai | 20 | 4 |
| Cold Coffee | Coffee | 80 | 1 |
| Filter Coffee | Coffee | 40 | 2 |
| Paneer Roll | Snack | 90 | 1 |
| Veg Sandwich | Snack | 70 | 2 |
| Maggi | Snack | 60 | 3 |
| Bun Maska | Snack | 35 | 4 |
| Vada Pav | Snack | 30 | 5 |
| Samosa | Snack | 25 | 6 |

The numbers start again at 1 in every category, so you can find the most expensive item in each group. (Masala Chai and Ginger Chai tie at ₹30; which one gets 2 can differ on your machine.)

## Common mistakes

All three were run for real in the video.

1. **Writing `GROUP BY` inside the brackets.**

   ```sql
   SELECT name, category,
     AVG(price) OVER (GROUP BY category) AS cat_avg
   FROM menu_items;
   ```

   ```text
   ERROR: syntax error at or near "GROUP"   (SQLSTATE 42601)
   ```

   Fix: inside `OVER`, the words are `PARTITION BY`.

2. **Forgetting `PARTITION BY`.**

   ```sql
   SELECT name, category, price,
     ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
   FROM menu_items ORDER BY category, rn;
   ```

   No error, but the numbers run across the whole menu: Kulhad Chai gets 6, Masala Chai 9. Fix: add `PARTITION BY category` so each group starts again.

3. **Splitting by a column that is different on every row.**

   ```sql
   SELECT name, category, price,
     AVG(price) OVER (PARTITION BY name) AS cat_avg
   FROM menu_items ORDER BY category, price DESC;
   ```

   Each window holds one row, so the "average" is just the item's own price (Kulhad Chai 40, Masala Chai 30 ...). Fix: partition by the group column, `category`.

## Try it yourself

1. How many items are in each item's category? (The video's task.)
2. Show each item with the most expensive price in its category (`MAX(price) OVER (PARTITION BY category)`).
3. Keep only the cheapest item in each category, using a CTE and `ROW_NUMBER`.

## Answers

1. Chai 4, Coffee 2, Snack 6, on every row of that category.

   ```sql
   SELECT name, category,
     COUNT(*) OVER (PARTITION BY category) AS in_cat
   FROM menu_items ORDER BY category, name;
   ```

2. Chai rows show 40, Coffee rows 80, Snack rows 90.

3. ```sql
   WITH ranked AS (
     SELECT name, category, price,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY price) AS rn
     FROM menu_items
   )
   SELECT name, category, price FROM ranked WHERE rn = 1;
   ```

   Cutting Chai 20, Filter Coffee 40, Samosa 25.

## Next

[M15-L04 · Running Totals and Moving Averages](../m15-l04-running-totals-and-moving-averages/)
