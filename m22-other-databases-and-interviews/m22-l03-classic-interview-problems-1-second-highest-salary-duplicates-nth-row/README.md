# M22-L03 · Classic Interview Problems 1: Second Highest Salary, Duplicates, Nth Row

> Video: Module 22, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- The second highest salary: the MAX below the MAX
- Why `LIMIT 1 OFFSET 3` gives a wrong "fourth highest" when there are ties
- The Nth highest salary with `DENSE_RANK`, where ties share a place (and why plain `RANK` skips a number)
- Finding duplicates with `GROUP BY` and `HAVING COUNT(*) > 1`, and listing the people behind them
- Picking the Nth row with `OFFSET N - 1`, always with `ORDER BY`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses the `staff` table (10 people, from [M09-L03](../../m09-joins/m09-l03-full-outer-join-everything-from-both-sides/)).
- **Run `setup.sql` first.** It is DB update 16: it adds a `salary` column to `staff` and gives each of the ten people a monthly salary in rupees. It is safe to run more than once.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | DB update 16: `staff.salary` for all 10 people |
| `interview_problems_1.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

### 1. Salaries, and the ties

Run `setup.sql`. The video ran it as `ALTER TABLE staff ADD COLUMN salary int;` then one `UPDATE` with a `CASE` on `staff_id`; the file adds `IF NOT EXISTS` so it can run twice. You should see `UPDATE 10`. Now sort:

```sql
SELECT name, role, salary FROM staff ORDER BY salary DESC;
```

You should see:

| name | role | salary |
|---|---|---|
| Meera | Owner | 90000 |
| Imran | Area Manager | 60000 |
| Pooja | Branch Manager | 45000 |
| Sameer | Branch Manager | 45000 |
| Kavya | Branch Manager | 42000 |
| Ravi | Barista | 22000 |
| Nisha | Barista | 22000 |
| Aman | Barista | 20000 |
| Leela | Cashier | 20000 |
| Farhan | Trainee | 12000 |

Notice the ties: some people earn the same amount. Ties are where most wrong answers come from. (Rows with the same salary can come back in a different order for you.)

### 2. Problem one: the second highest salary

First find the highest salary: the inner query, `MAX(salary)`, is 90000. Then keep only the salaries below it, and take the MAX again:

```sql
SELECT MAX(salary) AS second_highest
FROM staff
WHERE salary < (SELECT MAX(salary) FROM staff);
```

You should see:

| second_highest |
|---|
| 60000 |

Even if two people shared the top salary, this still works.

### 3. The OFFSET trap

What about the fourth highest? The shortcut: sort high to low, skip three rows, take one.

```sql
SELECT name, salary FROM staff ORDER BY salary DESC LIMIT 1 OFFSET 3;
```

You should see:

| name | salary |
|---|---|
| Pooja | 45000 |

That is wrong. The salaries go 90000, 60000, 45000, 45000. The tie fills two places, so the fourth different salary is really 42000.

### 4. The fix: DENSE_RANK

`DENSE_RANK` (from [M15-L02](../../m15-window-functions/m15-l02-row-number-rank-dense-rank/)) gives every row a rank number from the highest salary down. People with the same salary share a rank, and no number is skipped: Pooja and Sameer both get rank 3, Kavya gets rank 4.

```sql
WITH ranked AS (
  SELECT name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
  FROM staff
)
SELECT name, salary, rnk FROM ranked WHERE rnk = 4;
```

You should see:

| name | salary | rnk |
|---|---|---|
| Kavya | 42000 | 4 |

Plain `RANK` would skip a number after the tie and give Kavya rank 5. So for the Nth highest salary, use `DENSE_RANK`.

### 5. Problem two: duplicates

Which salaries appear more than once? `GROUP BY salary` makes one pile for each amount, and `HAVING COUNT(*) > 1` keeps only the piles with two or more people:

```sql
SELECT salary, COUNT(*) AS people
FROM staff
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;
```

You should see:

| salary | people |
|---|---|
| 45000 | 2 |
| 22000 | 2 |
| 20000 | 2 |

To see who they are, put that query inside an `IN` list:

```sql
SELECT name, salary
FROM staff
WHERE salary IN (
SELECT salary FROM staff
GROUP BY salary
HAVING COUNT(*) > 1
)
ORDER BY salary DESC, name;
```

You should see 6 people:

| name | salary |
|---|---|
| Pooja | 45000 |
| Sameer | 45000 |
| Nisha | 22000 |
| Ravi | 22000 |
| Aman | 20000 |
| Leela | 20000 |

### 6. Problem three: the Nth row

To get the third row, `ORDER BY staff_id`, then `LIMIT 1 OFFSET 2`:

```sql
SELECT staff_id, name FROM staff ORDER BY staff_id LIMIT 1 OFFSET 2;
```

You should see:

| staff_id | name |
|---|---|
| 3 | Pooja |

`OFFSET` is always N minus 1, because it counts the rows you skip. And always use `ORDER BY`: without it the database can return rows in any order, and your third row can change.

## Common mistakes

- Using `LIMIT 1 OFFSET N-1` on salaries for the Nth highest: ties fill several places and give a wrong answer.
- Using `RANK` instead of `DENSE_RANK` for the Nth highest: `RANK` skips numbers after a tie.
- Writing `WHERE COUNT(*) > 1`: a condition on a group goes in `HAVING`.
- `OFFSET N` instead of `OFFSET N - 1` for the Nth row.
- Picking "the third row" with no `ORDER BY`: the order is not guaranteed.

## Try it yourself

1. Find the third highest salary.
2. Find the fifth row by `staff_id`.
3. Using `RANK` instead of `DENSE_RANK`, what rank does Kavya get?
4. Find the second lowest salary.

## Answers

1. Change `rnk = 4` to `rnk = 3` in the `DENSE_RANK` query: 45000, shared by Pooja and Sameer (two rows, both rank 3).
2. `SELECT staff_id, name FROM staff ORDER BY staff_id LIMIT 1 OFFSET 4;` gives 5 Kavya.
3. Rank 5: Pooja and Sameer share rank 3, then `RANK` skips 4.
4. `SELECT MIN(salary) FROM staff WHERE salary > (SELECT MIN(salary) FROM staff);` gives 20000.

## Next

[M22-L04 · Classic Interview Problems 2: Consecutive Days, Gaps and Islands, Streaks](../m22-l04-classic-interview-problems-2-consecutive-days-gaps-and-islands-running-streaks/)
