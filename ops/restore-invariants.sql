-- Throwaway restore checks for Forrest's Wallet.
-- Run only against an isolated database. Fail on first error.
-- The ledger is the transactions table; balance is SUM(amount_fen).

SELECT COUNT(*) AS transaction_rows FROM transactions;

SELECT COALESCE(SUM(amount_fen), 0) AS balance_fen FROM transactions;

SELECT COUNT(*) AS non_integer_yuan_rows
FROM transactions
WHERE amount_fen % 100 <> 0;

SELECT COUNT(*) AS zero_amount_rows
FROM transactions
WHERE amount_fen = 0;
