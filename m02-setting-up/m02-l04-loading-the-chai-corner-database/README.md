# M02-L04 · Loading the Chai Corner Database

> Video: Module 2, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- What is inside `chai_corner.sql`: `CREATE TABLE` and `INSERT INTO` lines, a recipe for three tables
- How to make an empty database with `CREATE DATABASE` and move into it with `\c`
- How to run a whole file with `\i`, and how to read `INSERT 0 10`
- How to look around: `\dt`, `\d table`, and `SELECT * FROM table`
- The three mistakes beginners make when loading a file

## Before you start

- PostgreSQL 18 running ([M02-L01](../m02-l01-installing-postgresql-18-on-windows-and-mac/)), psql working ([M02-L03](../m02-l03-psql-the-database-in-a-terminal/)), and the password you chose when installing.
- Save `chai_corner.sql` from this folder in a folder you can find again. This is the starting Chai Corner database for the whole course (the same file is in [database/](../../database/)).

## Files in this folder

| File | What it is |
|---|---|
| `chai_corner.sql` | The Chai Corner database: 3 tables (`branches`, `menu_items`, `customers`) and their 35 rows |
| `look_around.sql` | Every command the video types in psql, in order, with the real result as a comment |

## Follow along

### 1. Meet the file

Open `chai_corner.sql` in any text editor. Inside there are only two kinds of line:

- `CREATE TABLE` makes an empty table and names its columns.
- `INSERT INTO` adds the rows.

So the file is a recipe: three tables, and every row that goes in them. The first two lines:

```sql
CREATE TABLE branches (branch_id int PRIMARY KEY, city varchar(30) NOT NULL, opened_on date NOT NULL);
INSERT INTO branches VALUES (1,'Pune','2019-04-12'),(2,'Mumbai','2019-09-02'),(3,'Delhi','2020-01-20'),(4,'Bengaluru','2020-07-15'),(5,'Chennai','2021-02-08'),
```

**Start psql from the same folder as the file.** Then psql can find it by its name alone. In a Mac Terminal, `cd` into that folder first, then run `psql -U postgres`.

### 2. Make an empty database

Connect with psql as before, then:

```sql
CREATE DATABASE chai_corner;
```

You should see:

```text
CREATE DATABASE
```

One server can hold many databases. Each one is a separate box with its own tables. Move into the new box:

```text
postgres=# \c chai_corner
You are now connected to database "chai_corner" as user "postgres".
chai_corner=#
```

The prompt changed from `postgres` to `chai_corner`. The prompt always tells you where you are.

### 3. Load the file

`\i` means: run every line in this file.

```text
chai_corner=# \i chai_corner.sql
CREATE TABLE
INSERT 0 10
CREATE TABLE
INSERT 0 10
CREATE TABLE
INSERT 0 15
```

psql reports each line: `CREATE TABLE` three times, once per table. `INSERT 0 10` means ten rows went in. Ignore the 0: the last number is the one that matters. Ten branches, ten menu items, fifteen customers. The whole database is loaded in about one second.

### 4. Take a look around

`\dt` lists the tables:

```text
             List of tables
 Schema |    Name    | Type  |  Owner
--------+------------+-------+----------
 public | branches   | table | postgres
 public | customers  | table | postgres
 public | menu_items | table | postgres
(3 rows)
```

`\d` and a table name describes that table:

```text
chai_corner=# \d menu_items
                    Table "public.menu_items"
 Column  |         Type          | Collation | Nullable | Default
---------+-----------------------+-----------+----------+---------
 item_id | integer               |           | not null |
 name    | character varying(40) |           | not null |
 price   | integer               |           | not null |
Indexes:
    "menu_items_pkey" PRIMARY KEY, btree (item_id)
```

- `item_id` and `price` are whole numbers (`integer`). `name` is text of up to 40 letters (`character varying(40)`).
- **not null** means the value can never be empty.
- The **primary key** `item_id` gives every row its own number, so no two rows share one.

Now real data. `*` (star) means every column:

```sql
SELECT * FROM branches;
```

