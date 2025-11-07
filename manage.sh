#!/bin/bash

# --- Configuration ---
REGISTRY_USER="dsaatools"  # CHANGE THIS or stay embarrassed
IMAGE_NAME="dsaa"
BACKUP_ARCHIVE_NAME="dev-environment-backup.tar"

# --- Helper Functions ---
function help_text() {
    echo "Usage: ./manage.sh [command]"
    echo "Commands: build, up, down, shell, login, push, pull, backup, restore, help"
    echo ""
    echo "Pro tip: backup/restore auto-syncs with Mega. No manual uploads."
}

function check_user() {
    if [ "$REGISTRY_USER" == "YOUR_REGISTRY_USER" ]; then
        echo "❌ Error: Please edit manage.sh and set your REGISTRY_USER."
        exit 1
    fi
}

# --- Main Commands ---
function build() { docker-compose build --no-cache; }

function up() { 
    docker-compose up -d; 
    echo "🚀 Env up. Portainer on https://localhost:9443. Shell with: ./manage.sh shell"; 
}

function down() { docker-compose down; }

function shell() { 
    docker-compose exec dev-container tmux attach -t dev || docker-compose exec dev-container tmux new -s dev; 
}

function login() { 
    read -p "Registry URL (e.g., docker.io, ghcr.io): " REGISTRY_URL; 
    docker login $REGISTRY_URL; 
}

function push() { 
    check_user; 
    docker-compose push; 
}

function pull() { 
    check_user; 
    docker-compose pull; 
}

# --- Backup/Restore: Stop manual uploads like it's 2005 ---
function backup() {
    check_user
    
    # One-time rclone setup (interactive)
    if ! docker run --rm -v rclone-config:/config rclone/rclone listremotes | grep -q mega; then
        echo "🚨 rclone not configured for Mega. Running setup..."
        docker run --rm -it -v rclone-config:/config rclone/rclone config
    fi
    
    echo "💾 Creating backup & pushing to Mega..."
    
    # Create local tarball
    docker save -o image.tar "${REGISTRY_USER}/${IMAGE_NAME}:latest"
    docker run --rm -v dev-data:/data -v $(pwd):/backup ubuntu tar cvf /backup/volume.tar -C /data .
    tar cvf $BACKUP_ARCHIVE_NAME image.tar volume.tar
    rm image.tar volume.tar
    
    # Upload to Mega (this is the magic)
    docker run --rm -v rclone-config:/config -v $(pwd):/data rclone/rclone \
        copy /data/$BACKUP_ARCHIVE_NAME mega:/backups/
    
    echo "✅ Backup uploaded to mega:/backups/$BACKUP_ARCHIVE_NAME"
    echo "📦 Local copy kept: $BACKUP_ARCHIVE_NAME"
}

function restore() {
    # Pull from Mega if missing locally
    if [ ! -f "$BACKUP_ARCHIVE_NAME" ]; then
        echo "🔄 Backup not found locally, pulling from Mega..."
        docker run --rm -v rclone-config:/config -v $(pwd):/data rclone/rclone \
            copy mega:/backups/$BACKUP_ARCHIVE_NAME /data/
    fi
    
    [ ! -f "$BACKUP_ARCHIVE_NAME" ] && { echo "❌ Error: Backup not found anywhere."; exit 1; }
    
    echo "🔄 Restoring from backup..."
    tar xvf $BACKUP_ARCHIVE_NAME
    docker load -i image.tar
    docker run --rm -v dev-data:/data -v $(pwd):/backup ubuntu tar xvf /backup/volume.tar -C /data
    rm image.tar volume.tar
    
    echo "✅ Restore complete. Run './manage.sh up'"
}

# --- Script Logic ---
case "$1" in
    build|up|down|shell|login|push|pull|backup|restore) "$1" ;;
    help|*) help_text ;;
esac
