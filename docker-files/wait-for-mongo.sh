#!/bin/sh 
set -e

host="$1"
user="$2"
password="$3"

until mongosh --host $host --eval "db.adminCommand( { listDatabases: 1 } )"; do
  >&2 echo "MongoDB is unavailable - sleeping"
  sleep 1
done

mongosh --host $host --eval "db.createUser({user: '$user', pwd: '$password', roles: [ { role: 'root', db: 'admin' } ]});" admin

>&2 echo "MongoDB is up"