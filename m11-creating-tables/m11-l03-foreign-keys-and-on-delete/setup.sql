-- M11-L03 setup: the tables this lesson adds to the Chai Corner database.
-- Only needed if you skipped the lesson. Safe to run more than once.
-- (Supplier 4, Konkan Spices, was added and deleted in the lesson, so suppliers stays at 3 rows.)

CREATE TABLE IF NOT EXISTS restocks (
  restock_id  int PRIMARY KEY,
  supplier_id int NOT NULL REFERENCES suppliers (supplier_id),
  item        varchar(40),
  qty         int
);

INSERT INTO restocks VALUES
  (1, 2, 'milk', 30),
  (2, 1, 'tea leaves', 8)
ON CONFLICT (restock_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS supplier_contacts (
  contact_id  int PRIMARY KEY,
  supplier_id int REFERENCES suppliers (supplier_id) ON DELETE CASCADE,
  person      varchar(40),
  job         varchar(30)
);

INSERT INTO supplier_contacts VALUES
  (1, 1, 'Ravi',  'sales'),
  (2, 2, 'Meena', 'delivery')
ON CONFLICT (contact_id) DO NOTHING;
