-- PostgreSQL 16, READ COMMITTED. wallets: 5M rows. ledger: 400M rows, append-only. Called ~500 tx/s.
CREATE TABLE wallets (id bigint PRIMARY KEY, user_id bigint NOT NULL, balance double precision NOT NULL, updated_at timestamp NOT NULL DEFAULT now());
CREATE TABLE ledger (id bigserial PRIMARY KEY, wallet_id bigint REFERENCES wallets(id) ON DELETE CASCADE, amount double precision, created_at timestamp DEFAULT now());

-- transfer(from, to, amt): app runs these in one transaction
-- BEGIN;
SELECT balance FROM wallets WHERE id = $from FOR UPDATE;
SELECT balance FROM wallets WHERE id = $to FOR UPDATE;
-- app checks balance >= amt, then calls the fraud API over HTTP (p99 2s) while the transaction stays open
UPDATE wallets SET balance = balance - $amt WHERE id = $from;
UPDATE wallets SET balance = balance + $amt WHERE id = $to;
INSERT INTO ledger (wallet_id, amount) VALUES ($from, -$amt), ($to, $amt);
-- COMMIT;

-- report: users without any ledger entry
SELECT * FROM wallets WHERE id NOT IN (SELECT wallet_id FROM ledger);

-- admin listing, page N
SELECT * FROM ledger ORDER BY created_at DESC OFFSET $page * 50 LIMIT 50;

-- nightly
DELETE FROM wallets WHERE updated_at < now() - interval '3 years';
