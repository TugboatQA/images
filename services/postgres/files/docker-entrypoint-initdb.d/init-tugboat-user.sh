#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER tugboat WITH PASSWORD 'tugboat';
    GRANT ALL PRIVILEGES ON DATABASE tugboat TO tugboat;
    ALTER DATABASE tugboat OWNER TO tugboat;
EOSQL
