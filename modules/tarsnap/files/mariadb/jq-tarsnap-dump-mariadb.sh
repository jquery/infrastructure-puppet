#!/bin/sh

DB_PATTERN="$1"

for DATABASE in $(mariadb --skip-column-names -e "SHOW DATABASES LIKE '$DB_PATTERN'"); do
  mariadb-dump --master-data --single-transaction "$DATABASE" > /var/lib/backup/mariadb/"$DATABASE".sql
done
