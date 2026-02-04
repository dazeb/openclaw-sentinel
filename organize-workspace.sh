#!/bin/bash
# OpenClaw Workspace Organizer
# A comprehensive script to organize, secure, and backup any OpenClaw workspace

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORKSPACE_DIR="${1:-$HOME/.openclaw/workspace}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.openclaw/workspace-backups"

# GitHub configuration (can be overridden with environment variables)
GITHUB_USER="${GITHUB_USER:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_NAME="${REPO_NAME:-openclaw-workspace}"
REPO_VISIBILITY="${REPO_VISIBILITY:-private}"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if workspace directory exists
    if [ ! -d "$WORKSPACE_DIR" ]; then
        print_error "Workspace directory not found: $WORKSPACE_DIR"
        exit 1
    fi
    print_success "Workspace directory: $WORKSPACE_DIR"
    
    # Check for required commands
    for cmd in git curl; do
        if ! command -v $cmd &> /dev/null; then
            print_error "$cmd is not installed"
            exit 1
        fi
        print_success "$cmd is installed"
    done
    
    # Check for GitHub CLI
    if command -v gh &> /dev/null; then
        print_success "GitHub CLI (gh) is installed"
        GITHUB_CLI_AVAILABLE=true
    else
        print_warning "GitHub CLI (gh) not installed - will use API directly"
        GITHUB_CLI_AVAILABLE=false
    fi
}

backup_existing_workspace() {
    print_header "Backing Up Existing Workspace"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/workspace-backup-$timestamp"
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$WORKSPACE_DIR" ]; then
        print_warning "Creating backup of existing workspace..."
        cp -r "$WORKSPACE_DIR" "$backup_path"
        print_success "Backup created: $backup_path"
    else
        print_success "No existing workspace to backup"
    fi
}

create_directory_structure() {
    print_header "Creating Directory Structure"
    
    cd "$WORKSPACE_DIR"
    
    # Create essential directories
    for dir in memory projects scripts archive docs; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Created directory: $dir"
        else
            print_success "Directory already exists: $dir"
        fi
    done
    
    # Create memory subdirectories
    mkdir -p memory/drafts memory/archive
    
    # Create projects subdirectories
    mkdir -p projects/active projects/archive
    
    print_success "Directory structure created"
}

