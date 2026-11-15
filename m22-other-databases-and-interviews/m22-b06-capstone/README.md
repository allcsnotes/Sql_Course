# M22-B06 · Capstone: Raw CSV to a Final Report

> Video: Build 6 (Module 22). Watch it first, then follow along here.

## What you'll build

The last build of the course: one real project, from start to finish. A chain of four tea kiosks sends you one month of sales (May 2026) as a raw CSV file: 200,000 sales, and it is messy. Your job has four stages:

1. **Load** the raw file.
2. **Clean** it into a real database, and check that every sale is accounted for.
3. **Make the queries fast** with an index.
4. **Hand over a final report**: a view, exported to a CSV file.

Everything lives in its own schema, `capstone`, inside your Chai Corner database (it uses `menu_items` to match the item names).

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). Only `menu_items` is needed.
- **psql**, the terminal client from [M02-L03](../../m02-setting-up/m02-l03-psql-the-database-in-a-terminal/). Open a terminal **in this folder**, so the paths `data/kiosk_sales.csv` and `data/kiosks.csv` work, and connect:

  ```text
  psql -U postgres -d chai_corner
  ```

  It asks for the password you chose when installing. Run the file in one go with `\i capstone.sql`, or paste one step at a time.

### Why `\copy` here, when the video used `COPY`

In the video the database server and the CSV file sat on the same computer, so it used **server-side `COPY`** with the file's full path. `COPY` is run by the database server: it reads and writes files on the **server's** disk, as the server's own user, so the path must be one the server can see.

In this repo you use psql's **`\copy`** instead. It runs the same `COPY` but streams the file through psql, so it reads and writes files on **your** computer, with a path **relative to the folder you started psql in**. It works the same whether your server is on your laptop, in Docker or in the cloud, and needs no special file permissions. Two rules: `\copy` must be written on **one line**, and it has no semicolon at the end.

(DBeaver cannot run `\copy`. If you work in DBeaver, either use server-side `COPY` with the full path to the `data` folder on your computer, or right-click the table and use **Import Data**.)

## Files in this folder

| File | What it is |
|---|---|
| `data/kiosk_sales.csv` | The raw sales file: a header plus 201,500 lines (8 MB). Columns `sale_id, sold_at, kiosk, item, qty` |
| `data/kiosks.csv` | The four kiosks: `K1 Station Pune`, `K2 Airport Mumbai`, `K3 Metro Delhi`, `K4 Mall Bengaluru` |
| `capstone.sql` | Every step from the video in order, with `\copy` and the real results as comments |
| `setup.sql` | DB update 19: builds the finished `capstone` schema in one go (raw table, clean tables, index, view). Re-runnable. Use it only if you skip the build |

## Build it step by step

### Stage 1, step 1: load the raw file

First a schema, so the project has its own space. The raw table makes **every column text**: text accepts anything, so the load never stops on a bad value. Then one `\copy` reads the whole file in one go.

```sql
CREATE SCHEMA capstone;
CREATE TABLE capstone.raw_sales (
  sale_id text, sold_at text, kiosk text, item text, qty text);
\copy capstone.raw_sales FROM 'data/kiosk_sales.csv' WITH (FORMAT csv, HEADER)
```

You should see `COPY 201500`. In the video, DBeaver showed Updated Rows 201500 in about a quarter of a second (0.265 s; yours will differ).

### Stage 2, step 2: how messy is it? Brackets show hidden spaces

```sql
SELECT '[' || kiosk || ']' AS kiosk, COUNT(*) AS rows
FROM capstone.raw_sales
GROUP BY kiosk
ORDER BY kiosk;
```

You should see 32 rows. Some of them for K1:

| kiosk | rows |
|---|---|
| `[ K1  ]` | 381 |
| `[ K1]` | 4838 |
| `[K1  ]` | 4744 |
| `[K1]` | 65675 |
| `[ k1]` | 328 |
| `[k1]` | 4234 |

K1 is written with a space before it, spaces after it, and in small letters. (The order of the 32 rows depends on your database's collation, its rules for sorting text, so yours may start with a different row than the video's.)

### Step 3: count every problem at once

`COUNT` with `FILTER` counts every problem in one pass. `!~` means "does not match this pattern"; `'^[0-9]+$'` means "only digits, from start to end".

```sql
SELECT COUNT(*) AS lines,
  COUNT(DISTINCT sale_id) AS sales,
  COUNT(DISTINCT kiosk) AS kiosks,
  COUNT(DISTINCT item) AS items,
  COUNT(*) FILTER (WHERE qty IS NULL) AS blank,
  COUNT(*) FILTER (WHERE qty !~ '^[0-9]+$') AS bad,
  COUNT(*) FILTER (WHERE sold_at LIKE '__/__/____%') AS dd_mm
FROM capstone.raw_sales;
```

