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