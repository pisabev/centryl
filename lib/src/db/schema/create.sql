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
CREATE INDEX "api_local_key" ON "base_api_local" USING btree ("key");

CREATE TABLE IF NOT EXISTS "base_api_remote"
(
    "api_remote_id" serial       NOT NULL PRIMARY KEY,
    "name"          varchar(100) NOT NULL,
    "key"           varchar(100) NOT NULL,
    "host"          varchar(100) NOT NULL UNIQUE
);
CREATE INDEX "api_remote_key" ON "base_api_remote" USING btree ("key");
CREATE INDEX "api_remote_host" ON "base_api_remote" USING btree ("host");

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