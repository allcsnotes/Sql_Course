# M04-L02 · LIMIT and OFFSET

> Video: Module 4, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- How `LIMIT` keeps only the first few rows (the top ten, the cheapest three)
- Why you always sort with `ORDER BY` before you cut
- How ties can change who makes the cut, and how a tie breaker fixes it
- How `OFFSET` skips rows, to show page two, page three and more
- Three beginner mistakes with LIMIT and OFFSET

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- A DBeaver SQL editor on `chai_corner`, or psql with `\c chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The six queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes |

## Follow along

A big shop has thousands of products. Its website never shows all of them at once: it shows the top ten, then a **next page** button. Two small words do this in SQL: `LIMIT` and `OFFSET`.

### 1. LIMIT, for the top few rows

First sort, then cut. `ORDER BY price DESC` puts the most expensive items on top; `LIMIT 3` keeps three:

```sql
SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3;
```

| name | price |
|---|---|
| Cold Coffee | 80 |
| Veg Sandwich | 70 |
| Maggi | 60 |

`LIMIT` always comes last, at the very end of the query. It keeps the first rows and drops the rest.

### 2. Watch out for ties

The three cheapest:

```sql
SELECT name, price FROM menu_items ORDER BY price LIMIT 3;
```

| name | price |
|---|---|
| Cutting Chai | 20 |
| Samosa | 25 |
| Ginger Chai | 30 |

But three items cost 30. Ginger Chai got the last place **by chance**: Masala Chai or Vada Pav could have taken it. To make the cut the same every time, add a tie breaker:

```sql
SELECT name, price FROM menu_items ORDER BY price, name LIMIT 3;
```

Same three rows, but now Ginger Chai wins every time, because G comes first.

### 3. OFFSET, for pages

Say each page shows four items, sorted by name. Page one:

```sql
SELECT name, price FROM menu_items ORDER BY name LIMIT 4;
```

| name | price |
|---|---|
| Bun Maska | 35 |
| Cold Coffee | 80 |
| Cutting Chai | 20 |
| Filter Coffee | 40 |

For page two, skip the first four. `OFFSET` means: skip this many rows first.

```sql
SELECT name, price FROM menu_items ORDER BY name LIMIT 4 OFFSET 4;
```

| name | price |
|---|---|
| Ginger Chai | 30 |
| Maggi | 60 |
| Masala Chai | 30 |
| Samosa | 25 |

Page three is `OFFSET 8`:

```sql
SELECT name, price FROM menu_items ORDER BY name LIMIT 4 OFFSET 8;
```

| name | price |
|---|---|
| Vada Pav | 30 |
| Veg Sandwich | 70 |

Only two items are left: the last page can be short.

The rule: **skip all the pages before this one.**

```text
OFFSET = (page number - 1) × page size
page 1: OFFSET 0    page 2: OFFSET 4    page 3: OFFSET 8
```

## Common mistakes

- **LIMIT before ORDER BY** (`... LIMIT 3 ORDER BY price DESC;`):
  ```text
  ERROR: syntax error at or near "ORDER"
  ```
  LIMIT always goes at the very end.
- **LIMIT with no ORDER BY** (`SELECT name, price FROM menu_items LIMIT 3;`): you get three rows (Bun Maska, Cold Coffee, Cutting Chai in the video), but they are not the top three of anything. Always sort before you cut.
- **The wrong OFFSET.** For page two, `OFFSET 1` skips only one row, so Cold Coffee, Cutting Chai and Filter Coffee show up again (with Ginger Chai). Skip a full page: `OFFSET 4`.

## Try it yourself

1. The video's task: find the oldest branch, using `ORDER BY` and `LIMIT 1`. Which city is it?
2. Show the two customers who joined most recently.
3. With three branches per page, sorted by city, what is on page two?

## Answers

1. ```sql
   SELECT city, opened_on FROM branches ORDER BY opened_on LIMIT 1;
   ```
   **Pune**, opened 2019-04-12.
2. ```sql
   SELECT name, joined_on FROM customers ORDER BY joined_on DESC LIMIT 2;
   ```
   Kiran (2026-06-10) and Tara (2026-03-27).
3. ```sql
   SELECT city FROM branches ORDER BY city LIMIT 3 OFFSET 3;
   ```
   Delhi, Hyderabad, Jaipur. (Page one is Ahmedabad, Bengaluru, Chennai.)

## Next

[M04-L03 · DISTINCT: Removing Repeated Rows](../m04-l03-distinct-removing-repeated-rows/)
