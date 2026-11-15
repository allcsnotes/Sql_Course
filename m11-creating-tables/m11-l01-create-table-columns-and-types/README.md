# M11-L01 · CREATE TABLE: Columns and Types

> Video: Module 11, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- How to plan a table: one column for each fact, and a type for each column
- The `CREATE TABLE` shape: a name, brackets, one column per line, commas between columns
- How to check a new table with `information_schema.columns`
- `IF NOT EXISTS`, so a script can run again safely
- Three beginner mistakes and the real errors they give

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner`, or `psql`.
- Until now every table was already there and you only read from it. Today you build two new tables yourself: `suppliers` and (in the task) `feedback`. Later lessons in Modules 11 to 13 use both.

## Files in this folder

| File | What it is |
|---|---|
| `create_table.sql` | Every query from the video in order, with the real result as a comment |
| `setup.sql` | The tables this lesson adds (`suppliers` with 3 rows, empty `feedback`). Run it only if you skipped the lesson; following along makes the same tables |

## Follow along

Think of a fresh register book. Before you write any rows, you draw the header: a name for each column, and what kind of thing goes in it. That header is what `CREATE TABLE` makes.

### 1. Plan the table

Meera buys tea leaves, milk and snacks from a few suppliers. For each one she wants a number, a name, a city, what they supply, since when, and a rating. Each fact becomes a column, and each column needs a type:

| Column | Type | Why |
|---|---|---|
| `supplier_id` | `int` | a whole number |
| `name` | `varchar(60)` | words, at most 60 characters |
| `city` | `varchar(30)` | words, at most 30 characters |
| `supplies` | `text` | words of any length |
| `since` | `date` | a day |
| `rating` | `numeric(2,1)` | like 4.5: two digits in total, one after the point |

### 2. Write the table

Start with `CREATE TABLE` and the name, then open a bracket. List the columns one per line: a name, then a type. Put a comma between columns, but not after the last one. `PRIMARY KEY` on `supplier_id` means every supplier gets one unique number (you met keys in Module 8). Close the bracket and end with a semicolon.

```sql
CREATE TABLE suppliers (
  supplier_id int PRIMARY KEY,
  name        varchar(60),
  city        varchar(30),
  supplies    text,
  since       date,
  rating      numeric(2,1)
);
```

You should see: `Updated Rows 0`. The table is made, and it is still empty.

> DBeaver tip: if the new table does not show up in the Database Navigator or in autocomplete, disconnect and connect again.

### 3. Check the table

The database keeps a list of every column in `information_schema.columns`. Ask it about `suppliers`:

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'suppliers'
ORDER BY ordinal_position;
```

You should see:

| column_name | data_type |
|---|---|
| supplier_id | integer |
| name | character varying |
| city | character varying |
| supplies | text |
| since | date |
| rating | numeric |

`varchar` shows its full name: `character varying`. And the table itself has headers but no rows yet:

```sql
SELECT * FROM suppliers;
```

You should see the six column headers and no rows.

### 4. Put some rows in

`INSERT INTO` adds rows, with the values in the same order as the columns. Module 12 explains it fully.

```sql
INSERT INTO suppliers VALUES
  (1, 'Nilgiri Tea Co', 'Coonoor', 'tea leaves', '2019-03-01', 4.5),
  (2, 'Pune Dairy', 'Pune', 'milk', '2019-04-10', 4.8),
  (3, 'Sahyadri Snacks', 'Pune', 'samosa, vada pav', '2021-06-15', 4.2);
```

You should see: `Updated Rows 3`.

```sql
SELECT * FROM suppliers;
```

You should see:

| supplier_id | name | city | supplies | since | rating |
|---|---|---|---|---|---|
| 1 | Nilgiri Tea Co | Coonoor | tea leaves | 2019-03-01 | 4.5 |
| 2 | Pune Dairy | Pune | milk | 2019-04-10 | 4.8 |
| 3 | Sahyadri Snacks | Pune | samosa, vada pav | 2021-06-15 | 4.2 |

### 5. Safe to run again: IF NOT EXISTS

```sql
CREATE TABLE IF NOT EXISTS suppliers (
  supplier_id int PRIMARY KEY,
  name        varchar(60)
);
```

You should see `Updated Rows 0`, and in the Output panel (DBeaver: SQL Editor > Panels > Show server output):

```text
relation "suppliers" already exists, skipping
```

Postgres skipped it, and the real `suppliers` table is untouched.

## Common mistakes

All three were run for real in the video.

1. **Running the same `CREATE TABLE` twice.**

   ```text
   ERROR: relation "suppliers" already exists   (SQLSTATE 42P07)
   ```

   Fix: `CREATE TABLE IF NOT EXISTS`, as in step 5.

2. **A missing comma between two columns.** Postgres reads on and stops at the next word.

   ```sql
   CREATE TABLE deliveries (
     delivery_id int PRIMARY KEY
     item        varchar(40)
   );
   ```

   ```text
   ERROR: syntax error at or near "item"   (SQLSTATE 42601)
   ```

   Fix: a comma after every column except the last.

3. **A type from another database**, like `number` from Oracle.

   ```sql
   CREATE TABLE deliveries (
     delivery_id int PRIMARY KEY,
     cost        number
   );
   ```

   ```text
   ERROR: type "number" does not exist   (SQLSTATE 42704)
   ```

   Fix: use the Postgres name, `numeric`, for exact decimals.

## Try it yourself

1. Create a `feedback` table with five columns: a feedback ID, a customer ID, a rating, a comment, and the date it was given. Then check its columns. (The video's task. Later lessons use this table, so do create it.)
2. Which type would you pick for a price like ₹30.50, and why not `int`?
3. Write the `information_schema.columns` query for the `menu_items` table.

## Answers

1. ```sql
   CREATE TABLE feedback (
     feedback_id int PRIMARY KEY,
     customer_id int,
     rating      int,
     comment     text,
     given_on    date
   );

   SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'feedback'
   ORDER BY ordinal_position;
   ```

   You should see 5 rows: `feedback_id`, `customer_id` and `rating` are `integer`, `comment` is `text`, `given_on` is `date`.

2. `numeric(6,2)` (or similar): an exact decimal. `int` can only hold whole numbers.

3. ```sql
   SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'menu_items'
   ORDER BY ordinal_position;
   ```

## Next

[M11-L02 · Constraints](../m11-l02-constraints/)
