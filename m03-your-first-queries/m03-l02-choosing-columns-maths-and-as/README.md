# M03-L02 · Choosing Columns, Maths and AS

> Video: Module 3, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- How to choose only the columns you want, in the order you want
- How to do maths on every row: `+`, `-`, `*` (times) and `/` (divide)
- How to name a result column with `AS`
- Why `35 / 2` gives `17` in PostgreSQL, and how `2.0` keeps the decimals
- Three beginner mistakes: a missing comma, an extra comma, a misspelled column

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- A DBeaver SQL editor on `chai_corner` ([M03-L01](../m03-l01-select-and-from-reading-a-table/)), or psql with `\c chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The six queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes, with what really happens |

## Follow along

`SELECT *` showed every column. Often you want less: Chai Corner's price board only shows two things, the name and the price.

### 1. Choose your columns

Instead of the star, write the column names, with a comma between them:

```sql
SELECT name, price FROM menu_items;
```

You should see the same ten rows, but only two columns:

| name | price |
|---|---|
| Bun Maska | 35 |
| Cold Coffee | 80 |
| Cutting Chai | 20 |
| Filter Coffee | 40 |
| Ginger Chai | 30 |
| Maggi | 60 |
| Masala Chai | 30 |
| Samosa | 25 |
| Vada Pav | 30 |
| Veg Sandwich | 70 |

The order is up to you:

```sql
SELECT price, name FROM menu_items;
```

Now `price` comes first (35 Bun Maska, 80 Cold Coffee, ...).

### 2. Maths in a query

What do two cups cost? Add a third item to the list. Here the star means **times**:

```sql
SELECT name, price, price * 2 FROM menu_items;
```

The database does the maths for every row:

| name | price | ?column? |
|---|---|---|
| Bun Maska | 35 | 70 |
| Cold Coffee | 80 | 160 |
| Cutting Chai | 20 | 40 |
| ... | ... | ... |

(10 rows.) You can add, subtract, multiply and divide: `+`, `-`, `*`, `/`.

Look at the column name: `?column?`. PostgreSQL did the maths but has no idea what to call it.

### 3. Give it a name with AS

```sql
SELECT name, price, price * 2 AS two_cups FROM menu_items;
```

Same numbers, but now the column is called `two_cups`:

| name | price | two_cups |
|---|---|---|
| Bun Maska | 35 | 70 |
| Cold Coffee | 80 | 160 |
| Cutting Chai | 20 | 40 |
| ... | ... | ... |

`AS` only changes the label in the answer. The table itself does not change at all. Pick short names, in small letters, with underscores instead of spaces: `two_cups`, `half_price`, not `Two Cups`.

### 4. The division surprise

Let's halve the prices. The first item costs 35: guess, what is half of 35?

```sql
SELECT name, price, price / 2 AS half FROM menu_items;
```

| name | price | half |
|---|---|---|
| Bun Maska | 35 | **17** |
| Cold Coffee | 80 | 40 |
| ... | ... | ... |
| Samosa | 25 | **12** |

PostgreSQL says **17**, not 17.5. `price` is a whole number and `2` is a whole number: whole number divided by whole number gives a whole number. The .5 is simply thrown away.

The fix: write `2.0`.

```sql
SELECT name, price, price / 2.0 AS half FROM menu_items;
```

| name | price | half |
|---|---|---|
| Bun Maska | 35 | 17.5 |
| Cold Coffee | 80 | 40 |
| Cutting Chai | 20 | 10 |
| ... | ... | ... |
| Samosa | 25 | 12.5 |

One decimal in the maths, and the result keeps its decimals. DBeaver shows `17.5`; psql shows the same value as `17.5000000000000000`.

## Common mistakes

- **A missing comma (the sneaky one).** There is **no error**:
  ```sql
  SELECT name price FROM menu_items;
  ```
  PostgreSQL thinks `price` is a new name for the `name` column. You get **one** column, called `price`, full of names (Bun Maska, Cold Coffee, ...).
- **An extra comma just before FROM.**
  ```sql
  SELECT name, price, FROM menu_items;
  ```
  ```text
  ERROR: syntax error at or near "FROM"
  ```
  The comma promised one more column, and none came.
- **A misspelled column.**
  ```sql
  SELECT nme, price FROM menu_items;
  ```
  ```text
  ERROR: column "nme" does not exist
  Hint: Perhaps you meant to reference the column "menu_items.name".
  ```
  PostgreSQL even suggests the right name.

## Try it yourself

1. The video's task: show every item's name and the price of three cups, named `three_cups`. What do three Masala Chais cost?
2. Show each item's name and its price with ₹5 off, named `after_discount`.
3. Show each item's name and a third of its price, named `third`, keeping the decimals.

## Answers

1. ```sql
   SELECT name, price * 3 AS three_cups FROM menu_items;
   ```
   Three Masala Chais cost **90** (30 × 3). Bun Maska 105, Cold Coffee 240.
2. ```sql
   SELECT name, price - 5 AS after_discount FROM menu_items;
   ```
   Bun Maska 30, Cutting Chai 15, Masala Chai 25.
3. ```sql
   SELECT name, price / 3.0 AS third FROM menu_items;
   ```
   Masala Chai 10, Bun Maska 11.666... (with `price / 3` you would get 11).

## Next

[M03-L03 · WHERE: Keeping Only the Rows You Want](../m03-l03-where-keeping-only-the-rows-you-want/)
