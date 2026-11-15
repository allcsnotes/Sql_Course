# M10-L02 · IN, EXISTS, NOT EXISTS and the NOT IN + NULL Trap

> Video: Module 10, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- `IN` with a subquery that gives back a whole list
- `EXISTS`: a yes or no question, "is there at least one matching row?", with a **link line** to the outer row
- `NOT EXISTS`: the rows with no match at all
- The **NOT IN + NULL trap**: why `NOT IN` quietly returns zero rows when the list has a `NULL`
- Two fixes: `IS NOT NULL` inside the list, or simply `NOT EXISTS`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 5 (the `staff` table) from [M09-L03](../../m09-joins/m09-l03-full-outer-join-everything-from-both-sides/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `in_exists.sql` | Every query of the video, in order, with the result as a comment |

## Follow along

### 1. What the subquery gives back

Run the inner query on its own first:

```sql
SELECT name, branch_id
FROM staff
ORDER BY staff_id;
```

| name | branch_id |
|---|---|
| Meera | NULL |
| Imran | NULL |
| Pooja | 1 |
| Sameer | 2 |
| Kavya | 3 |
| Ravi | 1 |
| Nisha | 1 |
| Aman | 2 |
| Leela | 3 |
| Farhan | NULL |

Each staff member has a branch number: 1, 2 or 3. Three people have no branch, so their number is `NULL`.

### 2. IN, with a list

Put that list inside `IN`. Now `WHERE` asks one question for every branch: is this branch number in the list?

```sql
SELECT branch_id, city
FROM branches
WHERE branch_id IN (SELECT branch_id FROM staff)
ORDER BY branch_id;
```

| branch_id | city |
|---|---|
| 1 | Pune |
| 2 | Mumbai |
| 3 | Delhi |

### 3. EXISTS

`EXISTS` asks a yes or no question: for each branch, is there at least one staff row?

```sql
SELECT branch_id, city
FROM branches
WHERE EXISTS (SELECT 1 FROM staff
              WHERE staff.branch_id = branches.branch_id)
ORDER BY branch_id;
```

- `WHERE staff.branch_id = branches.branch_id` is the **link**: it matches staff to the branch we are looking at right now.
- `SELECT 1` just means "any row will do". We only care that a row exists.

Again: 1 Pune, 2 Mumbai, 3 Delhi.

### 4. NOT EXISTS

Put `NOT` in front, and the question flips: which branches have no staff row at all?

```sql
SELECT branch_id, city
FROM branches
WHERE NOT EXISTS (SELECT 1 FROM staff
                  WHERE staff.branch_id = branches.branch_id)
ORDER BY branch_id;
```

| branch_id | city |
|---|---|
| 4 | Bengaluru |
| 5 | Chennai |
| 6 | Hyderabad |
| 7 | Kolkata |
| 8 | Jaipur |
| 9 | Ahmedabad |
| 10 | Kochi |

Seven branches. Nobody works there yet.

### 5. The trap: NOT IN with a NULL

`NOT IN` looks like it should give the same seven branches:

```sql
SELECT branch_id, city
FROM branches
WHERE branch_id NOT IN (SELECT branch_id FROM staff)
ORDER BY branch_id;
```

You get nothing: **0 rows**. The reason is the `NULL` in the list. For branch 4, `NOT IN` checks: not 1, and not 2, and not 3, and not `NULL`. But a comparison with `NULL` is never true, it is *unknown*, so no branch can pass.

The fix: keep `NULL`s out of the list:

```sql
SELECT branch_id, city
FROM branches
WHERE branch_id NOT IN (SELECT branch_id FROM staff
                        WHERE branch_id IS NOT NULL)
ORDER BY branch_id;
```

Now you get the seven branches. Or simply use `NOT EXISTS` (step 4), which is safe with `NULL`s.

## Common mistakes

**1. An equals sign with a whole list.** `WHERE branch_id = (SELECT branch_id FROM staff)` stops with `ERROR: more than one row returned by a subquery used as an expression` (the error from [M10-L01](../m10-l01-a-query-inside-a-query-subquery-in-where/)). Use `IN` instead.

**2. `EXISTS` with no link line.**

```sql
SELECT branch_id, city
FROM branches
WHERE EXISTS (SELECT 1 FROM staff)
ORDER BY branch_id;
```

The subquery finds staff every time, so all 10 branches come back.

**3. `NOT IN` with a `NULL` in the list** returns nothing. Use `NOT EXISTS`.

## Try it yourself

1. Which staff manage nobody? Use `NOT EXISTS`, with the `staff` table joined to itself. Guess first, then run it.
2. Which staff *do* manage someone? Change one word.
3. Which customers have placed an order at the Delhi branch? Use `IN` with a subquery on `orders`. How many are there?

## Next

[M10-L03 · Subqueries in SELECT and FROM: Derived Tables](../m10-l03-subqueries-in-select-and-from-derived-tables/)

## Answers

1. 5 staff: Ravi, Nisha, Aman, Leela, Farhan.
   ```sql
   SELECT name, role
   FROM staff
   WHERE NOT EXISTS (SELECT 1 FROM staff AS team
                     WHERE team.manager_id = staff.staff_id)
   ORDER BY staff_id;
   ```
2. Remove `NOT`: Meera, Imran, Pooja, Sameer, Kavya (5 managers).
3. All 15:
   ```sql
   SELECT name
   FROM customers
   WHERE customer_id IN (SELECT customer_id FROM orders WHERE branch_id = 3)
   ORDER BY name;
   ```
