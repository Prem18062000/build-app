#!/bin/bash

###########################################
# Production-Ready Deployment Script
###########################################

set -e  # Exit on error
IMAGE="$1"
APP_DIR="$HOME/app"
COMPOSE_FILE="$APP_DIR/docker-compose.yml"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

log() {
    echo "[$TIMESTAMP] $1"
}

if [ -z "$IMAGE" ]; then
    log "ERROR: No image provided. Usage: ./deploy.sh <IMAGE>"
    exit 1
fi

log "-------------------------------------------------"
log "Starting Deployment"
log "Image to deploy: $IMAGE"
log "-------------------------------------------------"

# Ensure docker is installed
if ! command -v docker >/dev/null 2>&1; then
    log "ERROR: Docker is not installed!"
    exit 1
fi

# Ensure docker-compose exists (Works with both V1 & V2)
if command -v docker compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    log "ERROR: docker compose or docker-compose is not installed!"
    exit 1
fi

# Ensure app directory exists
mkdir -p "$APP_DIR"

log "Copying docker-compose.yml to $APP_DIR ..."
cp "$HOME/docker-compose.yml" "$COMPOSE_FILE"

log "Pulling latest image: $IMAGE ..."
docker pull "$IMAGE"

log "Stopping existing containers..."
$COMPOSE_CMD -f "$COMPOSE_FILE" down || true

log "Starting new containers..."
IMAGE="$IMAGE" $COMPOSE_CMD -f "$COMPOSE_FILE" up -d

log "Waiting for container warmup..."
sleep 3

log "Checking running containers..."
docker ps

log "Deployment completed successfully!"
log "-------------------------------------------------"
