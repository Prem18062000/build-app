# Multi-stage Dockerfile: builder (optional) + nginx runner
# Behavior:
# - If building from project root that contains package.json and source, the builder stage will run npm ci and npm run build.
# - If building from this `build/` folder that already contains built assets, the Docker build will still work: it copies the local build output into the final image.

ARG BUILD_DIR=build

# Builder stage (optional). This stage will attempt to build the app if package.json is present.
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files first to leverage Docker layer caching when building from a repo root
COPY package*.json ./

# Install dependencies only if package.json exists
RUN if [ -f package.json ]; then npm ci --silent; fi

# Copy all files (this will include an already-built `build/` when building from the build folder)
COPY . .

# If package.json exists, run the build command to produce the production assets in /app/build
RUN if [ -f package.json ]; then npm run build --silent; else echo "No package.json found — assuming build/ already exists."; fi

# Runner stage: serve static files with nginx
FROM nginx:stable-alpine AS runner

# Remove default nginx static files (if present) and copy our built app
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets from the builder stage. This works whether the builder actually ran or the build folder was present originally.
COPY --from=builder /app/${BUILD_DIR} /usr/share/nginx/html

# Replace default nginx config with our SPA-friendly config (included alongside this Dockerfile)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
