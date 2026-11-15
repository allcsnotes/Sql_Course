-- M01-L04 · the menu_items table for MySQL or SQLite (PostgreSQL already has it from M02-L04)
CREATE TABLE menu_items (item_id int PRIMARY KEY, name varchar(40) NOT NULL, price int NOT NULL);
INSERT INTO menu_items VALUES (1,'Bun Maska',35),(2,'Cold Coffee',80),(3,'Cutting Chai',20),(4,'Filter Coffee',40),(5,'Ginger Chai',30),(6,'Maggi',60),(7,'Masala Chai',30),(8,'Samosa',25),(9,'Vada Pav',30),(10,'Veg Sandwich',70);
