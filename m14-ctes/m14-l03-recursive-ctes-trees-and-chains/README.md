# M14-L03 · Recursive CTEs: Trees and Chains

> Video: Module 14, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What a **recursive CTE** is: a step that reads its own rows, again and again, until nothing new is found
- The three parts: a start row, `UNION ALL`, and a step with a stop
- Counting 1 to 5 and listing every day of a week
- Walking **up** a chain of bosses and **down** a whole team tree in the `staff` table
- Three mistakes: no `RECURSIVE`, no stop, and types that do not match

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads the `staff` table (10 people, each with a `manager_id` that points to their boss) added in Module 9. It changes nothing.

The `staff` table, for reference:

| staff_id | name | manager_id |
|---|---|---|
| 1 | Meera | (NULL) |
| 2 | Imran | 1 |
| 3 | Pooja | 2 |
| 4 | Sameer | 2 |
| 5 | Kavya | 2 |
| 6 | Ravi | 3 |
| 7 | Nisha | 3 |
| 8 | Aman | 4 |
| 9 | Leela | 5 |
| 10 | Farhan | 2 |

## Files in this folder

| File | What it is |
|---|---|
| `recursive_ctes.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Who is Nisha's boss? And the boss of her boss, all the way to the top? You do not know how many steps that takes. A recursive CTE repeats one step until there is nothing new to find.

Picture climbing stairs, one stair at a time:

1. A **start row**. It runs only once.
2. A **step**. It reads the rows made last time and makes the next rows.
3. The step repeats. When it makes no new rows it stops, and all the rows are joined into one result.

### 1. Count from one to five

`WITH RECURSIVE`, then the name `counter`. The start row is `SELECT 1 AS n`. `UNION ALL` stacks the new rows under the old ones. The step reads `counter` itself and adds one to `n`; `WHERE n < 5` is the stop.

```sql
WITH RECURSIVE counter AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM counter WHERE n < 5
)
SELECT n FROM counter;
```

You should see 5 rows: `1, 2, 3, 4, 5`. Then it stopped.

### 2. A list of dates

The first row is 1 March; each step adds one day, and it stops at 7 March.

```sql
WITH RECURSIVE days AS (
  SELECT DATE '2026-03-01' AS day
  UNION ALL
  SELECT day + 1 FROM days WHERE day < DATE '2026-03-07'
)
SELECT day FROM days;
```

You should see 7 rows, `2026-03-01` to `2026-03-07`, one for every day of the week. Handy when a report needs every day, even a day with no sales.

### 3. Walk up a chain

Every person has a `manager_id` that points to their boss. The start row is Nisha (step 1). The step joins `staff` to `chain`: it finds the person whose `staff_id` is the `manager_id` of the last row.

```sql
WITH RECURSIVE chain AS (
  SELECT staff_id, name, manager_id, 1 AS step
  FROM staff WHERE name = 'Nisha'
  UNION ALL
  SELECT s.staff_id, s.name, s.manager_id, c.step + 1
  FROM staff s JOIN chain c ON s.staff_id = c.manager_id
)
SELECT step, name FROM chain;
```

You should see:

| step | name |
|---|---|
| 1 | Nisha |
| 2 | Pooja |
| 3 | Imran |
| 4 | Meera |

Meera has no manager, so the join finds nobody and the query stops on its own.

### 4. Walk down the tree

The start row is the top boss, the person whose `manager_id` is NULL (Meera). The step finds the people whose manager is in the last rows, and adds one to the level.

```sql
WITH RECURSIVE tree AS (
  SELECT staff_id, name, 1 AS level
  FROM staff WHERE manager_id IS NULL
  UNION ALL
  SELECT s.staff_id, s.name, t.level + 1
  FROM staff s JOIN tree t ON s.manager_id = t.staff_id
)
SELECT level, name FROM tree ORDER BY level, staff_id;
```

You should see 10 rows, the whole team:

| level | name |
|---|---|
| 1 | Meera |
| 2 | Imran |
| 3 | Pooja |
| 3 | Sameer |
| 3 | Kavya |
| 3 | Farhan |
| 4 | Ravi |
| 4 | Nisha |
| 4 | Aman |
| 4 | Leela |

## Common mistakes

All three were run for real in the video.

1. **Forgetting the word `RECURSIVE`.** `WITH counter AS (...)` with the same body: the step cannot read itself.

   ```text
   ERROR: relation "counter" does not exist   (SQLSTATE 42P01)
   HINT: Use WITH RECURSIVE, or re-order the WITH items to remove forward references.
   ```

   Fix: always write `WITH RECURSIVE`.

2. **No stop.** Without the `WHERE`, the step never ends. In the video a `LIMIT 10` on the main query cut it short:

   ```sql
   WITH RECURSIVE counter AS (
     SELECT 1 AS n
     UNION ALL
     SELECT n + 1 FROM counter
   )
   SELECT n FROM counter LIMIT 10;
   ```

   You see `1` to `10`. Without the `LIMIT` it would run for ever. Fix: always give the step a stop (`WHERE n < 5`).

3. **The start row and the step give different types.** `1` is a whole number, `n + 0.5` is not.

   ```sql
   WITH RECURSIVE counter AS (
     SELECT 1 AS n
     UNION ALL
     SELECT n + 0.5 FROM counter WHERE n < 3
   )
   SELECT n FROM counter;
   ```

   ```text
   ERROR: recursive query "counter" column 1 has type integer in non-recursive term but type numeric overall   (SQLSTATE 42804)
   ```

   Fix: make both the same type, `SELECT 1.0 AS n`. Then you get `1.0, 1.5, 2.0, 2.5, 3.0`.

## Try it yourself

1. How many people work under Imran, at any level? (The video's task.)
2. Walk up the chain from Leela instead of Nisha.
3. Make a list of every day of January 2026 and count the rows.

## Answers

1. 8 people.

   ```sql
   WITH RECURSIVE team AS (
     SELECT staff_id FROM staff WHERE name = 'Imran'
     UNION ALL
     SELECT s.staff_id
     FROM staff s JOIN team t ON s.manager_id = t.staff_id
   )
   SELECT COUNT(*) - 1 AS team_size FROM team;
   ```

   `- 1` removes Imran himself (the start row).

2. Change `WHERE name = 'Nisha'` to `WHERE name = 'Leela'`: Leela, Kavya, Imran, Meera.

3. Start at `DATE '2026-01-01'`, stop at `DATE '2026-01-31'`, then `SELECT COUNT(*) FROM days`: 31.

## Next

[M15-L01 · What a Window Is](../../m15-window-functions/m15-l01-what-a-window-is/)
