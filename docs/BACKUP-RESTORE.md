# Backup & Restore

## Backup

Run:

```bash
sudo inbackup
```

This will:

- Dump the MySQL database to `db.sql`
- Archive the Invoice Ninja files to `invoiceninja-files.tar.gz`
- Store everything under `/opt/invoiceninja-toolkit/backups/YYYY-MM-DD_HH-MM-SS`

Backups older than 14 days are pruned automatically.

## Restore

```bash
sudo inrestore /opt/invoiceninja-toolkit/backups/2025-01-01_12-00-00
```

You will be prompted to type `RESTORE` to confirm.
