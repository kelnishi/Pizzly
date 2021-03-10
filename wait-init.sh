#!/bin/bash
# Wait for DB, then init

set -e
  
cmd="$@"
  
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U "$DB_USER" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
  
>&2 echo "Postgres is up - let's go"

#init the db
>&2 echo "Create DB"
node src/lib/database/config/create
>&2 echo "Run Migrations"
knex --cwd src/lib/database/config migrate:latest

#run the command
>&2 echo "Run $cmd"
exec $cmd