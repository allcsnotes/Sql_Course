-- M06-L03 · Date Functions
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).
-- The video ran on 14 November 2026 in India time (+05:30). NOW, CURRENT_DATE and AGE
-- depend on the day you run them, so your results for steps 1 and 6 will differ.

-- Step 1: NOW gives the date and time right now with the time zone. CURRENT_DATE gives just today.
SELECT NOW() AS right_now, CURRENT_DATE AS today;
-- video: 2026-11-14 01:53:34.325 +0530 | 2026-11-14

-- Step 2: EXTRACT takes out the one part you name.
SELECT city, opened_on, EXTRACT(YEAR FROM opened_on) AS yr FROM branches;
-- 10 rows: Pune 2019-04-12 2019, Mumbai 2019-09-02 2019, Delhi 2020-01-20 2020, ... Kochi 2024-01-29 2024

-- Step 3: filter with it: everyone who joined in January (month 1).
SELECT name, joined_on FROM customers WHERE EXTRACT(MONTH FROM joined_on) = 1;
-- 3 rows: Rahul 2025-01-09, Kabir 2025-01-21, Dev 2026-01-15

-- Step 4: DATE_TRUNC cuts a date back to the start of the unit you choose.
SELECT joined_on, DATE_TRUNC('month', joined_on) AS mon FROM customers;
-- 15 rows, first: 2024-11-11 | 2024-11-01 00:00:00.000 +0530   (it adds midnight and a time zone)

-- Step 5: an INTERVAL is an amount of time. Add one year to get the renewal day.
SELECT name, joined_on + INTERVAL '1 year' AS renew_on FROM customers;
-- 15 rows, first: Asha 2025-11-11 00:00:00, Lukas 2025-11-14 00:00:00, Priya 2025-12-02 00:00:00

-- Step 6: AGE measures the gap from a date until today, in years, months and days.
SELECT name, joined_on, AGE(joined_on) AS member_for FROM customers;
-- video (on 2026-11-14): Asha 2 years 3 days, Lukas 2 years, Priya 1 year 11 mons 12 days, ...
