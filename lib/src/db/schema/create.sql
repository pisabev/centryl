CREATE TABLE IF NOT EXISTS "base_meta"
(
    "host"  varchar(100),
    "build" varchar(100)
);

CREATE TABLE IF NOT EXISTS "base_api_local"
(
    "api_local_id" serial       NOT NULL PRIMARY KEY,
    "name"         varchar(100) NOT NULL,
    "key"          varchar(100) NOT NULL,
    "limit"        integer,
    "active"       bool         NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS "api_local_key" ON "base_api_local" USING btree ("key");

CREATE TABLE IF NOT EXISTS "base_api_remote"
(
    "api_remote_id" serial       NOT NULL PRIMARY KEY,
    "name"          varchar(100) NOT NULL,
    "key"           varchar(100) NOT NULL,
    "host"          varchar(100) NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS "api_remote_key" ON "base_api_remote" USING btree ("key");
CREATE INDEX IF NOT EXISTS "api_remote_host" ON "base_api_remote" USING btree ("host");

CREATE TABLE IF NOT EXISTS "base_package"
(
    "name"    varchar(100) NOT NULL UNIQUE,
    "version" integer      NOT NULL
);

CREATE TABLE IF NOT EXISTS "base_notification"
(
    "notification_id" serial       NOT NULL PRIMARY KEY,
    "key"             varchar(100) NOT NULL,
    "value"           text,
    "date"            timestamptz  NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "base_cache"
(
    "key"    varchar(30) NOT NULL PRIMARY KEY,
    "value"  jsonb       NOT NULL,
    "expire" timestamptz
);

CREATE TABLE IF NOT EXISTS base_audit
(
    audit_ts   timestamptz NOT NULL DEFAULT now(),
    table_name text        NOT NULL,
    operation  varchar(10) NOT NULL,
    before     jsonb,
    after      jsonb
);
CREATE INDEX base_audit_audit_ts_operation_idx ON base_audit (audit_ts, table_name, operation);
CREATE INDEX base_users_audit_before_idx ON base_audit USING GIN (before);
CREATE INDEX base_users_audit_after_idx ON base_audit USING GIN (after);

CREATE OR REPLACE FUNCTION base_audit_trig()
    RETURNS trigger
    LANGUAGE plpgsql
AS
$function$
BEGIN
    IF TG_OP = 'UPDATE'
    THEN
        IF NEW != OLD THEN
            INSERT INTO base_audit (table_name, operation, before, after)
            VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD), to_jsonb(NEW));
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE'
    THEN
        INSERT INTO base_audit (table_name, operation, before)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(OLD));
        RETURN OLD;
    END IF;
END;
$function$;

-- CREATE TRIGGER audit_[table]
--     BEFORE UPDATE OR DELETE
--     ON [table]
--     FOR EACH ROW
-- EXECUTE PROCEDURE base_audit_trig();