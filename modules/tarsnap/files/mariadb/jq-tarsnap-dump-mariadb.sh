#!/bin/sh

DB_PATTERN="$1"

rm -v /var/lib/backup/mariadb/*.sql

for DATABASE in $(mariadb --skip-column-names -e "SHOW DATABASES LIKE '$DB_PATTERN'"); do
  echo "backing up $DATABASE"
  mariadb-dump --master-data --single-transaction "$DATABASE" > /var/lib/backup/mariadb/"$DATABASE".sql
done
