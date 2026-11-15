-- migration 001_add_customer_phone.sql
BEGIN;
ALTER TABLE customers ADD COLUMN phone text;
INSERT INTO schema_migrations (version, name) VALUES (1, 'add_customer_phone');
COMMIT;
