#!/bin/bash
set -e

echo "🔨 Construyendo MultiWall Flatpak..."

APP_ID="me.latinosoft.MultiWall"
BUILD_DIR="/build/flatpak-build"
REPO_DIR="/build/flatpak-repo"
VERSION="${VERSION:-0.1.0}"

# Crear directorios
mkdir -p "$BUILD_DIR"
mkdir -p "$REPO_DIR"    

# Construir Flatpak (sin --user porque el SDK ya está instalado system-wide)
echo "📦 Construyendo con flatpak-builder..."
flatpak-builder \
    --force-clean \
    --repo="$REPO_DIR" \
    --disable-rofiles-fuse \
    "$BUILD_DIR" \
    /app/${APP_ID}.yml

# Crear bundle (archivo .flatpak)
echo "🎁 Creando bundle..."
flatpak build-bundle \
    "$REPO_DIR" \
    "/output/MultiWall-${VERSION}-x86_64.flatpak" \
    "$APP_ID"

echo "✅ Flatpak creado: /output/MultiWall-${VERSION}-x86_64.flatpak"
ls -lh /output/*.flatpak