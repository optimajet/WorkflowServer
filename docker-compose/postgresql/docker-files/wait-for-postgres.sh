#!/bin/sh 
set -e

host="$1"
user="$2"
password="$3"
db="$4"

until PGPASSWORD=$password psql -h "$host" -U "$user" -d "$db" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up"