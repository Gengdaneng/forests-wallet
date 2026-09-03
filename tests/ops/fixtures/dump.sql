--
-- PostgreSQL database dump
--

SET statement_timeout = 0;

CREATE TABLE transactions (
    id uuid NOT NULL,
    amount_fen integer NOT NULL
);

INSERT INTO transactions VALUES ('00000000-0000-0000-0000-000000000001', 1000);
INSERT INTO transactions VALUES ('00000000-0000-0000-0000-000000000002', -200);

--
-- PostgreSQL database dump complete
--
