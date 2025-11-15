# Scheduler

The toolkit provides a systemd service and timer:

- `invoiceninja-scheduler.service`
- `invoiceninja-scheduler.timer`

These run `php artisan schedule:run` every minute as `www-data`, replacing a crontab entry.
