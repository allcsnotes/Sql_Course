# M20-L01 · Connecting from Python: psycopg and Safe Queries

> Video: Module 20, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a **driver** is: a small library that lets Python talk to PostgreSQL (for Python, the most used one is **psycopg**)
- Installing psycopg in a virtual environment, and asking for the password with `getpass` so it is never saved in a file
- `psycopg.connect`, a **cursor**, `execute` and `fetchall`: rows come back as **tuples** (small, fixed lists of values)
- Passing a value with the `%s` placeholder, and why pasting it into the SQL with an f-string lets an attacker read every row
- Three mistakes: a password in the code, SQL built with an f-string, quotes around `%s`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). This lesson only reads `menu_items` (12 items).
- PostgreSQL running on your computer (`localhost`, user `postgres`), and the password you chose when installing.
- Python 3.14 or newer (`python3 --version`). The video used Python on a Mac; the same steps work on Windows with `.venv\Scripts\python` instead of `.venv/bin/python`.
- A terminal opened in this folder (your project folder).

## Files in this folder

| File | What it is |
|------|------------|
| `demo.py` | The script the video runs: connect, read the menu, a safe `%s` query, the f-string attack, and the quotes-around-`%s` mistake |
| `requirements.txt` | The pinned driver version the video installed: `psycopg[binary]==3.3.9` |

## Follow along

### 1. The picture

Python cannot speak to PostgreSQL by itself. It needs a **driver**, a small library that knows the database's language:

```text
your code (Python)  →  the driver (psycopg)  →  the database (PostgreSQL, chai_corner)
```

Your code hands psycopg a query, psycopg sends it to PostgreSQL, and the rows come back to Python as tuples, like `('Paneer Roll', 90)`.

### 2. Install psycopg

Make a **virtual environment** (a private box for this project's packages), then install psycopg with `binary` in square brackets. Binary brings a ready-made build, so nothing needs compiling.

```bash
python3 -m venv .venv
.venv/bin/python -m pip install "psycopg[binary]"
```

You should see (the last line):

```text
Successfully installed psycopg-3.3.9 psycopg-binary-3.3.9
```

To get exactly the version from the video, you can instead run `.venv/bin/python -m pip install -r requirements.txt`.

### 3. Connect and read the menu

The first part of `demo.py`:

```python
import getpass
import psycopg

password = getpass.getpass("Database password: ")

with psycopg.connect(host="localhost", dbname="chai_corner",
                     user="postgres", password=password) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3")
        for row in cur.fetchall():
            print(row)
```

- `getpass` asks for the password when the script runs. It is typed, never saved in the file, and not shown on screen.
- `psycopg.connect` opens the connection (host, database name, user, password). The `with` block closes it for you at the end.
- A **cursor** runs queries: `execute` sends the SQL, `fetchall` brings back every row.

Run it and type the password you chose when installing:

```bash
.venv/bin/python demo.py
```

You should see (first part of the output):

```text
Database password:
psycopg 3.3.9

--- 1. top 3 by price ---
('Paneer Roll', 90)
('Cold Coffee', 80)
('Veg Sandwich', 70)
```

### 4. A value from a user: the `%s` placeholder

Say a customer types an item name. Never paste it into the SQL text. Put `%s` where the value goes, and pass the value on its own, in a tuple:

```python
for item in ["Samosa", "x' OR '1'='1"]:
    cur.execute("SELECT name, price FROM menu_items WHERE name = %s", (item,))
    rows = cur.fetchall()
    print(repr(item), "->", len(rows), "row(s)", rows)
```

You should see:

```text
--- 2. safe: %s placeholder ---
'Samosa' -> 1 row(s) [('Samosa', 25)]
"x' OR '1'='1" -> 0 row(s) []
```

The second value is an attacker's text: a quote, then `OR '1'='1`. With `%s` it stays a plain name. No item has that name, so zero rows.

### 5. The same text in an f-string

```python
item = "x' OR '1'='1"
cur.execute(f"SELECT name, price FROM menu_items WHERE name = '{item}'")
print(repr(item), "->", len(cur.fetchall()), "row(s)")
```

You should see:

```text
--- 3. unsafe: f-string ---
"x' OR '1'='1" -> 12 row(s)
```

Pasted in, the text becomes part of the SQL: `WHERE name = 'x' OR '1'='1'`. `'1'='1'` is true for every row, so all 12 rows leak out. This is **SQL injection** (more in [M19-L02](../../m19-users-security-and-backups/m19-l02-sql-injection-and-how-parameterised-queries-stop-it/)).

### 6. Quotes around `%s`

The last part of `demo.py` shows mistake 3:

```python
cur.execute("SELECT name FROM menu_items WHERE name = '%s'", ("Samosa",))
```

You should see:

```text
--- 4. mistake: quotes around %s ---
IndeterminateDatatype: could not determine data type of parameter $1
```

psycopg adds the quoting itself. Write `%s` bare, with no quotes.

## Common mistakes

- **Writing the password in the code** (`password = "my-secret"`). Anyone who opens the file can read it. Use `getpass`, or an environment variable.
- **Building SQL with an f-string, or with plus signs.** That is the door to SQL injection. Every value goes in through `%s`, with the values in a tuple.
- **Putting quotes around `%s`.** You get `could not determine data type of parameter $1`.
- Forgetting the comma in a one-value tuple: `(item,)` is a tuple, `(item)` is just `item`.

## Try it yourself

1. (The video's task.) Find the items cheaper than a price the user types. What goes after `<` in `WHERE price < ?`
2. Change the first query to show the 3 cheapest items instead.
3. Ask the user for an item name with `input()` and print its price, safely.

## Answers

1. `%s`, with the price passed in a tuple:

   ```python
   cur.execute("SELECT name FROM menu_items WHERE price < %s", (limit,))
   ```

   With `limit = 30` you get `[('Cutting Chai',), ('Samosa',)]`.
2. `ORDER BY price ASC LIMIT 3` (or just `ORDER BY price LIMIT 3`): Cutting Chai 20, Samosa 25, then one of the 30 items.
3. `name = input("Item: ")`, then `cur.execute("SELECT price FROM menu_items WHERE name = %s", (name,))` and `print(cur.fetchone())`.

## Next

[M20-L02 · What an ORM Is, and When Raw SQL Is Better](../m20-l02-what-an-orm-is-and-when-raw-sql-is-better/)
