-- M16-B04 setup: what Build 4 leaves in the Chai Corner database.
-- The monthly_orders view (orders per month). Re-runnable.
CREATE OR REPLACE VIEW monthly_orders AS
SELECT date_trunc('month', ordered_at)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month;

-- Check: 4 rows: 2026-01 383, 2026-02 932, 2026-03 1685, 2026-04 900
SELECT * FROM monthly_orders ORDER BY month;