```text
 branch_id |   city    | opened_on
-----------+-----------+------------
         1 | Pune      | 2019-04-12
         2 | Mumbai    | 2019-09-02
         3 | Delhi     | 2020-01-20
         4 | Bengaluru | 2020-07-15
         5 | Chennai   | 2021-02-08
         6 | Hyderabad | 2021-08-23
         7 | Kolkata   | 2022-03-14
         8 | Jaipur    | 2022-11-05
         9 | Ahmedabad | 2023-06-19
        10 | Kochi     | 2024-01-29
(10 rows)
```

```sql
SELECT * FROM menu_items;
```

```text
 item_id |     name      | price
---------+---------------+-------
       1 | Bun Maska     |    35
       2 | Cold Coffee   |    80
       3 | Cutting Chai  |    20
       4 | Filter Coffee |    40
       5 | Ginger Chai   |    30
       6 | Maggi         |    60
       7 | Masala Chai   |    30
       8 | Samosa        |    25
       9 | Vada Pav      |    30
      10 | Veg Sandwich  |    70
(10 rows)
```

Ten things to eat and drink, with their prices in rupees. From the next module you ask this data real questions.

### 5. Loading it with DBeaver instead (optional, not shown in the video)

The video loads the file with psql. If you prefer DBeaver:

1. Create the database first, either with `CREATE DATABASE chai_corner;` in a DBeaver SQL editor on your `postgres` connection, or by right-clicking **Databases** under your connection and choosing **Create New Database**.
2. Make DBeaver show it: click your connection, press **F4** (on a Mac maybe **fn + F4**), turn on **Show all databases**, click **OK**. [M03-L01](../../m03-your-first-queries/m03-l01-select-and-from-reading-a-table/) shows this step on screen.
3. Click **chai_corner** in the navigator, open **SQL Editor → New SQL script**, and check that the toolbar shows `chai_corner`.
4. Paste the whole content of `chai_corner.sql` into the editor and choose **Execute SQL Script** (Alt + X), not the single-query play button.
5. Refresh **chai_corner → Schemas → public → Tables** (F5): the three tables are there.

### 6. Starting again

Your database is your own copy. If something goes wrong in any later lesson, connect to `postgres` (not `chai_corner`), drop it and load it again:

```sql
DROP DATABASE chai_corner;
CREATE DATABASE chai_corner;
\c chai_corner
\i chai_corner.sql
```

Then run the `setup.sql` of every earlier lesson that has one (see [database/README.md](../../database/README.md)).

## Common mistakes

These are real messages from the video:

- **A wrong file name, or the wrong folder.**
  ```text
  chai_corner=# \i chai.sql
  chai.sql: No such file or directory
  ```
  Check the spelling, and start psql in the file's folder.
- **Loading the file twice.**
  ```text
  psql:chai_corner.sql:1: ERROR:  relation "branches" already exists
  psql:chai_corner.sql:3: ERROR:  duplicate key value violates unique constraint "branches_pkey"
  DETAIL:  Key (branch_id)=(1) already exists.
  ```
  (and the same for `menu_items` and `customers`). Do not worry: the primary key stopped every copy, so nothing was added twice.
- **Being in the wrong database.**
  ```text
  postgres=# SELECT * FROM branches;
  ERROR:  relation "branches" does not exist
  ```
  **Relation** just means table. Check the prompt, and type `\c chai_corner`.

## Try it yourself

1. The video's task: load Chai Corner, then run `SELECT * FROM customers;`. You should see fifteen rows.
2. Describe the `customers` table with `\d customers`. Which column is the primary key?
3. Which date did the Chennai branch open?

## Answers

1. 15 rows, from customer 1 Asha (joined 2024-11-11) to customer 15 Kiran (joined 2026-06-10).
2. `customer_id` (`"customers_pkey" PRIMARY KEY, btree (customer_id)`). The other columns are `name` (`character varying(40)`) and `joined_on` (`date`), all not null.
3. 2021-02-08 (branch 5 in `SELECT * FROM branches;`).

## Next

[M03-L01 · SELECT and FROM: Reading a Table](../../m03-your-first-queries/m03-l01-select-and-from-reading-a-table/)
