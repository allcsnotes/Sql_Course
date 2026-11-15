-- M10-L05 UNION, UNION ALL, INTERSECT, EXCEPT (Chai Corner, fictional data)
-- Who came to Pune in the first week of January? (7: 5, 6, 7, 8, 9, 10, 15)
SELECT DISTINCT customer_id
FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
ORDER BY customer_id;

-- Who came to Mumbai in the first week of January? (8: 1, 3, 4, 6, 7, 8, 10, 12)
SELECT DISTINCT customer_id
FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;

-- UNION: everyone from both lists, each customer once (11 rows)
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;

-- UNION ALL: every row from both, repeats kept (18 rows)
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION ALL
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;

-- INTERSECT: only customers in both lists (4: 6, 7, 8, 10)
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
INTERSECT
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;

-- EXCEPT: in the first list, but not in the second (3: 5, 9, 15)
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
EXCEPT
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;

-- Mistake 1: two columns on top, one column below
-- ERROR: each UNION query must have the same number of columns
SELECT customer_id, branch_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08';

-- Mistake 2: a number on top, text below
-- ERROR: UNION types integer and character varying cannot be matched
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION
SELECT name FROM customers;

-- Mistake 3: ORDER BY in the middle
-- ERROR: syntax error at or near "UNION"
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
ORDER BY customer_id
UNION
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08';

-- Your task: who came to Delhi in the first week, but not to Pune? (4: 2, 3, 11, 12)
SELECT customer_id FROM orders
WHERE branch_id = 3 AND ordered_at < '2026-01-08'
EXCEPT
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
ORDER BY customer_id;
