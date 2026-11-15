# M22-L04 · Classic Interview Problems 2: Consecutive Days, Gaps and Islands, Streaks

> Video: Module 22, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- What a **streak** (an **island**) and a **gap** are in a list of dates
- How `LAG` compares each day with the day before, and how subtracting two dates gives the gap in days
- The famous islands trick: the date minus the `ROW_NUMBER` gives one label for the whole streak
- One row for each streak with `GROUP BY customer, label`, and the longest streak per customer
- How to list the missing days between visits

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- **Run `setup.sql` first.** It is DB update 17: a small table `daily_visits` with one row for each day a customer came in (Asha 9 visits, Rahul 4). It is safe to run more than once.
- You know `LAG` ([M15-L05](../../m15-window-functions/m15-l05-lag-and-lead/)), `ROW_NUMBER` and `PARTITION BY` ([M15-L03](../../m15-window-functions/m15-l03-partition-by/)), and `WITH` ([M14-L01](../../m14-ctes/m14-l01-with-naming-a-step-of-your-query/)).

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | DB update 17: the `daily_visits` table, 13 rows |
| `interview_problems_2.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

### 1. The visits

```sql
SELECT * FROM daily_visits ORDER BY customer, visited_on;
```

You should see 13 rows. Asha came on March 1, 2 and 3, then the 5th and 6th, then the 9th to the 12th. Rahul came on March 2, 4, 5 and 8.

```text
March:     1  2  3  4  5  6  7  8  9 10 11 12
Asha       x  x  x  .  x  x  .  .  x  x  x  x
Rahul      .  x  .  x  x  .  .  x  .  .  .  .
```

A run of days in a row is a **streak**, or an **island**. The missing days between them are the **gaps**.

### 2. Compare each day with the day before

`LAG` looks back one row. `LAG(visited_on)` gives the previous visit, in date order. Subtract the two dates and you get the gap in days:

```sql
SELECT visited_on,
       LAG(visited_on) OVER (ORDER BY visited_on) AS prev_day,
       visited_on - LAG(visited_on) OVER (ORDER BY visited_on) AS gap
FROM daily_visits WHERE customer = 'Asha' ORDER BY visited_on;
```

You should see:

| visited_on | prev_day | gap |
|---|---|---|
| 2026-03-01 | NULL | NULL |
| 2026-03-02 | 2026-03-01 | 1 |
| 2026-03-03 | 2026-03-02 | 1 |
| 2026-03-05 | 2026-03-03 | 2 |
| 2026-03-06 | 2026-03-05 | 1 |
| 2026-03-09 | 2026-03-06 | 3 |
| 2026-03-10 | 2026-03-09 | 1 |
| 2026-03-11 | 2026-03-10 | 1 |
| 2026-03-12 | 2026-03-11 | 1 |

A gap of 1 means the very next day. A gap of 2 or 3 means some days were missed, and that row starts a new streak.

### 3. The islands trick

Number the visits 1, 2, 3 with `ROW_NUMBER`, then subtract that number, in days, from the date:

```sql
SELECT visited_on,
       ROW_NUMBER() OVER (ORDER BY visited_on) AS rn,
       visited_on - (ROW_NUMBER() OVER (ORDER BY visited_on))::int AS grp
FROM daily_visits WHERE customer = 'Asha' ORDER BY visited_on;
```

You should see:

| visited_on | rn | grp |
|---|---|---|
| 2026-03-01 | 1 | 2026-02-28 |
| 2026-03-02 | 2 | 2026-02-28 |
| 2026-03-03 | 3 | 2026-02-28 |
| 2026-03-05 | 4 | 2026-03-01 |
| 2026-03-06 | 5 | 2026-03-01 |
| 2026-03-09 | 6 | 2026-03-03 |
| 2026-03-10 | 7 | 2026-03-03 |
| 2026-03-11 | 8 | 2026-03-03 |
| 2026-03-12 | 9 | 2026-03-03 |

March 1 minus 1 day is February 28. March 2 minus 2 days is also February 28. Inside a streak the date and the row number both go up by one, so the answer stays the same. That shared date is a label for the whole streak. (`ROW_NUMBER` returns a `bigint`; `::int` turns it into a whole number that PostgreSQL can subtract from a date.)

### 4. One row for each streak

Put the trick in a `WITH` query. `PARTITION BY customer` restarts the numbering for each customer. Then `GROUP BY customer` and the label: `MIN` gives the first day, `MAX` the last day and `COUNT` the number of days.

```sql
WITH g AS (
  SELECT customer, visited_on,
         visited_on - (ROW_NUMBER() OVER (PARTITION BY customer ORDER BY visited_on))::int AS grp
  FROM daily_visits)
