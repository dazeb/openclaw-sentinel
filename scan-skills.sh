#!/bin/bash
#
# Skill Scanner Wrapper Script
# Makes it easy to run security scans on OpenClaw skills
#

set -euo pipefail

# Configuration
VENV_BIN="$HOME/.openclaw/workspace/venv/bin"
SKILLS_DIR="$HOME/.openclaw/workspace/skills"
SCANNER="${VENV_BIN}/skill-scanner"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
usage() {
    cat <<EOF
Skill Scanner - Security scanner for OpenClaw skills

Usage:
  $(basename "$0") [command] [options]

Commands:
  all               Scan all skills (default)
  single <name>     Scan a specific skill by name
  critical          Show only critical/high severity findings
  report            Generate detailed JSON report
  help              Show this help message

Options:
  --recursive       Scan subdirectories recursively (default for 'all')
  --format FORMAT   Output format: summary, json, detailed (default: summary)
  --behavioral      Enable behavioral analysis (dataflow tracking)
  --llm             Enable LLM-based analysis (experimental)

Examples:
  $(basename "$0")                    # Scan all skills with summary output
  $(basename "$0") single github      # Scan just the github skill
  $(basename "$0") critical           # Show critical/high findings only
  $(basename "$0") all --format json  # JSON output for all skills
  $(basename "$0") all --behavioral   # Deep scan with behavioral analysis

EOF
}

# Check if skill-scanner is installed
check_scanner() {
    if [[ ! -f "$SCANNER" ]]; then
        echo -e "${RED}Error: skill-scanner not found${NC}"
        echo "Install with: $VENV_BIN/pip install git+https://github.com/cisco-ai-defense/skill-scanner.git"
        exit 1
    fi
}

# Scan all skills
scan_all() {
    local format="${1:-summary}"
    local extra_flags="${2:-}"
    
    echo -e "${BLUE}Scanning all skills in $SKILLS_DIR${NC}"
    "$SCANNER" scan-all "$SKILLS_DIR" --recursive --format "$format" $extra_flags
}

# Scan a single skill
scan_single() {
    local skill_name="$1"
    local format="${2:-summary}"
    local extra_flags="${3:-}"
    
    local skill_path="$SKILLS_DIR/$skill_name"
    
    if [[ ! -d "$skill_path" ]]; then
        echo -e "${RED}Error: Skill not found at $skill_path${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Scanning skill: $skill_name${NC}"
    "$SCANNER" scan "$skill_path" --format "$format" $extra_flags
}

# Show only critical/high findings
scan_critical() {
    echo -e "${BLUE}Scanning for critical/high severity issues...${NC}\n"
    
    # Get JSON output and filter for critical/high
    local json_output
    json_output=$("$SCANNER" scan-all "$SKILLS_DIR" --recursive --format json 2>/dev/null)
    
    # Parse and display critical/high findings
    echo "$json_output" | python3 -c '
import sys, json

try:
    content = sys.stdin.read()
    start = content.find("{")
    end = content.rfind("}")
    if start == -1 or end == -1: sys.exit(0)
    
    data = json.loads(content[start:end+1])
    scans = data.get("results", [])
    
    total_critical = 0
    total_high = 0
    
    for scan in scans:
        skill_name = scan.get("skill_name", "Unknown")
        findings = scan.get("findings", [])
        
        critical_findings = [f for f in findings if f.get("severity") == "CRITICAL"]
        high_findings = [f for f in findings if f.get("severity") == "HIGH"]
        
        if critical_findings or high_findings:
            sep = "=" * 60
            print(f"\n{sep}")
            print(f"Skill: {skill_name}")
            print(f"{sep}")
            
            for finding in critical_findings + high_findings:
                if finding["severity"] == "CRITICAL": total_critical += 1
                else: total_high += 1
                
                print(f"\n[{finding['severity']}] {finding['title']}")
                print(f"Category: {finding['category']}")
                if finding.get("file_path"):
                    print(f"File: {finding['file_path']}")
                print(f"Description: {finding['description']}")
                print(f"Remediation: {finding['remediation']}")
    
    sep = "=" * 60
    print(f"\n{sep}")
    print(f"Summary: {total_critical} CRITICAL, {total_high} HIGH")
    print(f"{sep}")
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
'
}

# Main
check_scanner

# Parse command
CMD="${1:-all}"
shift || true

case "$CMD" in
    all)
        FORMAT="summary"
        EXTRA_FLAGS=""
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --format)
                    FORMAT="$2"
                    shift 2
                    ;;
                --behavioral)
                    EXTRA_FLAGS="$EXTRA_FLAGS --use-behavioral"
                    shift
                    ;;
                --llm)
                    EXTRA_FLAGS="$EXTRA_FLAGS --use-llm"
                    shift
                    ;;
                *)
                    echo -e "${RED}Unknown option: $1${NC}"
                    usage
                    exit 1
                    ;;
            esac
        done
        scan_all "$FORMAT" "$EXTRA_FLAGS"
        ;;
    
    single)
        if [[ $# -lt 1 ]]; then
            echo -e "${RED}Error: skill name required${NC}"
            usage
            exit 1
        fi
        SKILL_NAME="$1"
        shift
        
        FORMAT="summary"
        EXTRA_FLAGS=""
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --format)
                    FORMAT="$2"
                    shift 2
                    ;;
                --behavioral)
                    EXTRA_FLAGS="$EXTRA_FLAGS --use-behavioral"
                    shift
                    ;;
                --llm)
                    EXTRA_FLAGS="$EXTRA_FLAGS --use-llm"
                    shift
                    ;;
                *)
                    echo -e "${RED}Unknown option: $1${NC}"
                    usage
                    exit 1
                    ;;
            esac
        done
        scan_single "$SKILL_NAME" "$FORMAT" "$EXTRA_FLAGS"
        ;;
    
    critical)
        scan_critical
        ;;
    
    report)
        echo -e "${BLUE}Generating detailed JSON report...${NC}"
        OUTPUT_FILE="skill-scan-report-$(date +%Y%m%d-%H%M%S).json"
        "$SCANNER" scan-all "$SKILLS_DIR" --recursive --format json > "$OUTPUT_FILE"
        echo -e "${GREEN}Report saved to: $OUTPUT_FILE${NC}"
        ;;
    
    help|--help|-h)
        usage
        ;;
    
    *)
        echo -e "${RED}Unknown command: $CMD${NC}\n"
        usage
        exit 1
        ;;
esac
