-- M05-L04 · The three beginner mistakes. Each one fails on purpose.

-- Mistake 1: a boolean only takes clear values (true, false, yes, no ...).
SELECT 'maybe'::boolean AS is_open;
-- SQL Error [22P02]: ERROR: invalid input syntax for type boolean: "maybe"

-- Mistake 2: a UUID must follow its exact pattern.
SELECT 'order-42'::uuid AS order_id;
-- SQL Error [22P02]: ERROR: invalid input syntax for type uuid: "order-42"
-- Fix: let gen_random_uuid() make them for you.

-- Mistake 3: in JSON every name needs double quotes.
SELECT '{name: "Masala Chai"}'::jsonb AS menu_item;
-- SQL Error [22P02]: ERROR: invalid input syntax for type json
-- Detail: Token "name" is invalid.
-- Fix: '{"name": "Masala Chai"}'::jsonb
