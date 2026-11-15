# M20-L03 · Migrations: Changing a Live Database Safely

> Video: Module 20, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What a **migration** is: a small, numbered SQL file that changes the database, run once, in order, on every copy
- A table, `schema_migrations`, that remembers which numbers already ran
- Wrapping each migration in `BEGIN` ... `COMMIT`, so all its changes happen together or not at all
- Why a migration must never run twice, and how tools like Flyway and Alembic use the list
- Adding a required (`NOT NULL`) column to a table that already has rows: add, fill, then require

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (the video runs every file in a DBeaver SQL editor; `psql` works too).
- This lesson **changes** the database (DB update 13): it creates `schema_migrations` and adds `customers.phone` and `customers.signup_year`. Later lessons expect these.

## Files in this folder

| File | What it is |
|------|------------|
| `000_schema_migrations.sql` | Migration 000: the list of versions that already ran |
| `001_add_customer_phone.sql` | Migration 1: adds `customers.phone` and records version 1 |
| `002_add_signup_year.sql` | Migration 2: a required column in three steps (add, fill, require), then a check |
| `checks.sql` | The other queries the video runs: the list, the two errors, the result |
| `setup.sql` | Catch-up only: the same end state as 000-002, safe to run again. Use it only if you skip the lesson |

## Follow along

### 1. The idea

If you change a live database by hand, nobody knows what changed, and the other copies (your laptop, the test server, the live one) fall behind. Instead, every change is a numbered file:

```text
000_schema_migrations.sql  →  the list itself
001_add_customer_phone.sql →  adds a phone column
002_add_signup_year.sql    →  adds the year each customer signed up
```

You run them in order on every copy, and the database keeps a list of the numbers it has already run, so each file runs exactly once.

### 2. The list: schema_migrations

Run `000_schema_migrations.sql`:

```sql
-- migration 000: a table that remembers which migrations ran
CREATE TABLE schema_migrations (
  version    int PRIMARY KEY,
  name       text NOT NULL,
  applied_at timestamptz NOT NULL DEFAULT now()
);
```

### 3. Migration 1

Run `001_add_customer_phone.sql` (the whole script, so all four statements run):

```sql
-- migration 001_add_customer_phone.sql
BEGIN;
ALTER TABLE customers ADD COLUMN phone text;
INSERT INTO schema_migrations (version, name) VALUES (1, 'add_customer_phone');
COMMIT;
```

You should see: 4 queries ran, 1 row went into the list. Both changes happen together, or not at all.

```sql
SELECT * FROM schema_migrations ORDER BY version;
```

You should see:

| version | name | applied_at |
|---|---|---|
| 1 | add_customer_phone | (the time you ran it) |

### 4. Running it again, by mistake

```sql
-- running migration 001 a second time, by mistake
ALTER TABLE customers ADD COLUMN phone text;
```

You should see:

```text
SQL Error [42701]: ERROR: column "phone" of relation "customers" already exists
```

The file was never meant to run twice. That is why the list matters: a migration tool reads it first and only runs the numbers that are missing. Tools like **Flyway** (Java) and **Alembic** (Python) do exactly this for you: numbered files, and a list.

### 5. A required column, in one step (the wrong way)

```sql
-- a required column, in one step
ALTER TABLE customers ADD COLUMN signup_year int NOT NULL;
```

You should see:

```text
SQL Error [23502]: ERROR: column "signup_year" of relation "customers" contains null values
```

The old rows have no value yet, so "required" is impossible.

### 6. Migration 2: add, fill, then require

Run `002_add_signup_year.sql`:

```sql
-- migration 002_add_signup_year.sql
-- a required column on a table that already has rows: add, fill, then require
BEGIN;
ALTER TABLE customers ADD COLUMN signup_year int;                         -- 1. add it, empty is allowed
UPDATE customers SET signup_year = EXTRACT(YEAR FROM joined_on)::int;    -- 2. fill every row
ALTER TABLE customers ALTER COLUMN signup_year SET NOT NULL;              -- 3. now make it required
INSERT INTO schema_migrations (version, name) VALUES (2, 'add_signup_year');
COMMIT;

-- check
SELECT * FROM schema_migrations ORDER BY version;
```

You should see: 6 queries inside one transaction, 20 rows changed (19 customers, and 1 row in the list).

```sql
SELECT customer_id, name, joined_on, signup_year
FROM customers ORDER BY customer_id LIMIT 5;
```

You should see:

| customer_id | name | joined_on | signup_year |
|---|---|---|---|
| 1 | Asha | 2024-11-11 | 2024 |
| 2 | Lukas | 2024-11-14 | 2024 |
| 3 | Priya | 2024-12-02 | 2024 |
| 4 | Rahul | 2025-01-09 | 2025 |
| 5 | Kabir | 2025-01-21 | 2025 |

And the list shows two versions:

| version | name | applied_at |
|---|---|---|
| 1 | add_customer_phone | (time) |
| 2 | add_signup_year | (time) |

The database knows exactly where it is.

## Common mistakes

- **Changing the live database by hand.** Every change goes in a numbered file.
- **Adding a required column in one step** on a table with rows. Add it, fill it, then require it, inside one transaction.
- **Editing an old migration that already ran.** It will never run again on the copies that already have it. Write a new file instead.
- Running only one line of a migration in DBeaver (Ctrl+Enter). Run the whole script (Alt+X) so `BEGIN` and `COMMIT` run too.

## Try it yourself

1. (The video's task.) You want to rename a column. Versions 1 and 2 already ran. What number is the new file?
2. Write that file: rename `customers.phone` to `mobile` and record it in the list. Do not run it on your course database if you want to keep following later lessons exactly.
3. Why is `signup_year` filled from `joined_on` inside the same transaction as `SET NOT NULL`?

## Answers

1. Three: `003_...sql`. Never edit 001 or 002.
2. For example `003_rename_phone_to_mobile.sql`:

   ```sql
   BEGIN;
   ALTER TABLE customers RENAME COLUMN phone TO mobile;
   INSERT INTO schema_migrations (version, name) VALUES (3, 'rename_phone_to_mobile');
   COMMIT;
   ```

3. If any step fails (for example a row whose year cannot be filled), the whole migration rolls back and the list does not get version 2, so you can fix it and run it again cleanly.

## Next

[M21-L01 · Cleaning Messy Data: Duplicates, Extra Spaces, Wrong Formats](../../m21-sql-for-data-analysis/m21-l01-cleaning-messy-data-duplicates-extra-spaces-wrong-formats/)
