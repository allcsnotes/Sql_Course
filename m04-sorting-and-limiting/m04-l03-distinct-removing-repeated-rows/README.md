# M04-L03 · DISTINCT: Removing Repeated Rows

> Video: Module 4, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- How `DISTINCT` removes repeated rows, so each value shows up once
- That `DISTINCT` goes right after `SELECT`
- How DISTINCT works on several columns: the whole row must repeat
- That all NULLs count as one value for DISTINCT
- Three beginner mistakes, including the `ORDER BY` rule with DISTINCT

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). Step 3 uses `customers.email` from [M03-L06](../../m03-your-first-queries/m03-l06-null-the-unknown-value/).
- **Run this lesson's `setup.sql` first** (Chai Corner update 2). It adds a `category` column to `menu_items`. Later lessons expect it.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | Chai Corner update 2: adds `menu_items.category` (Chai, Coffee or Snack). Safe to run twice |
| `queries.sql` | The seven queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes, with the real errors |

## Follow along

The menu has ten items. Which categories do we sell? You do not want Chai written three times: you want each one once. One word does this: `DISTINCT`.

### 1. Get the new column

Run `setup.sql` on `chai_corner` (DBeaver: open the file and **Execute SQL Script**, Alt + X; psql: `\i setup.sql`):

```sql
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS category varchar(20);
UPDATE menu_items SET category = CASE WHEN name LIKE '%Chai' THEN 'Chai' WHEN name LIKE '%Coffee' THEN 'Coffee' ELSE 'Snack' END;
CLUSTER menu_items USING menu_items_pkey;
```

Names ending in Chai become `Chai`, names ending in Coffee become `Coffee`, everything else is a `Snack`. (`CASE` comes properly in a later module.) If DBeaver underlines the new column in red afterwards, refresh it with **Database → Invalidate/Reconnect**.

```sql
SELECT name, category FROM menu_items ORDER BY category, name;
```

| name | category |
|---|---|
| Cutting Chai | Chai |
| Ginger Chai | Chai |
| Masala Chai | Chai |
| Cold Coffee | Coffee |
| Filter Coffee | Coffee |
| Bun Maska | Snack |
| Maggi | Snack |
| Samosa | Snack |
| Vada Pav | Snack |
| Veg Sandwich | Snack |

### 2. DISTINCT on one column

Select only the category column:

```sql
SELECT category FROM menu_items ORDER BY category;
```

Ten rows: Chai three times, Coffee twice, Snack five times. Now add one word, `DISTINCT`, right after `SELECT`:

```sql
SELECT DISTINCT category FROM menu_items ORDER BY category;
```

| category |
|---|
| Chai |
| Coffee |
| Snack |

Only three rows: each value shows up once. It works on numbers too:

```sql
SELECT DISTINCT price FROM menu_items ORDER BY price;
```

Eight prices: 20, 25, 30, 35, 40, 60, 70, 80. Three items cost 30, but 30 shows up only once.

### 3. DISTINCT on many columns

```sql
SELECT category, price FROM menu_items ORDER BY category, price;
```

Ten rows. Chai at 30 shows up twice, for Ginger Chai and Masala Chai. Add `DISTINCT`:

```sql
SELECT DISTINCT category, price FROM menu_items ORDER BY category, price;
```

| category | price |
|---|---|
| Chai | 20 |
| Chai | 30 |
| Coffee | 40 |
| Coffee | 80 |
| Snack | 25 |
| Snack | 30 |
| Snack | 35 |
| Snack | 60 |
| Snack | 70 |

Nine rows: the two Chai 30 rows became one. But Snack 30 is still there. **DISTINCT looks at the whole row**: a row is removed only when every column matches another row.

### 4. What about NULLs?

```sql
SELECT DISTINCT email FROM customers ORDER BY email;
```

Twelve rows: eleven real emails, and just **one** NULL at the end. Four customers have no email, but DISTINCT keeps only one NULL: for DISTINCT, all NULLs count as the same value.

## Common mistakes

- **DISTINCT with a column that is always different**, like `name`:
  ```sql
  SELECT DISTINCT name, category FROM menu_items ORDER BY category;
  ```
  Every row is unique, so nothing is removed: still 10 rows. Pick only the columns you need.
- **DISTINCT in the middle** (`SELECT category, DISTINCT price FROM menu_items;`):
  ```text
  ERROR: syntax error at or near "DISTINCT"
  ```
  DISTINCT goes right after SELECT.
- **Sorting by a column you did not select** (`SELECT DISTINCT category FROM menu_items ORDER BY price;`):
  ```text
  ERROR: for SELECT DISTINCT, ORDER BY expressions must appear in select list
  ```
  With DISTINCT, ORDER BY can only use the columns you selected.

## Try it yourself

1. The video's task: which categories have an item under ₹40? Use DISTINCT and WHERE.
2. Which different prices does the Snack category have?
3. How many different `category, price` pairs cost more than 30?

## Answers

1. ```sql
   SELECT DISTINCT category FROM menu_items WHERE price < 40 ORDER BY category;
   ```
   **Chai** and **Snack**. Coffee is missing: Filter Coffee costs exactly 40, and 40 is not under 40.
2. ```sql
   SELECT DISTINCT price FROM menu_items WHERE category = 'Snack' ORDER BY price;
   ```
   5 prices: 25, 30, 35, 60, 70.
3. ```sql
   SELECT DISTINCT category, price FROM menu_items WHERE price > 30 ORDER BY category, price;
   ```
   5 pairs: Coffee 40, Coffee 80, Snack 35, Snack 60, Snack 70.

## Next

[M05-L01 · Numbers: Integer, Numeric, Float](../../m05-data-types/m05-l01-numbers-integer-numeric-float/)
