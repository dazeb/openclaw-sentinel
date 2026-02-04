#!/bin/bash
# Package OpenClaw Workspace Organizer for distribution

set -e

echo "📦 Packaging OpenClaw Workspace Organizer..."
echo

# Create distribution directory
DIST_DIR="openclaw-workspace-organizer-$(date +%Y%m%d)"
mkdir -p "$DIST_DIR"

# Copy all files
cp -r *.sh *.md LICENSE .gitignore "$DIST_DIR/"

# Create tarball
tar -czf "$DIST_DIR.tar.gz" "$DIST_DIR"

# Create zip file
zip -r "$DIST_DIR.zip" "$DIST_DIR"

echo "✅ Packaging complete!"
echo
echo "📁 Created packages:"
echo "  - $DIST_DIR.tar.gz"
echo "  - $DIST_DIR.zip"
echo
echo "📦 Package contents:"
ls -la "$DIST_DIR/"
echo
echo "🚀 To distribute:"
echo "1. Upload to GitHub Releases"
echo "2. Share tarball/zip files"
echo "3. Use one-line installer: install.sh"
echo
echo "📚 Documentation included:"
echo "  - README.md (main documentation)"
echo "  - SETUP-GITHUB.md (GitHub setup)"
echo "  - All organizer scripts"
echo
echo "Size:"
du -sh "$DIST_DIR"*
echo
echo "🎉 Ready for distribution!"