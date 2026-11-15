# M08-L01 · Why We Split Data into Many Tables

> Video: Module 8, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- Why one big table that copies the same facts again and again causes trouble
- The three copy-paste problems: changing, typing and losing
- How to count the copies with `COUNT(*)` and `COUNT(DISTINCT ...)`
- The fix: store each fact once, in its own table, with an ID, and point to that ID
- What stays in the sales table (the quantity and the time of the sale)

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). This lesson needs the `sales` table from [Build 1](../../m07-summarising-data/m07-b01-the-cafe-sales-report/) (6,028 rows).
- DBeaver open and connected to `chai_corner`, with a new SQL editor (SQL Editor > New SQL script).
- This lesson only reads data. Nothing in the database changes.

## Files in this folder

| File | What it is |
|---|---|
| `why_split.sql` | Every query of the video, in order, with the result as a comment |

## Follow along

Run each query on its own: put the cursor inside it and press Ctrl+Enter (Cmd+Enter on a Mac).

### 1. One big table repeats itself

```sql
SELECT branch, item, category, price
FROM sales
WHERE item = 'Masala Chai'
LIMIT 8;
```

You should see 8 rows. Look at the last three columns: every row says the same thing.

| branch | item | category | price |
|---|---|---|---|
| Pune | Masala Chai | Chai | 30 |
| Delhi | Masala Chai | Chai | 30 |
| Delhi | Masala Chai | Chai | 30 |
| Pune | Masala Chai | Chai | 30 |
| Pune | Masala Chai | Chai | 30 |
| Delhi | Masala Chai | Chai | 30 |
| Pune | Masala Chai | Chai | 30 |
| Pune | Masala Chai | Chai | 30 |

### 2. Count the copies

```sql
SELECT COUNT(*) AS copies_of_price
FROM sales
WHERE item = 'Masala Chai';
```

You should see:

| copies_of_price |
|---|
| 1093 |

One fact (Masala Chai costs 30) is stored 1,093 times.

### 3. Many rows, few things

```sql
SELECT COUNT(*) AS sale_rows,
   COUNT(DISTINCT item) AS items,
   COUNT(DISTINCT branch) AS branches
FROM sales;
```

You should see:

| sale_rows | items | branches |
|---|---|---|
| 6028 | 10 | 3 |

Six thousand rows, but only 13 things to describe: 10 items and 3 branches.

### 4. The copy-paste problems

**Problem 1, changing.** Say Masala Chai goes up to ₹35. You must change 1,093 rows. Miss one, and the table shows two prices for the same chai.

**Problem 2, typing.** Every copy must be typed exactly the same. `FILTER` (from [M07-L06](../../m07-summarising-data/m07-l06-filter-many-counts-in-one-query/)) counts three spellings in one query:

```sql
SELECT COUNT(*) FILTER (WHERE branch = 'Pune') AS exact,
   COUNT(*) FILTER (WHERE branch = 'pune') AS small_p,
   COUNT(*) FILTER (WHERE branch = 'Pune ') AS extra_space
FROM sales;
```

You should see:

| exact | small_p | extra_space |
|---|---|---|
| 3054 | 0 | 0 |

`'pune'` with a small p and `'Pune '` with an extra space both find zero rows. One typo, and a sale goes missing from the report.

**Problem 3, losing.** If you delete the only sales of an item, its price is gone too. And a new item with no sales yet has nowhere to live.

### 5. Split it: each fact once

The `menu_items` table already has every item once, with its price and category:

```sql
SELECT * FROM menu_items
ORDER BY item_id;
```

You should see 10 rows, not a thousand copies:

| item_id | name | price | category |
|---|---|---|---|
| 1 | Bun Maska | 35 | Snack |
| 2 | Cold Coffee | 80 | Coffee |
| 3 | Cutting Chai | 20 | Chai |
| 4 | Filter Coffee | 40 | Coffee |
| 5 | Ginger Chai | 30 | Chai |
| 6 | Maggi | 60 | Snack |
| 7 | Masala Chai | 30 | Chai |
| 8 | Samosa | 25 | Snack |
| 9 | Vada Pav | 30 | Snack |
| 10 | Veg Sandwich | 70 | Snack |

### 6. Each city once, with an ID

```sql
SELECT * FROM branches
WHERE city IN ('Pune', 'Mumbai', 'Delhi');
```

You should see:

| branch_id | city | opened_on |
|---|---|---|
| 1 | Pune | 2019-04-12 |
| 2 | Mumbai | 2019-09-02 |
| 3 | Delhi | 2020-01-20 |

So a sale only needs to say *which* item and *which* branch, using these ID numbers:

```text
one sale: item_id 7 · branch_id 1 · qty 2
   item_id 7   -> menu_items 7 · Masala Chai · 30
   branch_id 1 -> branches 1 · Pune
```

Now a price change is one update, in one row, and every sale that points to row 7 sees the new price at once. The next lessons show how to make these IDs and links, and how to join the tables back together.

## Common mistakes

- **Thinking more tables means more work.** Small tables are easier to keep correct, and one query can still read them all.
- **Copying a value that can change**, like a price or a name. If it can change, store it once and point to it.
- **Splitting everything.** Facts that belong to the sale itself, like the quantity and the time, stay in the sales table.

## Try it yourself

1. How many times is the price of Cutting Chai copied in the sales table? Guess first, then run it.
2. How many sales rows does the Mumbai branch have? Try `'Mumbai'` and `'mumbai'`.
3. Which facts in one `sales` row belong to the sale itself, and which belong to the item?

## Next

[M08-L02 · Primary Keys: One Unique ID per Row](../m08-l02-primary-keys-one-unique-id-per-row/)

## Answers

1. 1,038 copies:
   ```sql
   SELECT COUNT(*) AS copies_of_price
   FROM sales
   WHERE item = 'Cutting Chai';
   ```
2. `SELECT COUNT(*) FROM sales WHERE branch = 'Mumbai';` gives 1,952. With `'mumbai'` you get 0.
3. The sale's own facts: `order_id`, `qty`, `sold_at` (and which branch sold it). The item's facts: `item`, `category`, `price`. Those belong in `menu_items`.
