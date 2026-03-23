# 🐳 joakolabs – Raspberry Pi Docker Homelab

A collection of Docker Compose stacks, automation scripts, and configuration files powering a self-hosted homelab on a Raspberry Pi. Everything is organized by function: networking, monitoring, miscellaneous tools, media, and organization.

---

## 📁 Repository Structure

```
dockerfiles/
├── networking/           # DNS, VPN, reverse proxy, DDNS, speed test
├── monitoring/           # Grafana, Prometheus, Portainer, Home Assistant, ntopng, vnstat
├── misc/                 # Homepage dashboard, Paperless-ngx, Snippet Box, Composerize, File Browser, Karakeep
├── immich/               # Self-hosted photo library (Immich)
├── organization-tools/   # Task management (Vikunja)
├── bkp_logs/             # Backup log files
├── backup.sh             # Unified encrypted backup script
├── encrypt.sh            # .env file encryption/decryption manager
├── pi_to_pc_backup.sh    # Rsync backups from Pi to a Windows share
├── pi_to_pc_trigger.sh   # Auto-trigger Pi→PC backup when desktop is reachable
├── instal_docker.sh      # Fresh Raspberry Pi + Docker setup script
├── crontab-entries.txt   # Cron schedule reference for all backup jobs
└── env_files.txt         # List of .env paths managed by encrypt.sh
```

---

## 🗂️ Stacks

### 🔵 Networking (`networking/`)

DNS filtering, VPN access, reverse proxy, and DDNS updates.

| Service | Image | Port | Purpose |
|---|---|---|---|
| Pi-hole | `pihole/pihole` | 10000 (HTTPS), 10001 (HTTP) | DNS ad-blocking, web console |
| Unbound | `mvance/unbound-rpi` | 10002 | Recursive DNS resolver (upstream for Pi-hole) |
| WireGuard (wg-easy) | `ghcr.io/wg-easy/wg-easy` | 10003 (UDP), 10004 (web) | VPN server + web UI |
| Nginx Proxy Manager | `jc21/nginx-proxy-manager` | 10008 (admin), 80, 443 | Reverse proxy + SSL termination |
| Cloudflare DDNS | `timothyjmiller/cloudflare-ddns` | — | Keeps DNS records updated with dynamic IP |
| Cloudflare Tunnel | `cloudflare/cloudflared` | — | Exposes services without open ports |
| MySpeed | `germannewsmaker/myspeed` | 10017 | Scheduled internet speed tracking |

> **Note:** `noip-duc` is present but disabled via `profiles: skip`. Pi-hole and Unbound are connected over an internal Docker network (`10.8.1.0/24`), with Unbound assigned `10.8.1.253` as Pi-hole's upstream DNS.

---

### 🟢 Monitoring (`monitoring/`)

System observability, container management, and home automation.

| Service | Image | Port | Purpose |
|---|---|---|---|
| Portainer CE | `portainer/portainer-ce` | 10005, 10006 | Docker management UI |
| Grafana | `grafana/grafana` | 10007 | Metrics dashboards |
| Prometheus | `prom/prometheus` | (internal) | Metrics collection (1 year retention, 10 GB cap) |
| cAdvisor | `gcr.io/cadvisor/cadvisor` | (internal) | Per-container resource metrics |
| Node Exporter | `prom/node-exporter` | (internal) | Host-level system metrics |
| vnstat | `vergoh/vnstat` | 10014 | Network bandwidth usage over time |
| ntopng | `ntop/ntopng_arm64.dev` | host | Deep network traffic analysis |
| Home Assistant | `ghcr.io/home-assistant/home-assistant` | 8123 | Home automation (host networking) |
| Watchtower | `containrrr/watchtower` | — | Auto-updates container images daily at 5 AM |

A pre-built Grafana dashboard for Raspberry Pi monitoring is included at `monitoring/grafana-prometheus/grafana/provisioning/dashboards/rpi-monitoring.json` and is auto-provisioned on startup.

---

### 🟡 Miscellaneous Tools (`misc/`)

Productivity and utility services.

