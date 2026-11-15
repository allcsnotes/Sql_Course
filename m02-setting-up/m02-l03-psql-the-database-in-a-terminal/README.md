# M02-L03 · psql: the Database in a Terminal

> Video: Module 2, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- How to make `psql` work in every Terminal window on a Mac (a permanent PATH fix), and where psql is on Windows
- How to connect with `psql -U postgres`, and why the password prompt shows nothing
- How to read the prompt: `postgres=#` (ready) and `postgres-#` (waiting for more)
- How to run SQL in psql, and why a query only ends at the semicolon
- Four backslash commands: `\conninfo`, `\l`, `\dt` and `\q`

## Before you start

- PostgreSQL 18 installed and running, from [M02-L01](../m02-l01-installing-postgresql-18-on-windows-and-mac/).
- The password you chose when installing.
- A Terminal (Mac) or the Start menu (Windows).

## Files in this folder

| File | What it is |
|---|---|
| `session.sql` | Every SQL query and backslash command from the video, in order, with the real result as a comment |

## Follow along

psql is the waiter that lives in the Terminal: no buttons, just text. It is on almost every server, so knowing a little goes a long way.

### 1. Make psql work in every Terminal window (Mac)

In M02-L01, `psql --version` said `command not found`, because the Terminal does not know which folder psql lives in. `export PATH=...` fixed it for one window only.

Your Terminal (zsh) reads a small settings file every time it opens. It is called `.zshrc` and it lives in your home folder. This one line adds the PostgreSQL folder to your PATH, at the **end** of that file:

```bash
echo 'export PATH="/Library/PostgreSQL/18/bin:$PATH"' >> ~/.zshrc
```

The two arrows `>>` mean **add to the end**. Do not use one arrow `>`: that would replace the whole file.

Then read the file again, right now, and check:

```bash
source ~/.zshrc
psql --version
which psql
```

You should see:

```text
psql (PostgreSQL) 18.7
/Library/PostgreSQL/18/bin/psql
```

`which psql` shows where it was found. Open a new Terminal window and `psql --version` still works: that is the permanent fix.

**On Windows** you do not need this. Open the Start menu and search for **SQL Shell (psql)**. It asks for the server, database, port and username: press **Return** four times to keep the defaults (`localhost`, `postgres`, `5432`, `postgres`), then type your password.

### 2. Connect

```bash
psql -U postgres
```

`-U` means which user. We log in as `postgres`, the manager account. psql asks:

```text
Password for user postgres:
```

As you type the password, **nothing appears on screen**: no dots, no stars. That is normal. Type it and press Return.

```text
psql (18.7)
Type "help" for help.

postgres=#
```

You are in. Read the prompt:

| Part | Meaning |
|---|---|
| `postgres` | the database you are connected to |
| `=` | psql is ready for a new query |
| `#` | you are the **superuser** (the manager) |

### 3. Run some SQL

```sql
SELECT version();
```

The same answer as in DBeaver, but as plain text:

```text
                         version
---------------------------------------------------------
 PostgreSQL 18.7 on ...
(1 row)
```

(The rest of the line names your computer and compiler.)

```sql
SELECT 2 + 3;
```

```text
 ?column?
----------
        5
(1 row)
```

The column has no name, so psql calls it `?column?`. The row count is at the bottom.

Now type the same query **without** the semicolon and press Return. Nothing runs, and the prompt changes:

```text
postgres=# SELECT 2 + 3
postgres-#
```

The dash means psql is waiting for more: a query only ends at the semicolon. Type `;` on the new line and press Return:

```text
postgres-# ;
 ?column?
----------
        5
(1 row)
```

### 4. Backslash commands

Commands that start with a backslash are **not SQL**. They are psql's own shortcuts, and they need no semicolon.

`\conninfo` shows who you are, and where (a few of its 12 rows):

```text
      Parameter       |  Value
----------------------+----------
 Database             | postgres
 Client User          | postgres
 Server Port          | 5432
 Superuser            | on
```

`\l` lists every database:

```text
   Name    |  Owner   | Encoding | ...
-----------+----------+----------+----
 postgres  | postgres | UTF8     | ...
 template0 | postgres | UTF8     | ...
 template1 | postgres | UTF8     | ...
(3 rows)
```

`postgres` is ours. `template0` and `template1` are blank copies PostgreSQL uses to make new databases: leave them alone.

`\dt` lists the tables:

```text
Did not find any tables.
```

That is right: we have none yet. The next lesson loads the Chai Corner data.

`\q` quits psql and takes you back to the Terminal.

## Common mistakes

- **Thinking the password prompt is broken.** Nothing shows as you type. Just type it and press Return.
- **Forgetting the semicolon.** The prompt shows `postgres-#`. Type `;` and press Return.
- **Typing SQL straight into the Terminal before connecting.** zsh does not know SQL:
  ```text
  % SELECT 2 + 3;
  zsh: command not found: SELECT
  ```
  Connect with `psql -U postgres` first.
- **Using `>` instead of `>>`** when adding the PATH line. One arrow overwrites `.zshrc`.

## Try it yourself

1. The video's task: connect with psql, run `SELECT 2 + 3;`, then `\l`, and quit with `\q`.
2. Run `SELECT 10 * 4;`. What is the column called?
3. Type `\dt;` (with a semicolon). Does it still work?

## Answers

1. `5`, then the list of 3 databases, then you are back at the Terminal prompt.
2. `40`, in a column called `?column?`, because it has no name. You will name columns with `AS` in [M03-L02](../../m03-your-first-queries/m03-l02-choosing-columns-maths-and-as/).
3. Yes. Backslash commands do not need a semicolon, and psql ignores it here.

## Next

[M02-L04 · Loading the Chai Corner Database](../m02-l04-loading-the-chai-corner-database/)
