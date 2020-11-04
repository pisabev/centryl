CREATE TABLE IF NOT EXISTS "notification" (
    "notification_id"   serial          NOT NULL PRIMARY KEY,
    "key"               varchar(100)    NOT NULL,
    "value"             text            ,
    "date"              timestamptz     NOT NULL DEFAULT NOW()
);