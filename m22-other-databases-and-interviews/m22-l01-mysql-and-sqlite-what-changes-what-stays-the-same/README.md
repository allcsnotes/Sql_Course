# M22-L01 · MySQL and SQLite: What Changes, What Stays the Same

> Video: Module 22, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- That almost everything you learned on PostgreSQL (SELECT, WHERE, GROUP BY, JOIN) works the same on MySQL and SQLite
- What **SQLite** is: a whole database in one file, with no server, opened with the `sqlite3` command
- What **MySQL** is: a database server, like PostgreSQL, used by many websites
- How strict each one is about types (`'forty'` in a number column)
- The small things that change: auto IDs, the month of a date, `LIKE` and capital letters, and joining text with `||`
- Which one to choose for a new project

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). Only `postgres_compare.sql` uses it, read only.
- **SQLite:** the `sqlite3` command. It is built into macOS (type `sqlite3 --version` in a terminal). On Windows, download the "command-line tools" zip from the official SQLite download page and unzip `sqlite3.exe`.
- **MySQL 8.4:** the video runs the official `mysql:8.4` image in Docker, so you need Docker Desktop for this step. The image is a download of a few hundred MB.
- Nothing in this lesson changes your Chai Corner database in PostgreSQL. The two small practice databases (`chai.db` and the MySQL `chai_corner`) are separate and hold only `menu_items`.

## Files in this folder

| File | What it is |
|---|---|
| `seed.sql` | SQLite: creates `menu_items` (`INTEGER PRIMARY KEY`) with 10 items |
| `seed_mysql.sql` | MySQL: the same table with `INT AUTO_INCREMENT PRIMARY KEY` and the same 10 items |
| `sqlite_queries.sql` | Every SQLite command from the video, in order, with the real result as a comment |
| `mysql_queries.sql` | Every MySQL command from the video, in order, with the real result as a comment |
| `postgres_compare.sql` | The PostgreSQL side of the "what changes" table |

## Follow along

The practice data is 10 Chai Corner menu items (Cutting Chai ₹20 up to Cold Coffee ₹80). Your PostgreSQL `menu_items` has 12 items (it also has Paneer Roll ₹90), so the same query there starts with Paneer Roll.

### 1. Set up SQLite (one file)

In a terminal, in this folder. This step happens in your terminal, not in DBeaver:

```bash
sqlite3 chai.db
```

The file `chai.db` is created the first time. Inside the `sqlite>` prompt, load the seed:

```text
sqlite> .read seed.sql
sqlite> .tables
menu_items
```

Commands that start with a dot (`.read`, `.tables`, `.mode`, `.quit`) belong to the `sqlite3` tool, not to SQL. If your results print as plain `a|b` lines, type `.mode box` to get the boxes shown below.

### 2. Set up MySQL (a server in Docker)

These commands run in your terminal. The container listens only on your own computer (`127.0.0.1`), and the empty root password is fine only for a local practice container like this:

```bash
docker run -d --name chai-mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -e MYSQL_DATABASE=chai_corner -p 127.0.0.1:3306:3306 mysql:8.4
docker exec -i chai-mysql mysql chai_corner < seed_mysql.sql
docker exec -it chai-mysql mysql chai_corner
```

Wait about 20 seconds after `docker run` before loading the seed: the server needs time to start. The last command opens the `mysql>` prompt. Type `exit` to leave it.

### 3. The same query on two new databases

```sql
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3;
```

You should see the same three rows in both:

```text
mysql>                              sqlite>
+--------------+-------+            ┌──────────────┬───────┐
| name         | price |            │     name     │ price │
+--------------+-------+            ├──────────────┼───────┤
| Cold Coffee  |    80 |            │ Cold Coffee  │ 80    │
| Veg Sandwich |    70 |            │ Veg Sandwich │ 70    │
| Maggi        |    60 |            │ Maggi        │ 60    │
+--------------+-------+            └──────────────┴───────┘
```

SELECT, WHERE, GROUP BY and JOIN work the same way on all three.

### 4. SQLite is relaxed about types

There is no server to start: the whole database is one file. SQLite is inside phones, web browsers and Python, which makes it the most used database in the world. Now put the word `forty` into the number column:

```sql
INSERT INTO menu_items (name, category, price) VALUES ('Lassi', 'Drink', 'forty');
SELECT name, price, typeof(price) FROM menu_items WHERE name = 'Lassi';
```

You should see (no error at all):

```text
┌───────┬───────┬───────────────┐
│ name  │ price │ typeof(price) │
├───────┼───────┼───────────────┤
│ Lassi │ forty │ text          │
└───────┴───────┴───────────────┘
```

`typeof` shows SQLite kept it as text. Remove the test row with `DELETE FROM menu_items WHERE name = 'Lassi';`.

### 5. MySQL checks your types

MySQL runs as a server, like PostgreSQL. Many websites use it, including most WordPress sites. The same bad insert:

```sql
INSERT INTO menu_items (name, category, price) VALUES ('Lassi', 'Drink', 'forty');
```

You should see:

```text
ERROR 1366 (HY000): Incorrect integer value: 'forty' for column 'price' at row 1
```

