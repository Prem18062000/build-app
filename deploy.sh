#!/bin/bash

###########################################
# Production-Ready Deployment Script
###########################################

set -e  # Exit on error
IMAGE="$1"
APP_DIR="$HOME/app"
COMPOSE_FILE="$APP_DIR/docker-compose.yaml"
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
    COMPOSE_CMD="sudo docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="sudo docker-compose"
else
    log "ERROR: docker compose or docker-compose is not installed!"
    exit 1
fi

# Ensure app directory exists
mkdir -p "$APP_DIR"

log "Copying docker-compose.yaml to $APP_DIR ..."
cp "$HOME/docker-compose.yaml" "$COMPOSE_FILE"

log "Pulling latest image: $IMAGE ..."
sudo docker pull "$IMAGE"

# Create .env file so docker-compose gets the IMAGE value
echo "IMAGE=$IMAGE" > "$APP_DIR/.env"
log "Generated .env file with IMAGE=$IMAGE"

log "Stopping existing containers..."
sudo $COMPOSE_CMD -f "$COMPOSE_FILE" down || true

log "Starting new containers..."
sudo $COMPOSE_CMD -f "$COMPOSE_FILE" up -d


log "Waiting for container warmup..."
sleep 3

log "Checking image list"
sudo docker images

log "Checking deployed containers..."
$COMPOSE_CMD -f "$COMPOSE_FILE" ps

log "Checking running containers..."
sudo docker ps

log "Deployment completed successfully!"
log "-------------------------------------------------"
