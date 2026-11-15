-- M16-L02 setup: what this lesson leaves in the Chai Corner database.
-- Three materialized views (branch_cups_mv with a unique index on branch,
-- signups_mv, item_cups_mv) and one new newsletter sign-up (Zoya).
-- Needs M15-L06, M15-L07 and M16-L01 setup first. Re-runnable.
CREATE MATERIALIZED VIEW IF NOT EXISTS branch_cups_mv AS
SELECT branch, SUM(qty) AS cups
FROM sales
GROUP BY branch;

CREATE UNIQUE INDEX IF NOT EXISTS branch_cups_mv_branch_idx ON branch_cups_mv (branch);

CREATE MATERIALIZED VIEW IF NOT EXISTS signups_mv AS
SELECT COUNT(*) AS people FROM newsletter;

INSERT INTO newsletter (email, joined_on)
SELECT 'zoya@mail.com', '2026-03-10'
WHERE NOT EXISTS (SELECT 1 FROM newsletter WHERE email = 'zoya@mail.com');

REFRESH MATERIALIZED VIEW signups_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS item_cups_mv AS
SELECT item, SUM(qty) AS cups
FROM sales
GROUP BY item;

-- Check: signups_mv says 5; newsletter has 5 rows (ids 1, 2, 4, 6, 7)
SELECT * FROM signups_mv;
SELECT id, email, joined_on FROM newsletter ORDER BY id;