You should see:

| lines | sales | kiosks | items | blank | bad | dd_mm |
|---|---|---|---|---|---|---|
| 201500 | 200000 | 32 | 117 | 863 | 425 | 30425 |

- 201,500 lines but only 200,000 different sales: 1,500 lines are copies.
- Four kiosks are spelled 32 ways, and ten menu items are spelled 117 ways.
- 863 quantities are blank, 425 are not numbers (they say `two`), and about 30,000 dates are written day first (`04/05/2026 17:32` instead of `2026-05-04 17:32`).

### Step 4: build the clean tables, with real types and rules

```sql
CREATE TABLE capstone.kiosks (kiosk text PRIMARY KEY, place text, city text);
\copy capstone.kiosks FROM 'data/kiosks.csv' WITH (FORMAT csv, HEADER)
CREATE TABLE capstone.sales (
  sale_id int PRIMARY KEY,
  sold_at timestamp NOT NULL,
  kiosk   text NOT NULL REFERENCES capstone.kiosks,
  item_id int  NOT NULL REFERENCES menu_items,
  qty     int  NOT NULL CHECK (qty > 0));
```

You should see `COPY 4` for the kiosks. The kiosk code is the primary key of `kiosks`. In `sales`, the sale ID is the primary key, so one sale can never get in twice; the kiosk and the item are foreign keys; and a `CHECK` rule makes sure the quantity is more than zero.

### Step 5: one INSERT cleans every column, and copies it across

```sql
INSERT INTO capstone.sales
SELECT DISTINCT ON (r.sale_id::int) r.sale_id::int,
  CASE WHEN r.sold_at LIKE '__/__/____%'
       THEN to_timestamp(r.sold_at, 'DD/MM/YYYY HH24:MI')::timestamp
       ELSE r.sold_at::timestamp END,
  UPPER(TRIM(r.kiosk)), m.item_id, r.qty::int
FROM capstone.raw_sales r
JOIN menu_items m ON m.name = INITCAP(TRIM(r.item))
WHERE r.qty ~ '^[0-9]+$';
```

You should see `INSERT 0 198719` (198,719 rows go in).

- `DISTINCT ON` the sale ID keeps just one line for each sale, so the copies are gone.
- `CASE` looks at the date: if it is written day first, `to_timestamp` reads it that way; if not, it is converted directly.
- `TRIM` and `UPPER` tidy every kiosk name, and `INITCAP` with `TRIM` matches each item to the menu (`' samosa'` becomes `Samosa`).
- `WHERE` keeps only quantities made of digits.

### Step 6: where did the rest go? Never guess

200,000 sales went in and fewer came out. Give every sale a label with `CASE`, then count each label:

```sql
SELECT CASE WHEN r.qty IS NULL THEN 'blank qty'
            WHEN r.qty !~ '^[0-9]+$' THEN 'bad qty'
            WHEN m.item_id IS NULL THEN 'unknown item'
            ELSE 'kept' END AS result,
       COUNT(DISTINCT r.sale_id) AS sales
FROM capstone.raw_sales r
LEFT JOIN menu_items m ON m.name = INITCAP(TRIM(r.item))
GROUP BY 1 ORDER BY 2 DESC;
```

You should see:

| result | sales |
|---|---|
| kept | 198719 |
| blank qty | 856 |
| bad qty | 425 |

198,719 + 856 + 425 = exactly 200,000. No sale is unaccounted for. (856 sales, not 863 lines: some blank lines were copies of the same sale.)

The blank check comes first on purpose. A blank became NULL when it was loaded, and a NULL quietly slips past the digits test: `NULL !~ '...'` is not true, it is unknown, so without the `IS NULL` line the blanks would hide.

### Stage 3, step 7: one kiosk, one day. How fast is it?

A manager asks: how many cups did the Bengaluru kiosk (K4) sell on May the 20th?

```sql
EXPLAIN (ANALYZE, COSTS OFF, BUFFERS OFF)
SELECT SUM(qty) AS cups
FROM capstone.sales
WHERE kiosk = 'K4'
  AND sold_at >= '2026-05-20' AND sold_at < '2026-05-21';
```

You should see a **Parallel Seq Scan on sales**: PostgreSQL reads the whole table, and each worker throws away about 99,000 rows (`Rows Removed by Filter: 99050`). It took 11.601 ms in the video (yours will differ; a check run gave about 10.5 ms).

