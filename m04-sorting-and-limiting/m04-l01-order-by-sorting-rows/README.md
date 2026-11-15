# M04-L01 · ORDER BY: Sorting Rows

> Video: Module 4, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- How `ORDER BY` sorts rows: ascending (`ASC`, the default) or descending (`DESC`)
- How to sort text from A to Z
- Why tied rows have no fixed order, and how a second column breaks the tie
- How each column gets its own direction
- Where NULLs go when you sort, and how `NULLS FIRST` / `NULLS LAST` choose
- Why `WHERE` comes before `ORDER BY`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need `customers.email` from [M03-L06](../../m03-your-first-queries/m03-l06-null-the-unknown-value/).
- A DBeaver SQL editor on `chai_corner`, or psql with `\c chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The nine queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes |

## Follow along

Run a query and the rows come back in whatever order the database likes. Today you choose the order: cheapest first, newest first, or A to Z.

### 1. Sorting by one column

```sql
SELECT name, price FROM menu_items ORDER BY price;
```

You should see ten rows, cheapest first:

| name | price |
|---|---|
| Cutting Chai | 20 |
| Samosa | 25 |
| Masala Chai | 30 |
| Vada Pav | 30 |
| Ginger Chai | 30 |
| Bun Maska | 35 |
| Filter Coffee | 40 |
| Maggi | 60 |
| Veg Sandwich | 70 |
| Cold Coffee | 80 |

Small to big is the normal direction, called **ascending** (`ASC`). You do not need to write it. For biggest first, add `DESC` (**descending**) after the column:

```sql
SELECT name, price FROM menu_items ORDER BY price DESC;
```

Now Cold Coffee (80) is on top and Cutting Chai (20) is last.

### 2. Text, and ties

`ORDER BY` works on text too, from A to Z:

```sql
SELECT name, price FROM menu_items ORDER BY name;
```

Bun Maska first, Veg Sandwich last.

Look back at the price list: three items cost 30. Which one should come first? **For a tie, SQL does not promise any order.** So add a second column:

```sql
SELECT name, price FROM menu_items ORDER BY price, name;
```

SQL sorts by price first. Only when two prices are the same does it use the name. Now the ₹30 items always go Ginger Chai, Masala Chai, Vada Pav, A to Z.

### 3. Up and down together

Each column gets its own direction:

```sql
SELECT name, price FROM menu_items ORDER BY price DESC, name;
```

| name | price |
|---|---|
| Cold Coffee | 80 |
| Veg Sandwich | 70 |
| Maggi | 60 |
| Filter Coffee | 40 |
| Bun Maska | 35 |
| Ginger Chai | 30 |
| Masala Chai | 30 |
| Vada Pav | 30 |
| Samosa | 25 |
| Cutting Chai | 20 |

Prices go big to small, but the names inside the tie still go A to Z.

### 4. Where do NULLs go?

Sort the customers by email:

```sql
SELECT name, email FROM customers ORDER BY email;
```

The eleven emails come A to Z (`ananya@example.com` ... `vikram@example.com`). The four NULL emails (Lukas, Kabir, Isha, Dev) go to the very end, in any order among themselves.

```sql
SELECT name, email FROM customers ORDER BY email DESC;
```

The NULLs jump to the top. In PostgreSQL, **NULL counts as bigger than every value**. You can choose:

```sql
SELECT name, email FROM customers ORDER BY email DESC NULLS LAST;
```

Now the emails go Z to A (`vikram@` first) and the NULLs stay at the bottom. (`NULLS FIRST` does the opposite.)

### 5. WHERE and ORDER BY together

`WHERE` comes first, then `ORDER BY`:

```sql
SELECT name, price FROM menu_items WHERE price < 50 ORDER BY price;
```

Seven rows, cheapest first: Cutting Chai 20, Samosa 25, the three at 30, Bun Maska 35, Filter Coffee 40.

Look at the 30s again. In the video they came out **Ginger, Masala, Vada Pav** this time, but **Masala, Vada Pav, Ginger** in step 1. Same data, different order for the ties. That is why a second column matters. (Your computer may show yet another order.)

## Common mistakes

- **ORDER BY before WHERE** (`... ORDER BY price WHERE price < 50;`):
  ```text
  ERROR: syntax error at or near "WHERE"
  ```
  The order of clauses is fixed: `WHERE` first, `ORDER BY` last.
- **Thinking DESC covers every column.** In `ORDER BY price, name DESC` the prices still go up. `DESC` only changes `name`, the column right before it, so only the 30s turn round (Vada Pav, Masala Chai, Ginger Chai). For both, write `ORDER BY price DESC, name DESC`.
- **Trusting the order of ties.** Without a second column, tied rows can come back in any order. Add a tie breaker, like `name`.

## Try it yourself

1. The video's task: show every branch, newest first. Which city comes first?
2. Show the customers from the newest to the oldest joiner.
3. Show the menu from the most expensive to the cheapest, and inside a tie from Z to A.

## Answers

1. ```sql
   SELECT city, opened_on FROM branches ORDER BY opened_on DESC;
   ```
   **Kochi** (2024-01-29) comes first, Pune (2019-04-12) last.
2. ```sql
   SELECT name, joined_on FROM customers ORDER BY joined_on DESC;
   ```
   Kiran (2026-06-10) first, Asha (2024-11-11) last.
3. ```sql
   SELECT name, price FROM menu_items ORDER BY price DESC, name DESC;
   ```
   Cold Coffee 80 first; the 30s go Vada Pav, Masala Chai, Ginger Chai; Cutting Chai 20 last.

## Next

[M04-L02 · LIMIT and OFFSET](../m04-l02-limit-and-offset/)
