# M19-L04 · Row-Level Security: Each Branch Sees Only Its Own Data

> Video: Module 19, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- Why `GRANT` is not enough: it opens the whole table, not "only these rows"
- **Row-level security** (RLS): a rule the database checks on every single row
- `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` and `CREATE POLICY ... USING (...)`
- How one query gives each role a different answer, and how the rule also checks new rows
- Why you must test with `SET ROLE`, never as `postgres`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- Connect as `postgres`, as in [M19-L01](../m19-l01-users-and-roles-grant-and-revoke-least-privilege/).
- This lesson **adds** a table, `branch_orders`, and two demo roles, `pune` and `delhi`. They have **no password** and **cannot log in**: you act as them with `SET ROLE`.
- Roles belong to the whole server. If `pune` or `delhi` already exist, skip those `CREATE ROLE` lines.

## Files in this folder

| File | What it is |
|---|---|
| `row_level_security.sql` | Every statement from the video in order, with the real result as a comment |
| `setup.sql` | DB update 12: `branch_orders` with its 7 rows, the roles, the grants, RLS on and the policy `own_branch`. Only for a rebuild |

## Follow along

The Pune manager opens the orders table and sees every branch, not just Pune. `GRANT` is the door to the room: once you are inside, you see every row. **Row-level security** adds a rule, and the database checks it on every single row. Our rule: show a row only if its branch matches the user's name. Pune sees Pune's rows; Delhi sees Delhi's rows.

### 1. A small table

```sql
CREATE TABLE branch_orders (
  order_id int PRIMARY KEY,
  branch   text NOT NULL,
  total    int NOT NULL
);
```

```sql
INSERT INTO branch_orders VALUES
  (1, 'pune', 120),
  (2, 'delhi', 80),
  (3, 'pune', 45),
  (4, 'mumbai', 200),
  (5, 'delhi', 60),
  (6, 'pune', 90);
```

Six orders from three branches: Pune, Delhi and Mumbai. The branch names are written in lower case, exactly like the role names.

### 2. One role per branch

```sql
CREATE ROLE pune;
CREATE ROLE delhi;
```

```sql
GRANT SELECT, INSERT ON branch_orders TO pune, delhi;
```

### 3. Before RLS: Pune sees everything

```sql
SET ROLE pune;
```

```sql
SELECT current_user, *
FROM branch_orders;
```

You should see all six rows:

| current_user | order_id | branch | total |
|---|---|---|---|
| pune | 1 | pune | 120 |
| pune | 2 | delhi | 80 |
| pune | 3 | pune | 45 |
| pune | 4 | mumbai | 200 |
| pune | 5 | delhi | 60 |
| pune | 6 | pune | 90 |

The grant opened the whole table.

### 4. Turn on row-level security

Back to `postgres` first:

```sql
RESET ROLE;
```

```sql
ALTER TABLE branch_orders
ENABLE ROW LEVEL SECURITY;
```

### 5. On, but no rule yet

```sql
SET ROLE pune;
```

```sql
SELECT current_user, *
FROM branch_orders;
```

**0 rows.** Security is on, but there is no rule yet, so nobody sees anything.

### 6. Write the rule

A **policy** is the rule each row must pass. `USING (...)` is the check; `current_user` is the role you are acting as.

```sql
RESET ROLE;
```

```sql
CREATE POLICY own_branch
ON branch_orders
USING (branch = current_user);
```

### 7. As Pune

```sql
SET ROLE pune;
```

```sql
SELECT current_user, *
FROM branch_orders;
```

| current_user | order_id | branch | total |
|---|---|---|---|
| pune | 1 | pune | 120 |
| pune | 3 | pune | 45 |
| pune | 6 | pune | 90 |

Three rows: orders 1, 3 and 6. Only Pune's orders.

### 8. As Delhi

```sql
RESET ROLE;
SET ROLE delhi;
```

```sql
SELECT current_user, *
FROM branch_orders;
```

| current_user | order_id | branch | total |
|---|---|---|---|
| delhi | 2 | delhi | 80 |
| delhi | 5 | delhi | 60 |

Two rows: orders 2 and 5. The same query gives each role a different answer. Nobody changed the query: the database adds the rule by itself.

### 9. The rule also checks new rows

As Pune, insert an order for Delhi:

```sql
RESET ROLE;
SET ROLE pune;
```

```sql
INSERT INTO branch_orders
VALUES (7, 'delhi', 500);
```

```text
ERROR: new row violates row-level security policy for table "branch_orders"   (SQLSTATE 42501)
```

### 10. Pune adds its own order

```sql
INSERT INTO branch_orders
VALUES (7, 'pune', 50);
```

```sql
SELECT current_user, *
FROM branch_orders;
```

It works, and Pune now sees four rows: orders 1, 3, 6 and 7.

### 11. As postgres

```sql
RESET ROLE;
```

```sql
SELECT current_user, *
FROM branch_orders;
```

All **seven** rows, with `current_user` postgres. The table's owner and superusers skip the rules.

## Common mistakes

1. **Testing as postgres.** You see every row and think the rule is broken. Test with `SET ROLE` instead.
2. **Turning on row-level security with no policy.** Every user sees zero rows. Create the policy straight away.
3. **Creating a policy but forgetting to enable row-level security.** Then the rule does nothing, and everyone sees everything.

## Try it yourself

1. After Pune's new order, Delhi counts the rows in `branch_orders`. What number comes back? (The video's task.)
2. As `delhi`, try `INSERT INTO branch_orders VALUES (8, 'delhi', 70);`. Does it work? How many rows does Delhi see now?
3. Which rows would a new role `mumbai` see, once it has `SELECT` on the table?

## Answers

1. **2.** Pune's new order stays hidden from Delhi.

   ```sql
   SET ROLE delhi;

   SELECT count(*) AS orders
   FROM branch_orders;

   RESET ROLE;
   ```

2. Yes, it is Delhi's own branch: Delhi now sees 3 rows (2, 5 and 8). To get back to the video's state, run `RESET ROLE;` then `DELETE FROM branch_orders WHERE order_id = 8;` as postgres.
3. Only order 4 (mumbai, 200). The same policy works for every role whose name matches a branch.

## Next

[M20-L01 · Connecting from Python: psycopg and Safe Queries](../../m20-sql-from-code/m20-l01-connecting-from-python-psycopg-and-running-safe-queries/)
