# M22-L06 · The Top 50 SQL Interview Questions, Answered

> Video: Module 22, Lesson 6. Watch it first, then follow along here.

## What you'll learn

- The 50 SQL questions that job interviews ask again and again, in ten rounds of five
- A short answer to each one, and the small piece of SQL that goes with it
- The three ideas most answers come back to: the order SQL runs a query, how NULL behaves, and how joins match rows

## How to use this page

Cover the answer, say yours out loud, then read. Every answer points back to a lesson of this course, so if one surprises you, go back and watch that lesson again. There is nothing to run in this lesson.

## Key ideas

### Round 1: Basics

| # | Question | Answer | SQL |
|---|---|---|---|
| 1 | What is SQL? | A language to ask a database questions, and to change its data. | `SELECT name FROM customers;` |
| 2 | Primary key vs UNIQUE? | Both stop repeats. A primary key also can't be empty, and a table has only one. | `id int PRIMARY KEY` |
| 3 | What is NULL? | It means unknown. It is not zero, and it is not empty text. | `price IS NULL` |
| 4 | DELETE, TRUNCATE, DROP? | DELETE removes some rows. TRUNCATE empties the table fast. DROP removes the whole table. | `DELETE ... WHERE id = 7;` |
| 5 | What is a foreign key? | A column that points to a row in another table, so links can never break. | `REFERENCES customers` |

### Round 2: Filtering

| # | Question | Answer | SQL |
|---|---|---|---|
| 6 | WHERE vs HAVING? | WHERE filters rows before grouping. HAVING filters the groups after. | `HAVING COUNT(*) > 5` |
| 7 | Why does = NULL find nothing? | Because unknown is never equal to anything. Use IS NULL instead. | `WHERE email IS NULL` |
| 8 | Is BETWEEN inclusive? | Yes. Both ends are included. | `price BETWEEN 20 AND 40` |
| 9 | LIKE: % vs _? | % matches any number of letters. _ matches exactly one. | `name LIKE 'A%'` |
| 10 | IN vs EXISTS? | IN checks a list of values. EXISTS only asks: is there at least one matching row? | `WHERE EXISTS (SELECT 1 ...)` |

### Round 3: Sorting

| # | Question | Answer | SQL |
|---|---|---|---|
| 11 | The order SQL runs a query? | FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY, and then LIMIT. | `FROM → WHERE → ... → LIMIT` |
| 12 | ORDER BY default? | Smallest first. Add DESC for biggest first. | `ORDER BY price DESC` |
| 13 | Where do NULLs sort? | In PostgreSQL they come last when going up. You can choose with NULLS FIRST. | `NULLS FIRST` |
| 14 | DISTINCT vs GROUP BY? | DISTINCT removes repeated rows. GROUP BY makes piles, so you can count or sum each pile. | `SELECT DISTINCT city` |
| 15 | Why is a big OFFSET slow? | The database still reads every skipped row. Keyset paging jumps straight there. | `WHERE id > 1000 LIMIT 20` |

### Round 4: Aggregates

| # | Question | Answer | SQL |
|---|---|---|---|
| 16 | `COUNT(*)` vs `COUNT(col)`? | `COUNT(*)` counts every row. COUNT of a column skips the NULLs. | `COUNT(email)` |
| 17 | Alias in WHERE? | No. WHERE runs before SELECT, so the alias does not exist yet. | `WHERE total > 100  -- error` |
| 18 | Non-grouped columns? | No. Every column must be grouped, or inside a function like SUM. | `GROUP BY city` |
| 19 | Does AVG count NULLs? | No. It skips them, which can change the answer. | `AVG(rating)` |
| 20 | Many counts in one query? | Use FILTER, or a CASE inside SUM. | `COUNT(*) FILTER (WHERE ...)` |

### Round 5: Joins

| # | Question | Answer | SQL |
|---|---|---|---|
| 21 | INNER vs LEFT JOIN? | INNER keeps only matches. LEFT keeps every row from the left table, even with no match. | `LEFT JOIN orders o ON ...` |
| 22 | LEFT JOIN that acts like INNER? | When WHERE filters the right table. Put that rule in the ON part instead. | `ON ... AND o.year = 2026` |
| 23 | What is a self join? | A table joined to itself, like each staff member and their manager. | `staff s JOIN staff m` |
| 24 | Why did my JOIN repeat rows? | One row matched many rows. Sum before you join, or join on the full key. | `fan out: 1 → many` |
| 25 | FULL OUTER JOIN? | It keeps every row from both sides, with NULLs where there is no match. | `FULL JOIN ...` |

### Round 6: Subqueries

| # | Question | Answer | SQL |
|---|---|---|---|
| 26 | Subquery vs JOIN? | Both work. A join is often clearer. A subquery is good for one value, like the average. | `WHERE price > (SELECT AVG ...)` |
| 27 | The NOT IN trap? | If the list has a NULL, NOT IN returns no rows at all. Use NOT EXISTS. | `NOT EXISTS (...)` |
| 28 | Correlated subquery? | A subquery that runs once for every outer row, because it uses that row. | `WHERE o.c = c.id` |
| 29 | CTE vs subquery? | A CTE gives each step a name with WITH, so long queries read top to bottom. | `WITH big AS (...)` |
| 30 | Recursive CTE? | Trees and chains, like a manager chain, or every day in a month. | `WITH RECURSIVE ...` |

