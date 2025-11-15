#!/bin/bash
#
# inrestore.sh - Restore Invoice Ninja from a backup set
#

BACKUP_DIR="$1"
IN_DIR="${IN_DIR:-/var/www/invoiceninja}"
DB_NAME="${DB_NAME:-invoiceninja}"
DB_USER="${DB_USER:-root}"
DB_HOST="${DB_HOST:-localhost}"
DB_EXTRA_OPTS="${DB_EXTRA_OPTS:-}"

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: inrestore /path/to/backup-dir"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

DB_DUMP="$BACKUP_DIR/db.sql"
FILES_ARCHIVE="$BACKUP_DIR/invoiceninja-files.tar.gz"

if [ ! -f "$DB_DUMP" ] || [ ! -f "$FILES_ARCHIVE" ]; then
    echo "❌ Backup directory must contain db.sql and invoiceninja-files.tar.gz"
    exit 1
fi

echo "⚠️ Restoring Invoice Ninja from backup: $BACKUP_DIR"
echo "   Target directory: $IN_DIR"
echo "   Database: $DB_NAME on $DB_HOST (user: $DB_USER)"
echo

read -p "Type 'RESTORE' to continue: " CONFIRM
if [ "$CONFIRM" != "RESTORE" ]; then
    echo "Aborted."
    exit 1
fi

echo "👉 Stopping web/PHP services (nginx + php-fpm*) ..."
systemctl stop nginx 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true
systemctl stop php*-fpm 2>/dev/null || true

echo "👉 Restoring files ..."
tar -xzf "$FILES_ARCHIVE" -C / || {
    echo "❌ Failed to extract files archive"
    exit 1
}

echo "👉 Restoring database ..."
if ! command -v mysql >/dev/null 2>&1; then
    echo "❌ mysql client not found; cannot restore database"
    exit 1
fi

mysql -h "$DB_HOST" -u "$DB_USER" $DB_EXTRA_OPTS "$DB_NAME" < "$DB_DUMP" || {
    echo "❌ Database restore failed"
    exit 1
}

echo "👉 Running inrepairs to fix permissions and caches ..."
if command -v inrepairs >/dev/null 2>&1; then
    inrepairs
else
    echo "⚠️ inrepairs command not found; please run repairs manually"
fi

echo "👉 Starting web/PHP services ..."
systemctl start php*-fpm 2>/dev/null || true
systemctl start apache2 2>/dev/null || true
systemctl start nginx 2>/dev/null || true

echo "🎉 Restore complete."
