#!/bin/bash
# Quick OpenClaw Workspace Organizer
# One-line installer and organizer

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

# Check if running in OpenClaw workspace
WORKSPACE_DIR="${1:-$HOME/.openclaw/workspace}"
if [ ! -d "$WORKSPACE_DIR" ]; then
    print_error "OpenClaw workspace not found at: $WORKSPACE_DIR"
    echo "Usage: $0 [workspace-path]"
    echo "Default: $HOME/.openclaw/workspace"
    exit 1
fi

echo -e "${BLUE}🚀 OpenClaw Quick Organizer${NC}"
echo "Workspace: $WORKSPACE_DIR"
echo

cd "$WORKSPACE_DIR"

# Create basic structure
mkdir -p memory projects scripts archive
mkdir -p memory/drafts memory/archive
mkdir -p projects/active projects/archive

# Create minimal .gitignore if not exists
if [ ! -f .gitignore ]; then
    cat > .gitignore << 'EOF'
# Security rules
.env
*.key
*.pem
secrets*
credentials*
openclaw.json
agents/
sessions/
*.log
.DS_Store
node_modules/
EOF
    print_success "Created .gitignore"
fi

# Create essential scripts
cat > scripts/quick-backup.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/.."
git add . && git commit -m "Backup $(date '+%Y-%m-%d %H:%M')" && git push
EOF
chmod +x scripts/quick-backup.sh

cat > scripts/quick-check.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/.."
echo "Workspace: $(pwd)"
echo "Core files:"
ls -la *.md 2>/dev/null || echo "No markdown files"
echo "Git status:"
git status --short 2>/dev/null || echo "Not a git repo"
EOF
chmod +x scripts/quick-check.sh

# Initialize git if not already
if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial workspace"
    print_success "Git initialized"
fi

# Create README
cat > README-QUICKSTART.md << 'EOF'
# Quick OpenClaw Workspace

Organized with quick-organizer.sh

## Quick Commands
- Backup: `./scripts/quick-backup.sh`
- Check: `./scripts/quick-check.sh`

## Next Steps
1. Update USER.md with your info
2. Customize SOUL.md
3. Add remote: `git remote add origin <url>`
4. Push: `git push -u origin main`

Created: $(date)
EOF

print_success "Workspace organized!"
echo
echo "Next:"
echo "  ./scripts/quick-check.sh"
echo "  Review README-QUICKSTART.md"
echo
echo "For full organization, run the complete organizer:"