| Service | Image | Port | Purpose |
|---|---|---|---|
| Homepage | `ghcr.io/gethomepage/homepage` | 10016 | Customizable homelab dashboard |
| Paperless-ngx | `ghcr.io/paperless-ngx/paperless-ngx` | 10015 | Document management system |
| Snippet Box | `pawelmalak/snippet-box:arm` | 10012 | Code snippet manager |
| Composerize | `oaklight/composerize` | 10013 | Converts `docker run` commands to Compose YAML |
| File Browser | `filebrowser/filebrowser` | 10019 | Web UI for browsing Paperless archived documents |
| Karakeep | `ghcr.io/karakeep-app/karakeep` | 10020 | Bookmark manager |
| first-homepage | `nginx:alpine` | 10011 | Legacy static homepage (disabled via `profiles: skip`) |

Paperless-ngx runs as a full stack internally: `paperless-webserver` + `paperless-broker` (Redis) + `paperless-gotenberg` (document conversion) + `paperless-tika` (file parsing).

---

### 📸 Immich (`immich/`)

Self-hosted photo and video library with machine learning features.

| Service | Port | Purpose |
|---|---|---|
| immich-server | 10100 | Main app + API |
| immich-machine-learning | (internal) | Face recognition, CLIP search |
| Redis (Valkey) | (internal) | Cache |
| PostgreSQL (pgvecto.rs) | (internal) | Database with vector search |

Configuration via `.env` file (see `encrypt.sh` for how secrets are managed).

---

### 📋 Organization Tools (`organization-tools/`)

| Service | Image | Port | Purpose |
|---|---|---|---|
| Vikunja | `vikunja/vikunja` | 10018 | Self-hosted task and project management |

Uses SQLite by default. PostgreSQL config is present but commented out.

---

## 📦 Port Assignment Reference

| Port | Service | Notes |
|---|---|---|
| 10000 | Pi-hole | HTTPS web console |
| 10001 | Pi-hole | HTTP (deprecated) |
| 10002 | Unbound | DNS |
| 10003 | WireGuard | UDP – port forwarding |
| 10004 | WireGuard | Web console |
| 10005 | Portainer | Agent port |
| 10006 | Portainer | HTTPS web console |
| 10007 | Grafana | Web console |
| 10008 | Nginx Proxy Manager | Admin web console |
| 10009 | *(reserved)* | Was NPM HTTP reroute |
| 10010 | *(reserved)* | Was NPM HTTPS reroute |
| 10011 | first-homepage | Static legacy homepage (disabled) |
| 10012 | Snippet Box | Web console |
| 10013 | Composerize | Web console |
| 10014 | vnstat | Web console |
| 10015 | Paperless-ngx | Web console |
| 10016 | Homepage | Dashboard |
| 10017 | MySpeed | Web console |
| 10018 | Vikunja | Web console |
| 10019 | File Browser | Web console |
| 10020 | Karakeep | Bookmark manager |
| 80 / 443 | Nginx Proxy Manager | Public HTTP/HTTPS |

---

## 🛠️ Scripts

### `instal_docker.sh` — Fresh Pi + Docker Setup

Run once on a new Raspberry Pi to install handy CLI tools and Docker.

```bash
bash instal_docker.sh
```

What it does:
- Installs `neovim`, `git`, `htop`, `exa`, `bat`
- Sets up shell aliases (`ls` → `exa`, `cat` → `batcat`, `top` → `htop`, etc.)
- Removes unofficial Docker packages
- Installs official Docker CE + Docker Compose plugin from Docker's apt repo
- Adds your user to the `docker` group

> After running, log out and back in for the `docker` group change to take effect.

---

### `encrypt.sh` — .env File Encryption Manager

Encrypts and decrypts all `.env` files listed in `env_files.txt` using AES-256-CBC via OpenSSL. Keeps secrets out of the repository while still tracking file paths in git.

```bash
# Encrypt all .env files → produces .env.enc files
./encrypt.sh -e

# Decrypt all .env.enc files back to .env
./encrypt.sh -d

# Create a single encrypted tarball backup of all .env files
./encrypt.sh -b

# Restore from the latest encrypted tarball backup
./encrypt.sh -r
```

`env_files.txt` contains the list of paths to manage (relative to the repo root):

```
./monitoring/.env
./networking/.env
./networking/cloudflare/cloudflare-ddns-config.json
./immich/.env
```

