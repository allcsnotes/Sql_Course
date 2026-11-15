# M21-L04 · From SQL to a Chart: Exporting to Google Sheets

> Video: Module 21, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- `to_char` to turn a month into short text like `2026-01`
- `COPY ... TO ... WITH (FORMAT csv, HEADER)` to save a query result as a CSV file, and `\copy`, its psql cousin that writes to your own computer
- Bringing the CSV into Google Sheets with File > Import
- Drawing a chart with Insert > Chart, and fixing the X axis and the series when Sheets guesses wrong

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses the `sales` table. It makes no changes to the database.
- A Google account, signed in at sheets.google.com in your browser (any free account works).
- psql opened in this folder, so the CSV file lands here (see [M02-L03](../../m02-setting-up/m02-l03-psql-the-database-in-a-terminal/)).

## Files in this folder

| File | What it is |
|------|------------|
| `export_to_sheets.sql` | The report query, the export to CSV, and the task export |
| `monthly_cups.csv` | What your exported file should look like (3 months, with a header line) |

## Follow along

### 1. The report

Cups sold each month, with one column for chai, coffee and snack. It's the pivot from [M21-L03](../m21-l03-pivoting-rows-into-columns/). A new function, `to_char`, turns each month into short text: the year, a dash, then the month:

```sql
SELECT to_char(date_trunc('month', sold_at), 'YYYY-MM') AS month,
       SUM(qty) FILTER (WHERE category = 'Chai')   AS chai,
       SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee,
       SUM(qty) FILTER (WHERE category = 'Snack')  AS snack
FROM sales
GROUP BY month
ORDER BY month;
```

You should see:

| month | chai | coffee | snack |
|-------|------|--------|-------|
| 2026-01 | 394 | 127 | 417 |
| 2026-02 | 1077 | 341 | 1006 |
| 2026-03 | 1911 | 576 | 1686 |

### 2. Save it as a CSV file

In the video, the whole query is wrapped in `COPY` and sent `TO` a file path:

```sql
COPY (
  SELECT to_char(date_trunc('month', sold_at), 'YYYY-MM') AS month,
         SUM(qty) FILTER (WHERE category = 'Chai')   AS chai,
         SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee,
         SUM(qty) FILTER (WHERE category = 'Snack')  AS snack
  FROM sales GROUP BY month ORDER BY month
) TO '<full path to a folder>/monthly_cups.csv'
WITH (FORMAT csv, HEADER);
```

`FORMAT csv` means comma separated values, and `HEADER` puts the column names on the first line. DBeaver shows `Updated Rows 3`.

`COPY ... TO` is run by the **database server**, so the file is written on the computer where PostgreSQL runs, and the server must be allowed to write in that folder. On your own laptop that works. In this repo we use psql's `\copy` instead, which runs the same query but writes the file on **your** computer, next to where you started psql, with a relative path and no special permissions. `\copy` must be written on one line:

```text
\copy (SELECT to_char(date_trunc('month', sold_at), 'YYYY-MM') AS month, SUM(qty) FILTER (WHERE category = 'Chai') AS chai, SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee, SUM(qty) FILTER (WHERE category = 'Snack') AS snack FROM sales GROUP BY month ORDER BY month) TO 'monthly_cups.csv' WITH (FORMAT csv, HEADER)
```

You should see:

```text
COPY 3
```

Open the file in any text editor. It's just plain text: the names on top, then one line for each month, with commas between the values:

```text
month,chai,coffee,snack
2026-01,394,127,417
2026-02,1077,341,1006
2026-03,1911,576,1686
```

### 3. Open Google Sheets (steps 1 and 2)

In your browser, go to `sheets.google.com` and sign in with your Google account. These steps happen in Google Sheets, not in SQL.

1. Click **Blank spreadsheet**. An empty sheet opens.
2. Click the title at the top (**Untitled spreadsheet**) and type a name, like `Chai Corner monthly cups`.

### 4. Bring the file in (steps 3 to 6)

3. Open the **File** menu and click **Import**.
4. Choose the **Upload** tab, click **Browse**, and pick `monthly_cups.csv`.
5. Under **Import location**, choose **Replace current sheet**.
6. Click **Import data**.

You should see the same three rows you saw in SQL, now in the sheet: `month`, `chai`, `coffee`, `snack` in row 1, then 2026-01 to 2026-03 in rows 2 to 4.

### 5. Draw the chart (steps 7 to 9)

7. Select the cells from **A1** to **D4**. Then open **Insert** and click **Chart**.

Sheets guesses a column chart, but it guesses wrong. It reads the month as a date, and a date is stored as a big number (about 46,000), so `month` becomes its own series of giant blue bars and the real cups are tiny.

8. In the chart editor (Setup tab), click **Add X-axis** and pick **month**.
9. Next to **month** under **Series**, open the three dots menu and click **Remove**.

You should see three bars for every month: chai, coffee and snack. Chai grew from 394 to 1,911.

## Common mistakes

- **`COPY` writes the file on the computer where the database runs, not on yours.** If the server is somewhere else, export from DBeaver instead (the **Export data** button under the result grid) or use psql's `\copy`.
- **Forgetting `HEADER`.** The first line is data, and the columns have no names. Always add `HEADER`.
- **The sheet is a snapshot.** When new sales come in, export again and import with **Replace current sheet**.

## Try it yourself

1. Export cups per branch, with one column per category, and chart it. How many bars does each branch get?
2. Open your `monthly_cups.csv` in a text editor. How many lines does it have, and why?
3. In the chart editor, change the chart type to **Line chart**. Which line rises the most?

## Answers

1. Three bars per branch (chai, coffee, snack).
   ```text
   \copy (SELECT branch, SUM(qty) FILTER (WHERE category = 'Chai') AS chai, SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee, SUM(qty) FILTER (WHERE category = 'Snack') AS snack FROM sales GROUP BY branch ORDER BY branch) TO 'branch_cups.csv' WITH (FORMAT csv, HEADER)
   ```
   ```text
   branch,chai,coffee,snack
   Delhi,559,176,534
   Mumbai,1093,348,998
   Pune,1730,520,1577
   ```
2. Four lines: one header line (because of `HEADER`) and one line per month.
3. Chai: 394 to 1,911.

## Next

[M22-L01 · MySQL and SQLite: What Changes, What Stays the Same](../../m22-other-databases-and-interviews/m22-l01-mysql-and-sqlite-what-changes-what-stays-the-same/)
