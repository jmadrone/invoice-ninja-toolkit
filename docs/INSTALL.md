# Installation

## Prerequisites

- Ubuntu 20.04 or later
- Invoice Ninja v5 installed at `/var/www/invoiceninja`
- Web server user: `www-data`
- Systemd-based system

## Steps

```bash
git clone https://github.com/YOURORG/invoice-ninja-toolkit.git
cd invoice-ninja-toolkit/scripts
sudo bash install_toolkit.sh
```

This will:

- Copy scripts into `/opt/invoiceninja-toolkit`
- Create symlinks in `/usr/local/bin`
- Install and enable the `invoiceninja-scheduler.timer`
