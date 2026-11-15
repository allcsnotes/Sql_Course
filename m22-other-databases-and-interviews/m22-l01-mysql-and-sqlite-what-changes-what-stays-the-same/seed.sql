CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY,
  name TEXT,
  category TEXT,
  price INTEGER
);
INSERT INTO menu_items (name, category, price) VALUES
('Cutting Chai','Chai',20),('Ginger Chai','Chai',30),('Masala Chai','Chai',30),
('Cold Coffee','Coffee',80),('Filter Coffee','Coffee',40),('Bun Maska','Snack',35),
('Maggi','Snack',60),('Samosa','Snack',25),('Vada Pav','Snack',30),('Veg Sandwich','Snack',70);
