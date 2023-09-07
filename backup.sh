#!/bin/bash

# Set the backup directory
BACKUP_DIR="/root/db_backups"

# Set the MySQL credentials
MYSQL_USER="root"
MYSQL_PASSWORD="" # Set to empty string if no password is set

# Check if the backup directory exists, and create it with permissions 700 if it doesn't
if [ ! -d "$BACKUP_DIR" ]
then
  mkdir -m 700 "$BACKUP_DIR"
fi

# Get the current date and time
NOW="$(date +'%Y-%m-%d_%H-%M-%S')"

# Set the number of backup to retain before deleting the oldest ones
BACKUPS_TO_KEEP=5

# Loop through each database and create a backup
for DATABASE in $(mysql -u $MYSQL_USER $( [ -n "$MYSQL_PASSWORD" ] && echo "-p $MYSQL_PASSWORD" ) -e "show databases;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")
do
  # Create a directory for the database if it doesn't exist and set its permissions to 700
  if [ ! -d "$BACKUP_DIR/$DATABASE" ]
  then
    mkdir -m 700 "$BACKUP_DIR/$DATABASE"
  fi

  # Create a backup file name
  BACKUP_FILE="$BACKUP_DIR/$DATABASE/$DATABASE.$NOW.sql.gz"

  # Dump the database to a compressed file
  mysqldump -u $MYSQL_USER $( [ -n "$MYSQL_PASSWORD" ] && echo "-p $MYSQL_PASSWORD" ) --opt --skip-lock-tables --default-character-set=utf8mb4 $DATABASE | gzip > $BACKUP_FILE

  # Set file permissions
  chmod 600 $BACKUP_FILE

  # Delete the oldest backups for the database
  NUM_BACKUPS=$(ls -1t $BACKUP_DIR/$DATABASE/$DATABASE.*.sql.gz | wc -l)
  if [ $NUM_BACKUPS -gt $BACKUPS_TO_KEEP ]
  then
    DELETE_COUNT=$((NUM_BACKUPS - BACKUPS_TO_KEEP))
    ls -1t $BACKUP_DIR/$DATABASE/$DATABASE.*.sql.gz | tail -n $DELETE_COUNT | xargs rm -f
  fi
done