### Step 8: add one index, then time it again

An index on the kiosk and the time together:

```sql
CREATE INDEX idx_sales_kiosk_day ON capstone.sales (kiosk, sold_at);
```

Run the same `EXPLAIN ANALYZE` again. Now it is a **Bitmap Index Scan on idx_sales_kiosk_day**, and it takes about half a millisecond (0.519 ms in the video): over twenty times faster.

### Stage 4, step 9: the final report, saved as a view

A view saves the query, so anyone can read the report with one simple `SELECT`, and it is always up to date.

```sql
CREATE VIEW capstone.may_report AS
SELECT k.city || ' ' || k.place AS kiosk,
       COUNT(*) AS sales, SUM(s.qty) AS cups,
       SUM(s.qty * m.price) AS revenue,
       ROUND(SUM(s.qty * m.price) / 31.0) AS per_day
FROM capstone.sales s
JOIN capstone.kiosks k USING (kiosk)
JOIN menu_items m USING (item_id)
GROUP BY 1;
```

### Step 10: read the report, biggest first

```sql
SELECT * FROM capstone.may_report
ORDER BY revenue DESC;
```

You should see:

| kiosk | sales | cups | revenue | per_day |
|---|---|---|---|---|
| Pune Station | 79395 | 126765 | 4383815 | 141413 |
| Mumbai Airport | 59730 | 95833 | 3312445 | 106853 |
| Delhi Metro | 39862 | 63954 | 2210660 | 71312 |
| Bengaluru Mall | 19732 | 31428 | 1088065 | 35099 |

Pune Station is far ahead, with over 4.3 million rupees (₹4,383,815) in May. Bengaluru Mall makes about a quarter of that.

### Step 11: hand the report over as a file

```sql
\copy (SELECT * FROM capstone.may_report ORDER BY revenue DESC) TO 'may_report.csv' WITH (FORMAT csv, HEADER)
```

You should see `COPY 4`, and a new file `may_report.csv` in this folder, ready for a spreadsheet or an email:

```text
kiosk,sales,cups,revenue,per_day
Pune Station,79395,126765,4383815,141413
Mumbai Airport,59730,95833,3312445,106853
Delhi Metro,39862,63954,2210660,71312
Bengaluru Mall,19732,31428,1088065,35099
```

## Check your work

- `SELECT COUNT(*) FROM capstone.raw_sales;` gives 201500, and `SELECT COUNT(*) FROM capstone.sales;` gives 198719.
- The labels in step 6 add up to exactly 200,000.
- After step 8 the plan says Bitmap Index Scan, not Seq Scan.
- The report has 4 rows, Pune Station first.
- The video's task: add a second report, the best selling item at each kiosk (by cups). Try it, then compare:

  ```sql
  SELECT DISTINCT ON (s.kiosk) s.kiosk, m.name, SUM(s.qty) AS cups
  FROM capstone.sales s
  JOIN menu_items m USING (item_id)
  GROUP BY s.kiosk, m.name
  ORDER BY s.kiosk, cups DESC;
  ```

  | kiosk | name | cups |
  |---|---|---|
  | K1 | Masala Chai | 27592 |
  | K2 | Masala Chai | 21225 |
  | K3 | Masala Chai | 13854 |
  | K4 | Masala Chai | 6850 |

  Masala Chai, at all four.

To start again from scratch: `DROP SCHEMA capstone CASCADE;`

## Common mistakes

- Loading straight into typed columns: the first bad value (`'two'` in a number column) stops the whole load. Load as text first, clean after.
- Trusting `COUNT(*)` as the number of sales: 1,500 lines are copies. Count `DISTINCT sale_id`.
- Testing only `qty !~ '^[0-9]+$'` for bad quantities: blanks are NULL and slip past. Check `IS NULL` first.
- Writing a multi-line `\copy`, or ending it with a semicolon: `\copy` must be one line.
- Using server-side `COPY` with a path on your own computer when the server is somewhere else (Docker, the cloud): the server cannot see your files. Use `\copy`.
- Reading `04/05/2026` with a plain cast: with the default date style (`ISO, MDY`) PostgreSQL reads it as 5 April, not 4 May. Use `to_timestamp` with `'DD/MM/YYYY HH24:MI'`.
- Guessing why rows went missing. Label every row and count the labels until the total matches.

## Next

That is the end of the course: you started with one simple `SELECT`, and now you can take a messy file all the way to a fast, trusted report. Well done.

[Back to the course home](../../README.md)