PostgreSQL and MySQL check your types. SQLite mostly trusts you.

### 6. What changes

| | PostgreSQL | MySQL | SQLite |
|---|---|---|---|
| Auto ID | `GENERATED ... AS IDENTITY` | `AUTO_INCREMENT` | `INTEGER PRIMARY KEY` |
| Month of a date | `date_trunc('month', d)` | `DATE_FORMAT(d, '%Y-%m')` | `strftime('%Y-%m', d)` |
| `LIKE 'masala%'` | no match | Masala Chai | Masala Chai |

Try the month in each one:

```sql
-- MySQL
SELECT DATE_FORMAT('2026-03-14', '%Y-%m') AS month;
-- SQLite
SELECT strftime('%Y-%m', '2026-03-14') AS month;
```

Both give `2026-03`. In PostgreSQL, `date_trunc('month', DATE '2026-03-14')` gives `2026-03-01 00:00:00` (the first moment of the month, with your time zone).

Searching text: `LIKE` cares about capital letters in PostgreSQL, but not in MySQL or SQLite, so `masala` in small letters still finds Masala Chai:

```sql
SELECT name FROM menu_items WHERE name LIKE 'masala%';
```

MySQL and SQLite: 1 row, `Masala Chai`. PostgreSQL: 0 rows (that is why PostgreSQL has `ILIKE`).

### 7. The biggest surprise: joining text

In PostgreSQL and SQLite, two bars join text together. In MySQL, two bars mean OR:

```sql
SELECT 'Masala' || ' Chai' AS item;
SHOW WARNINGS;
```

MySQL gives:

```text
+------+
| item |
+------+
|    0 |
+------+
+---------+------+-----------------------------------------------------------------+
| Level   | Code | Message                                                         |
+---------+------+-----------------------------------------------------------------+
| Warning | 1287 | '|| as a synonym for OR' is deprecated and will be removed ...   |
| Warning | 1292 | Truncated incorrect DOUBLE value: 'Masala'                      |
| Warning | 1292 | Truncated incorrect DOUBLE value: ' Chai'                       |
+---------+------+-----------------------------------------------------------------+
```

MySQL turns both words into numbers (both become 0), so the answer is zero. There is no error, only warnings. SQLite and PostgreSQL give `Masala Chai`. In MySQL, use `CONCAT` instead:

```sql
SELECT CONCAT('Masala', ' Chai') AS item;
```

You should see `Masala Chai`.

### 8. Which one should you use?

- **SQLite:** one app on one device: a phone app, a small tool, or your tests.
- **MySQL:** when your web host or an existing app already uses it.
- **PostgreSQL:** most new projects. It is strict, and it has more features. For example, MySQL has no `FILTER`:

```sql
SELECT SUM(price) FILTER (WHERE category = 'Chai') AS chai FROM menu_items;
```

MySQL gives `ERROR 1064 (42000): You have an error in your SQL syntax ... near '(WHERE category = 'Chai') AS chai FROM menu_items'`. Write `SUM` of `CASE` instead (from [M07-L06](../../m07-summarising-data/m07-l06-filter-many-counts-in-one-query/)):

```sql
SELECT SUM(CASE WHEN category = 'Chai' THEN price ELSE 0 END) AS chai FROM menu_items;
```

You should see `80` (Cutting Chai 20 + Ginger Chai 30 + Masala Chai 30). SQLite understands `FILTER` and also gives `80`.

## Common mistakes

- Using `||` to join text in MySQL: you get `0` and only warnings, not an error. Use `CONCAT`.
- Trusting SQLite to reject bad values: it stores `'forty'` in a number column as text. Check your data in your app.
- Expecting `LIKE` to behave the same everywhere: PostgreSQL cares about capital letters, MySQL and SQLite do not.
- Copying PostgreSQL-only features (`FILTER`, `ILIKE`, `::` casts, `GENERATED ... AS IDENTITY`) into MySQL.
- Forgetting the semicolon in the `mysql>` or `sqlite>` prompt: the tool waits for more input.

## Clean up

```bash
docker stop chai-mysql
```

`docker start chai-mysql` brings it back later. To remove it completely: `docker rm -f chai-mysql`. The SQLite database is the file `chai.db`: delete the file to remove it.

## Try it yourself

1. In MySQL, what does `SELECT CONCAT('Chai', 'Corner');` return? Guess first.
2. In SQLite, write the query that counts the items in each category.
3. In MySQL, find every item with `chai` anywhere in the name, written in small letters.

## Answers

1. `ChaiCorner`, with no space in between. `CONCAT` joins exactly what you give it.
2. `SELECT category, COUNT(*) FROM menu_items GROUP BY category;` gives Chai 3, Coffee 2, Snack 5. The same SQL works on all three databases.
3. `SELECT name FROM menu_items WHERE name LIKE '%chai%';` gives Cutting Chai, Ginger Chai and Masala Chai, because MySQL's `LIKE` ignores capital letters. In PostgreSQL you would write `ILIKE`.

## Next

[M22-L02 · Cloud Warehouses (BigQuery, Snowflake) and When to Choose NoSQL](../m22-l02-cloud-warehouses-bigquery-snowflake-and-when-to-choose-nosql/)
