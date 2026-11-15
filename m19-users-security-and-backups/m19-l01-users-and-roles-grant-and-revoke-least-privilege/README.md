# M19-L01 · Users and Roles: GRANT, REVOKE and Least Privilege

> Video: Module 19, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a **role** is in PostgreSQL (a key card) and why a **user** is just a role that may log in
- `GRANT`: add one action on one table to a role; `REVOKE`: take it away
- How to check a role's grants in `information_schema.role_table_grants`
- How to act as another role with `SET ROLE` and come back with `RESET ROLE`
- **Least privilege**: give each role only what it really needs, and see the database say no

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- Connect as `postgres` (in DBeaver or `psql`), with the password you chose when installing.
- This lesson **adds** a demo role, `reporter`. It has **no password** and **cannot log in**: you only act as it with `SET ROLE`. No real password appears anywhere in this lesson.
- Roles belong to the whole PostgreSQL server, not to one database. If `reporter` already exists, skip `CREATE ROLE`.

## Files in this folder

| File | What it is |
|---|---|
| `users_and_roles.sql` | Every statement from the video in order, with the real result as a comment |
| `setup.sql` | Creates the demo role `reporter` (no grants, as the video leaves it). Only for a rebuild |

## Follow along

Your app only needs to read the menu, but it logs in as `postgres`, the user that can change and delete everything. One bug, or one stolen password, and any table can be wiped.

Think of the database as a building with many rooms; each table is a room. A **role** is a key card. `GRANT` adds a room to the card (you may read `menu_items`), and `REVOKE` takes it away. **Least privilege** means: give each card only the rooms it really needs, nothing more.

Every grant says three things:

| Part | Example | Choices |
|---|---|---|
| What you may do | `SELECT` | `SELECT` (read), `INSERT` (add), `UPDATE` (change), `DELETE` (remove) |
| On which table | `ON menu_items` | Any table |
| To which role | `TO reporter` | Any role |

### 1. Create a role and grant one room

```sql
CREATE ROLE reporter;
```

```sql
GRANT SELECT ON menu_items TO reporter;
```

### 2. Check the grant

```sql
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'reporter';
```

You should see:

| grantee | table_name | privilege_type |
|---|---|---|
| reporter | menu_items | SELECT |

Reporter has one privilege: `SELECT` on `menu_items`.

### 3. Act as reporter

`SET ROLE` makes every next statement run as that role, until `RESET ROLE`. Only a superuser like `postgres` (or a member of the role) can do this.

```sql
SET ROLE reporter;
```

```sql
SELECT current_user, name, price
FROM menu_items
LIMIT 5;
```

You should see:

| current_user | name | price |
|---|---|---|
| reporter | Bun Maska | 35 |
| reporter | Cold Coffee | 80 |
| reporter | Cutting Chai | 20 |
| reporter | Filter Coffee | 40 |
| reporter | Ginger Chai | 30 |

`current_user` says reporter, and the menu comes back.

### 4. What reporter cannot do

Even an update that changes nothing (`price = price`) is stopped:

```sql
UPDATE menu_items
SET price = price
WHERE name = 'Samosa';
```

```text
ERROR: permission denied for table menu_items   (SQLSTATE 42501)
```

And reading `orders`? Reporter never got that room:

```sql
SELECT *
FROM orders
LIMIT 5;
```

```text
ERROR: permission denied for table orders   (SQLSTATE 42501)
```

That is least privilege at work: the database itself says no.

### 5. Take the key back

Become `postgres` again, then revoke:

```sql
RESET ROLE;
```

```sql
REVOKE SELECT ON menu_items FROM reporter;
```

### 6. Try again as reporter

```sql
SET ROLE reporter;
```

```sql
SELECT name, price
FROM menu_items
LIMIT 5;
```

```text
ERROR: permission denied for table menu_items   (SQLSTATE 42501)
```

The grant is gone.

### 7. Back to postgres

```sql
RESET ROLE;
SELECT current_user;
```

You should see `postgres`.

A real login user is a role created `WITH LOGIN` and a password, for example `CREATE ROLE menu_app WITH LOGIN PASSWORD '...';`. The video does not create one, and you do not need one for this course.

## Common mistakes

1. **Letting the app log in as postgres.** Make a separate role for each app, with only what it needs.
2. **`GRANT ALL`, just to make an error go away.** Grant only the exact actions, on the exact tables.
3. **Forgetting to clean up.** When a person leaves or a tool is retired, revoke its access or drop the role (`DROP ROLE reporter;`).

## Try it yourself

1. A `dashboard` role must read `orders`, but never change them. What do you run? (The video's task.)
2. Give `reporter` the right to read **and add** rows to `menu_items`, check it in `role_table_grants`, then revoke both.
3. What does `SELECT current_user;` return right after `SET ROLE reporter;`?

## Answers

1. Only `SELECT`:

   ```sql
   GRANT SELECT ON orders TO dashboard;
   ```

   To try it, create the demo role first (`CREATE ROLE dashboard;`). As `dashboard`, `SELECT count(*) FROM orders` returns 3900, and any `UPDATE` gives `permission denied for table orders`. Clean up with `REVOKE SELECT ON orders FROM dashboard;` and `DROP ROLE dashboard;`.

2. ```sql
   GRANT SELECT, INSERT ON menu_items TO reporter;
   ```

   `role_table_grants` shows two rows (INSERT and SELECT). Then `REVOKE SELECT, INSERT ON menu_items FROM reporter;`.

3. `reporter`.

## Next

[M19-L02 · SQL Injection, and How Parameterised Queries Stop It](../m19-l02-sql-injection-and-how-parameterised-queries-stop-it/)
