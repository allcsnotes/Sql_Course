-- M11-L04 setup: the changes this lesson makes to deliveries and restocks.
-- Only needed if you skipped the lesson. Safe to run more than once.

ALTER TABLE deliveries ADD COLUMN IF NOT EXISTS delivered_on date;
ALTER TABLE deliveries ADD COLUMN IF NOT EXISTS paid boolean NOT NULL DEFAULT false;

-- qty becomes quantity (only if it was not renamed yet)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'deliveries' AND column_name = 'qty') THEN
    ALTER TABLE deliveries RENAME COLUMN qty TO quantity;
  END IF;
END $$;

ALTER TABLE deliveries ALTER COLUMN bill_no TYPE varchar(40);

ALTER TABLE deliveries DROP CONSTRAINT IF EXISTS deliveries_supplier_id_fkey;
ALTER TABLE deliveries
  ADD CONSTRAINT deliveries_supplier_id_fkey FOREIGN KEY (supplier_id)
  REFERENCES suppliers (supplier_id);

-- The lesson's task
ALTER TABLE restocks ADD COLUMN IF NOT EXISTS received boolean NOT NULL DEFAULT false;
