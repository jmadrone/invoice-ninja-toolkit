#!/bin/bash
#
# install_toolkit.sh - Install Invoice Ninja Toolkit onto the system
#
# Run from the repository's scripts/ directory:
#   cd invoice-ninja-toolkit/scripts
#   sudo bash install_toolkit.sh
#

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLKIT_DIR="/opt/invoiceninja-toolkit"
BIN_DIR="/usr/local/bin"

echo "🔧 Installing Invoice Ninja Toolkit from $REPO_ROOT ..."
echo "   Toolkit target directory: $TOOLKIT_DIR"
echo

mkdir -p "$TOOLKIT_DIR"
mkdir -p "$TOOLKIT_DIR/logs"

echo "👉 Copying scripts to $TOOLKIT_DIR ..."
cp "$REPO_ROOT"/scripts/*.sh "$TOOLKIT_DIR"/

echo "👉 Setting execute permissions on scripts ..."
chmod 755 "$TOOLKIT_DIR"/*.sh

echo "👉 Creating command symlinks in $BIN_DIR ..."
ln -sf "$TOOLKIT_DIR/inrepairs.sh"           "$BIN_DIR/inrepairs"
ln -sf "$TOOLKIT_DIR/inaudit.sh"             "$BIN_DIR/inaudit"
ln -sf "$TOOLKIT_DIR/inbackup.sh"            "$BIN_DIR/inbackup"
ln -sf "$TOOLKIT_DIR/inrestore.sh"           "$BIN_DIR/inrestore"
ln -sf "$TOOLKIT_DIR/in-supervisor-heal.sh"  "$BIN_DIR/inhealsupervisor"

echo "👉 Installing systemd units ..."
cp "$REPO_ROOT/systemd/invoiceninja-scheduler.service" /etc/systemd/system/
cp "$REPO_ROOT/systemd/invoiceninja-scheduler.timer"   /etc/systemd/system/

echo "👉 Reloading systemd daemon and enabling timer ..."
systemctl daemon-reload
systemctl enable --now invoiceninja-scheduler.timer

echo
echo "🎉 Toolkit installed successfully."
echo "Commands available: inrepairs, inaudit, inbackup, inrestore, inhealsupervisor"
echo "Check timer: systemctl status invoiceninja-scheduler.timer"
