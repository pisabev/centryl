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
    IF TG_OP = 'INSERT'
    THEN
        INSERT INTO base_audit (table_name, operation, after)
        VALUES (TG_TABLE_NAME, TG_OP, to_jsonb(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE'
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