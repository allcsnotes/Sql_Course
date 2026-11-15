-- M18-L03 setup: DB update 10, the plan_demo test table
-- 100,000 rows (every 100th is Pune, the rest Delhi), autovacuum off for this table only,
-- then every city made upper case (PUNE / DELHI) and the table rewritten by VACUUM FULL,
-- exactly as the video leaves it. No random values: you get the same rows as the video.
-- Safe to run again: it drops and rebuilds plan_demo.

DROP TABLE IF EXISTS plan_demo;

CREATE TABLE plan_demo (id int, city text)
WITH (autovacuum_enabled = false);

INSERT INTO plan_demo
SELECT g, CASE WHEN g % 100 = 0 THEN 'Pune' ELSE 'Delhi' END
FROM generate_series(1, 100000) AS g;

ANALYZE plan_demo;

UPDATE plan_demo
SET city = upper(city)
WHERE id > 0;

VACUUM FULL plan_demo;
