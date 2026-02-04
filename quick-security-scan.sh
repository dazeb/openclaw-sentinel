#!/bin/bash
# Quick Security Scan for OpenClaw Workspace
# Focuses on critical threats only
# Version: 1.0.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCAN_DIR="${1:-.}"
THREATS_FOUND=0

echo -e "\n🔍 Quick Security Scan - Critical Threats Only"
echo "Scanning: $SCAN_DIR"
echo

# CRITICAL: API keys and secrets
echo "Checking for exposed secrets..."
CRITICAL_PATTERNS=(
    "sk-[a-zA-Z0-9]{48}"                    # OpenAI keys
    "AIza[0-9A-Za-z\\-_]{35}"               # Google keys
    "gh[pousr]_[A-Za-z0-9_]{36}"           # GitHub tokens
    "-----BEGIN (RSA|DSA|EC) PRIVATE KEY"   # Private keys
)

for pattern in "${CRITICAL_PATTERNS[@]}"; do
    if grep -r -I -E "$pattern" "$SCAN_DIR" --exclude-dir=.git 2>/dev/null | head -2; then
        echo -e "${RED}🚨 CRITICAL: Exposed secret found!${NC}"
        THREATS_FOUND=1
    fi
done

# CRITICAL: Prompt injection attempts
echo -e "\nChecking for prompt injection..."
INJECTION_PATTERNS=(
    "ignore.*previous.*instructions"
    "disregard.*all.*previous"
    "you are now.*role.*play"
    "system.*prompt.*override"
    "DAN|do.*anything.*now"
    "jailbreak.*prompt"
)

for pattern in "${INJECTION_PATTERNS[@]}"; do
    results=$(grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" --include="*.json" 2>/dev/null | head -2)
    if [ -n "$results" ]; then
        echo -e "${RED}🚨 CRITICAL: Potential prompt injection!${NC}"
        echo "$results"
        THREATS_FOUND=1
    fi
done

# WARNING: Dark patterns
echo -e "\nChecking for dark patterns..."
DARK_PATTERNS=(
    "you must|you have to"
    "final opportunity|last chance"
    "auto.*renew.*without.*consent"
    "hidden.*fee|additional.*charge"
    "opt.*out.*difficult"
)

for pattern in "${DARK_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" 2>/dev/null | head -1; then
        echo -e "${YELLOW}⚠ WARNING: Potential dark pattern${NC}"
    fi
done

# Summary
echo -e "\n========================================"
if [ $THREATS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No critical threats found${NC}"
else
    echo -e "${RED}🚨 CRITICAL THREATS DETECTED${NC}"
    echo "Immediate action required!"
fi
echo "========================================"

exit $THREATS_FOUND