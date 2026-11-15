# M10-B02 · Build 2: Customer Insights

> Video: Module 10, Build 2. Watch it first, then follow along here.

## What you'll build

Meera owns Chai Corner. April 2026 has just ended, and this time she wants to understand her **customers**, not just her sales. She has five questions:

1. Who is **new** this month?
2. Who **came back**?
3. Who **stopped coming**?
4. Which menu item does **nobody buy**?
5. Who is the **best customer in each branch**?

You answer all five with the tools of Module 10: `EXCEPT` and `INTERSECT`, a subquery inside `IN`, `NOT EXISTS`, a `LEFT JOIN` with `IS NULL`, and a linked (correlated) subquery. Then you check that the answers add up.

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need `orders` and `order_items` (update 4, from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/)), January to March 2026.
- Then run **`setup.sql`** from this folder as a whole script (DBeaver: Execute SQL Script, Alt+X; or `psql -d chai_corner -f setup.sql`). This is **Chai Corner update 6**: the month of April 2026.
  - 4 new customers join: Zoya, Manav, Riya and Kunal (ids 16 to 19).
  - 2 new menu items: Kulhad Chai (₹40) and Paneer Roll (₹90).
  - 900 more orders (order ids 3001 to 3900), with their order items.
  - Kabir, Neha and Tara stop coming.
  - It uses `setseed(0.44)`, so `random()` gives the same numbers for everyone and your results match the video.
- Run it **once**. A second run stops with `duplicate key value violates unique constraint "customers_pkey"`, because customer 16 already exists.
- `setup.sql` makes a helper table `april` with `CREATE TEMP TABLE`. A temporary table disappears when you disconnect, so it does not stay in your database.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | Chai Corner update 6: April 2026 (run once, as a script) |
| `customer_insights.sql` | Every query of the build, in order, then the three mistakes and your task, each with its real result |

## Build it step by step

### Stage 1. Count the customers in each month

```sql
SELECT DATE_TRUNC('month', ordered_at)::date AS month,
       COUNT(DISTINCT customer_id) AS customers
FROM orders
GROUP BY month
ORDER BY month;
```

You should see:

| month | customers |
|---|---|
| 2026-01-01 | 15 |
| 2026-02-01 | 15 |
| 2026-03-01 | 15 |
| 2026-04-01 | 16 |

Fifteen, fifteen, fifteen, sixteen. But are they the same people? The counts cannot tell you.

**The plan.** Make two lists of customers: everyone who ordered **before April**, and everyone who ordered **in April**. Then compare the lists:

| In April? | Before April? | Meaning | Keyword |
|---|---|---|---|
| yes | no | new | April `EXCEPT` before |
| yes | yes | returning | before `INTERSECT` April |
| no | yes | lost | last order before April |

### Stage 2. New customers

New customers are in the April list, except the ones in the earlier list. So the April query comes first, `EXCEPT` goes in the middle, and the "before April" query comes last:

```sql
SELECT customer_id FROM orders
WHERE ordered_at >= '2026-04-01'
EXCEPT
SELECT customer_id FROM orders
WHERE ordered_at < '2026-04-01'
ORDER BY customer_id;
```

You should see 4 customer numbers: 16, 17, 18, 19.

Numbers are hard to read. Put that whole query inside `IN ( ... )` and ask for the names:

```sql
SELECT name, joined_on FROM customers
WHERE customer_id IN (
  SELECT customer_id FROM orders WHERE ordered_at >= '2026-04-01'
  EXCEPT
  SELECT customer_id FROM orders WHERE ordered_at < '2026-04-01'
)
ORDER BY joined_on;
```

| name | joined_on |
|---|---|
| Zoya | 2026-04-03 |
| Manav | 2026-04-08 |
| Riya | 2026-04-15 |
| Kunal | 2026-04-22 |

All four joined in April.

### Stage 3. Returning customers

Swap `EXCEPT` for `INTERSECT`: on both lists.

```sql
SELECT name FROM customers
WHERE customer_id IN (
  SELECT customer_id FROM orders WHERE ordered_at < '2026-04-01'
  INTERSECT
  SELECT customer_id FROM orders WHERE ordered_at >= '2026-04-01'
)
ORDER BY name;
```

You should see 12 names: Ananya, Arjun, Asha, Dev, Isha, Kiran, Lukas, Priya, Rahul, Rohan, Sara, Vikram. They came before April, and came back in April.

### Stage 4. Customers who stopped ordering

Look at each customer's **last** order: join customers to orders, group by customer, and take `MAX(ordered_at)`. Then `HAVING` keeps only the customers whose last order is before 1 April:

```sql
SELECT c.name, MAX(o.ordered_at)::date AS last_order
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
HAVING MAX(o.ordered_at) < '2026-04-01'
ORDER BY last_order;
```

| name | last_order |
|---|---|
| Kabir | 2026-03-31 |
| Neha | 2026-03-31 |
| Tara | 2026-03-31 |

They came until the end of March, and then stopped. (All three share the same date, so they can come back in a different order.) This is a list Meera can act on: a message, or a free chai, might bring them back.

### Stage 5. Items nobody buys

For each menu item, `NOT EXISTS` looks in `order_items` for a matching row. If there is none, the item has never been sold:

```sql
SELECT m.name, m.price
FROM menu_items m
WHERE NOT EXISTS (
  SELECT 1 FROM order_items oi
  WHERE oi.item_id = m.item_id
);
```

