# M12-L05 · Importing and Exporting CSV Files

> Video: Module 12, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- What a **CSV file** is: plain text, one row per line, commas between the values
- Export with `COPY table TO 'file' WITH (FORMAT csv, HEADER)`
- Import with `COPY table FROM 'file'` into a table that already exists
- Export only part of a table: `COPY (SELECT ...) TO ...`
- `COPY` (the server reads the file) versus psql's `\copy` (your computer reads it)

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `menu_items` with its `category` column (12 items) and `customers` (19 rows).
- This lesson adds a table, `price_updates`, with 4 rows. `menu_items` does not change.

## Files in this folder

| File | What it is |
|---|---|
| `price_list.csv` | The supplier's price list from the video: `item_id,new_price`, 4 rows |
| `csv_import_export.sql` | Every command from the video in order, written with psql's `\copy` and relative paths |
| `setup.sql` | `price_updates` with its 4 rows, as plain SQL. Run it only if you skipped the lesson |
| `expected/` | The three files the video wrote (`menu_items.csv`, `chai_menu.csv`, `customers.csv`), to compare with yours |

## COPY or \copy?

In the video, `COPY` runs in DBeaver with a full file path. With `COPY`, the **PostgreSQL server** opens the file itself, so the path must be a folder the server is allowed to read and write (the video uses a shared folder for this, not your Documents folder).

psql's `\copy` takes the same options, but **psql on your computer** opens the file and sends the rows. Relative paths then work from the folder you started psql in. That is what `csv_import_export.sql` uses:

```bash
cd m12-changing-data/m12-l05-importing-and-exporting-csv-files
psql -U postgres -d chai_corner
```

psql asks for the password you chose when installing. A `\copy` command must stay on one line.

| | `COPY` (video) | `\copy` (this folder) |
|---|---|---|
| Who opens the file | the database server | psql, on your computer |
| Path | full path the server can reach | relative to where you started psql |
| Where it runs | DBeaver, psql, any client | psql only |

## Follow along

Data often lives outside the database: a supplier sends a price list, your manager wants the menu in a spreadsheet. The common format for both is a CSV file.

### 1. Export a table

The video's command (put in a folder your server can write to):

```sql
COPY menu_items TO '/path/to/folder/menu_items.csv'
WITH (FORMAT csv, HEADER);
```

The same with psql:

```text
\copy menu_items TO 'menu_items.csv' WITH (FORMAT csv, HEADER)
```

You should see: `Updated Rows 12` in DBeaver (`COPY 12` in psql). Open the file: the first line is the header with the column names, then one line for each row:

```text
item_id,name,price,category
1,Bun Maska,35,Snack
2,Cold Coffee,80,Coffee
3,Cutting Chai,20,Chai
...
12,Paneer Roll,90,Snack
```

### 2. Import, part 1: a table to fill

The supplier's price list, `price_list.csv`, has two columns and four rows:

```text
item_id,new_price
1,38
3,22
5,32
8,28
```

`COPY` needs a table to fill, so first create one with the same columns, in the same order:

```sql
CREATE TABLE price_updates (
  item_id   int PRIMARY KEY,
  new_price numeric(6,2) NOT NULL
);
```

### 3. Import, part 2: read the file

```sql
COPY price_updates FROM '/path/to/folder/price_list.csv'
WITH (FORMAT csv, HEADER);
```

```text
\copy price_updates FROM 'price_list.csv' WITH (FORMAT csv, HEADER)
```

`HEADER` tells Postgres to skip the first line. You should see: `Updated Rows 4`. Join it with the menu:

```sql
SELECT m.name, m.price, p.new_price
FROM price_updates p
JOIN menu_items m ON m.item_id = p.item_id
ORDER BY p.item_id;
```

| name | price | new_price |
|---|---|---|
| Bun Maska | 35 | 38.00 |
| Cutting Chai | 20 | 22.00 |
| Ginger Chai | 30 | 32.00 |
| Samosa | 25 | 28.00 |

Every new price sits next to today's price.

### 4. Export only part of a table

Put a `SELECT` in brackets right after `COPY`. Only the chai items, cheapest first:

```sql
COPY (SELECT name, price FROM menu_items
      WHERE category = 'Chai' ORDER BY price)
TO '/path/to/folder/chai_menu.csv'
WITH (FORMAT csv, HEADER);
```

```text
\copy (SELECT name, price FROM menu_items WHERE category = 'Chai' ORDER BY price) TO 'chai_menu.csv' WITH (FORMAT csv, HEADER)
```

Four rows come out, and the file has exactly those two columns:

```text
name,price
Cutting Chai,20
Ginger Chai,30
Masala Chai,30
Kulhad Chai,40
```

## Common mistakes

All three were run for real in the video.

1. **Forgetting `HEADER` on an import.**

   ```text
   \copy price_updates FROM 'price_list.csv' WITH (FORMAT csv)
   ```

   ```text
   ERROR: invalid input syntax for type integer: "item_id"   (SQLSTATE 22P02)
   ```

   Postgres tries to read the word `item_id` as a number.

2. **A typo in the path** (`pricelist.csv`). With `COPY` the server says `could not open file ... for reading: No such file or directory` (SQLSTATE 58P01); with `\copy` psql says `pricelist.csv: No such file or directory`. Copy the path exactly.

3. **Importing the same file twice.**

   ```text
   ERROR: duplicate key value violates unique constraint "price_updates_pkey"   (SQLSTATE 23505)
     Detail: Key (item_id)=(1) already exists.
   ```

   The primary key blocks the repeated rows, so the whole import stops. Not even the new rows go in.

## Try it yourself

1. Export every customer's name and join date. How many rows are written, and how many lines does the file have? (The video's task.)
2. Export the `Snack` items, most expensive first, to `snacks.csv`.
3. Why did the import in mistake 3 save nothing at all, not even part of the file?

## Answers

1. ```sql
   COPY (SELECT name, joined_on FROM customers ORDER BY name)
   TO '/path/to/folder/customers.csv'
   WITH (FORMAT csv, HEADER);
   ```

   ```text
   \copy (SELECT name, joined_on FROM customers ORDER BY name) TO 'customers.csv' WITH (FORMAT csv, HEADER)
   ```

   19 rows are written (`Updated Rows 19`), and the file has 20 lines: the header plus one line per customer. Compare with `expected/customers.csv`.

2. ```text
   \copy (SELECT name, price FROM menu_items WHERE category = 'Snack' ORDER BY price DESC) TO 'snacks.csv' WITH (FORMAT csv, HEADER)
   ```

   6 rows, starting with Paneer Roll, 90.

3. One `COPY` is one statement, and a statement is all or nothing: the first error undoes the whole import. Module 13 explains why.

## Next

[M13-L01 · Transactions: All or Nothing](../../m13-transactions/m13-l01-transactions-all-or-nothing/)
