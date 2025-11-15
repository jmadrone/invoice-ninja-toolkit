# Toolkit Design

The Invoice Ninja Toolkit is designed to be:

- Idempotent: running repair or audit multiple times is safe.
- Environment-driven: key paths and database parameters are overridable via environment variables.
- Systemd-native: replaces cron for running the Laravel scheduler.