| name | price |
|---|---|
| Paneer Roll | 90 |

The Paneer Roll, at ₹90, was added in April and nobody has ordered it yet.

A `LEFT JOIN` gives the same answer. An item with no orders gets empty (`NULL`) values on the right side, and `IS NULL` keeps just those rows:

```sql
SELECT m.name, m.price
FROM menu_items m
LEFT JOIN order_items oi ON oi.item_id = m.item_id
WHERE oi.item_id IS NULL;
```

Two methods, one answer: Paneer Roll, 90.

### Stage 6. The top customer in each branch

**Step 1, just for Pune.** Count the orders of each customer, biggest first:

```sql
SELECT c.name, COUNT(*) AS orders
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.branch_id = 1
GROUP BY c.name
ORDER BY orders DESC;
```

You should see 19 rows, from Kiran 151, Isha 147, Rahul 146 ... down to Manav 9. Kiran is the top customer in Pune.

**Step 2, every branch at once.** Group by branch and customer, and count. Then `HAVING` keeps a row only when its count equals the biggest count **in that branch**:

```sql
SELECT b.city, c.name, COUNT(*) AS orders
FROM orders o
JOIN branches b ON b.branch_id = o.branch_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.branch_id, b.city, c.name
HAVING COUNT(*) = (SELECT MAX(n) FROM (
    SELECT COUNT(*) AS n FROM orders o2
    WHERE o2.branch_id = o.branch_id GROUP BY o2.customer_id) AS per_customer)
ORDER BY orders DESC;
```

- The inner query counts the orders of every customer in one branch, as a derived table `per_customer`.
- `MAX(n)` picks the biggest of those counts.
- `WHERE o2.branch_id = o.branch_id` is the **link** to the outer row ([M10-L04](../m10-l04-correlated-subqueries-once-for-every-row/)), so each branch is compared only with itself.

| city | name | orders |
|---|---|---|
| Pune | Kiran | 151 |
| Mumbai | Vikram | 99 |
| Delhi | Asha | 47 |
| Delhi | Arjun | 47 |

Delhi gives two rows: Asha and Arjun have 47 orders each. It is a tie, and the query keeps both. (`ORDER BY ... LIMIT 1` would have hidden one of them.)

## Check your work

The three lists must fit together:

| Check | Sum | Should equal |
|---|---|---|
| new + returning = everyone in April | 4 + 12 = 16 | April count in Stage 1: 16 |
| returning + lost = everyone before April | 12 + 3 = 15 | January to March count: 15 |

Both checks pass. Also check:

- `SELECT COUNT(*) FROM orders WHERE ordered_at >= '2026-04-01';` gives 900.
- `SELECT COUNT(*) FROM customers;` gives 19, and `SELECT COUNT(*) FROM menu_items;` gives 12.

## Common mistakes

**1. `WHERE` instead of `HAVING` for lost customers.**

```sql
SELECT c.name, MAX(o.ordered_at)::date AS last_order
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.ordered_at < '2026-04-01'
GROUP BY c.customer_id, c.name
ORDER BY last_order;
```

You get 15 rows, every one with last order 2026-03-31. `WHERE` throws away the April orders **before** grouping, so every old customer looks lost. Filter on `MAX(...)` with `HAVING`, after grouping.

**2. The two lists swapped around `EXCEPT`.**

```sql
SELECT name, joined_on FROM customers
WHERE customer_id IN (
  SELECT customer_id FROM orders WHERE ordered_at < '2026-04-01'
  EXCEPT
  SELECT customer_id FROM orders WHERE ordered_at >= '2026-04-01'
)
ORDER BY joined_on;
```

You get Kabir, Neha and Tara: the **lost** customers, not the new ones. With `EXCEPT`, the order matters: the list you want comes first.

**3. The inner query forgot its branch.**

```sql
SELECT b.city, c.name, COUNT(*) AS orders
FROM orders o
JOIN branches b ON b.branch_id = o.branch_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.branch_id, b.city, c.name
HAVING COUNT(*) = (SELECT MAX(n) FROM (
    SELECT COUNT(*) AS n FROM orders o2
    GROUP BY o2.branch_id, o2.customer_id) AS per_customer)
ORDER BY orders DESC;
```

You get only 1 row: Pune, Kiran, 151. Without the link, every branch is compared with the biggest count in the whole chain, and only Pune can reach it.

## Try it yourself

1. Which customer placed the most orders in April? Guess first, then run it.
2. Which new customer (16 to 19) ordered the most in April?
3. How many of Meera's 12 menu items were sold at least once in April?

## Next

[M11-L01 · CREATE TABLE: Columns and Types](../../m11-creating-tables/m11-l01-create-table-columns-and-types/)

## Answers

1. Rohan, with 79 orders. Kiran is second with 74:
   ```sql
   SELECT c.name, COUNT(*) AS orders
   FROM orders o
   JOIN customers c ON c.customer_id = o.customer_id
   WHERE o.ordered_at >= '2026-04-01'
   GROUP BY c.name
   ORDER BY orders DESC;
   ```
2. Kunal, with 37 orders (then Riya 35, Zoya 32, Manav 21).
3. 11 of the 12. Only the Paneer Roll was never sold:
   ```sql
   SELECT COUNT(DISTINCT oi.item_id) AS items_sold
   FROM order_items oi
   JOIN orders o ON o.order_id = oi.order_id
   WHERE o.ordered_at >= '2026-04-01';
   ```
