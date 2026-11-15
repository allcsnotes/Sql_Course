# M08-L05 · Normalisation: 1NF, 2NF, 3NF

> Video: Module 8, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- What **normalisation** is: a few simple rules that store each fact once, in the right table
- **First normal form (1NF):** one value per cell
- **Second normal form (2NF):** with a two-column key, every column depends on the *whole* key
- **Third normal form (3NF):** every column depends on the key and nothing else
- When it is fine to break the rules (reports, the price at the time, measured speed)

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need the `sales` table from [Build 1](../../m07-summarising-data/m07-b01-the-cafe-sales-report/) and update 4 from [M08-L03](../m08-l03-foreign-keys-linking-tables-together/).
- This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `normalisation.sql` | Every query of the video, in order, with the result as a comment |

## Follow along

### 1. Rule one (1NF): one value per cell

Every cell holds just one value. No lists like `'Cutting Chai, Samosa'`: a list inside one cell cannot be counted, sorted or linked. Put each item on its own row.

```sql
SELECT sale_id, order_id, branch, item, category, price
FROM sales
ORDER BY sale_id
LIMIT 8;
```

You should see:

| sale_id | order_id | branch | item | category | price |
|---|---|---|---|---|---|
| 1 | 1 | Mumbai | Cutting Chai | Chai | 20 |
| 2 | 2 | Pune | Samosa | Snack | 25 |
| 3 | 2 | Pune | Masala Chai | Chai | 30 |
| 4 | 2 | Pune | Cutting Chai | Chai | 20 |
| 5 | 3 | Pune | Filter Coffee | Coffee | 40 |
| 6 | 3 | Pune | Samosa | Snack | 25 |
| 7 | 4 | Pune | Cutting Chai | Chai | 20 |
| 8 | 4 | Pune | Cutting Chai | Chai | 20 |

The sales table already passes: order 2 has three rows, one for each item.

### 2. Rule two (2NF): the whole key

Second normal form matters when the key has two columns. In `order_items`, the key is `order_id` plus `item_id`:

```sql
SELECT * FROM order_items ORDER BY order_id, item_id LIMIT 8;
```

| order_id | item_id | qty |
|---|---|---|
| 1 | 3 | 1 |
| 2 | 3 | 1 |
| 2 | 7 | 2 |
| 2 | 8 | 1 |
| 3 | 4 | 1 |
| 3 | 8 | 1 |
| 4 | 3 | 3 |
| 5 | 1 | 1 |

`qty` depends on both: how many of *this item*, in *this order*. That is fine. But an item's name depends only on `item_id` (half of the key), so the name does not belong here. It lives once, in `menu_items`:

```sql
SELECT item_id, name, category, price
FROM menu_items
ORDER BY item_id;
```

You should see 10 rows, from `1 | Bun Maska | Snack | 35` to `10 | Veg Sandwich | Snack | 70` (item 7 is `Masala Chai | Chai | 30`).

### 3. Rule three (3NF): nothing but the key

Every column must depend on the key, and nothing else. In `sales` the key is `sale_id`. But `price` depends on the item, not on the sale:

```sql
SELECT item, price, COUNT(*) AS copies
FROM sales
GROUP BY item, price
ORDER BY copies DESC;
```

You should see:

| item | price | copies |
|---|---|---|
| Masala Chai | 30 | 1093 |
| Cutting Chai | 20 | 1038 |
| Vada Pav | 30 | 666 |
| Bun Maska | 35 | 620 |
| Samosa | 25 | 570 |
| Ginger Chai | 30 | 569 |
| Filter Coffee | 40 | 423 |
| Maggi | 60 | 412 |
| Cold Coffee | 80 | 401 |
| Veg Sandwich | 70 | 236 |

Masala Chai's price is copied 1,093 times. Change the price, and you must fix every copy. Miss one, and your data disagrees with itself. The fix: each fact once, the price in `menu_items`.

`branch` is the same: it depends on the order, not the sale. So the `orders` table stores the branch ID once per order:

```sql
SELECT * FROM orders WHERE order_id = 2;
```

| order_id | customer_id | branch_id | ordered_at |
|---|---|---|---|
| 2 | 7 | 1 | 2026-03-10 18:34:00 |

### 4. When to break the rules

- **Reports.** A copied table like `sales` is fine for fast reading. It is just not the place where you change data.
- **The price at the time.** The price a customer paid is a new fact, not a copy, because menu prices change later.
- **Speed.** Copy data only when a real query is too slow, and you have measured it.

## Common mistakes

- Putting a list of values in one cell (breaks 1NF).
- Keeping a column that depends on only half of a two-column key, like an item name in `order_items` (breaks 2NF).
- Keeping a column that depends on another non-key column, like `price` following `item` in `sales` (breaks 3NF).
- Treating the price a customer paid as a copy: it is a fact of the sale and may stay with the sale.

## Try it yourself

1. How many rows in `sales` store the word Pune? Guess first, then run it.
2. In `sales`, which column does `category` depend on? Which normal form does that break?
3. Is `qty` in `order_items` a 2NF problem? Why or why not?

## Next

[M08-L06 · Drawing an ER Diagram](../m08-l06-drawing-an-er-diagram/)

## Answers

1. 3,054 rows:
   ```sql
   SELECT COUNT(*) AS pune_rows FROM sales WHERE branch = 'Pune';
   ```
2. `category` depends on the item, not on `sale_id`, so it breaks 3NF. It belongs in `menu_items` (where it already is).
3. No. `qty` depends on both `order_id` and `item_id` (how many of this item in this order), so it depends on the whole key.
