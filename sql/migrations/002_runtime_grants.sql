-- Runtime role is not a superuser, cannot DDL, and cannot mutate the ledger
-- except by INSERT. Grants assume role forests_wallet_runtime already exists.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'forests_wallet_runtime') THEN
    RAISE EXCEPTION 'role forests_wallet_runtime does not exist';
  END IF;
END
$$;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO forests_wallet_runtime;

DO $$
BEGIN
  EXECUTE format(
    'GRANT CONNECT ON DATABASE %I TO forests_wallet_runtime',
    current_database()
  );
END
$$;

GRANT SELECT, UPDATE ON settings TO forests_wallet_runtime;
GRANT SELECT, INSERT, UPDATE ON children TO forests_wallet_runtime;
GRANT SELECT, INSERT, UPDATE ON devices TO forests_wallet_runtime;
GRANT SELECT ON categories TO forests_wallet_runtime;
GRANT SELECT, INSERT ON transactions TO forests_wallet_runtime;
GRANT SELECT, INSERT, UPDATE ON checkin_items TO forests_wallet_runtime;
GRANT SELECT, INSERT, UPDATE ON checkins TO forests_wallet_runtime;
GRANT SELECT, INSERT ON rule_changes TO forests_wallet_runtime;
GRANT SELECT, INSERT, UPDATE ON goals TO forests_wallet_runtime;
GRANT SELECT, INSERT ON idempotency_keys TO forests_wallet_runtime;
GRANT SELECT ON schema_migrations TO forests_wallet_runtime;

REVOKE UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON transactions FROM forests_wallet_runtime;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON schema_migrations FROM forests_wallet_runtime;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON categories FROM forests_wallet_runtime;
