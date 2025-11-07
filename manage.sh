#!/bin/bash

# --- Configuration ---
# IMPORTANT: CHANGE THIS to your registry user (Docker Hub, GitHub, etc.)
REGISTRY_USER="dsaatools"
IMAGE_NAME="dsaa"
BACKUP_ARCHIVE_NAME="dev-environment-backup.tar"

# --- Helper Functions ---
function help_text() {
    echo "Usage: ./manage.sh [command]"
    echo "Commands: build, up, down, shell, login, push, pull, backup, restore, help"
}

# --- Main Commands ---
function build() { docker-compose build --no-cache; }
function up() { docker-compose up -d; echo "🚀 Env up. Portainer on https://localhost:9443. Shell with: ./manage.sh shell"; }
function down() { docker-compose down; }
function shell() { docker-compose exec dev-container tmux attach -t dev || docker-compose exec dev-container tmux new -s dev; }
function login() { read -p "Registry URL (e.g., docker.io, ghcr.io): " REGISTRY_URL; docker login $REGISTRY_URL; }
function check_user() {
    if [ "$REGISTRY_USER" == "YOUR_REGISTRY_USER" ]; then
        echo "❌ Error: Please edit manage.sh and set your REGISTRY_USER."
        exit 1
    fi
}
function push() { check_user; docker-compose push; }
function pull() { check_user; docker-compose pull; }
function backup() {
    check_user
    echo "💾 Creating backup..."
    docker save -o image.tar "${REGISTRY_USER}/${IMAGE_NAME}:latest"
    docker run --rm -v dev-data:/data -v $(pwd):/backup ubuntu tar cvf /backup/volume.tar -C /data .
    tar cvf $BACKUP_ARCHIVE_NAME image.tar volume.tar
    rm image.tar volume.tar
    echo "✅ Backup '${BACKUP_ARCHIVE_NAME}' created. Upload to Mega.io."
}
function restore() {
    [ ! -f "$BACKUP_ARCHIVE_NAME" ] && { echo "❌ Error: '${BACKUP_ARCHIVE_NAME}' not found."; exit 1; }
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
