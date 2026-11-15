-- Chai Corner update 5 (Module 9, Lesson 3): a staff table.
-- branch_id is empty (NULL) for head office staff and a new trainee.
-- manager_id points to another row of staff (used in the self join lesson).
CREATE TABLE staff (
  staff_id   int PRIMARY KEY,
  name       varchar(40) NOT NULL,
  role       varchar(30) NOT NULL,
  branch_id  int REFERENCES branches (branch_id),
  manager_id int REFERENCES staff (staff_id)
);
INSERT INTO staff VALUES
 (1, 'Meera', 'Owner', NULL, NULL),
 (2, 'Imran', 'Area Manager', NULL, 1),
 (3, 'Pooja', 'Branch Manager', 1, 2),
 (4, 'Sameer', 'Branch Manager', 2, 2),
 (5, 'Kavya', 'Branch Manager', 3, 2),
 (6, 'Ravi', 'Barista', 1, 3),
 (7, 'Nisha', 'Barista', 1, 3),
 (8, 'Aman', 'Barista', 2, 4),
 (9, 'Leela', 'Cashier', 3, 5),
 (10, 'Farhan', 'Trainee', NULL, 2);
