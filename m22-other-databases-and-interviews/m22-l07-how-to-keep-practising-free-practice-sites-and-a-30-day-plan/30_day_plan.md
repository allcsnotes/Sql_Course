# 30-day SQL practice plan

20 minutes a day beats 5 hours once a week.

## Free sites (no account)
- SQLBolt: https://sqlbolt.com (lessons + 5 tasks each, from SELECT to creating tables)
- PostgreSQL Exercises: https://pgexercises.com (country club database, real PostgreSQL, up to window functions)
- Your own Chai Corner database: make up a question, answer it

## How to practise one question
1. Read the question twice. Find the tables you need.
2. Guess the shape of the answer: how many rows, which columns?
3. Write it one part at a time: FROM, then WHERE, then GROUP BY, then SELECT.
4. Run it and compare with the expected result. Find the first wrong row.
5. Look at the answer only after you really tried.

## The plan
| Week | Days | Focus |
|---|---|---|
| 1 | 1-7 | Basics: SELECT, WHERE, sorting, grouping. 3 questions a day |
| 2 | 8-14 | Joins and subqueries: INNER, LEFT, self join, IN, EXISTS |
| 3 | 15-21 | Window functions, CTEs, the classic interview problems |
| 4 | 22-30 | One small Chai Corner project a day, then a timed mock interview |

Missed a day? Don't start over. Carry on the next day.

## Mistakes notebook
| Question | What I wrote | Why it was wrong |
|---|---|---|
| Find customers with no email | `WHERE email = NULL` (0 rows) | NULL is unknown, so = never matches. Use `WHERE email IS NULL` |

Read it once a week.