### Round 7: Windows

| # | Question | Answer | SQL |
|---|---|---|---|
| 31 | Window vs GROUP BY? | GROUP BY squashes rows into one. A window keeps every row and adds a value beside it. | `SUM(x) OVER (...)` |
| 32 | ROW_NUMBER, RANK, DENSE_RANK? | On a tie, ROW_NUMBER still counts on, RANK skips numbers, and DENSE_RANK does not skip. | `1, 2, 2, 4  vs  1, 2, 2, 3` |
| 33 | A running total? | SUM OVER, ordered by date. | `SUM(cups) OVER (ORDER BY day)` |
| 34 | Compare with the day before? | LAG looks back one row. LEAD looks ahead. | `LAG(cups) OVER (ORDER BY day)` |
| 35 | Top 3 in each group? | ROW_NUMBER over PARTITION BY the group, then keep numbers one to three. | `WHERE rn <= 3` |

### Round 8: Design

| # | Question | Answer | SQL |
|---|---|---|---|
| 36 | What is normalisation? | Splitting data so each fact is stored only once. | `1 fact = 1 place` |
| 37 | 1NF, 2NF, 3NF? | One value per cell. Every column needs the whole key. No column depends on another plain column. | `1NF · 2NF · 3NF` |
| 38 | One to many vs many to many? | One to many is a foreign key. Many to many needs a table in the middle. | `order_items` |
| 39 | When to denormalise? | For speed in reports, when you read a lot and write very little. | `copy for speed` |
| 40 | Natural vs surrogate key? | A made up ID never changes. Real values like phone numbers can. | `id int PRIMARY KEY` |

### Round 9: Speed

| # | Question | Answer | SQL |
|---|---|---|---|
| 41 | What does an index do? | Like the index of a book, it finds rows without reading the whole table. | `CREATE INDEX ...` |
| 42 | When does an index hurt? | Every INSERT and UPDATE must change it too. And it rarely helps a yes or no column. | `slower writes` |
| 43 | Column order in an index? | Yes, it matters. It helps most when your search uses the first column. | `(branch, day)` |
| 44 | How do you find a slow part? | Run EXPLAIN ANALYZE, and look for a full scan of a big table. | `EXPLAIN ANALYZE ...` |
| 45 | Why avoid `SELECT *`? | It reads columns you do not need, and breaks when columns change. | `SELECT id, name` |

### Round 10: Safety

| # | Question | Answer | SQL |
|---|---|---|---|
| 46 | What is a transaction? | A group of changes that all happen, or none happen. | `BEGIN; ... COMMIT;` |
| 47 | What is ACID? | All or nothing, rules always hold, users do not clash, and saved data stays saved. | `A · C · I · D` |
| 48 | What is a deadlock? | Two users each wait for the other's lock. The database cancels one. | `deadlock detected` |
| 49 | What is SQL injection? | When user text is glued into a query and runs as code. Pass it as a parameter. | `WHERE name = %s` |
| 50 | Least privilege? | Give each user only the rights they need, like read only for a report. | `GRANT SELECT ...` |

### The three ideas behind most answers

1. **The order SQL runs a query** (FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY, LIMIT) explains questions 6, 11, 17 and 18.
2. **How NULL behaves** (unknown, never equal to anything) explains questions 3, 7, 13, 16, 19 and 27.
3. **How joins match rows** (each row of one side paired with every matching row of the other) explains questions 21 to 25.

### Where each round was taught

| Round | Go back to |
|---|---|
| 1 Basics | Modules 1, 3, 8, 11 |
| 2 Filtering | Modules 3, 7, 10 |
| 3 Sorting | Modules 4, 7, 18 |
| 4 Aggregates | Module 7 |
| 5 Joins | Module 9 |
| 6 Subqueries | Modules 10, 14 |
| 7 Windows | Module 15 |
| 8 Design | Module 8 |
| 9 Speed | Modules 17, 18 |
| 10 Safety | Modules 13, 19 |

## Try it yourself

1. The video's task: pick any five questions, and answer them out loud without looking. Then check yourself in the tables above.
2. Question 7 says `= NULL` finds nothing. In your Chai Corner database, how many rows does `SELECT COUNT(*) FROM customers WHERE email = NULL;` return, whatever the data?
3. Question 32: for the scores 90, 80, 80, 70 (highest first), write the ROW_NUMBER, RANK and DENSE_RANK of each.
4. Question 11: in which step does `HAVING` run, and can `HAVING` use an alias made in `SELECT` in standard SQL?

## Answers

1. There is no single answer: count how many of your five matched the meaning of the answers above. Re-watch the lesson behind any you missed.
2. Always 0. `email = NULL` is unknown for every row, and WHERE keeps only rows where the condition is true. Use `WHERE email IS NULL`.
3. ROW_NUMBER 1, 2, 3, 4. RANK 1, 2, 2, 4. DENSE_RANK 1, 2, 2, 3.
4. HAVING runs right after GROUP BY and before SELECT, so in standard SQL it cannot use a SELECT alias: repeat the expression, such as `HAVING COUNT(*) > 5`.

## Next

[M22-L07 · How to Keep Practising: Free Practice Sites and a 30-Day Plan](../m22-l07-how-to-keep-practising-free-practice-sites-and-a-30-day-plan/)
