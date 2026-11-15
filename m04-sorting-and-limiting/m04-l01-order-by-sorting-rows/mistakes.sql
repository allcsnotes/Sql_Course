-- M04-L01 · three beginner mistakes

-- Mistake 1: ORDER BY before WHERE
SELECT name, price FROM menu_items ORDER BY price WHERE price < 50;
-- ERROR:  syntax error at or near "WHERE"

-- Mistake 2: thinking DESC covers every column. It only changes name
SELECT name, price FROM menu_items ORDER BY price, name DESC;
-- prices still go up; only the 30s turn round: Vada Pav, Masala Chai, Ginger Chai

-- Mistake 2, what was meant: DESC on both columns
SELECT name, price FROM menu_items ORDER BY price DESC, name DESC;
-- Cold Coffee 80 first ... the 30s go Vada Pav, Masala Chai, Ginger Chai ... Cutting Chai 20 last

-- Mistake 3: trusting the order of ties. Add a tie breaker, like name (see Step 4)
