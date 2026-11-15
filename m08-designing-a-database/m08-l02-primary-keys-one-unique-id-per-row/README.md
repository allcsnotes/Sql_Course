# M08-L02 · Primary Keys: One Unique ID per Row

> Video: Module 8, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- What a **primary key** is: one value that points to exactly one row, like a roll number in a class
- Its two rules: it never repeats and it is never empty
- The errors PostgreSQL gives when you break a rule (`23505` and `23502`)
- How to ask the database which column is the key of each table
- Why `order_id`, the row number and `email` would all be bad keys

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner`, with a new SQL editor.
- The two `INSERT` statements fail on purpose, so nothing in the database changes.

## Files in this folder

| File | What it is |
|---|---|
| `primary_keys.sql` | Every statement of the video, in order, with the result or error as a comment |

## Follow along

### 1. Look at the customers table

```sql
SELECT customer_id, name, joined_on FROM customers ORDER BY customer_id;
```

You should see 15 rows, `customer_id` 1 to 15, no number twice:

| customer_id | name | joined_on |
|---|---|---|
| 1 | Asha | 2024-11-11 |
| 2 | Lukas | 2024-11-14 |
| 3 | Priya | 2024-12-02 |
| ... | ... | ... |
| 7 | Rohan | 2025-03-05 |
| ... | ... | ... |
| 15 | Kiran | 2026-06-10 |

In DBeaver a small **key icon** sits next to `customer_id` in the column header. It means: this column is the primary key.

### 2. One ID, one row

```sql
SELECT * FROM customers WHERE customer_id = 7;
```

You should see exactly one row:

| customer_id | name | joined_on | email |
|---|---|---|---|
| 7 | Rohan | 2025-03-05 | rohan@example.com |

### 3. Rule 1: no repeats

Add a branch in Goa with `branch_id` 1. Pune already has ID 1.

```sql
INSERT INTO branches VALUES (1, 'Goa', '2026-11-14');
```

PostgreSQL refuses:

```text
SQL Error [23505]: ERROR: duplicate key value violates unique constraint "branches_pkey"
  Detail: Key (branch_id)=(1) already exists.
```

### 4. Rule 2: never empty

The same branch with no ID at all (`NULL` means "no value"):

```sql
INSERT INTO branches VALUES (NULL, 'Goa', '2026-11-14');
```

Refused again:

```text
SQL Error [23502]: ERROR: null value in column "branch_id" of relation "branches" violates not-null constraint
  Detail: Failing row contains (null, Goa, 2026-11-14).
```

Both inserts failed, so nothing changed. The database guards the key for you.

### 5. Find the keys in our tables

This query asks the database itself (`information_schema` is a set of built-in tables that describe your tables). Every primary key is named `<table>_pkey`:

```sql
SELECT table_name, column_name
FROM information_schema.key_column_usage
WHERE constraint_name LIKE '%pkey'
ORDER BY table_name;
```

You should see:

| table_name | column_name |
|---|---|
| branches | branch_id |
| customers | customer_id |
| menu_items | item_id |
| sales | sale_id |

The pattern: each key is a plain number, named after its table. The number means nothing by itself; its only job is to name one row.

## Common mistakes

**1. Picking a column that repeats.**

```sql
SELECT COUNT(*) AS sale_rows,
       COUNT(DISTINCT order_id) AS different_orders
FROM sales;
```

| sale_rows | different_orders |
|---|---|
| 6028 | 3000 |

One order has many rows, so `order_id` cannot be the key of `sales`.

**2. Thinking the row number is the ID.**

```sql
SELECT item_id, name, price FROM menu_items ORDER BY price;
```

Row 1 is `item_id` 3 (Cutting Chai, 20), row 2 is `item_id` 8 (Samosa, 25). The numbers on the far left are just DBeaver counting rows.

**3. Using a column that can be empty.**

```sql
SELECT COUNT(*) AS customers,
       COUNT(email) AS with_email
FROM customers;
```

| customers | with_email |
|---|---|
| 15 | 11 |

Only 11 of 15 customers gave an email. A key can never be empty, so `email` cannot be the key.

## Try it yourself

1. Prove that `item_id` is unique in `menu_items`: count the rows, and count the different item IDs. Guess first, then run it.
2. Could `name` be the key of `customers`? What could go wrong later?
3. Try to add a menu item with `item_id` 3. Which constraint name does the error show?

## Next

[M08-L03 · Foreign Keys: Linking Tables Together](../m08-l03-foreign-keys-linking-tables-together/)

## Answers

1. Both numbers are 10, so no ID repeats:
   ```sql
   SELECT COUNT(*) AS item_rows,
          COUNT(DISTINCT item_id) AS different_ids
   FROM menu_items;
   ```
   | item_rows | different_ids |
   |---|---|
   | 10 | 10 |
2. The 15 names are different today, but two customers can share a name (like two students in a class), and a name can change. Keep the plain number `customer_id`.
3. `INSERT INTO menu_items (item_id, name, price, category) VALUES (3, 'Test', 10, 'Chai');` fails with `duplicate key value violates unique constraint "menu_items_pkey"` and `Key (item_id)=(3) already exists.`
