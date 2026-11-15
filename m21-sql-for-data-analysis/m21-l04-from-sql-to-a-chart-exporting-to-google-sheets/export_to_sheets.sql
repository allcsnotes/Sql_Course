-- M21-L04 From SQL to a chart: exporting to Google Sheets
-- The queries in the order the video runs them, with the real results. No database changes.

-- Step 1: the report: one row per month, one column per category
SELECT to_char(date_trunc('month', sold_at), 'YYYY-MM') AS month,
       SUM(qty) FILTER (WHERE category = 'Chai')   AS chai,
       SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee,
       SUM(qty) FILTER (WHERE category = 'Snack')  AS snack
FROM sales
GROUP BY month
ORDER BY month;
-- 3 rows: 2026-01 394 127 417, 2026-02 1077 341 1006, 2026-03 1911 576 1686

-- Step 2: save the same report as a CSV file.
-- The video ran a server-side COPY with a full folder path on its own computer:
--   COPY ( ...the report... ) TO '<a folder on the database server>/monthly_cups.csv'
--   WITH (FORMAT csv, HEADER);
-- That writes the file on the computer where PostgreSQL runs, and the server needs
-- permission to write there. In psql, \copy does the same job but writes the file on
-- YOUR computer, relative to the folder you started psql in. \copy must be on one line:
\copy (SELECT to_char(date_trunc('month', sold_at), 'YYYY-MM') AS month, SUM(qty) FILTER (WHERE category = 'Chai') AS chai, SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee, SUM(qty) FILTER (WHERE category = 'Snack') AS snack FROM sales GROUP BY month ORDER BY month) TO 'monthly_cups.csv' WITH (FORMAT csv, HEADER)
-- COPY 3   (DBeaver shows "Updated Rows 3" for the server-side COPY)

-- Steps 3 to 9 happen in Google Sheets (see README.md).

-- Task: cups per branch, one column per category. Each branch gets 3 bars.
\copy (SELECT branch, SUM(qty) FILTER (WHERE category = 'Chai') AS chai, SUM(qty) FILTER (WHERE category = 'Coffee') AS coffee, SUM(qty) FILTER (WHERE category = 'Snack') AS snack FROM sales GROUP BY branch ORDER BY branch) TO 'branch_cups.csv' WITH (FORMAT csv, HEADER)
-- COPY 3
