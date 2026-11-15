-- M01-L04 · the dialect fixes shown in the video

-- Step 4 (PostgreSQL): divide by 2.0 to keep the decimals
SELECT 7 / 2.0 AS result;
-- 3.5000000000000000

-- Step 5 (MySQL): see why || gave 0
SHOW WARNINGS;
-- Warning 1287: '|| as a synonym for OR' is deprecated ...
-- Warning 1292: Truncated incorrect DOUBLE value: 'Chai'
-- Warning 1292: Truncated incorrect DOUBLE value: ' Corner'

-- Step 6 (MySQL): CONCAT joins text
SELECT CONCAT('Chai', ' Corner') AS shop;
-- Chai Corner
