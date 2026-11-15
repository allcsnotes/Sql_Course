-- M10-L04 Correlated subqueries: once for every row (Chai Corner, fictional data)
-- Step by hand: the average price of each category (Chai 26.67, Coffee 60.00, Snack 44.00)
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category
ORDER BY category;

-- A correlated subquery: each item vs its own category (5 items)
SELECT name, category, price
FROM menu_items m
WHERE price > (SELECT AVG(price)
               FROM menu_items i
               WHERE i.category = m.category)
ORDER BY category, price DESC;

-- In SELECT: each item with its own category average
SELECT name, category, price,
       (SELECT ROUND(AVG(price), 2)
        FROM menu_items i
        WHERE i.category = m.category) AS cat_avg
FROM menu_items m
ORDER BY category, price DESC;

-- Same answer, averages worked out once: JOIN a derived table (5 items)
SELECT m.name, m.category, m.price
FROM menu_items m
JOIN (SELECT category, AVG(price) AS avg_price
      FROM menu_items
      GROUP BY category) AS c ON c.category = m.category
WHERE m.price > c.avg_price
ORDER BY m.category, m.price DESC;

-- Mistake 1: no table names in the link (always true): 3 rows, the wrong answer
SELECT name, category, price
FROM menu_items m
WHERE price > (SELECT AVG(price)
               FROM menu_items
               WHERE category = category)
ORDER BY category, price DESC;

-- Mistake 2: the link still leaves many rows
-- ERROR: more than one row returned by a subquery used as an expression
SELECT name, category,
       (SELECT price
        FROM menu_items i
        WHERE i.category = m.category) AS cat_price
FROM menu_items m;

-- Mistake 3: the inner name i used outside the brackets
-- ERROR: missing FROM-clause entry for table "i"
SELECT i.name, category, price
FROM menu_items m
WHERE price > (SELECT AVG(price)
               FROM menu_items i
               WHERE i.category = m.category);

-- Your task: who placed the most orders? (answer: Tara, 218)
SELECT name,
       (SELECT COUNT(*)
        FROM orders o
        WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c
ORDER BY order_count DESC
LIMIT 3;
