-- Forrest's Wallet relational foundation.
-- Ledger is append-only transactions. Operational tables sit beside it.
-- No JSON document columns. Human-readable plain SQL.

CREATE TABLE IF NOT EXISTS schema_migrations (
  version text PRIMARY KEY,
  applied_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE settings (
  id boolean PRIMARY KEY DEFAULT true CHECK (id),
  timezone text NOT NULL DEFAULT 'Asia/Shanghai',
  currency_scale integer NOT NULL DEFAULT 100 CHECK (currency_scale = 100),
  bootstrap_open_until timestamptz
);

INSERT INTO settings (id, timezone, currency_scale, bootstrap_open_until)
VALUES (true, 'Asia/Shanghai', 100, NULL);

CREATE TABLE children (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- One-child-capable: a single row is enough for MVP, the table is not a singleton.
INSERT INTO children (display_name) VALUES ('child');

CREATE TABLE devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES children (id),
  role text NOT NULL CHECK (role IN ('parent', 'child')),
  status text NOT NULL CHECK (status IN ('pending', 'active', 'revoked')),
  label text NOT NULL DEFAULT '',
  token_hash bytea,
  revoked_at timestamptz,
  last_seen_at timestamptz,
  pairing_code_hash bytea,
  pairing_expires_at timestamptz,
  pairing_attempts integer NOT NULL DEFAULT 0 CHECK (pairing_attempts >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (status = 'pending' AND token_hash IS NULL AND revoked_at IS NULL
      AND pairing_code_hash IS NOT NULL AND pairing_expires_at IS NOT NULL)
    OR (status = 'active' AND token_hash IS NOT NULL AND revoked_at IS NULL
      AND pairing_code_hash IS NULL AND pairing_expires_at IS NULL)
    OR (status = 'revoked' AND revoked_at IS NOT NULL)
  )
);

CREATE UNIQUE INDEX devices_one_active_per_role
  ON devices (role)
  WHERE revoked_at IS NULL AND token_hash IS NOT NULL;

CREATE UNIQUE INDEX devices_token_hash_uq
  ON devices (token_hash)
  WHERE token_hash IS NOT NULL;

CREATE UNIQUE INDEX devices_one_live_pairing
  ON devices ((true))
  WHERE pairing_code_hash IS NOT NULL AND revoked_at IS NULL AND token_hash IS NULL;

CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  label text NOT NULL,
  sort integer NOT NULL UNIQUE
);

INSERT INTO categories (slug, label, sort) VALUES
  ('food', '吃的', 1),
  ('toys', '玩具', 2),
  ('games', '游戏', 3),
  ('books', '书和文具', 4),
  ('gifts', '送人的礼物', 5),
  ('other', '其他', 6);

CREATE TABLE transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES children (id),
  amount_fen integer NOT NULL CHECK (amount_fen <> 0 AND amount_fen % 100 = 0),
  occurred_on date NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  memo text NOT NULL DEFAULT '',
  category_id uuid NOT NULL REFERENCES categories (id),
  kind text NOT NULL CHECK (
    kind IN ('opening', 'allowance_weekly', 'income_temp', 'spend', 'reverse', 'replacement')
  ),
  reverses_id uuid REFERENCES transactions (id),
  replaces_id uuid REFERENCES transactions (id),
  settlement_week_start date,
  rule_snapshot text,
  account_kind text NOT NULL DEFAULT 'pocket' CHECK (account_kind = 'pocket'),
  idempotency_key text NOT NULL,
  request_hash bytea NOT NULL,
  device_id uuid NOT NULL REFERENCES devices (id),
  CHECK (
    (kind = 'allowance_weekly' AND settlement_week_start IS NOT NULL)
    OR (kind <> 'allowance_weekly' AND settlement_week_start IS NULL)
  ),
  CHECK (
    (kind = 'reverse' AND reverses_id IS NOT NULL)
    OR (kind <> 'reverse' AND reverses_id IS NULL)
  ),
  CHECK (
    (kind = 'replacement' AND replaces_id IS NOT NULL)
    OR (kind <> 'replacement' AND replaces_id IS NULL)
  )
);

CREATE UNIQUE INDEX transactions_one_weekly_settlement
  ON transactions (child_id, settlement_week_start)
  WHERE kind = 'allowance_weekly' AND settlement_week_start IS NOT NULL;

CREATE UNIQUE INDEX transactions_device_idempotency
  ON transactions (device_id, idempotency_key);

CREATE TABLE checkin_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES children (id),
  name text NOT NULL,
  weekly_target integer NOT NULL CHECK (weekly_target > 0),
  amount_fen integer NOT NULL CHECK (amount_fen >= 0 AND amount_fen % 100 = 0),
  sort integer NOT NULL,
  archived_at timestamptz
);

CREATE TABLE checkins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL REFERENCES checkin_items (id),
  local_date date NOT NULL,
  ticked_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (item_id, local_date)
);

CREATE TABLE rule_changes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES children (id),
  occurred_on date NOT NULL,
  summary text NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES children (id),
  name text NOT NULL,
  target_amount_fen integer NOT NULL CHECK (target_amount_fen > 0 AND target_amount_fen % 100 = 0),
  status text NOT NULL CHECK (status IN ('active', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK (
    (status = 'active' AND archived_at IS NULL)
    OR (status = 'archived' AND archived_at IS NOT NULL)
  )
);

CREATE UNIQUE INDEX goals_one_active_per_child
  ON goals (child_id)
  WHERE status = 'active';

-- HTTP write-idempotency contract for later product mutations.
CREATE TABLE idempotency_keys (
  device_id uuid NOT NULL REFERENCES devices (id),
  idempotency_key text NOT NULL,
  request_hash bytea NOT NULL,
  response_status integer NOT NULL,
  response_body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (device_id, idempotency_key)
);
