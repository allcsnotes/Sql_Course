# M09-L03 · FULL OUTER JOIN: Everything From Both Sides

> Video: Module 9, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- How Chai Corner update 5 adds a `staff` table (some staff have no branch)
- What `FULL OUTER JOIN` keeps: the matches, plus the leftovers from **both** tables
- How to show only the gaps with `IS NULL ... OR ... IS NULL`
- How `COALESCE` turns `NULL` into a clear label on a report
- Why `WHERE` on one side breaks it, and what to do in MySQL, which has no full outer join

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- **Run `setup.sql` once** (Chai Corner update 5). In DBeaver: open the file, then SQL Editor > Execute SQL Script (Alt+X); then Database > Disconnect and Connect so DBeaver sees the new table. In psql: `\i setup.sql`. It creates a table, so a second run stops with `relation "staff" already exists`.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | Chai Corner update 5: creates `staff` (10 rows) with foreign keys to `branches` and to `staff` itself |
| `full_outer_join.sql` | Every query of the video, in order, with the result as a comment |

## What setup.sql does

```sql
CREATE TABLE staff (
  staff_id   int PRIMARY KEY,
  name       varchar(40) NOT NULL,
  role       varchar(30) NOT NULL,
  branch_id  int REFERENCES branches (branch_id),
  manager_id int REFERENCES staff (staff_id)
);
```

`branch_id` may be empty (`NULL`) for head office staff and a new trainee. `manager_id` points to another row of `staff`; the self join lesson (M09-L05) uses it.

## Follow along

### 1. The staff table

```sql
SELECT staff_id, name, role, branch_id
FROM staff
ORDER BY staff_id;
```

| staff_id | name | role | branch_id |
|---|---|---|---|
| 1 | Meera | Owner | NULL |
| 2 | Imran | Area Manager | NULL |
| 3 | Pooja | Branch Manager | 1 |
| 4 | Sameer | Branch Manager | 2 |
| 5 | Kavya | Branch Manager | 3 |
| 6 | Ravi | Barista | 1 |
| 7 | Nisha | Barista | 1 |
| 8 | Aman | Barista | 2 |
| 9 | Leela | Cashier | 3 |
| 10 | Farhan | Trainee | NULL |

Seven branches have no staff yet, and three staff members have no branch. A left join keeps one side; a **full outer join** keeps both.

### 2. The inner join: only the matches

```sql
SELECT branches.city, staff.name
FROM branches
INNER JOIN staff
  ON staff.branch_id = branches.branch_id
ORDER BY branches.branch_id, staff.staff_id;
```

You should see 7 rows: Pune Pooja, Pune Ravi, Pune Nisha, Mumbai Sameer, Mumbai Aman, Delhi Kavya, Delhi Leela.

### 3. FULL OUTER JOIN

```sql
SELECT branches.city, staff.name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
ORDER BY branches.branch_id, staff.staff_id;
```

You should see 17 rows: 7 matches, 7 empty branches and 3 people with no branch.

| city | name |
|---|---|
| Pune | Pooja |
| Pune | Ravi |
| Pune | Nisha |
| Mumbai | Sameer |
| Mumbai | Aman |
| Delhi | Kavya |
| Delhi | Leela |
| Bengaluru | NULL |
| Chennai | NULL |
| Hyderabad | NULL |
| Kolkata | NULL |
| Jaipur | NULL |
| Ahmedabad | NULL |
| Kochi | NULL |
| NULL | Meera |
| NULL | Imran |
| NULL | Farhan |

Bengaluru finds nobody, so the name side is `NULL`. Meera works at head office with no branch, so her city side is `NULL`.

### 4. Only the gaps

```sql
SELECT branches.city, staff.name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
WHERE branches.branch_id IS NULL
   OR staff.staff_id IS NULL
ORDER BY branches.branch_id, staff.staff_id;
```

You should see 10 rows: the 7 branches that need people (Bengaluru to Kochi, name `NULL`) and the 3 people who need a branch (Meera, Imran, Farhan, city `NULL`).

### 5. Give NULL a clean label

On a report, `NULL` looks like an error. `COALESCE` (from [M06-L05](../../m06-functions/m06-l05-coalesce-and-nullif/)) swaps `NULL` for a word you choose:

```sql
SELECT COALESCE(branches.city, 'no branch') AS city,
       COALESCE(staff.name, 'nobody yet') AS name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
ORDER BY branches.branch_id, staff.staff_id;
```

Still 17 rows, now with labels: `Bengaluru | nobody yet` ... `Kochi | nobody yet`, then `no branch | Meera`, `no branch | Imran`, `no branch | Farhan`.

## Common mistakes

**1. `WHERE` on one side.**

```sql
SELECT branches.city, staff.name
FROM branches
FULL OUTER JOIN staff
  ON staff.branch_id = branches.branch_id
WHERE staff.role = 'Barista'
ORDER BY branches.branch_id, staff.staff_id;
```

The `NULL` rows fail it, and only 3 rows are left: Pune Ravi, Pune Nisha, Mumbai Aman. Put that condition inside `ON` (`ON staff.branch_id = branches.branch_id AND staff.role = 'Barista'`): then every branch stays (Delhi and the seven empty ones with no barista), and every non-barista appears as a leftover with city `NULL`, 18 rows in all.

**2. Expecting every database to have it.** MySQL has no `FULL OUTER JOIN`. There you join left and right, and stack them with `UNION` (Module 10, lesson 5):

```sql
SELECT branches.city, staff.name FROM branches LEFT JOIN staff ON staff.branch_id = branches.branch_id
UNION
SELECT branches.city, staff.name FROM branches RIGHT JOIN staff ON staff.branch_id = branches.branch_id;
```

In PostgreSQL this also gives the same 17 rows (in no fixed order).

**3. Leaving raw NULLs in a report.** People read them as broken data. Use `COALESCE` to give each one a label.

## Try it yourself

1. How many branches have no staff yet? Try a full outer join with `IS NULL`. Guess first, then run it.
2. How many staff members have no branch?
3. Label only the gap rows from step 4 with `COALESCE`.

## Next

[M09-L04 · Joining Three or More Tables](../m09-l04-joining-three-or-more-tables/)

## Answers

1. 7:
   ```sql
   SELECT COUNT(*) AS no_staff
   FROM branches
   FULL OUTER JOIN staff
     ON staff.branch_id = branches.branch_id
   WHERE staff.staff_id IS NULL;
   ```
2. 3 (Meera, Imran, Farhan): the same query with `WHERE branches.branch_id IS NULL`.
3. Use the `COALESCE` select list of step 5 with the `WHERE` of step 4: 10 rows, from `Bengaluru | nobody yet` to `no branch | Farhan`.
