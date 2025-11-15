# Invoice Ninja Toolkit

A GitHub-ready toolkit for maintaining a self-hosted **Invoice Ninja v5** installation on Ubuntu.

## Features

- 🔧 `inrepairs` — fix permissions, ownership, and clear Laravel caches
- 🔍 `inaudit` — audit ownership, permissions, writability, and worker status
- 💾 `inbackup` — create file + DB backups with retention
- ♻️ `inrestore` — restore from a backup set
- 🛠 `inhealsupervisor` — auto-heal Supervisor queue workers
- ⏱ Systemd scheduler (service + timer) to replace cron-based scheduler

## Layout

- `scripts/` — all toolkit scripts
- `systemd/` — systemd unit files for the scheduler
- `docs/` — additional documentation
- `packaging/` — scripts to build release archives
- `.github/workflows/` — optional GitHub Actions workflow for releases

## Quick Install

```bash
git clone https://github.com/YOURORG/invoice-ninja-toolkit.git
cd invoice-ninja-toolkit/scripts
sudo bash install_toolkit.sh
```

After installation, the toolkit will live at `/opt/invoiceninja-toolkit` and the following commands will be available:

```bash
sudo inrepairs
sudo inaudit
sudo inbackup
sudo inrestore /path/to/backup
sudo inhealsupervisor
```

See `docs/INSTALL.md` for full details.
