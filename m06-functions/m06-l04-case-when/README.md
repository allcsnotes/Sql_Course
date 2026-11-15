# M06-L04 · CASE WHEN

> Video: Module 6, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- `CASE WHEN ... THEN ... ELSE ... END` gives each row its own label, based on a rule (like if and else)
- With many `WHEN` lines, PostgreSQL checks from top to bottom and the first true test wins
- The test can use any column, even a date
- Three beginner mistakes: tests in the wrong order, a missing `ELSE`, and answers of different types

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.
- These queries span several lines. In DBeaver, put the cursor inside the query and press Ctrl+Enter.

## Files in this folder

| File | What it is |
|------|------------|
| `case_when.sql` | The three queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and the fix for mistake 3 |

## Follow along

Is a menu item cheap or costly? Is a customer early or new? Each row needs its own label, based on a rule. `CASE WHEN` lets a query make that choice.

### 1. One choice

```sql
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly'
       ELSE 'cheap' END AS tag
FROM menu_items;
```

- `CASE WHEN` works like if and else. `WHEN` gives a test: the price is 50 or more.
- `THEN` gives the answer when the test is true: `'costly'`.
- `ELSE` gives the answer for every other row: `'cheap'`. `END` closes the CASE, and `AS tag` names the new column.

You should see:

| name | price | tag |
|------|------:|-----|
| Bun Maska | 35 | cheap |
| Cold Coffee | 80 | costly |
| Cutting Chai | 20 | cheap |
| Filter Coffee | 40 | cheap |
| Ginger Chai | 30 | cheap |
| Maggi | 60 | costly |
| Masala Chai | 30 | cheap |
| Samosa | 25 | cheap |
| Vada Pav | 30 | cheap |
| Veg Sandwich | 70 | costly |

PostgreSQL checks every row. Cold Coffee is ₹80, so it is costly. Bun Maska is ₹35, so it is cheap. (There is no `ORDER BY`, so your rows may come in another order.)

### 2. Many choices

You can write many `WHEN` lines. PostgreSQL checks them from top to bottom and stops at the first one that is true:

```sql
SELECT name, price,
  CASE WHEN price < 30 THEN 'low'
       WHEN price < 60 THEN 'mid'
       ELSE 'high' END AS band
FROM menu_items;
```

You should see:

| name | price | band |
|------|------:|------|
| Bun Maska | 35 | mid |
| Cold Coffee | 80 | high |
| Cutting Chai | 20 | low |
| Filter Coffee | 40 | mid |
| Ginger Chai | 30 | mid |
| Maggi | 60 | high |
| Masala Chai | 30 | mid |
| Samosa | 25 | low |
| Vada Pav | 30 | mid |
| Veg Sandwich | 70 | high |

Samosa is ₹25, so the very first test is true, and it gets `low`.

### 3. Choices on dates

The test can use any column, even a date. Customers who joined before 2025 are early, everyone else is new:

```sql
SELECT name, joined_on,
  CASE WHEN joined_on < '2025-01-01' THEN 'early'
       ELSE 'new' END AS member
FROM customers;
```

You should see 15 rows, starting:

| name | joined_on | member |
|------|-----------|--------|
| Asha | 2024-11-11 | early |
| Lukas | 2024-11-14 | early |
| Priya | 2024-12-02 | early |
| Rahul | 2025-01-09 | new |
| Kabir | 2025-01-21 | new |

Asha, Lukas and Priya are early. The other 12 are new.

## Common mistakes

The queries are in `mistakes.sql`.

**1. The tests are in the wrong order.** If `price < 60` comes first:

```sql
SELECT name, price,
  CASE WHEN price < 60 THEN 'mid'
       WHEN price < 30 THEN 'low'
       ELSE 'high' END AS band
FROM menu_items;
```

Samosa stops at the first test and gets `mid`. No row ever reaches `low`. Put the smallest test first.

**2. You forget the ELSE:**

```sql
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly' END AS tag
FROM menu_items;
```

Every row that matches no test gets `[NULL]` (7 of the 10 rows). Always add an `ELSE`.

**3. The answers have different types.** `'costly'` is text, but `price` is a number:

```sql
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly' ELSE price END AS tag
FROM menu_items;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type integer: "costly"
```

Cast the number to text:

```sql
SELECT name, price,
  CASE WHEN price >= 50 THEN 'costly' ELSE price::text END AS tag
FROM menu_items;
```

Now the costly items say `costly` and the others show their price as text (`35`, `20`, `40` ...).

## Try it yourself

1. Tag items that cost ₹30 or less as `budget`, and all the others `regular`. How many budget items are there? Guess first, then run it.
2. Tag each branch as `old` if it opened before 2021, else `young`.
3. Add a fourth band to step 2: `premium` for ₹75 or more. Where must the new `WHEN` go?

## Answers

1. The task from the video:

   ```sql
   SELECT name, price,
     CASE WHEN price <= 30 THEN 'budget'
          ELSE 'regular' END AS deal
   FROM menu_items;
   ```

   5 budget items: Cutting Chai, Ginger Chai, Masala Chai, Samosa and Vada Pav.
2. `SELECT city, CASE WHEN opened_on < '2021-01-01' THEN 'old' ELSE 'young' END AS age_band FROM branches;` (Pune, Mumbai, Delhi and Bengaluru are old).
3. Keep the tests from small to big: `WHEN price < 30 THEN 'low' WHEN price < 60 THEN 'mid' WHEN price < 75 THEN 'high' ELSE 'premium' END`. Cold Coffee (₹80) becomes premium.

## Next

[M06-L05 · COALESCE and NULLIF](../m06-l05-coalesce-and-nullif/)
