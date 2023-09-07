# MySQL-Backup
A bash script to automatically dump, compress and store your MySQL/MariaDB database backups.

# Configuration
- `BACKUP_DIR` - The directory to be used for storing the database backups.
- `MYSQL_USER` - MySQL username, typically you'd use the root user.
- `MYSQL_PASSWORD` Password for your MySQL user, if user has no password, keep as empty string.
- `BACKUPS_TO_KEEP` - Amount of backups to store before deleting the oldest one.

Once configured, I recommend running the script at least once manually and see if backups are created successfully.

## Making it run automatically
You can use a simple cronjob to make it execute the script automatically.

1. Run `crontab -e` to open the cronjob editor.
2. Press `i` to enable insert mode in the editor.
3. Paste this into a new line: `0 0 * * * bash /root/db_backup.sh >> /dev/null 2>&1`
4. Press ESC (Escape) on your keyboard.
5. Type `:wq` to save and exit.

> This is going to create a new backup of all databases every 24 hours at midnight, but you can adjust the cronjob as you wish to have it run whenever you want.
