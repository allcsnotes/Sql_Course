-- M15-L06 setup (DB update 7): a newsletter table with duplicate sign-ups.
-- Added to the Chai Corner database after this lesson, ready for M15-L07.
-- Asha and Ravi signed up twice.
-- Re-runnable: the table and its 6 starting rows are only added if they are missing
-- (later lessons change these rows, and a materialized view in M16-L02 depends on the table).
CREATE TABLE IF NOT EXISTS newsletter (
  id serial PRIMARY KEY,
  email text NOT NULL,
  joined_on date NOT NULL
);

INSERT INTO newsletter (email, joined_on)
SELECT v.email, v.joined_on::date
FROM (VALUES
  ('asha@mail.com',  '2026-03-01'),
  ('ravi@mail.com',  '2026-03-02'),
  ('asha@mail.com',  '2026-03-04'),
  ('meena@mail.com', '2026-03-05'),
  ('ravi@mail.com',  '2026-03-07'),
  ('kabir@mail.com', '2026-03-08')
) AS v(email, joined_on)
WHERE NOT EXISTS (SELECT 1 FROM newsletter);

-- Check: 6 rows, ids 1 to 6 (on a first run)
SELECT * FROM newsletter ORDER BY id;
