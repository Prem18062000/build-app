#!/bin/bash

#############################################
# Production-Ready Docker Build Script
#############################################

set -e  # exit on error

IMAGE="$1"
DOCKERFILE="build/Dockerfile"
BUILD_CONTEXT="build/"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

log() {
    echo "[$TIMESTAMP] $1"
}

if [ -z "$IMAGE" ]; then
    log "ERROR: No image provided. Usage: ./build.sh <IMAGE>"
    exit 1
fi

log "-------------------------------------------------"
log "Starting Build"
log "Image to build: $IMAGE"
log "-------------------------------------------------"

# Validate Docker exists
if ! command -v docker >/dev/null 2>&1; then
    log "ERROR: Docker is not installed on build agent!"
    exit 1
fi

# Validate Dockerfile exists
if [ ! -f "$DOCKERFILE" ]; then
    log "ERROR: Dockerfile not found at $DOCKERFILE"
    exit 1
fi

# Build the image
log "Building Docker image..."
sudo docker build -t "$IMAGE" -f "$DOCKERFILE" "$BUILD_CONTEXT"

log "Build completed successfully!"
log "-------------------------------------------------"