SELECT customer, MIN(visited_on) AS first_day, MAX(visited_on) AS last_day, COUNT(*) AS days
FROM g GROUP BY customer, grp ORDER BY customer, first_day;
```

You should see:

| customer | first_day | last_day | days |
|---|---|---|---|
| Asha | 2026-03-01 | 2026-03-03 | 3 |
| Asha | 2026-03-05 | 2026-03-06 | 2 |
| Asha | 2026-03-09 | 2026-03-12 | 4 |
| Rahul | 2026-03-02 | 2026-03-02 | 1 |
| Rahul | 2026-03-04 | 2026-03-05 | 2 |
| Rahul | 2026-03-08 | 2026-03-08 | 1 |

Asha has three streaks: three days, two days and four days. Rahul's longest is two days.

### 5. The longest streak for each customer

Add a second `WITH` step, `streaks`, with one row for each streak, then take the `MAX` of days for each customer:

```sql
WITH g AS (
  SELECT customer, visited_on,
         visited_on - (ROW_NUMBER() OVER (PARTITION BY customer ORDER BY visited_on))::int AS grp
  FROM daily_visits),
streaks AS (SELECT customer, COUNT(*) AS days FROM g GROUP BY customer, grp)
SELECT customer, MAX(days) AS longest_streak FROM streaks GROUP BY customer ORDER BY customer;
```

You should see:

| customer | longest_streak |
|---|---|
| Asha | 4 |
| Rahul | 2 |

### 6. Find the gaps

Use `LAG` again for the previous visit. Where the gap is more than one day, some days are missing. The gap starts the day after the previous visit and ends the day before this one:

```sql
WITH p AS (
  SELECT customer, visited_on,
         LAG(visited_on) OVER (PARTITION BY customer ORDER BY visited_on) AS prev_day
  FROM daily_visits)
SELECT customer, prev_day + 1 AS gap_starts, visited_on - 1 AS gap_ends
FROM p WHERE visited_on - prev_day > 1 ORDER BY customer, gap_starts;
```

You should see:

| customer | gap_starts | gap_ends |
|---|---|---|
| Asha | 2026-03-04 | 2026-03-04 |
| Asha | 2026-03-07 | 2026-03-08 |
| Rahul | 2026-03-03 | 2026-03-03 |
| Rahul | 2026-03-06 | 2026-03-07 |

Asha missed March 4, and the 7th to the 8th. Rahul missed the 3rd, and the 6th to the 7th.

## Common mistakes

- Forgetting `PARTITION BY customer`: Asha's and Rahul's dates get numbered together and the labels mix up.
- Forgetting `ORDER BY visited_on` inside `OVER`: `LAG` and `ROW_NUMBER` then follow no fixed order.
- Leaving out `::int`: `date - bigint` is an error in PostgreSQL.
- Two visits on the same day break the trick: remove duplicates first (`SELECT DISTINCT customer, visited_on`).
- Putting a condition on the count in `WHERE` instead of `HAVING`.

## Try it yourself

1. Find every streak of three days or more.
2. How many days did each customer miss in total between their first and last visit?
3. Find Asha's longest gap in days.

## Answers

1. Add `HAVING COUNT(*) >= 3` to the streaks query (see the last query in `interview_problems_2.sql`): two streaks for Asha, 3 days from March 1 and 4 days from March 9.
2. Sum the gap lengths: `SELECT customer, SUM(visited_on - prev_day - 1) AS missed FROM (SELECT customer, visited_on, LAG(visited_on) OVER (PARTITION BY customer ORDER BY visited_on) AS prev_day FROM daily_visits) p GROUP BY customer ORDER BY customer;` gives Asha 3, Rahul 3.
3. 3 days (March 6 to March 9), from the `gap` column in step 2. Missed days: 2 (March 7 and 8).

## Next

[M22-L05 · Design Interview: the Database for a Food Delivery App](../m22-l05-design-interview-the-database-for-a-food-delivery-app/)
