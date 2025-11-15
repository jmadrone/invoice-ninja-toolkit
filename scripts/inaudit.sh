#!/bin/bash
#
# inaudit.sh - Audit Invoice Ninja installation health
#

IN_DIR="${IN_DIR:-/var/www/invoiceninja}"
WEB_USER="${WEB_USER:-www-data}"

echo "🔍 Invoice Ninja Audit — $(date)"
echo "Target directory: $IN_DIR"
echo

if [ ! -d "$IN_DIR" ]; then
    echo "❌ ERROR: Invoice Ninja directory not found: $IN_DIR"
    exit 1
fi

echo "📁 Checking ownership (first 20 mismatches)..."
BAD=$(find "$IN_DIR" ! -user "$WEB_USER" -o ! -group "$WEB_USER" | head -n 20 || true)
if [ -z "$BAD" ]; then
    echo "✅ Ownership OK"
else
    echo "❌ Ownership issues detected:"
    echo "$BAD"
fi
echo

echo "🔐 Checking permissions (first 20 mismatches)..."
BAD_F=$(find "$IN_DIR" -type f ! -perm 644 | head -n 20 || true)
BAD_D=$(find "$IN_DIR" -type d ! -perm 755 | head -n 20 || true)

if [ -z "$BAD_F" ]; then
    echo "✅ File permissions OK"
else
    echo "❌ Files with incorrect permissions:"
    echo "$BAD_F"
fi

if [ -z "$BAD_D" ]; then
    echo "✅ Directory permissions OK"
else
    echo "❌ Directories with incorrect permissions:"
    echo "$BAD_D"
fi
echo

echo "📝 Checking writability of storage/ and bootstrap/cache ..."
for d in storage bootstrap/cache; do
    if sudo -u "$WEB_USER" test -w "$IN_DIR/$d"; then
        echo "✅ $d is writable by $WEB_USER"
    else
        echo "❌ $d is NOT writable by $WEB_USER"
    fi
done
echo

echo "🔐 Checking .env file ..."
if [ -f "$IN_DIR/.env" ]; then
    PERMS=$(stat -c "%a" "$IN_DIR/.env")
    OWNER=$(stat -c "%U:%G" "$IN_DIR/.env")
    echo "   Permissions: $PERMS"
    echo "   Owner:       $OWNER"
    if [ "$PERMS" = "640" ]; then
        echo "✅ .env permissions look good"
    else
        echo "❌ .env permissions should typically be 640"
    fi
else
    echo "❌ .env is missing!"
fi
echo

echo "🚦 Checking Supervisor and queue workers ..."
if systemctl is-active --quiet supervisor; then
    echo "✅ supervisor service is active"
    WORKERS=$(supervisorctl status 2>/dev/null | grep -i invoiceninja-worker || true)
    if [ -n "$WORKERS" ]; then
        echo "✅ Invoice Ninja workers detected:"
        echo "$WORKERS"
    else
        echo "❌ No invoiceninja-worker processes found in supervisorctl status"
    fi
else
    echo "❌ supervisor service is not active"
fi
echo

echo "🖨️ Checking for snappdf binary (for PDF generation) ..."
if ls "$IN_DIR/vendor/beganovich/snappdf/versions"/*/chrome-linux/chrome >/dev/null 2>&1; then
    echo "✅ Snappdf chrome binary detected"
else
    echo "⚠️  Snappdf chrome binary NOT found — PDF generation may fail"
fi
echo

echo "📊 Audit complete."
