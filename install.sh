#!/bin/bash
# OpenClaw Workspace Organizer - One-line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/dazeb/openclaw-workspace-organizer/main/install.sh | bash

set -e

echo "🚀 Installing OpenClaw Workspace Organizer..."
echo

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the organizer
echo "📥 Downloading organizer..."
curl -sSL -o organizer.tar.gz https://github.com/dazeb/openclaw-workspace-organizer/archive/main.tar.gz
tar -xzf organizer.tar.gz
cd openclaw-workspace-organizer-main

# Install to workspace
INSTALL_DIR="$HOME/.openclaw/workspace/scripts"
mkdir -p "$INSTALL_DIR"

echo "📦 Installing scripts..."
cp *.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR"/*.sh

# Copy documentation
cp README.md "$INSTALL_DIR/ORGANIZER-README.md"

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "✅ Installation complete!"
echo
echo "📁 Scripts installed in: $INSTALL_DIR"
echo
echo "🚀 To organize your workspace:"
echo "  cd ~/.openclaw/workspace"
echo "  ./scripts/organize-workspace.sh"
echo
echo "📚 Documentation:"
echo "  $INSTALL_DIR/ORGANIZER-README.md"
echo
echo "🌐 GitHub: https://github.com/dazeb/openclaw-workspace-organizer"