# M16-B04 · The Business Dashboard

> Video: Module 16, Build 4. Watch it first, then follow along here.

## What you'll build

Every Monday, the owner of Chai Corner asks four questions. You answer all four with SQL, and together the answers make a **business dashboard**:

| Question | Dashboard tile | SQL you use |
|---|---|---|
| 1. Are we growing? | Orders this month vs last month | a view, `LAG`, a growth percentage |
| 2. Do customers come back? | Retention by cohort (customers who started in January) | a CTE, `MIN`, `COUNT(DISTINCT ...)` |
| 3. Do people buy more than one thing? | The funnel: all orders, 2+ items, 3+ items | a CTE, `COUNT(*) FILTER (WHERE ...)` |
| 4. Which branch is the best? | Branch rankings by revenue | joins, `SUM`, `RANK()` |

It pulls together CTEs (Module 14), window functions (Module 15) and views (Module 16).

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `orders` and `order_items` (Module 8) with the April 2026 orders from Build 2, plus `branches` and `menu_items`. The orders run from January to April 2026: 3,900 orders.
- This build **creates one view**, `monthly_orders`. `setup.sql` creates the same view.

## Files in this folder

| File | What it is |
|---|---|
| `business_dashboard.sql` | Every statement from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | What this build leaves in the database: the `monthly_orders` view. Safe to run again |

## Build it step by step

### Step 1 · Are we growing? (month over month)

First, save the count of orders for each month as a view, `monthly_orders`. `date_trunc('month', ...)` turns every order time into the first day of its month.

```sql
CREATE VIEW monthly_orders AS
SELECT date_trunc('month', ordered_at)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month;
```

Now `LAG` looks one row back, so next to each month you see last month's orders. Growth is this month minus last month, divided by last month, times 100.

```sql
SELECT month, orders,
  LAG(orders) OVER (ORDER BY month) AS last_month,
  ROUND(100.0 * (orders - LAG(orders) OVER (ORDER BY month))
    / LAG(orders) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly_orders
ORDER BY month;
```

You should see:

| month | orders | last_month | growth_pct |
|---|---|---|---|
| 2026-01-01 | 383 | NULL | NULL |
| 2026-02-01 | 932 | 383 | 143.3 |
| 2026-03-01 | 1685 | 932 | 80.8 |
| 2026-04-01 | 900 | 1685 | -46.6 |

February grew by 143%, March by 81%, and April fell by 47%.

### Step 2 · Who comes back? (retention by cohort)

A **cohort** is a group of customers who started in the same month. The first step, `firsts`, finds each customer's first month. Then you join back to every order and count the different customers in each month.

```sql
WITH firsts AS (
  SELECT customer_id,
    date_trunc('month', MIN(ordered_at))::date AS cohort
  FROM orders GROUP BY customer_id
)
SELECT f.cohort, o.month, COUNT(DISTINCT customer_id) AS customers
FROM firsts f
JOIN (SELECT customer_id, date_trunc('month', ordered_at)::date AS month
      FROM orders) o USING (customer_id)
GROUP BY f.cohort, o.month ORDER BY 1, 2;
```

You should see:

| cohort | month | customers |
|---|---|---|
| 2026-01-01 | 2026-01-01 | 15 |
| 2026-01-01 | 2026-02-01 | 15 |
| 2026-01-01 | 2026-03-01 | 15 |
| 2026-01-01 | 2026-04-01 | 12 |
| 2026-04-01 | 2026-04-01 | 4 |

The January cohort has 15 customers. All 15 came back in February and March; in April, 12 are left. April brought a new cohort of 4 customers.

### Step 3 · Do they buy more? (the funnel)

First count the items in each order. Then `COUNT(*) FILTER (WHERE ...)` counts only the orders that pass each step.

```sql
WITH per_order AS (
  SELECT order_id, COUNT(*) AS items
  FROM order_items
  GROUP BY order_id
)
SELECT COUNT(*) AS all_orders,
  COUNT(*) FILTER (WHERE items >= 2) AS two_plus,
  COUNT(*) FILTER (WHERE items >= 3) AS three_plus
FROM per_order;
```