---

### `backup.sh` — Unified Encrypted Service Backup

Creates GPG-encrypted (AES-256) backups of service data. All backups land in `~/bkps/`. A passphrase file at `~/.gpg_pass` is used (no interactive prompts — safe for cron).

```bash
# Backup / restore Homepage config
./backup.sh homepage zip
./backup.sh homepage unzip

# Backup Paperless data, media, and Redis volumes
./backup.sh paperless

# Backup Immich data directory
./backup.sh immich

# Backup / restore Nginx Proxy Manager data
./backup.sh proxy zip
./backup.sh proxy unzip

# Backup / restore Karakeep data
./backup.sh karakeep zip
./backup.sh karakeep unzip
```

**Retention policy:**
- Homepage, Proxy Manager, and Karakeep: keeps the 2 most recent backups
- Immich: keeps the 2 most recent backups
- Paperless: deletes backups older than 7 days

---

### `immich/backup.sh` — Immich Google Drive Backup

Separate script that compresses, encrypts, and uploads the Immich data directory to Google Drive via `rclone`. Also cleans up the previous remote backup.

```bash
bash immich/backup.sh
```

Requirements: `rclone` configured with a remote named `GoogleDrive`, and `~/.gpg_pass` for the encryption passphrase.

---

### `pi_to_pc_trigger.sh` + `pi_to_pc_backup.sh` — Pi → PC Rsync Backup

Automatically syncs `~/bkps/` on the Pi to a mounted Windows share (`/mnt/winbackup/pi_backups/`) whenever the desktop PC comes online — but only once per day.

**How it works:**
1. `pi_to_pc_trigger.sh` is run frequently by cron (e.g. every 15 minutes). It pings the desktop IP; if reachable and no backup has run today, it fires `pi_to_pc_backup.sh`.
2. `pi_to_pc_backup.sh` checks that the Windows share is mounted, then runs `rsync` with `--delete` to mirror the backup directory.

```bash
# Edit the desktop IP in pi_to_pc_trigger.sh before use
DESKTOP_IP="10.10.1.199"
```

Logs are written to `bkp_logs/pi_to_pc_backup.log` and `bkp_logs/pi_auto_trigger.log`.

---

### `networking/create_local_hosts.sh` — Pi-hole Local DNS Generator

Generates a `dnsmasq` config file mapping all homelab subdomains (`*.joakolabs.com`) to a given local IP, then installs it into Pi-hole's config directory.

```bash
# Replace 192.168.1.x with your Pi's local IP
./networking/create_local_hosts.sh 192.168.1.100
```

This creates `networking/pihole/dnsmasq/joakolabs-custom.conf` with entries like:

```
address=/pihole.joakolabs.com/192.168.1.100
address=/grafana.joakolabs.com/192.168.1.100
...
```

Restart Pi-hole after running to apply the new DNS entries.

---

## ⏰ Cron Schedule

Add these entries via `crontab -e`. The full reference is in `crontab-entries.txt`.

| Schedule | Job |
|---|---|
| Every Monday @ 03:00 | Homepage backup |
| Every Monday @ 03:30 | Nginx Proxy Manager backup |
| Every Wednesday & Saturday @ 04:00 | Immich backup |
| Every 2 days @ 03:00 | Paperless backup |

---

## 🔐 Secret Management Workflow

1. Create `.env` files for each stack as needed.
2. Add their paths to `env_files.txt`.
3. Run `./encrypt.sh -e` to encrypt them before committing. Only `.env.enc` files are tracked by git (`.env` is gitignored).
4. On a fresh clone, run `./encrypt.sh -d` to restore the `.env` files.

---

## ⚙️ k3s on Raspberry Pi

If adding k3s alongside Docker, two configuration changes are required:

**1. Enable memory cgroups** — edit `/boot/firmware/cmdline.txt` and append to the single line:

```
cgroup_memory=1 cgroup_enable=memory
```

**2. Set Docker's cgroup driver to systemd** — create/edit `/etc/docker/daemon.json`:

```json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

Restart Docker after making this change. These settings allow k3s to enforce pod resource limits and avoid cgroup conflicts with Docker.
