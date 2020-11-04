ALTER TABLE IF EXISTS "meta" RENAME TO "base_meta";
ALTER TABLE IF EXISTS "api_local" RENAME TO "base_api_local";
ALTER TABLE IF EXISTS "api_remote" RENAME TO "base_api_remote";
ALTER TABLE IF EXISTS "notification" RENAME TO "base_notification";
ALTER TABLE IF EXISTS "cache" RENAME TO "base_cache";