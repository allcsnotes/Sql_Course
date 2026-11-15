# M12-L04 · UPSERT: INSERT ... ON CONFLICT

> Video: Module 12, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- What an **upsert** is: insert the row, or update it if it is already there, in one command
- `ON CONFLICT (column) DO NOTHING`: skip the clash quietly
- `ON CONFLICT (column) DO UPDATE SET ...`: change the row that is already there
- `EXCLUDED` (the new values) versus the table name (the old values), and a counter that adds one
- Three mistakes: no unique rule, forgetting `EXCLUDED`, the same key twice in one command

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the empty `promo_codes` table from the task of [M11-L02](../../m11-creating-tables/m11-l02-constraints/). Its `code` column has a `UNIQUE` rule.
- This lesson leaves 3 promo codes in the table.

## Files in this folder

| File | What it is |
|---|---|
| `upsert.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | The 3 promo codes as they are at the end of the lesson. Run it only if you skipped the lesson |

## Follow along

Sometimes you do not know if a row already exists. `INSERT` fails if the row exists; `UPDATE` does nothing if it is missing. An upsert does both.

### 1. Two codes, then a clash

```sql
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 10),
       ('WELCOME15', 15)
RETURNING code, discount, uses;
```

You should see:

| code | discount | uses |
|---|---|---|
| CHAI10 | 10 | 0 |
| WELCOME15 | 15 | 0 |

Now CHAI10 should give 12% off. A plain insert with the same code fails:

```sql
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 12);
```

```text
ERROR: duplicate key value violates unique constraint "promo_codes_code_key"   (SQLSTATE 23505)
  Detail: Key (code)=(CHAI10) already exists.
```

So we tell Postgres what to do when this clash happens.

### 2. Option 1: skip it

```sql
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 12)
ON CONFLICT (code) DO NOTHING
RETURNING code, discount;
```

No error this time, and no rows come back. The clash was quietly skipped, and the old discount stays at 10.

### 3. Option 2: update the row that is there

```sql
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 12)
ON CONFLICT (code)
DO UPDATE SET discount = EXCLUDED.discount
RETURNING code, discount, uses;
```

You should see: `CHAI10 | 12 | 0`. `EXCLUDED` is the row you tried to insert, so the discount becomes 12.

Run the same command with a new code, and it simply inserts:

```sql
INSERT INTO promo_codes (code, discount)
VALUES ('MONSOON20', 20)
ON CONFLICT (code)
DO UPDATE SET discount = EXCLUDED.discount
RETURNING code, discount, uses;
```

You should see: `MONSOON20 | 20 | 0`.

### 4. A counter

Someone used CHAI10. On conflict, add one to the old value. `promo_codes.uses` (the table name) means the old value:

```sql
INSERT INTO promo_codes (code, discount, uses)
VALUES ('CHAI10', 12, 1)
ON CONFLICT (code)
DO UPDATE SET uses = promo_codes.uses + 1
RETURNING code, discount, uses;
```

Run it once: `CHAI10 | 12 | 1`. Run it again: `CHAI10 | 12 | 2`. The same command works every time.

| Inside `DO UPDATE` | Means |
|---|---|
| `EXCLUDED.discount` | the new value you tried to insert |
| `promo_codes.uses` | the old value already in the table |

## Common mistakes

All three were run for real in the video.

1. **A conflict column with no unique rule.** `discount` has none.

   ```sql
   INSERT INTO promo_codes (code, discount)
   VALUES ('TEA5', 5)
   ON CONFLICT (discount) DO NOTHING;
   ```

   ```text
   ERROR: there is no unique or exclusion constraint matching the ON CONFLICT specification   (SQLSTATE 42P10)
   ```

2. **Forgetting `EXCLUDED`.** The old one, or the new one?

   ```sql
   INSERT INTO promo_codes (code, discount)
   VALUES ('WELCOME15', 18)
   ON CONFLICT (code)
   DO UPDATE SET discount = discount;
   ```

   ```text
   ERROR: column reference "discount" is ambiguous   (SQLSTATE 42702)
   ```

   Write `EXCLUDED.discount`.

3. **The same code twice in one command.**

   ```sql
   INSERT INTO promo_codes (code, discount)
   VALUES ('CHAI10', 14),
          ('CHAI10', 16)
   ON CONFLICT (code)
   DO UPDATE SET discount = EXCLUDED.discount;
   ```

   ```text
   ERROR: ON CONFLICT DO UPDATE command cannot affect row a second time   (SQLSTATE 21000)
   ```

   Remove the repeat first. None of the three changed anything.

## Try it yourself

1. WELCOME15 now gives 25% off. Use one `INSERT ... ON CONFLICT`. What discount does it show, and how many codes are there? (The video's task.)
2. Run the step 4 counter for MONSOON20 instead. What is `uses` after one run? (Then set it back: `UPDATE promo_codes SET uses = 0 WHERE code = 'MONSOON20';`.)
3. Why is `DO NOTHING` safe to run many times?

## Answers

1. ```sql
   INSERT INTO promo_codes (code, discount)
   VALUES ('WELCOME15', 25)
   ON CONFLICT (code)
   DO UPDATE SET discount = EXCLUDED.discount
   RETURNING code, discount, uses;
   ```

   Returns `WELCOME15 | 25 | 0`. Then:

   ```sql
   SELECT code, discount, uses
   FROM promo_codes
   ORDER BY code;
   ```

   | code | discount | uses |
   |---|---|---|
   | CHAI10 | 12 | 2 |
   | MONSOON20 | 20 | 0 |
   | WELCOME15 | 25 | 0 |

   Discount 25, and 3 codes.

2. `uses` is 1: the code exists, so `promo_codes.uses + 1` turns 0 into 1.
3. If the row exists it is skipped; if not, it is inserted. Running it again never makes a second copy or an error.

## Next

[M12-L05 · Importing and Exporting CSV Files](../m12-l05-importing-and-exporting-csv-files/)
