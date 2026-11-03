\set ON_ERROR_STOP on

-- Bootstrap the diagnostics schema and application access roles.
-- Run while connected to the diagnostics database as dbadmin.
-- This script intentionally contains no passwords.

-- PostgreSQL roles are cluster-wide. Create them only if they do not exist.
SELECT 'CREATE ROLE app_owner NOLOGIN'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = 'app_owner'
)
\gexec

SELECT 'CREATE ROLE app_user LOGIN'
WHERE NOT EXISTS (
  SELECT 1 FROM pg_roles WHERE rolname = 'app_user'
)
\gexec

ALTER ROLE app_owner NOLOGIN;
ALTER ROLE app_user LOGIN;

GRANT CONNECT ON DATABASE diagnostics TO app_user;
-- app_owner is NOLOGIN and needs CREATE on this database to own the app schema.
GRANT CREATE ON DATABASE diagnostics TO app_owner;

-- Let dbadmin create future schema objects as app_owner with SET ROLE.
GRANT app_owner TO dbadmin;

BEGIN;
SET ROLE app_owner;

CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION app_owner;

-- Future diagnostics API table and index creation DDL goes here.
-- Create objects as app_owner so default privileges apply to app_user.

-- app_user is the API login. It can read and write diagnostic data,
-- but cannot delete records or own/create schema objects.
GRANT USAGE ON SCHEMA app TO app_user;
GRANT SELECT, INSERT, UPDATE
  ON ALL TABLES IN SCHEMA app TO app_user;
GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA app TO app_user;

-- Apply the same access to tables and sequences created later by app_owner.
ALTER DEFAULT PRIVILEGES IN SCHEMA app
  GRANT SELECT, INSERT, UPDATE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA app
  GRANT USAGE, SELECT ON SEQUENCES TO app_user;

COMMIT;
RESET ROLE;

-- After this script, set the app_user password interactively in psql with:
--   \password app_user
-- Store that credential in Secrets Manager; never add it to this file or Git.
