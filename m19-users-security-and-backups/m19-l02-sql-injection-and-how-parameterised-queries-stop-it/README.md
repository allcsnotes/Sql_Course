# M19-L02 · SQL Injection, and How Parameterised Queries Stop It

> Video: Module 19, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- What **SQL injection** is: the user's text becomes part of your query
- How one typed quote turns a menu search into "give me every row"
- Why the root problem is data and code mixed in one string
- The fix, a **parameterised query**: the query and the value travel separately
- How to try it in PostgreSQL with `PREPARE`, `EXECUTE` and `DEALLOCATE`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads `menu_items`, which has 12 rows by now. Nothing in this lesson changes the database.
- Only ever try injection on your own practice database.

## Files in this folder

| File | What it is |
|---|---|
| `sql_injection.sql` | Every statement from the video in order, with the real result as a comment |

## Follow along

A search box asks for a menu item. The app glues text together: the start of the query, then whatever the user typed, then a closing quote.

```text
"SELECT name, price FROM menu_items WHERE name = '" + typed + "'"
```

- The user types `Samosa`: the query is normal, `WHERE name = 'Samosa'`.
- The user types `x' OR '1'='1`: the text becomes `WHERE name = 'x' OR '1'='1'`.

That first quote ends the name early, and the rest becomes real SQL. `'1'='1'` is always true, so every row matches. And it is not only about reading: the same trick can show other people's data, skip a password check, or even change and delete rows. The root problem is always the same: **data and code are mixed in one string**.

### 1. The normal search

```sql
SELECT name, price
FROM menu_items
WHERE name = 'Samosa';
```

You should see:

| name | price |
|---|---|
| Samosa | 25 |

### 2. What the attacker's text builds

```sql
SELECT name, price
FROM menu_items
WHERE name = 'x' OR '1'='1';
```

You should see all 12 menu items:

| name | price |
|---|---|
| Bun Maska | 35 |
| Cold Coffee | 80 |
| Cutting Chai | 20 |
| Filter Coffee | 40 |
| Ginger Chai | 30 |
| Maggi | 60 |
| Samosa | 25 |
| Vada Pav | 30 |
| Veg Sandwich | 70 |
| Kulhad Chai | 40 |
| Paneer Roll | 90 |
| Masala Chai | 30 |

The database did exactly what the text said. The text was the problem.

### 3. The fix: a placeholder

A parameterised query is sent first with a **placeholder**, `$1`. The value is sent separately, so it can never become code: it is only ever compared, as a plain name. PostgreSQL lets you try this with `PREPARE`, which saves a query under a name:

```sql
PREPARE find_item(text) AS
SELECT name, price
FROM menu_items
WHERE name = $1;
```

`find_item(text)` means the query takes one text value.

### 4. Execute with a normal value

```sql
EXECUTE find_item('Samosa');
```

You should see one row: Samosa, 25. Just like before.

### 5. Execute with the attacker's text

```sql
EXECUTE find_item('x'' OR ''1''=''1');
```

You should see **0 rows**. No menu item has that strange name, so nothing matches.

Each quote is typed twice here (`''`), because that is how you write a quote inside SQL text. In a real app, the library does this for you.

### 6. Clean up

```sql
DEALLOCATE find_item;
```

A prepared query lives until you `DEALLOCATE` it or close the connection.

In app code, use your library's placeholders. In Python with psycopg (Module 20) it looks like this:

```python
cur.execute("SELECT name, price FROM menu_items WHERE name = %s", (typed,))
```

## Common mistakes

1. **Building queries by joining strings.** Always use placeholders.
2. **Trying to clean the input yourself**, like removing quotes. Attackers find a way around it. Placeholders are safer.
3. **Forgetting least privilege** ([M19-L01](../m19-l01-users-and-roles-grant-and-revoke-least-privilege/)). If the app's role can only read, an attack cannot delete anything.

## Try it yourself

1. A login form builds `WHERE email = '` plus whatever the user typed. Is that safe? (The video's task.)
2. With `find_item` prepared again, execute it with `'Masala Chai'`. How many rows?
3. Write a prepared query `cheap_items(int)` that returns items with `price < $1`, and run it with 30.

## Answers

1. No. Use a placeholder, like `$1`: `WHERE email = $1`, with the typed email sent as a separate value.
2. One row: Masala Chai, 30.
3. ```sql
   PREPARE cheap_items(int) AS
   SELECT name, price FROM menu_items WHERE price < $1;

   EXECUTE cheap_items(30);

   DEALLOCATE cheap_items;
   ```

   Two rows: Cutting Chai 20 and Samosa 25.

## Next

[M19-L03 · Backups and Restore: pg_dump and pg_restore](../m19-l03-backups-and-restore-pg-dump-and-pg-restore/)
