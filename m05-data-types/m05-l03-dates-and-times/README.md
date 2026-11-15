# M05-L03 · Dates and Times

> Video: Module 5, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- `date` is a day, `time` is a time of day, and `timestamp` is both
- Add a number to a date to move forward by days; subtract two dates to get the days between them
- `timestamptz` adds a time zone, and `AT TIME ZONE` shows the same moment on another clock
- Always write dates as year, month, day, inside single quotes

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.
- The video's session uses India time (`Asia/Kolkata`). If your time zone is different, steps 5 and 6 show other clock times.

## Files in this folder

| File | What it is |
|------|------------|
| `dates_and_times.sql` | The six queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes |

## Follow along

When did Asha place her order? How many days has the Pune branch been open? To answer questions about time, a database needs special types. People write dates in many ways around the world. PostgreSQL has one clear way, and it can even do maths with dates.

### 1. The date type

Our `branches` table has an `opened_on` column:

```sql
SELECT city, opened_on, pg_typeof(opened_on) AS its_type FROM branches LIMIT 3;
```

You should see:

| city | opened_on | its_type |
|------|-----------|----------|
| Pune | 2019-04-12 | date |
| Mumbai | 2019-09-02 | date |
| Delhi | 2020-01-20 | date |

A **date** is a day on the calendar: year, then month, then day.

### 2. date, time and timestamp

There are three main types. `date` holds a day, `time` holds a time of day like 9:30, and `timestamp` holds both together:

```sql
SELECT '2026-11-14'::date AS a_date, '09:30'::time AS a_time, '2026-11-14 09:30'::timestamp AS a_timestamp;
```

You should see:

| a_date | a_time | a_timestamp |
|--------|--------|-------------|
| 2026-11-14 | 09:30:00 | 2026-11-14 09:30:00.000 |

(`psql` prints the timestamp without the `.000`.)

### 3. Maths with dates

Add a number to a date and you move forward by that many days:

```sql
SELECT '2026-11-14'::date + 7 AS one_week_later;
```

You should see `2026-11-21`: the 14th of November plus 7 is the 21st.

Subtract one date from another and you get the number of days between them:

```sql
SELECT city, '2026-11-14'::date - opened_on AS days_open FROM branches ORDER BY opened_on;
```

You should see:

| city | days_open |
|------|----------:|
| Pune | 2773 |
| Mumbai | 2630 |
| Delhi | 2490 |
| Bengaluru | 2313 |
| Chennai | 2105 |
| Hyderabad | 1909 |
| Kolkata | 1706 |
| Jaipur | 1470 |
| Ahmedabad | 1244 |
| Kochi | 1020 |

The Pune branch has been open for 2773 days. Kochi, our newest branch, for 1020.

### 4. Time zones

9:30 in India is not 9:30 in Germany. The type **timestamptz** adds a time zone to a timestamp:

```sql
SELECT current_setting('TimeZone') AS my_time_zone, '2026-11-14 09:30'::timestamptz AS order_time;
```

You should see:

| my_time_zone | order_time |
|--------------|------------|
| Asia/Kolkata | 2026-11-14 09:30:00.000 +0530 |

This session uses India time, `Asia/Kolkata`, so the value ends with +05:30.

`AT TIME ZONE` shows the same moment on another clock. When Asha orders at 9:30 in Pune, it is 5 in the morning for Lukas in Berlin:

```sql
SELECT '2026-11-14 09:30'::timestamptz AT TIME ZONE 'Europe/Berlin' AS same_moment_in_berlin;
```

You should see `2026-11-14 05:00:00` (DBeaver adds `.000`).

If your users live in different places, store times as `timestamptz`. It always knows the exact moment.

## Common mistakes

The queries are in `mistakes.sql`.

**1. Writing the day first.**

```sql
SELECT '14-11-2026'::date AS day_first;
```

```text
SQL Error [22008]: ERROR: date/time field value out of range: "14-11-2026"
  Hint: Perhaps you need a different "DateStyle" setting.
```

PostgreSQL reads the first number as the month, and there is no month 14.

**2. A day that also fits as a month (worse).**

```sql
SELECT '05-11-2026'::date AS meant_5_november;
```

You see `2026-05-11`, the 11th of May, with no error at all. Always write year, month, day: `'2026-11-05'`.

**3. Forgetting the quotes.** Without quotes, `2022-01-01` is a sum of numbers:

```sql
SELECT city FROM branches WHERE opened_on > 2022-01-01;
```

```text
SQL Error [42883]: ERROR: operator does not exist: date > integer
```

Put dates in single quotes: `WHERE opened_on > '2022-01-01'` gives Kolkata, Jaipur, Ahmedabad and Kochi.

## Try it yourself

1. How many days are there from the 14th of November to the 31st of December? Guess first, then run it.
2. Which date is 30 days before `'2026-11-14'`?
3. Show 9:30 on the 14th of November 2026 (India time) on the clock in `'Asia/Tokyo'`.

## Answers

1. The task from the video:

   ```sql
   SELECT '2026-12-31'::date - '2026-11-14'::date AS days_left;
   ```

   It gives `47`.
2. `SELECT '2026-11-14'::date - 30;` gives `2026-10-15`.
3. `SELECT '2026-11-14 09:30'::timestamptz AT TIME ZONE 'Asia/Tokyo';` gives `2026-11-14 13:00:00` (Tokyo is 3:30 ahead of India; with a session time zone other than Asia/Kolkata, write `'2026-11-14 09:30+05:30'::timestamptz`).

## Next

[M05-L04 · Boolean, UUID and JSON](../m05-l04-boolean-uuid-and-json/)
