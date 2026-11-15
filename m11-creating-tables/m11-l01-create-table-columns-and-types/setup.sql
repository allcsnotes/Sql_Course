-- M11-L01 setup: the tables this lesson adds to the Chai Corner database.
-- Only needed if you skipped the lesson. Safe to run more than once.

CREATE TABLE IF NOT EXISTS suppliers (
  supplier_id int PRIMARY KEY,
  name        varchar(60),
  city        varchar(30),
  supplies    text,
  since       date,
  rating      numeric(2,1)
);

INSERT INTO suppliers VALUES
  (1, 'Nilgiri Tea Co', 'Coonoor', 'tea leaves', '2019-03-01', 4.5),
  (2, 'Pune Dairy', 'Pune', 'milk', '2019-04-10', 4.8),
  (3, 'Sahyadri Snacks', 'Pune', 'samosa, vada pav', '2021-06-15', 4.2)
ON CONFLICT (supplier_id) DO NOTHING;

-- The table from the lesson's task (empty for now, rows come in M12-L01)
CREATE TABLE IF NOT EXISTS feedback (
  feedback_id int PRIMARY KEY,
  customer_id int,
  rating      int,
  comment     text,
  given_on    date
);
