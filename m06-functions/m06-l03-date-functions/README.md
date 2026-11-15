# M06-L03 · Date Functions

> Video: Module 6, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- `NOW()` gives the date and the time right now; `CURRENT_DATE` gives just today
- `EXTRACT(YEAR FROM ...)` pulls out one part of a date, and you can filter with it
- `DATE_TRUNC('month', ...)` cuts a date back to the start of its month
- Add an `INTERVAL` to move a date, and use `AGE` to measure how long ago it was
- Three beginner mistakes: no `INTERVAL` word, month ends, and month 1 in every year

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.
- The video ran on **14 November 2026**, in India time (+05:30). `NOW`, `CURRENT_DATE` and `AGE` depend on the day you run them, so those results will differ for you.

## Files in this folder

| File | What it is |
|------|------------|
| `date_functions.sql` | The six queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and their fixes |

## Follow along

Which customers joined in January? When does each membership renew? How long has each customer been with us? Date functions answer all of these.

### 1. What is the time right now?

```sql
SELECT NOW() AS right_now, CURRENT_DATE AS today;
```

In the video:

| right_now | today |
|-----------|-------|
| 2026-11-14 01:53:34.325 +0530 | 2026-11-14 |

`NOW()` gives the date and the time, right this second, with your time zone (+05:30 is India time). `CURRENT_DATE` gives just today's date, with no time at all. Use it when the hour does not matter.

### 2. Pull out one part with EXTRACT

A date has three parts: a year, a month and a day. `EXTRACT` takes out the one part you name:

```sql
SELECT city, opened_on, EXTRACT(YEAR FROM opened_on) AS yr FROM branches;
```

You should see 10 rows, starting:

| city | opened_on | yr |
|------|-----------|---:|
| Pune | 2019-04-12 | 2019 |
| Mumbai | 2019-09-02 | 2019 |
| Delhi | 2020-01-20 | 2020 |

You can filter with it too. Keep only month 1:

```sql
SELECT name, joined_on FROM customers WHERE EXTRACT(MONTH FROM joined_on) = 1;
```

You should see:

| name | joined_on |
|------|-----------|
| Rahul | 2025-01-09 |
| Kabir | 2025-01-21 |
| Dev | 2026-01-15 |

Everyone who joined in January: Rahul, Kabir and Dev.

### 3. Cut a date back with DATE_TRUNC

`DATE_TRUNC` cuts a date back to the start of the unit you choose:

```sql
SELECT joined_on, DATE_TRUNC('month', joined_on) AS mon FROM customers;
```

You should see 15 rows, starting:

| joined_on | mon |
|-----------|-----|
| 2024-11-11 | 2024-11-01 00:00:00.000 +0530 |
| 2024-11-14 | 2024-11-01 00:00:00.000 +0530 |
| 2024-12-02 | 2024-12-01 00:00:00.000 +0530 |

With `'month'`, the 11th of November becomes the 1st of November. Every day in a month lands on the same first day, which makes it easy to put dates into monthly piles later. Notice it also adds a time, midnight, and a time zone.

### 4. Add time, and measure time

An **INTERVAL** is an amount of time, like `'1 year'`, `'3 days'` or `'2 hours'`. Add one year to the day each customer joined to get the day their membership renews:

```sql
SELECT name, joined_on + INTERVAL '1 year' AS renew_on FROM customers;
```

You should see 15 rows, starting:

| name | renew_on |
|------|----------|
| Asha | 2025-11-11 00:00:00 |
| Lukas | 2025-11-14 00:00:00 |
| Priya | 2025-12-02 00:00:00 |

`AGE` measures the gap from a date until today, in years, months and days:

```sql
SELECT name, joined_on, AGE(joined_on) AS member_for FROM customers;
```

In the video (run on 14 November 2026):

| name | joined_on | member_for |
|------|-----------|------------|
| Asha | 2024-11-11 | 2 years 3 days |
| Lukas | 2024-11-14 | 2 years |
| Priya | 2024-12-02 | 1 year 11 mons 12 days |

Lukas joined on the 14th of November 2024, so on that day he had been a member for exactly two years. Your numbers depend on today's date.

## Common mistakes

The queries are in `mistakes.sql`.

**1. Adding one month as plain text,** without the word `INTERVAL`:

```sql
SELECT CURRENT_DATE + '1 month' AS next_month;
```

```text
SQL Error [42725]: ERROR: operator is not unique: date + unknown
```

PostgreSQL cannot tell what that text is. Put `INTERVAL` before the text:

```sql
SELECT CURRENT_DATE + INTERVAL '1 month' AS next_month;
```

In the video: `2026-12-14 00:00:00` (a month after the day you run it).

**2. Month ends are tricky:**

```sql
SELECT '2026-01-31'::date + INTERVAL '1 month' AS one_month_later;
```

You see `2026-02-28 00:00:00`, because February has no 31st. There is no error, so check dates near the end of a month.

**3. Month = 1 finds January in every year,** so Dev from 2026 sneaks into step 2's list. For one exact month, use `DATE_TRUNC` and compare it with the first day of that month:

```sql
SELECT name FROM customers WHERE DATE_TRUNC('month', joined_on) = '2025-01-01';
```

You should see only Rahul and Kabir.

## Try it yourself

1. Find every customer who joined in 2025. Use `EXTRACT` on the year. Guess how many first, then run it.
2. Show each branch's city with the date 30 days after it opened.
3. Find the customers who joined in March 2026 with `DATE_TRUNC`.

## Answers

1. The task from the video:

   ```sql
   SELECT name FROM customers WHERE EXTRACT(YEAR FROM joined_on) = 2025;
   ```

   9 rows: Rahul, Kabir, Ananya, Rohan, Isha, Vikram, Neha, Arjun, Sara.
2. `SELECT city, opened_on + INTERVAL '30 days' FROM branches;` (or `opened_on + 30`).
3. `SELECT name FROM customers WHERE DATE_TRUNC('month', joined_on) = '2026-03-01';` gives Tara.

## Next

[M06-L04 · CASE WHEN](../m06-l04-case-when/)
