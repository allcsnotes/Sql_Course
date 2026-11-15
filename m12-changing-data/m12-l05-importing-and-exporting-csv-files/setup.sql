-- M12-L05 setup: the price_updates table this lesson imports (4 rows from price_list.csv).
-- Only needed if you skipped the lesson. Safe to run more than once.
-- (menu_items is NOT changed: the new prices only sit in price_updates.)

CREATE TABLE IF NOT EXISTS price_updates (
  item_id   int PRIMARY KEY,
  new_price numeric(6,2) NOT NULL
);

INSERT INTO price_updates (item_id, new_price)
VALUES (1, 38), (3, 22), (5, 32), (8, 28)
ON CONFLICT (item_id) DO NOTHING;