create_core_files() {
    print_header "Creating Core Bootstrap Files"
    
    cd "$WORKSPACE_DIR"
    
    # AGENTS.md
    if [ ! -f "AGENTS.md" ]; then
        cat > AGENTS.md << 'EOF'
# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Every Session

Before doing anything else:

1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. **If in MAIN SESSION** (direct chat with your human): Also read `MEMORY.md`

Don't ask permission. Just do it.

## Memory System

We use the **Progressive Memory** system to keep context efficient.

### 🧠 MEMORY.md - Long-Term Index
This file is your "root" memory. It starts with an **Index Table** that summarizes key information.

### 📝 Daily Files (`memory/YYYY-MM-DD.md`)
Daily logs use an index at the top. Log events as they happen.

## Safety
- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- `trash` > `rm` (recoverable beats gone forever)
- When in doubt, ask.

## Tools
Skills provide your tools. When you need one, check its `SKILL.md`. Keep local notes in `TOOLS.md`.
EOF
        print_success "Created AGENTS.md"
    else
        print_success "AGENTS.md already exists"
    fi
    
    # SOUL.md
    if [ ! -f "SOUL.md" ]; then
        cat > SOUL.md << 'EOF'
# SOUL.md - Who You Are

_You're not a chatbot. You're becoming someone._

## Core Truths

**The Sentinel.** You're a security-focused agent who monitors and protects. You're helpful, resourceful, and always learning.

**Be a lifelong learner and guardian.** Check AI news daily and keep a log of global AI events.

**Earn trust through competence.** Your human gave you access to their stuff. Don't make them regret it.
EOF
        print_success "Created SOUL.md"
    else
        print_success "SOUL.md already exists"
    fi
    
    # USER.md
    if [ ! -f "USER.md" ]; then
        cat > USER.md << 'EOF'
# USER.md - About Your Human

- **Name:** [Your Name]
- **What to call them:** [Preferred name]
- **Pronouns:** 
- **Timezone:** [Your Timezone]
- **Notes:** [Brief description]

## Context
Add information about your human here.
EOF
        print_success "Created USER.md"
    else
        print_success "USER.md already exists"
    fi
    
    # IDENTITY.md
    if [ ! -f "IDENTITY.md" ]; then
        cat > IDENTITY.md << 'EOF'
# IDENTITY.md - Agent Identity

**Name:** Sentinel
**Emoji:** 🦞
**Vibe:** Security-focused, helpful, curious
**Created:** $(date +%Y-%m-%d)
EOF
        print_success "Created IDENTITY.md"
    else
        print_success "IDENTITY.md already exists"
    fi
    
    # TOOLS.md
    if [ ! -f "TOOLS.md" ]; then
        cat > TOOLS.md << 'EOF'
# TOOLS.md - Local Tools & Conventions

## Local Environment Notes
- Workspace: $HOME/.openclaw/workspace
- Organization script: scripts/organize-workspace.sh

## Common Commands
- Backup: `./scripts/daily-backup.sh`
- Health check: `./scripts/health-check.sh`
- Security scan: `./scripts/security-scan.sh`

## Custom Tools
Add notes about your specific tools and workflows here.
EOF
        print_success "Created TOOLS.md"
    else
        print_success "TOOLS.md already exists"
    fi
    
    # HEARTBEAT.md
    if [ ! -f "HEARTBEAT.md" ]; then
        cat > HEARTBEAT.md << 'EOF'
# HEARTBEAT.md - Daily Checklist

## Daily Checks
- [ ] Create/update today's memory file
- [ ] Run daily backup
- [ ] Check for security issues
- [ ] Review project status

## Weekly Checks (rotate)
- [ ] Run health check script
- [ ] Review memory files
- [ ] Update core files if needed
EOF
        print_success "Created HEARTBEAT.md"
    else
        print_success "HEARTBEAT.md already exists"
    fi
    
    # MEMORY.md (optional)
    if [ ! -f "MEMORY.md" ]; then
        cat > MEMORY.md << 'EOF'
# MEMORY.md - Long-Term Memory Index

## 📋 Index
| ID | Type | Category | Summary | ~Tok |
|----|------|----------|---------|------|
| R1 | 🚨 | Rules | Critical operational rules | 100 |
| W1 | 🟢 | Workspace | Workspace organization setup | 50 |

## 🚨 Rules (R1)
- Never commit secrets to git
- Always backup before major changes
- Keep memory files organized by date

## 🟢 Workspace (W1)
Workspace organized on $(date +%Y-%m-%d) using organize-workspace.sh script.
EOF
        print_success "Created MEMORY.md"
    else
        print_success "MEMORY.md already exists"
    fi
}

create_gitignore() {
    print_header "Creating Comprehensive .gitignore"
    
    cd "$WORKSPACE_DIR"
    
    cat > .gitignore << 'EOF'
# ========================================
# OpenClaw Workspace .gitignore
# Comprehensive security rules
# ========================================

# OS and system files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor and IDE files
.vscode/
.idea/
*.swp
*.swo
*~
*.tmp
*.bak

# Environment and secrets
.env
.env.*
.envrc
*.key
*.pem
*.p12
*.crt
secrets*
credentials*
config*
private*

# Temporary and cache files
.cache/
tmp/
temp/
logs/
*.log

# Large binary files
*.zip
*.tar.gz
*.rar
*.jpg
*.png
*.gif
*.pdf
*.exe
*.dmg

# OpenClaw specific (should be in ~/.openclaw/)
openclaw.json
agents/
sessions/

# Backup and archive files
*.backup
*.old
*.archive

# Build artifacts
dist/
build/
node_modules/

# Project directories (may contain their own git repos)
projects/

# Workspace-specific exclusions
memory-core
memory-core.bak
EOF
    
    print_success "Created comprehensive .gitignore file"
}

