ALTER TABLE meta DROP COLUMN IF EXISTS "uuid";

CREATE TABLE IF NOT EXISTS "api_local" (
    "api_local_id"      serial          NOT NULL PRIMARY KEY,
    "key"               varchar(100)    NOT NULL,
    "limit"             integer         ,
    "active"            bool            NOT NULL DEFAULT FALSE
); CREATE INDEX "api_local_key" ON "api_local" USING btree ("key");

CREATE TABLE IF NOT EXISTS "api_remote" (
    "api_remote_id"     serial          NOT NULL PRIMARY KEY,
    "key"               varchar(100)    NOT NULL,
    "host"              varchar(100)    NOT NULL UNIQUE
); CREATE INDEX "api_remote_key" ON "api_remote" USING btree ("key");
CREATE INDEX "api_remote_host" ON "api_remote" USING btree ("host");