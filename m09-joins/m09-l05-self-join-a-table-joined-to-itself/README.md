# M09-L05 · Self Join: a Table Joined to Itself

> Video: Module 9, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- Why a link can point back into the same table (`staff.manager_id` → `staff.staff_id`)
- How a **self join** reads one table twice, with an **alias** (nickname) for each copy: `emp` and `boss`
- How `LEFT JOIN` + `COALESCE` keeps people who have no manager
- How to count each manager's team with `GROUP BY`
- Three traps: no aliases, a bare column name, and a flipped `ON`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 5 (the `staff` table) from [M09-L03](../m09-l03-full-outer-join-everything-from-both-sides/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `self_join.sql` | Every query of the video, in order, with the result or error as a comment |

## Follow along

### 1. Same table twice

```sql
SELECT staff_id, name, role, manager_id FROM staff ORDER BY staff_id;
```

| staff_id | name | role | manager_id |
|---|---|---|---|
| 1 | Meera | Owner | NULL |
| 2 | Imran | Area Manager | 1 |
| 3 | Pooja | Branch Manager | 2 |
| 4 | Sameer | Branch Manager | 2 |
| 5 | Kavya | Branch Manager | 2 |
| 6 | Ravi | Barista | 3 |
| 7 | Nisha | Barista | 3 |
| 8 | Aman | Barista | 4 |
| 9 | Leela | Cashier | 5 |
| 10 | Farhan | Trainee | 2 |

Every staff row has a `manager_id`: the `staff_id` of that person's manager. Pooja's `manager_id` is 2, and staff number 2 is Imran. The link points back into the same table, so we use the table twice: one copy for the employee, called `emp`, one copy for the manager, called `boss`.

### 2. Writing a self join

`FROM staff AS emp`, then `JOIN staff AS boss`. The keyword `AS` gives each copy its own nickname. `ON boss.staff_id = emp.manager_id`: each employee finds their manager's row.

```sql
SELECT emp.name  AS employee,
       boss.name AS manager
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id
ORDER BY emp.staff_id;
```

You should see 9 rows:

| employee | manager |
|---|---|
| Imran | Meera |
| Pooja | Imran |
| Sameer | Imran |
| Kavya | Imran |
| Ravi | Pooja |
| Nisha | Pooja |
| Aman | Sameer |
| Leela | Kavya |
| Farhan | Imran |

Meera is missing.

### 3. Keeping everyone

Meera owns Chai Corner, so she has no manager, and the inner join dropped her. Switch to a `LEFT JOIN` so every employee stays, and wrap the name in `COALESCE` to fill her empty manager:

```sql
SELECT emp.name  AS employee,
       COALESCE(boss.name, 'no manager') AS manager
FROM staff AS emp
LEFT JOIN staff AS boss ON boss.staff_id = emp.manager_id
ORDER BY emp.staff_id;
```

Now all 10 staff are here: `Meera | no manager` first, then the 9 rows above.

### 4. Team sizes

Who manages the most people? Group by the boss's name and count:

```sql
SELECT boss.name AS manager,
       COUNT(*)  AS team_size
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id
GROUP BY boss.name
ORDER BY team_size DESC, manager;
```

| manager | team_size |
|---|---|
| Imran | 4 |
| Pooja | 2 |
| Kavya | 1 |
| Meera | 1 |
| Sameer | 1 |

Imran leads with 4 (Pooja, Sameer, Kavya and Farhan). Pooja has 2 (Ravi and Nisha).

## Common mistakes

**1. Forgetting the nicknames.**

```sql
SELECT staff.name, staff.name
FROM staff
JOIN staff ON staff.staff_id = staff.manager_id;
```

```text
SQL Error [42712]: ERROR: table name "staff" specified more than once
```

Give each copy its own alias.

**2. Writing just `name`.** Both copies have a `name` column:

```sql
SELECT name
FROM staff AS emp
JOIN staff AS boss ON boss.staff_id = emp.manager_id;
```

```text
SQL Error [42702]: ERROR: column reference "name" is ambiguous
  Position: 8
```

Write `emp.name` or `boss.name`.

**3. Flipping the `ON`.**

```sql
SELECT emp.name  AS employee,
       boss.name AS manager
FROM staff AS emp
JOIN staff AS boss ON boss.manager_id = emp.staff_id
ORDER BY emp.staff_id;
```

It runs, but the first row now says Meera's manager is Imran, which is backwards (it lists each person with the people *they* manage). Always match the boss's `staff_id` to the employee's `manager_id`.

## Try it yourself

1. Who is Nisha's manager's manager? Join `staff` three times. Guess first, then run it.
2. List the people who report directly to Imran.
3. Show each employee with their manager and the manager's role.

## Next

[M09-L06 · CROSS JOIN: Every Combination](../m09-l06-cross-join-every-combination/)

## Answers

1. Imran (Nisha → Pooja → Imran):
   ```sql
   SELECT emp.name  AS employee,
          boss.name AS manager,
          big.name  AS managers_manager
   FROM staff AS emp
   JOIN staff AS boss ON boss.staff_id = emp.manager_id
   JOIN staff AS big  ON big.staff_id  = boss.manager_id
   WHERE emp.name = 'Nisha';
   ```
   | employee | manager | managers_manager |
   |---|---|---|
   | Nisha | Pooja | Imran |
2. Pooja, Sameer, Kavya and Farhan: the step 2 query with `WHERE boss.name = 'Imran'`.
3. Add `boss.role AS manager_role` to the step 2 query. Pooja's manager Imran is an Area Manager; Ravi's manager Pooja is a Branch Manager.
