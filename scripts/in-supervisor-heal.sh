#!/bin/bash
#
# in-supervisor-heal.sh - Auto-heal Supervisor workers for Invoice Ninja
#

if ! command -v supervisorctl >/dev/null 2>&1; then
    echo "❌ supervisorctl not found"
    exit 1
fi

STATUS=$(supervisorctl status 2>/dev/null | grep -i invoiceninja-worker || true)

if echo "$STATUS" | grep -q "RUNNING"; then
    echo "✅ Invoice Ninja workers are running:"
    echo "$STATUS"
else
    echo "❌ Workers not running — attempting restart..."
    supervisorctl restart all
fi
