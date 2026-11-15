# M22-L07 · How to Keep Practising: Free Practice Sites and a 30-Day Plan

> Video: Module 22, Lesson 7. Watch it first, then follow along here.

## What you'll learn

- Why a little practice every day beats a lot once a week: 20 minutes a day beats 5 hours once a week
- Two free practice sites with no account: SQLBolt for the basics, PostgreSQL Exercises for harder questions
- A five-step way to practise any one question
- A simple 30-day plan, week by week
- The mistakes notebook: the habit that stops you repeating the same few mistakes

## Files in this folder

| File | What it is |
|---|---|
| `30_day_plan.md` | The plan from the video on one page: the sites, the five steps, the four weeks and a mistakes notebook to copy |

Also keep the course cheat sheet next to you while you practise: [SQL_Cheat_Sheet.pdf](../../resources/SQL_Cheat_Sheet.pdf).

## Key ideas

### 1. Skills fade, so practise a little every day

You now know a lot of SQL, but skills fade fast when you stop using them. The fix is small: 20 minutes every day beats 5 hours once a week.

### 2. Free site 1: SQLBolt

[SQLBolt](https://sqlbolt.com) is free, and you don't need an account.

- Each lesson explains one idea with short examples. The first one is on `SELECT`.
- Scroll down and you get a real table and a box to type your query. In lesson 1 it is a table of ten movies.
- On the right are five small tasks. Solve them all, and the next lesson opens.
- The lessons go from `SELECT` all the way to creating tables.

### 3. Free site 2: PostgreSQL Exercises

When you want harder questions, try [PostgreSQL Exercises](https://pgexercises.com). It is free too, with no account.

- Every question uses one small database: a country club, with members, facilities and bookings (the tables `cd.members`, `cd.facilities` and `cd.bookings`).
- Each page shows the question, a map of the tables, and the expected result on the left. The first question is "Retrieve everything from a table" (all the information from `cd.facilities`, 9 rows).
- You type your answer on the right and click **Run Query**. It runs on a real PostgreSQL database, and the questions go up to window functions.

### 4. And your own Chai Corner database

Make up a question about the Chai Corner database and answer it, any time. You know its tables better than any practice site's. Two ideas are in "Try it yourself" below.

### 5. How to practise one question

1. Read the question twice, and find the tables you need.
2. Guess the shape of the answer. How many rows, and which columns?
3. Write the query one part at a time: `FROM` first, then `WHERE`, then the rest.
4. Run it, and compare it with the expected result. If they differ, find the first row that is wrong.
5. Look at the answer only after you have really tried.

### 6. A 30-day plan

| Week | Days | Focus |
|---|---|---|
| 1 | 1-7 | The basics: `SELECT`, `WHERE`, sorting and grouping. 3 questions a day |
| 2 | 8-14 | Joins and subqueries |
| 3 | 15-21 | Window functions, CTEs, and the classic interview problems from this module ([M22-L03](../m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row/), [M22-L04](../m22-l04-classic-interview-problems-2-consecutive-days-gaps-and-islands-running-streaks/)) |
| 4 | 22-30 | One small project on Chai Corner each day, then finish with a timed mock interview ([Build 5](../m22-b05-interview-mock/)) |

If you miss a day, don't start over. Just carry on the next day.

### 7. The mistakes notebook

Each time you get a question wrong, write three things: the question, what you wrote, and why it was wrong. The video's example:

| Question | What I wrote | Why it was wrong |
|---|---|---|
| Find customers with no email | `WHERE email = NULL` (0 rows) | NULL is unknown, so `=` never matches. The right way is `WHERE email IS NULL` |

Read the notebook once a week. Most people repeat the same few mistakes, and this is how you stop.

## Common mistakes

- Practising only on weekends, for hours: the skill fades in between. Little and often.
- Looking at the answer after one minute. Really try first: the struggle is where you learn.
- Writing the whole query at once, then not knowing which part is wrong. Build it one clause at a time and run it after each part.
- Starting the plan again from day 1 after a missed day. Carry on.
- Getting a question wrong and not writing it down. The same mistake will come back.

## Try it yourself

1. The video's task: go to the SQLBolt site today, and finish lesson one. That is five small tasks.
2. Make up a Chai Corner question and answer it: which menu item has never been ordered in a shop order? (Use `menu_items` and `order_items`.)
3. Another one: for each menu category, how many items are there, and what is the cheapest price?
4. Start your mistakes notebook: write one mistake you made in this course, in the three columns.

## Answers

1. SQLBolt checks each task for you: when all five are ticked, lesson 2 opens.
2. One row, Paneer Roll:

   ```sql
   SELECT m.name
   FROM menu_items m
   WHERE NOT EXISTS (
     SELECT 1 FROM order_items oi
     WHERE oi.item_id = m.item_id);
   ```

3. Three rows:

   ```sql
   SELECT category, COUNT(*) AS items, MIN(price) AS cheapest
   FROM menu_items
   GROUP BY category
   ORDER BY category;
   ```

   | category | items | cheapest |
   |---|---|---|
   | Chai | 4 | 20 |
   | Coffee | 2 | 40 |
   | Snack | 6 | 25 |

4. Any honest mistake counts. A common one: `WHERE COUNT(*) > 1`, which fails because a condition on a group goes in `HAVING`.

## Next

[M22-B05 · Interview Mock](../m22-b05-interview-mock/)
