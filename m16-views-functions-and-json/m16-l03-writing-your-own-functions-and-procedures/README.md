# M16-L03 · Writing Your Own Functions and Procedures

> Video: Module 16, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What a **function** is: input in, one answer out, used inside `SELECT`
- What a **procedure** is: it does a job (like inserting a row), run with `CALL`
- How to write both in plain SQL, with the body between `$$` signs
- How to use a function on its own and inside a bigger query
- Three mistakes: `SELECT` on a procedure, the wrong input type, and creating twice

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the `sales` table and the `newsletter` table (5 sign-ups after [M16-L02](../m16-l02-materialized-views-saving-the-result-for-speed/)).
- This lesson **changes the database**: two functions, one procedure, and one new sign-up (Neha).

## Files in this folder

| File | What it is |
|---|---|
| `functions_procedures.sql` | Every statement from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | What this lesson leaves in the database: `cups_for`, `item_cups`, `add_signup`, Neha's sign-up. Safe to run again |

## Follow along

Some calculations you write again and again, like the cups sold by one branch. Give that calculation a name, pass it an input, and get the answer back.

```text
function:  'Pune'          -> cups_for   -> 3827           (returns a value)
procedure: 'neha@mail.com' -> add_signup -> new newsletter row (does a job)
```

### 1. Write a function

`CREATE FUNCTION`, the name `cups_for`, and inside the brackets the input: `b`, of type `text`. `RETURNS bigint` says the answer is a whole number; `LANGUAGE sql` says the body is plain SQL. The body sits between two pairs of dollar signs (`$$`).

```sql
CREATE FUNCTION cups_for(b text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE branch = b;
$$;
```

DBeaver says **Updated Rows: 0** (psql prints `CREATE FUNCTION`): you only saved the function.

### 2. Use it

```sql
SELECT cups_for('Pune');
```

You should see `3827`.

Use it inside a bigger query too: for each branch, call `cups_for` on that branch.

```sql
SELECT DISTINCT branch, cups_for(branch) AS cups
FROM sales
ORDER BY branch;
```

| branch | cups |
|---|---|
| Delhi | 1269 |
| Mumbai | 2439 |
| Pune | 3827 |

### 3. Write a procedure

`CREATE PROCEDURE add_signup` takes an email, `e`. Its body inserts a new row into the `newsletter` table.

```sql
CREATE PROCEDURE add_signup(e text) LANGUAGE sql AS $$
  INSERT INTO newsletter (email, joined_on) VALUES (e, '2026-03-12');
$$;
```

### 4. Run it with CALL

```sql
CALL add_signup('neha@mail.com');

SELECT COUNT(*) AS people FROM newsletter;
```

You should see `6`. The procedure did its job.

## Common mistakes

All three were run for real in the video.

1. **Running a procedure with `SELECT`.**

   ```sql
   SELECT add_signup('ravi@mail.com');
   ```

   ```text
   ERROR: add_signup(unknown) is a procedure   (SQLSTATE 42809)
   HINT: To call a procedure, use CALL.
   ```

   Fix: `CALL add_signup(...)`. (Nothing was inserted: the statement failed.)

2. **Passing the wrong type.** `cups_for` needs text, but this passes the number 42:

   ```sql
   SELECT cups_for(42);
   ```

   ```text
   ERROR: function cups_for(integer) does not exist   (SQLSTATE 42883)
   ```

   Fix: put the input in quotes: `cups_for('Pune')`.

3. **Running `CREATE FUNCTION` twice.**

   ```text
   ERROR: function "cups_for" already exists with same argument types   (SQLSTATE 42723)
   ```

   Fix: use `CREATE OR REPLACE FUNCTION` to change it:

   ```sql
   CREATE OR REPLACE FUNCTION cups_for(b text) RETURNS bigint LANGUAGE sql AS $$
     SELECT SUM(qty) FROM sales WHERE branch = b;
   $$;
   ```

## Try it yourself

1. Write a function that returns the cups for one item, and try it on Masala Chai. (The video's task.)
2. Use `item_cups` inside a query: every item on `menu_items` with its cups.
3. Write a function `revenue_for(b text)` that returns `SUM(qty * price)` for one branch, and try it on Delhi.

## Answers

1. ```sql
   CREATE FUNCTION item_cups(i text) RETURNS bigint LANGUAGE sql AS $$
     SELECT SUM(qty) FROM sales WHERE item = i;
   $$;

   SELECT item_cups('Masala Chai');
   ```

   `1382`.

2. `SELECT name, item_cups(name) AS cups FROM menu_items ORDER BY cups DESC NULLS LAST;` Masala Chai 1382 comes first; Kulhad Chai and Paneer Roll show NULL because the `sales` table has no rows for them.

3. ```sql
   CREATE FUNCTION revenue_for(b text) RETURNS bigint LANGUAGE sql AS $$
     SELECT SUM(qty * price) FROM sales WHERE branch = b;
   $$;
   SELECT revenue_for('Delhi');
   ```

   `45015`. (Drop it afterwards with `DROP FUNCTION revenue_for(text);` to keep your database like the course's.)

## Next

[M16-L04 · Triggers: Running Code When Data Changes](../m16-l04-triggers-running-code-when-data-changes/)
