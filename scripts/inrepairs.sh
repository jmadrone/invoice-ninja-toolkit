#!/bin/bash
#
# inrepairs.sh - Repair permissions and caches for Invoice Ninja
#

TOOLKIT_DIR="${TOOLKIT_DIR:-/opt/invoiceninja-toolkit}"
IN_DIR="${IN_DIR:-/var/www/invoiceninja}"
WEB_USER="${WEB_USER:-www-data}"
LOG="$TOOLKIT_DIR/logs/inrepairs.log"

mkdir -p "$(dirname "$LOG")"

echo "🔧 Running Invoice Ninja Repair: $(date)" | tee -a "$LOG"

if [ ! -d "$IN_DIR" ]; then
    echo "❌ ERROR: Invoice Ninja directory not found: $IN_DIR" | tee -a "$LOG"
    exit 1
fi

echo "👉 Fixing ownership to $WEB_USER:$WEB_USER ..." | tee -a "$LOG"
chown -R "$WEB_USER:$WEB_USER" "$IN_DIR"

echo "👉 Fixing file/dir permissions (644 files, 755 dirs) ..." | tee -a "$LOG"
find "$IN_DIR" -type f -exec chmod 644 {} \;
find "$IN_DIR" -type d -exec chmod 755 {} \;

echo "👉 Setting writable permissions on storage/ and bootstrap/cache ..." | tee -a "$LOG"
chmod -R 775 "$IN_DIR/storage" "$IN_DIR/bootstrap/cache"
if command -v setfacl >/dev/null 2>&1; then
    setfacl -Rm "u:$WEB_USER:rwx" "$IN_DIR/storage" "$IN_DIR/bootstrap/cache" >/dev/null 2>&1 || true
    setfacl -dRm "u:$WEB_USER:rwx" "$IN_DIR/storage" "$IN_DIR/bootstrap/cache" >/dev/null 2>&1 || true
fi

echo "👉 Securing .env (640, owned by $WEB_USER) ..." | tee -a "$LOG"
if [ -f "$IN_DIR/.env" ]; then
    chmod 640 "$IN_DIR/.env"
    chown "$WEB_USER:$WEB_USER" "$IN_DIR/.env"
else
    echo "⚠️  Warning: .env file not found in $IN_DIR" | tee -a "$LOG"
fi

echo "👉 Ensuring public storage directory exists ..." | tee -a "$LOG"
sudo -u "$WEB_USER" mkdir -p "$IN_DIR/storage/app/public"

echo "👉 Clearing Laravel caches ..." | tee -a "$LOG"
if command -v php >/dev/null 2>&1; then
    sudo -u "$WEB_USER" php "$IN_DIR/artisan" optimize:clear >/dev/null 2>&1 || echo "⚠️  artisan optimize:clear failed" | tee -a "$LOG"
    sudo -u "$WEB_USER" php "$IN_DIR/artisan" optimize >/dev/null 2>&1 || echo "⚠️  artisan optimize failed" | tee -a "$LOG"
else
    echo "⚠️  php command not found; skipping artisan commands" | tee -a "$LOG"
fi

echo "🚀 Repair completed!" | tee -a "$LOG"
