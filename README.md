# Dev-Environment-in-a-Box

Drop this on any VPS and get your dev environment with one command. Comes with Bun, Node, GitHub CLI, and Claude Code pre-installed. Backups auto-sync to Mega so you don't lose work when your $5 VPS dies.

---

## ⚡ Quick Start (First VPS)

```bash
# 1. Install Docker (if you haven't)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER && newgrp docker

# 2. Clone this repo
git clone <your-repo-url> dev-env && cd dev-env

# 3. **IMPORTANT**: Edit manage.sh and change this line:
#    REGISTRY_USER="YOUR_REGISTRY_USER"  # <-- Change to YOUR username

# 4. Build and start
./manage.sh build
./manage.sh up

# 5. Access your environment
./manage.sh shell
```

---

## 📋 Available Commands

```bash
./manage.sh build    # Build the dev container
./manage.sh up       # Start everything
./manage.sh down     # Stop everything
./manage.sh shell    # Jump into tmux session
./manage.sh backup   # Backup to Mega (first time will ask for Mega creds)
./manage.sh restore  # Restore from Mega
```

---

## 🔧 First-Time Mega Setup

When you run `./manage.sh backup` the first time, it'll prompt:

```
🚨 rclone not configured for Mega. Running setup...
```

Just follow the prompts:
- Type `n` for "New remote"
- Name it `mega`
- Choose `mega` from the list (type the number)
- Enter your Mega email/password
- Leave other settings default
- Type `q` to quit

That's it. Future backups will be automatic.

---

## 🚨 Important Warnings for Newbies

1. **Change REGISTRY_USER in manage.sh** - Unless you want to push/pull from my repo (you don't).

2. **Host Network Mode** - `network_mode: host` exposes all ports directly. Great for dev, terrible for security. Don't run this on a production server.

3. **Portainer on https://localhost:9443** - Only accessible from inside the VPS. To access remotely, use SSH tunnel:
   ```bash
   ssh -L 9443:localhost:9443 your-vps-ip
   ```
   Then open `https://localhost:9443` in your browser.

4. **Backups are NOT encrypted** - Anyone with your Mega creds can read them. Use a strong password.

---

## 🎯 Typical Workflow

```bash
# Day 1: Setup
./manage.sh build && ./manage.sh up

# Day 2-30: Work and backup
./manage.sh shell
# ... do work ...
./manage.sh backup  # Auto-uploads to Mega

# VPS dies: New VPS restore
./manage.sh restore  # Pulls from Mega
./manage.sh up
```

---

## 🐛 Troubleshooting

**"Permission denied" on manage.sh**
```bash
chmod +x manage.sh
```

**"Cannot connect to Docker daemon"**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

**Backups not uploading?**
- Run `./manage.sh backup` manually to see the error
- Check Mega credentials: `docker run --rm -v rclone-config:/config rclone/rclone config`

**Portainer shows "Your session has expired"**
Clear browser cookies or use incognito mode.

---

## 💡 Pro Tips

- **Cron your backups**: `crontab -e` then add `0 3 * * * cd /path/to/dev-env && ./manage.sh backup`
- **Multiple VPS?** Use the same Mega account and restore anywhere
- **Don't trust the backup?** Run `./manage.sh backup && ls -lh *.tar` to see the local file

---

That's it. Now go break things.
