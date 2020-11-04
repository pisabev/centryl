CREATE TABLE IF NOT EXISTS "cache" (
    "key"       varchar(30)         NOT NULL PRIMARY KEY,
    "value"     jsonb               NOT NULL,
    "expire"    timestamptz
);