#!/bin/sh 
set -e

host="$1"
user="$2"
password="$3"
db="$4"

until /opt/mssql-tools/bin/sqlcmd -S $host -U $user -P $password -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'$db') BEGIN CREATE DATABASE [$db] END;"; do
  >&2 echo "MS SQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "MS SQL is up"