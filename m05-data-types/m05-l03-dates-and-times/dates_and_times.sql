-- M05-L03 · Dates and Times
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: opened_on is a date (year, then month, then day).
SELECT city, opened_on, pg_typeof(opened_on) AS its_type FROM branches LIMIT 3;
-- 3 rows: Pune 2019-04-12 date, Mumbai 2019-09-02 date, Delhi 2020-01-20 date

-- Step 2: the three main types: date, time, timestamp.
SELECT '2026-11-14'::date AS a_date, '09:30'::time AS a_time, '2026-11-14 09:30'::timestamp AS a_timestamp;
-- 2026-11-14 | 09:30:00 | 2026-11-14 09:30:00   (DBeaver shows 2026-11-14 09:30:00.000)

-- Step 3: a date plus a number moves forward by that many days.
SELECT '2026-11-14'::date + 7 AS one_week_later;
-- 2026-11-21

-- Step 4: a date minus a date gives the number of days between them.
SELECT city, '2026-11-14'::date - opened_on AS days_open FROM branches ORDER BY opened_on;
-- 10 rows: Pune 2773, Mumbai 2630, Delhi 2490, Bengaluru 2313, Chennai 2105,
--          Hyderabad 1909, Kolkata 1706, Jaipur 1470, Ahmedabad 1244, Kochi 1020

-- Step 5: timestamptz adds a time zone. This session uses India time.
SELECT current_setting('TimeZone') AS my_time_zone, '2026-11-14 09:30'::timestamptz AS order_time;
-- Asia/Kolkata | 2026-11-14 09:30:00.000 +0530   (your time zone setting may differ)

-- Step 6: AT TIME ZONE shows the same moment on another clock.
SELECT '2026-11-14 09:30'::timestamptz AT TIME ZONE 'Europe/Berlin' AS same_moment_in_berlin;
-- 2026-11-14 05:00:00   (when the session time zone is Asia/Kolkata)
