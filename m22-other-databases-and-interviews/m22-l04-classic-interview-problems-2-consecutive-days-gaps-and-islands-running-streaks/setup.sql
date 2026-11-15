-- M22-L04 setup (DB update 17): one row for each day a customer visited
-- Safe to run more than once (it rebuilds the table).
DROP TABLE IF EXISTS daily_visits;
CREATE TABLE daily_visits (customer text, visited_on date);
INSERT INTO daily_visits VALUES
('Asha','2026-03-01'),('Asha','2026-03-02'),('Asha','2026-03-03'),
('Asha','2026-03-05'),('Asha','2026-03-06'),
('Asha','2026-03-09'),('Asha','2026-03-10'),('Asha','2026-03-11'),('Asha','2026-03-12'),
('Rahul','2026-03-02'),('Rahul','2026-03-04'),('Rahul','2026-03-05'),('Rahul','2026-03-08');
-- 13 rows: Asha 9, Rahul 4