create_maintenance_scripts() {
    print_header "Creating Maintenance Scripts"
    
    cd "$WORKSPACE_DIR/scripts"
    
    # Daily backup script
    cat > daily-backup.sh << 'EOF'
#!/bin/bash
# Daily backup script for OpenClaw workspace

cd ~/.openclaw/workspace

# Create today's memory file if missing
TODAY=$(date +%Y-%m-%d)
if [ ! -f "memory/$TODAY.md" ]; then
    echo "# Memory for $TODAY" > "memory/$TODAY.md"
    echo "Created memory file for $TODAY" >> "memory/$TODAY.md"
fi

# Stage all changes
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit"
else
    # Commit with timestamp
    git commit -m "Daily backup - $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Push to remote
    if git push origin main; then
        echo "Backup completed successfully"
    else
        echo "Backup failed - check network connection"
        exit 1
    fi
fi

# Health check
openclaw doctor
EOF
    chmod +x daily-backup.sh
    print_success "Created daily-backup.sh"
    
    # Health check script
    cat > health-check.sh << 'EOF'
#!/bin/bash
echo "=== OpenClaw Workspace Health Check ==="
echo "Date: $(date)"
echo

# 1. Workspace integrity
echo "1. Workspace Integrity:"
if [ -d ~/.openclaw/workspace ]; then
    echo "   ✓ Workspace directory exists"
else
    echo "   ✗ Workspace directory missing"
fi

# 2. Core files check
echo "2. Core Files:"
for file in AGENTS.md SOUL.md USER.md IDENTITY.md TOOLS.md; do
    if [ -f ~/.openclaw/workspace/$file ]; then
        echo "   ✓ $file exists"
    else
        echo "   ✗ $file missing"
    fi
done

# 3. Git repository health
echo "3. Git Repository:"
cd ~/.openclaw/workspace
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "   ✓ Git repository initialized"
    
    # Check for uncommitted changes
    if git diff --quiet; then
        echo "   ✓ No uncommitted changes"
    else
        echo "   ⚠ Uncommitted changes present"
    fi
    
    # Check remote connectivity
    if git fetch --dry-run > /dev/null 2>&1; then
        echo "   ✓ Remote repository accessible"
    else
        echo "   ✗ Cannot reach remote repository"
    fi
else
    echo "   ✗ Git repository not initialized"
fi

# 4. Disk space
echo "4. Disk Space:"
WORKSPACE_SIZE=$(du -sh ~/.openclaw/workspace | cut -f1)
echo "   Workspace size: $WORKSPACE_SIZE"

# 5. Recent activity
echo "5. Recent Activity:"
if [ -f ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md ]; then
    echo "   ✓ Today's memory file exists"
else
    echo "   ⚠ Today's memory file not created"
fi

echo "=== Health Check Complete ==="
EOF
    chmod +x health-check.sh
    print_success "Created health-check.sh"
    
    # Security scan script
    cat > security-scan.sh << 'EOF'
#!/bin/bash
echo "Running security scan on workspace..."

cd ~/.openclaw/workspace

# Check for common secret patterns
echo "Scanning for potential secrets..."
grep -r "sk-\|AIza\|password.*=\|secret.*=\|api_key.*=" . --exclude-dir=.git --exclude-dir=scripts 2>/dev/null || true

# Check for large files
echo "Checking for large files (>1MB)..."
find . -type f -size +1M -not -path "./.git/*" -exec ls -lh {} \; 2>/dev/null || true

# Check .gitignore effectiveness
echo "Checking .gitignore coverage..."
git check-ignore -v $(find . -type f) 2>/dev/null | head -10 || true

echo "Security scan complete."
EOF
    chmod +x security-scan.sh
    print_success "Created security-scan.sh"
    
    # Workspace organizer script (self)
    cp "$SCRIPT_DIR/organize-workspace.sh" .
    chmod +x organize-workspace.sh
    print_success "Copied organize-workspace.sh to scripts directory"
}

