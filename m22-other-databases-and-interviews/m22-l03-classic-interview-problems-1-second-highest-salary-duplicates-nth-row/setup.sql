-- M22-L03 setup (DB update 16): give every staff member a monthly salary (rupees)
-- Safe to run more than once.
ALTER TABLE staff ADD COLUMN IF NOT EXISTS salary int;
UPDATE staff SET salary = CASE staff_id
  WHEN 1 THEN 90000  WHEN 2 THEN 60000  WHEN 3 THEN 45000
  WHEN 4 THEN 45000  WHEN 5 THEN 42000  WHEN 6 THEN 22000
  WHEN 7 THEN 22000  WHEN 8 THEN 20000  WHEN 9 THEN 20000
  WHEN 10 THEN 12000 END;
-- 10 rows updated
