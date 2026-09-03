-- Throwaway restore checks for Forrest's Wallet.
-- Run only against an isolated database with psql -v ON_ERROR_STOP=1.
-- RAISE EXCEPTION on any violated invariant so psql exits non-zero.

DO $$
BEGIN
  IF to_regclass('public.transactions') IS NULL THEN
    RAISE EXCEPTION 'restore invariant failed: transactions table is missing';
  END IF;
END
$$;

DO $$
DECLARE
  n bigint;
BEGIN
  SELECT COUNT(*) INTO n FROM transactions WHERE amount_fen % 100 <> 0;
  IF n <> 0 THEN
    RAISE EXCEPTION 'restore invariant failed: % row(s) with amount_fen not a whole yuan', n;
  END IF;

  SELECT COUNT(*) INTO n FROM transactions WHERE amount_fen = 0;
  IF n <> 0 THEN
    RAISE EXCEPTION 'restore invariant failed: % zero-amount row(s)', n;
  END IF;
END
$$;

SELECT COUNT(*) AS transaction_rows FROM transactions;
SELECT COALESCE(SUM(amount_fen), 0) AS balance_fen FROM transactions;