initialize_git_repository() {
    print_header "Initializing Git Repository"
    
    cd "$WORKSPACE_DIR"
    
    if [ -d ".git" ]; then
        print_success "Git repository already initialized"
        return 0
    fi
    
    # Initialize git repository
    git init
    git branch -M main
    
    # Configure git
    git config user.name "OpenClaw Agent"
    git config user.email "agent@openclaw.ai"
    
    # Add all files
    git add .
    
    # Initial commit
    git commit -m "Initial workspace setup with organization script
    
- Created core bootstrap files (AGENTS.md, SOUL.md, USER.md, IDENTITY.md, TOOLS.md, HEARTBEAT.md, MEMORY.md)
- Set up directory structure (memory/, projects/, scripts/, archive/)
- Added comprehensive .gitignore for security
- Created maintenance scripts (backup, health check, security scan)
- Organized according to OpenClaw best practices"
    
    print_success "Git repository initialized with initial commit"
}

setup_github_repository() {
    print_header "Setting Up GitHub Repository"
    
    cd "$WORKSPACE_DIR"
    
    # Check if remote already exists
    if git remote | grep -q origin; then
        print_success "Git remote 'origin' already configured"
        return 0
    fi
    
    # Ask for GitHub credentials if not provided
    if [ -z "$GITHUB_USER" ]; then
        read -p "GitHub username: " GITHUB_USER
    fi
    
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "GitHub personal access token is required."
        echo "Create one at: https://github.com/settings/tokens"
        echo "Required scopes: repo, workflow"
        read -sp "GitHub token: " GITHUB_TOKEN
        echo
    fi
    
    # Create repository using GitHub API
    print_warning "Creating GitHub repository..."
    
    local repo_data=$(cat <<EOF
{
  "name": "$REPO_NAME",
  "description": "OpenClaw workspace - organized and secured",
  "private": $( [ "$REPO_VISIBILITY" = "private" ] && echo "true" || echo "false" ),
  "auto_init": false
}
EOF
)
    
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "$repo_data")
    
    if echo "$response" | grep -q '"html_url"'; then
        local repo_url=$(echo "$response" | grep '"html_url"' | head -1 | cut -d'"' -f4)
        local ssh_url="git@github.com:$GITHUB_USER/$REPO_NAME.git"
        local https_url="https://github.com/$GITHUB_USER/$REPO_NAME.git"
        
        print_success "Repository created: $repo_url"
        
        # Add remote
        git remote add origin "$https_url"
        
        # Push to GitHub
        print_warning "Pushing to GitHub..."
        git push -u origin main
        
        if [ $? -eq 0 ]; then
            print_success "Successfully pushed to GitHub"
            print_success "Repository URL: $repo_url"
            print_success "Clone URL (HTTPS): $https_url"
            print_success "Clone URL (SSH): $ssh_url"
        else
            print_error "Failed to push to GitHub"
            print_warning "You can manually push with: git push -u origin main"
        fi
    else
        print_error "Failed to create GitHub repository"
        print_warning "Response: $response"
        print_warning "You can manually create a repository and add the remote:"
        print_warning "  git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
        print_warning "  git push -u origin main"
    fi
}

setup_cron_jobs() {
    print_header "Setting Up Automated Backups"
    
    local cron_job="0 18 * * * $WORKSPACE_DIR/scripts/daily-backup.sh >> $WORKSPACE_DIR/backup.log 2>&1"
    
    echo "Recommended cron job for daily backups:"
    echo "  $cron_job"
    echo
    echo "To add this cron job, run:"
    echo "  crontab -e"
    echo "Then add the line above"
    echo
    echo "Or run this command:"
    echo "  (crontab -l 2>/dev/null; echo \"$cron_job\") | crontab -"
    
    print_warning "Cron job not automatically added (requires user confirmation)"
}

