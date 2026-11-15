-- M22-L05 setup (DB update 18): the food delivery design, in its own schema called delivery,
-- so the Chai Corner tables are not touched.
-- Safe to run more than once: it drops and rebuilds the delivery schema (sample data as at the start of step 4).
DROP SCHEMA IF EXISTS delivery CASCADE;
CREATE SCHEMA delivery;
SET search_path TO delivery;

-- step 2: the simple tables
CREATE TABLE customers (id int PRIMARY KEY, name text NOT NULL, phone text UNIQUE);
CREATE TABLE addresses (id int PRIMARY KEY, customer_id int REFERENCES customers,
  line text NOT NULL, city text NOT NULL);
CREATE TABLE restaurants (id int PRIMARY KEY, name text NOT NULL, city text NOT NULL);
CREATE TABLE menu_items (id int PRIMARY KEY, restaurant_id int REFERENCES restaurants,
  name text NOT NULL, price int CHECK (price > 0));
CREATE TABLE riders (id int PRIMARY KEY, name text NOT NULL, phone text UNIQUE);

-- step 3: orders link everything together
CREATE TABLE orders (id int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers,
  restaurant_id int NOT NULL REFERENCES restaurants,
  address_id int NOT NULL REFERENCES addresses,
  rider_id int REFERENCES riders,
  status text NOT NULL CHECK (status IN ('placed','cooking','on_the_way','delivered','cancelled')),
  placed_at timestamp NOT NULL);
CREATE TABLE order_items (order_id int REFERENCES orders, menu_item_id int REFERENCES menu_items,
  qty int NOT NULL CHECK (qty > 0), price_at_order int NOT NULL,
  PRIMARY KEY (order_id, menu_item_id));

-- step 4: a little sample data
INSERT INTO customers VALUES (1,'Asha','98000 11111'),(2,'Rahul','98000 22222');
INSERT INTO addresses VALUES (1,1,'12 Park Street','Kolkata'),(2,2,'5 MG Road','Pune');
INSERT INTO restaurants VALUES (1,'Spice Box','Pune'),(2,'Dosa Hut','Kolkata');
INSERT INTO menu_items VALUES (1,1,'Paneer Roll',120),(2,1,'Veg Biryani',180),
  (3,2,'Masala Dosa',90),(4,2,'Filter Coffee',40);
INSERT INTO riders VALUES (1,'Vikram','98000 33333');
INSERT INTO orders VALUES (101,2,1,2,1,'delivered','2026-03-10 13:05'),
  (102,1,2,1,1,'on_the_way','2026-03-10 19:40');
INSERT INTO order_items VALUES (101,1,2,120),(101,2,1,180),(102,3,2,90),(102,4,2,40);
-- 2 customers, 2 addresses, 2 restaurants, 4 menu items, 1 rider, 2 orders, 4 order items

-- back to the Chai Corner tables
SET search_path TO public;
