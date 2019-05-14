#!/bin/sh 
set -e

host="$1"
user="$2"
password="$3"

until mongo --username $user --password $password --host $host --authenticationDatabase admin --eval "db.adminCommand( { listDatabases: 1 } )"; do
  >&2 echo "MongoDB is unavailable - sleeping"
  sleep 1
done

>&2 echo "MongoDB is up"
