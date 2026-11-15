-- Build 5: Interview Mock (Chai Corner database, PostgreSQL)
-- Pause, give yourself 3 minutes per question, then compare with these answers.

-- Q1: orders per branch, biggest first   (Pune 1999, Mumbai 1281, Delhi 620)
SELECT b.city, COUNT(*) AS orders
FROM orders o
JOIN branches b USING (branch_id)
GROUP BY b.city
ORDER BY orders DESC;

-- Q2: top 3 items by quantity sold   (Masala Chai 1704, Cutting Chai 1592, Vada Pav 1045)
SELECT m.name, SUM(oi.qty) AS sold
FROM order_items oi
JOIN menu_items m USING (item_id)
GROUP BY m.name
ORDER BY sold DESC
LIMIT 3;

-- Q3: branches with no orders yet   (7 rows: 4 Bengaluru ... 10 Kochi)
SELECT b.branch_id, b.city
FROM branches b
WHERE NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.branch_id = b.branch_id)
ORDER BY b.branch_id;

-- Q4: revenue per month   (Jan 34490, Feb 86770, Mar 150005, Apr 83245)
SELECT date_trunc('month', o.ordered_at)::date AS month,
       SUM(oi.qty * m.price) AS revenue
FROM orders o
JOIN order_items oi USING (order_id)
JOIN menu_items m USING (item_id)
GROUP BY month
ORDER BY month;

-- Q5: each staff member and their manager   (Meera has NULL: she is the owner)
SELECT s.name, s.role, m.name AS manager
FROM staff s
LEFT JOIN staff m ON m.staff_id = s.manager_id
ORDER BY s.staff_id;

-- Q6: average order value per branch   (Pune 91.12, Mumbai 90.73, Delhi 90.56)
WITH totals AS (
  SELECT o.order_id, o.branch_id, SUM(oi.qty * m.price) AS total
  FROM orders o
  JOIN order_items oi USING (order_id)
  JOIN menu_items m USING (item_id)
  GROUP BY o.order_id, o.branch_id)
SELECT b.city, ROUND(AVG(total), 2) AS avg_order
FROM totals JOIN branches b USING (branch_id)
GROUP BY b.city ORDER BY avg_order DESC;

-- Q7: top 2 items in each branch   (Masala Chai, then Cutting Chai, in every branch)
WITH sales AS (
  SELECT o.branch_id, m.name, SUM(oi.qty) AS sold,
    ROW_NUMBER() OVER (PARTITION BY o.branch_id ORDER BY SUM(oi.qty) DESC) AS rn
  FROM orders o JOIN order_items oi USING (order_id)
  JOIN menu_items m USING (item_id)
  GROUP BY o.branch_id, m.name)
SELECT b.city, s.name, s.sold, s.rn FROM sales s
JOIN branches b USING (branch_id) WHERE rn <= 2;

-- Q8: salaries shared by more than one person   (45000, 22000, 20000: two people each)
SELECT salary, COUNT(*) AS people,
       string_agg(name, ', ') AS who
FROM staff
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;

-- Q9: revenue and share by category   (Snack 43.5, Chai 34.2, Coffee 22.3)
SELECT m.category,
       SUM(oi.qty * m.price) AS revenue,
       ROUND(100.0 * SUM(oi.qty * m.price)
             / SUM(SUM(oi.qty * m.price)) OVER (), 1) AS pct
FROM order_items oi
JOIN menu_items m USING (item_id)
GROUP BY m.category
ORDER BY revenue DESC;

-- Q10: top 5 customers by orders, with first order date   (Isha 273, Kiran 272, ...)
SELECT c.name,
       COUNT(*) AS orders,
       MIN(o.ordered_at)::date AS first_order
FROM customers c
JOIN orders o USING (customer_id)
GROUP BY c.customer_id, c.name
ORDER BY orders DESC, c.name
LIMIT 5;
