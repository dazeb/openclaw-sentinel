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