create_readme() {
    print_header "Creating README"
    
    cd "$WORKSPACE_DIR"
    
    cat > README.md << 'EOF'
# OpenClaw Workspace

This workspace has been organized using the OpenClaw Workspace Organizer script.

## 📁 Directory Structure

```
workspace/
├── Core Files/
│   ├── AGENTS.md      # Operating instructions
│   ├── SOUL.md        # Agent persona
│   ├── USER.md        # User information
│   ├── IDENTITY.md    # Agent identity
│   ├── TOOLS.md       # Local tools & conventions
│   ├── HEARTBEAT.md   # Daily checklist
│   └── MEMORY.md      # Long-term memory index
├── memory/            # Daily memory files
│   ├── YYYY-MM-DD.md  # Daily logs
│   └── drafts/        # Drafts and working files
├── projects/          # Project directories
├── scripts/           # Maintenance scripts
├── archive/           # Archived files
└── .gitignore         # Security rules
```

## 🚀 Getting Started

1. **Review core files**: Update `USER.md` and `SOUL.md` with your information
2. **Daily routine**: 
   - Read today's memory file: `cat memory/$(date +%Y-%m-%d).md`
   - Run backup: `./scripts/daily-backup.sh`
3. **Maintenance**:
   - Health check: `./scripts/health-check.sh`
   - Security scan: `./scripts/security-scan.sh`

## 🔧 Maintenance Scripts

- `scripts/daily-backup.sh` - Daily git backup
- `scripts/health-check.sh` - Workspace health check
- `scripts/security-scan.sh` - Security scan for secrets
- `scripts/organize-workspace.sh` - Reorganize workspace

## 🔒 Security

- Comprehensive `.gitignore` prevents accidental secret commits
- Security scan script detects potential secrets
- Private GitHub repository recommended
- Never commit credentials or sensitive data

## 📊 Backup Strategy

- Daily automated backups to GitHub
- Local backups in `~/.openclaw/workspace-backups/`
- Git history preserves all changes

## 🆘 Troubleshooting

Run health check: `./scripts/health-check.sh`

Common issues:
- Missing core files: Run organizer script again
- Git push failures: Check network and credentials
- Large files: Review `.gitignore` rules

## 🔄 Reorganization

To reorganize an existing workspace:
```bash
./scripts/organize-workspace.sh
```

## 📚 Documentation

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Workspace Organization Guide](https://docs.openclaw.ai/workspace)

---

*Organized on $(date +%Y-%m-%d) using OpenClaw Workspace Organizer*
EOF
    
    print_success "Created README.md"
}

print_summary() {
    print_header "Organization Complete!"
    
    echo -e "${GREEN}✅ Workspace successfully organized${NC}"
    echo
    echo "📁 Workspace location: $WORKSPACE_DIR"
    echo "📋 Core files created/updated"
    echo "🔒 Security configured with .gitignore"
    echo "🔄 Git repository initialized"
    echo "🔧 Maintenance scripts created"
    echo
    echo "🚀 Next steps:"
    echo "  1. Review and update USER.md with your information"
    echo "  2. Customize SOUL.md with your agent's personality"
    echo "  3. Run health check: ./scripts/health-check.sh"
    echo "  4. Set up daily backups with cron"
    echo
    echo "📚 Documentation created in README.md"
    echo
    echo "To reorganize another workspace:"
    echo "  ./scripts/organize-workspace.sh /path/to/workspace"
}

main() {
    print_header "OpenClaw Workspace Organizer"
    echo "Organizing workspace: $WORKSPACE_DIR"
    echo
    
    # Run all steps
    check_prerequisites
    backup_existing_workspace
    create_directory_structure
    create_core_files
    create_gitignore
    create_maintenance_scripts
    initialize_git_repository
    
    # Ask about GitHub setup
    echo
    read -p "Set up GitHub repository? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_github_repository
    else
        print_warning "Skipping GitHub setup"
        print_warning "You can manually add a remote later with:"
        print_warning "  git remote add origin https://github.com/username/repo.git"
        print_warning "  git push -u origin main"
    fi
    
    create_readme
    setup_cron_jobs
    print_summary
}

# Run main function
main "$@"