You should see:

| all_orders | two_plus | three_plus |
|---|---|---|
| 3900 | 2433 | 884 |

```text
all orders      3900  ##########
2+ items        2433  ######
3+ items         884  ##
```

Most people add a second item, but few add a third.

### Step 4 · Which branch wins? (rankings)

Join orders, branches, order items and the menu. `qty * price` gives the money for each line. `RANK()`, ordered by that total from biggest to smallest, gives each branch its place.

```sql
SELECT b.city, SUM(oi.qty * m.price) AS revenue,
  RANK() OVER (ORDER BY SUM(oi.qty * m.price) DESC) AS rnk
FROM orders o
JOIN branches b USING (branch_id)
JOIN order_items oi USING (order_id)
JOIN menu_items m USING (item_id)
GROUP BY b.city
ORDER BY rnk;
```

You should see:

| city | revenue | rnk |
|---|---|---|
| Pune | 182145 | 1 |
| Mumbai | 116220 | 2 |
| Delhi | 56145 | 3 |

Pune is first with ₹1,82,145 (about one lakh eighty-two thousand rupees), Mumbai second, Delhi third.

## Check your work

| Tile | Your numbers should be |
|---|---|
| Orders per month | 383, 932, 1685, 900 |
| Growth | +143.3%, +80.8%, -46.6% |
| January cohort | 15, 15, 15, 12 (and an April cohort of 4) |
| Funnel | 3900 → 2433 → 884 |
| Revenue ranking | Pune 182145, Mumbai 116220, Delhi 56145 |

The video's task: which branch had the most orders in April?

```sql
SELECT b.city, COUNT(*) AS april_orders
FROM orders o
JOIN branches b USING (branch_id)
WHERE ordered_at >= '2026-04-01'
GROUP BY b.city
ORDER BY april_orders DESC;
```

| city | april_orders |
|---|---|
| Pune | 477 |
| Mumbai | 305 |
| Delhi | 118 |

The answer is Pune, with 477 orders.

## Common mistakes

All three were run for real in the video.

1. **Dividing whole numbers.**

   ```sql
   SELECT month, orders,
     (orders - LAG(orders) OVER (ORDER BY month))
       / LAG(orders) OVER (ORDER BY month) AS growth
   FROM monthly_orders
   ORDER BY month;
   ```

   Growth comes out as `1, 0, 0`: SQL drops the decimals when both sides are whole numbers (549 / 383 = 1). Fix: multiply by `100.0` first, as in step 1, to keep them: 143.3, 80.8, -46.6.

2. **Grouping by the full time.**

   ```sql
   SELECT ordered_at, COUNT(*) AS orders
   FROM orders
   GROUP BY ordered_at
   ORDER BY ordered_at;
   ```

   Every order has its own minute, so you get 3,795 groups and almost every one holds just 1 order. Fix: group by the month (`date_trunc('month', ordered_at)`), which gives 4 rows.

3. **Filtering on the rank with `WHERE`.**

   ```sql
   SELECT b.city, COUNT(*) AS orders,
     RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
   FROM orders o
   JOIN branches b USING (branch_id)
   WHERE rnk = 1
   GROUP BY b.city;
   ```

   ```text
   ERROR: column "rnk" does not exist   (SQLSTATE 42703)
   ```

   `WHERE` runs before the rank is made. Fix: rank inside a CTE, then filter outside:

   ```sql
   WITH ranked AS (
     SELECT b.city, COUNT(*) AS orders,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
     FROM orders o
     JOIN branches b USING (branch_id)
     GROUP BY b.city
   )
   SELECT * FROM ranked
   WHERE rnk = 1;
   ```

   One row: Pune, 1999 orders, rank 1.

## Next

[M17-L01 · Full Scan vs Index: How a Database Finds a Row](../../m17-indexes/m17-l01-full-scan-vs-index-how-a-database-finds-a-row/)
