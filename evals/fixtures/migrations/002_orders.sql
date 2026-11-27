-- PostgreSQL 16. orders: ~50M rows, ~2k writes/s at peak. coupons: 20k rows.
ALTER TABLE orders ADD COLUMN coupon_code text NOT NULL;
CREATE INDEX orders_customer_idx ON orders (customer_id);
ALTER TABLE orders ADD CONSTRAINT orders_coupon_fk FOREIGN KEY (coupon_code) REFERENCES coupons (code);
ALTER TABLE orders ALTER COLUMN total TYPE numeric(12,2);
UPDATE orders SET status = 'archived' WHERE created_at < now() - interval '2 years';
