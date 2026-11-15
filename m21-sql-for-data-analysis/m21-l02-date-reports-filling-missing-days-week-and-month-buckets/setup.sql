-- M21-L02 setup (DB update 15): stall_sales
-- A small tea stall: cups sold per day, 1 to 10 March 2026, closed on the 4th and the 7th.
-- Re-runnable: drops and rebuilds the table (8 rows, 367 cups in total).

DROP TABLE IF EXISTS stall_sales;
CREATE TABLE stall_sales (sold_on date, cups int);
INSERT INTO stall_sales VALUES
 ('2026-03-01', 40), ('2026-03-02', 35), ('2026-03-03', 52),
 ('2026-03-05', 48), ('2026-03-06', 61),
 ('2026-03-08', 30), ('2026-03-09', 44), ('2026-03-10', 57);
