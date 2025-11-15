#!/bin/bash
#
# inbackup.sh - Backup Invoice Ninja files + database
#

IN_DIR="${IN_DIR:-/var/www/invoiceninja}"
BACKUP_ROOT="${BACKUP_ROOT:-/opt/invoiceninja-toolkit/backups}"
DB_NAME="${DB_NAME:-invoiceninja}"
DB_USER="${DB_USER:-root}"
DB_HOST="${DB_HOST:-localhost}"
DB_EXTRA_OPTS="${DB_EXTRA_OPTS:-}"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DEST="$BACKUP_ROOT/$DATE"

mkdir -p "$DEST"

echo "🔐 Creating Invoice Ninja backup at: $DEST"

if [ ! -d "$IN_DIR" ]; then
    echo "❌ ERROR: Invoice Ninja directory not found: $IN_DIR"
    exit 1
fi

echo "👉 Dumping MySQL database '$DB_NAME' ..."
if ! command -v mysqldump >/dev/null 2>&1; then
    echo "❌ mysqldump not found; cannot backup database"
    exit 1
fi

mysqldump -h "$DB_HOST" -u "$DB_USER" $DB_EXTRA_OPTS "$DB_NAME" > "$DEST/db.sql"
if [ $? -ne 0 ]; then
    echo "❌ Database dump failed"
    exit 1
fi

echo "👉 Archiving Invoice Ninja files from $IN_DIR ..."
tar -czf "$DEST/invoiceninja-files.tar.gz" -C / "$(echo "$IN_DIR" | sed 's#^/##')" || {
    echo "❌ File archive failed"
    exit 1
}

echo "🧹 Pruning backups older than 14 days in $BACKUP_ROOT ..."
find "$BACKUP_ROOT" -maxdepth 1 -mindepth 1 -type d -mtime +14 -exec rm -rf {} \; || true

echo "🎉 Backup complete: $DEST"
