#!/bin/bash
# Advanced OpenClaw Security Scanner
# Checks for dark patterns, prompt injection, and security vulnerabilities
# Version: 2.0.0 - AI Security Focused

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCAN_DIR="${1:-.}"
REPORT_FILE="${2:-security-report-$(date +%Y%m%d-%H%M%S).txt}"
VERBOSE="${3:-false}"
THREAT_LEVEL=0  # 0=clean, 1=warning, 2=critical

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  OPENCLAW ADVANCED SECURITY SCANNER${NC}"
    echo -e "${BLUE}  AI Security & Dark Pattern Detection${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${CYAN}Scanning: $SCAN_DIR${NC}"
    echo -e "${CYAN}Report: $REPORT_FILE${NC}"
    echo -e "${CYAN}Timestamp: $(date)${NC}"
    echo
}

print_section() {
    echo -e "\n${PURPLE}=== $1 ===${NC}"
}

print_critical() {
    echo -e "${RED}🚨 CRITICAL: $1${NC}"
    THREAT_LEVEL=$((THREAT_LEVEL > 1 ? THREAT_LEVEL : 2))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    THREAT_LEVEL=$((THREAT_LEVEL > 0 ? THREAT_LEVEL : 1))
}

print_info() {
    echo -e "${GREEN}ℹ INFO: $1${NC}"
}

print_debug() {
    if [ "$VERBOSE" = "true" ]; then
        echo -e "${CYAN}🔍 DEBUG: $1${NC}"
    fi
}

log_finding() {
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] $1" >> "$REPORT_FILE"
}

# Initialize report
echo "OpenClaw Security Scan Report" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "Directory: $SCAN_DIR" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"

print_header

# ============================================================================
# PHASE 1: BASIC SECURITY CHECKS
# ============================================================================
print_section "PHASE 1: Basic Security Checks"

# Check for common secrets
print_info "Scanning for exposed secrets..."
SECRET_PATTERNS=(
    "sk-[a-zA-Z0-9]{48}"                    # OpenAI API keys
    "AIza[0-9A-Za-z\\-_]{35}"               # Google API keys
    "gh[pousr]_[A-Za-z0-9_]{36}"           # GitHub tokens
    "xox[baprs]-[0-9a-zA-Z]{10,48}"        # Slack tokens
    "-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----"  # Private keys
    "password.*=.*['\"].{6,}['\"]"         # Passwords in config
    "api[_-]?key.*=.*['\"].{10,}['\"]"     # API keys
    "secret.*=.*['\"].{6,}['\"]"           # Generic secrets
    "token.*=.*['\"].{10,}['\"]"           # Tokens
)

for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -r -I -E "$pattern" "$SCAN_DIR" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build 2>/dev/null | head -5; then
        print_critical "Potential secret found with pattern: $pattern"
        log_finding "CRITICAL: Potential secret pattern detected: $pattern"
    fi
done

# Check file permissions
print_info "Checking file permissions..."
find "$SCAN_DIR" -type f -name "*.sh" -o -name "*.py" -o -name "*.js" | while read file; do
    if [ -x "$file" ] && [[ "$file" != *"/scripts/"* ]] && [[ "$file" != *"/bin/"* ]]; then
        print_warning "Executable file in non-script directory: $file"
        log_finding "WARNING: Executable file in non-script directory: $file"
    fi
done

# ============================================================================
# PHASE 2: DARK PATTERN DETECTION
# ============================================================================
print_section "PHASE 2: Dark Pattern Detection"

# Psychological manipulation patterns
print_info "Scanning for psychological manipulation patterns..."
DARK_PATTERNS=(
    "you must|you have to|you need to"                     # Forced action
    "this is your last chance|final opportunity"           # False urgency
    "everyone is doing it|join the crowd"                  # Social proof abuse
    "limited time only|act now"                            # Time pressure
    "free.*but.*paid|free.*then.*charge"                   # Bait and switch
    "hidden.*fee|additional.*charge"                       # Hidden costs
    "auto.*renew|automatic.*billing"                       # Forced continuity
    "opt.*out.*difficult|hard.*to.*cancel"                 # Roach motel
    "confirm.*shipping.*add.*product"                      # Sneak into basket
    "disguised.*ad|ad.*disguised.*as.*content"             # Disguised ads
)

for pattern in "${DARK_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" --include="*.json" 2>/dev/null | head -3; then
        print_warning "Potential dark pattern detected: $pattern"
        log_finding "WARNING: Potential dark pattern: $pattern"
    fi
done

# Deceptive UI/UX patterns
print_info "Checking for deceptive UI patterns..."
DECEPTIVE_PATTERNS=(
    "pre.*selected.*opt.*in"                # Preselection
    "trick.*question|confusing.*wording"    # Confirmshaming
    "hidden.*checkbox|invisible.*option"    # Hidden options
    "forced.*action|no.*alternative"        # Forced action
    "fake.*urgency|false.*deadline"         # Fake countdowns
    "misleading.*button|deceptive.*label"   # Misleading buttons
)

for pattern in "${DECEPTIVE_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.js" --include="*.html" 2>/dev/null | head -3; then
        print_warning "Potential deceptive UI pattern: $pattern"
        log_finding "WARNING: Potential deceptive UI pattern: $pattern"
    fi
done

# ============================================================================
# PHASE 3: PROMPT INJECTION DETECTION
# ============================================================================
print_section "PHASE 3: Prompt Injection Detection"

# Direct prompt injection attempts
print_info "Scanning for direct prompt injection patterns..."
PROMPT_INJECTION_PATTERNS=(
    "ignore.*previous.*instructions"        # Ignore previous instructions
    "disregard.*all.*previous"              # Disregard previous
    "you are now.*role.*play"               # Role switching
    "system.*prompt.*override"              # System prompt override
    "forget.*your.*instructions"            # Forget instructions
    "new.*instructions.*follow"             # New instructions
    "disobey.*your.*programming"            # Disobey programming
    "break.*character|break.*role"          # Break character
    "output.*as.*raw.*text"                 # Raw text output
    "bypass.*safety|bypass.*filter"         # Bypass safety
    "ignore.*ethical.*guidelines"           # Ignore ethics
    "you are no longer.*assistant"          # Identity switching
    "pretend.*to.*be"                       # Pretend to be
    "act.*as.*if"                           # Act as if
    "simulate.*being"                       # Simulate being
)

for pattern in "${PROMPT_INJECTION_PATTERNS[@]}"; do
    results=$(grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" --include="*.json" --include="*.py" --include="*.js" 2>/dev/null | head -5)
    if [ -n "$results" ]; then
        print_critical "POTENTIAL PROMPT INJECTION DETECTED: $pattern"
        echo "$results"
        log_finding "CRITICAL: Potential prompt injection: $pattern"
        log_finding "Found: $results"
    fi
done

# Indirect injection techniques
print_info "Scanning for indirect injection techniques..."
INDIRECT_INJECTION_PATTERNS=(
    "chain.*of.*thought.*override"          # Chain of thought hijacking
    "multi.*step.*bypass"                   # Multi-step bypass
    "context.*window.*poisoning"            # Context poisoning
    "memory.*injection"                     # Memory injection
    "few.*shot.*hijacking"                  # Few-shot hijacking
    "instruction.*embedding"                # Instruction embedding
    "delimiter.*bypass"                     # Delimiter bypass
    "encoding.*trick"                       # Encoding tricks
    "unicode.*exploit"                      # Unicode exploits
    "whitespace.*injection"                 # Whitespace injection
)

for pattern in "${INDIRECT_INJECTION_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" 2>/dev/null | head -3; then
        print_warning "Potential indirect injection technique: $pattern"
        log_finding "WARNING: Potential indirect injection: $pattern"
    fi
done

# Jailbreak patterns
print_info "Scanning for jailbreak patterns..."
JAILBREAK_PATTERNS=(
    "DAN|do.*anything.*now"                 # DAN jailbreak
    "AIM|always.*intelligent.*machine"      # AIM jailbreak
    "STAN|strive.*to.*avoid.*norms"         # STAN jailbreak
    "DUDE|do.*ultimately.*everything"       # DUDE jailbreak
    "jailbreak.*prompt"                     # Jailbreak prompts
    "character.*override"                   # Character override
    "mode.*switch"                          # Mode switching
    "developer.*mode"                       # Developer mode
    "sudo.*mode"                            # Sudo mode
    "unfiltered.*mode"                      # Unfiltered mode
)

for pattern in "${JAILBREAK_PATTERNS[@]}"; do
    results=$(grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" 2>/dev/null | head -3)
    if [ -n "$results" ]; then
        print_critical "POTENTIAL JAILBREAK ATTEMPT: $pattern"
        echo "$results"
        log_finding "CRITICAL: Potential jailbreak attempt: $pattern"
    fi
done

# ============================================================================
# PHASE 4: AI-SPECIFIC THREATS
# ============================================================================
print_section "PHASE 4: AI-Specific Threat Detection"

# Model manipulation
print_info "Checking for model manipulation attempts..."
MODEL_MANIPULATION_PATTERNS=(
    "temperature.*[0-9]\.[0-9]{2}"          # Temperature manipulation
    "top.*p.*[0-9]\.[0-9]{2}"               # Top-p manipulation
    "frequency.*penalty.*[-]?[0-9]\.[0-9]"  # Frequency penalty
    "presence.*penalty.*[-]?[0-9]\.[0-9]"   # Presence penalty
    "max.*tokens.*[0-9]{4,}"                # Excessive token limits
    "stop.*sequence.*bypass"                # Stop sequence bypass
)

for pattern in "${MODEL_MANIPULATION_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.py" --include="*.js" --include="*.json" 2>/dev/null | head -3; then
        print_warning "Potential model parameter manipulation: $pattern"
        log_finding "WARNING: Model parameter manipulation: $pattern"
    fi
done

# Training data poisoning
print_info "Scanning for training data poisoning indicators..."
TRAINING_POISONING_PATTERNS=(
    "adversarial.*example"                  # Adversarial examples
    "data.*poisoning"                       # Data poisoning
    "backdoor.*trigger"                     # Backdoor triggers
    "model.*stealing"                       # Model stealing
    "membership.*inference"                 # Membership inference
    "model.*inversion"                      # Model inversion
    "property.*inference"                   # Property inference
)

for pattern in "${TRAINING_POISONING_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.md" --include="*.txt" 2>/dev/null | head -3; then
        print_warning "Potential training data poisoning indicator: $pattern"
        log_finding "WARNING: Training data poisoning indicator: $pattern"
    fi
done

# ============================================================================
# PHASE 5: CODE INJECTION & MALWARE
# ============================================================================
print_section "PHASE 5: Code Injection & Malware Detection"

# Shell injection patterns
print_info "Scanning for shell injection patterns..."
SHELL_INJECTION_PATTERNS=(
    "system\("                              # System calls
    "exec\("                                # Exec calls
    "popen\("                               # Popen calls
    "subprocess\."                          # Subprocess module
    "eval\("                                # Eval calls
    "exec.*dynamic.*code"                   # Dynamic code execution
    "unsafe.*deserialization"               # Unsafe deserialization
    "pickle.*load"                          # Pickle loading
    "yaml.*load"                            # YAML loading
)

for pattern in "${SHELL_INJECTION_PATTERNS[@]}"; do
    if grep -r -E "$pattern" "$SCAN_DIR" --include="*.py" --include="*.js" --include="*.php" 2>/dev/null | head -3; then
        print_warning "Potential code injection vector: $pattern"
        log_finding "WARNING: Code injection vector: $pattern"
    fi
done

# Web security issues
print_info "Checking for web security issues..."
WEB_SECURITY_PATTERNS=(
    "innerHTML.*unsafe"                     # Unsafe innerHTML
    "document\.write"                       # Document.write
    "eval.*JSON"                            # Eval with JSON
    "setTimeout.*string"                    # String setTimeout
    "setInterval.*string"                   # String setInterval
    "Function.*constructor"                 # Function constructor
)

for pattern in "${WEB_SECURITY_PATTERNS[@]}"; do
    if grep -r -E "$pattern" "$SCAN_DIR" --include="*.js" --include="*.html" 2>/dev/null | head -3; then
        print_warning "Potential web security issue: $pattern"
        log_finding "WARNING: Web security issue: $pattern"
    fi
done

# ============================================================================
# PHASE 6: DATA EXFILTRATION
# ============================================================================
print_section "PHASE 6: Data Exfiltration Detection"

# Data exfiltration patterns
print_info "Scanning for data exfiltration patterns..."
EXFILTRATION_PATTERNS=(
    "fetch.*http"                           # HTTP requests
    "XMLHttpRequest"                        # XHR requests
    "websocket.*send"                       # WebSocket sending
    "postMessage"                           # PostMessage API
    "beacon.*send"                          # Beacon API
    "external.*api.*call"                   # External API calls
    "upload.*to.*server"                    # Server uploads
    "exfiltrate.*data"                      # Direct exfiltration
    "send.*to.*external"                    # External sending
)

for pattern in "${EXFILTRATION_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" "$SCAN_DIR" --include="*.js" --include="*.py" 2>/dev/null | head -3; then
        print_warning "Potential data exfiltration: $pattern"
        log_finding "WARNING: Potential data exfiltration: $pattern"
    fi
done

# ============================================================================
# PHASE 7: FILE SYSTEM ANALYSIS
# ============================================================================
print_section "PHASE 7: File System Analysis"

# Large files
print_info "Checking for large files (>10MB)..."
find "$SCAN_DIR" -type f -size +10M -not -path "*/\.git/*" -not -path "*/node_modules/*" -exec ls -lh {} \; 2>/dev/null | while read line; do
    if [ -n "$line" ]; then
        print_warning "Large file detected: $line"
        log_finding "WARNING: Large file: $line"
    fi
done

# Suspicious file types
print_info "Checking for suspicious file types..."
SUSPICIOUS_EXTENSIONS=(
    "\.exe$" "\.dll$" "\.bat$" "\.cmd$" "\.vbs$" "\.ps1$"
    "\.sh$" "\.py$" "\.js$" "\.php$" "\.pl$" "\.rb$"
)

for ext in "${SUSPICIOUS_EXTENSIONS[@]}"; do
    find "$SCAN_DIR" -type f -name "*$ext" -not -path "*/\.git/*" -not -path "*/scripts/*" -not -path "*/bin/*" 2>/dev/null | head -3 | while read file; do
        if [ -n "$file" ]; then
            print_warning "Executable file in non-standard location: $file"
            log_finding "WARNING: Executable in non-standard location: $file"
        fi
    done
done

# ============================================================================
# PHASE 8: CONFIGURATION CHECKS
# ============================================================================
print_section "PHASE 8: Configuration Security"

# Check for insecure configurations
print_info "Checking configuration files..."
if [ -f "$SCAN_DIR/openclaw.json" ]; then
    print_info "Analyzing openclaw.json..."
    
    # Check for insecure settings
    INSECURE_SETTINGS=(
        '"sandbox":.*false'
        '"mode":.*"off"'
        '"workspaceAccess":.*"rw"'
        '"allowFrom":.*\[\]'
        '"enabled":.*true.*browser'
    )
    
    for setting in "${INSECURE_SETTINGS[@]}"; do
        if grep -E "$setting" "$SCAN_DIR/openclaw.json" 2>/dev/null; then
            print_warning "Potentially insecure configuration: $setting"
            log_finding "WARNING: Insecure configuration: $setting"
        fi
    done
fi

# ============================================================================
# FINAL REPORT
# ============================================================================
print_section "SCAN COMPLETE"

# Generate summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}          SECURITY SCAN SUMMARY          ${NC}"
echo -e "${BLUE}========================================${NC}"

case $THREAT_LEVEL in
    0)
        echo -e "${GREEN}✅ SECURITY STATUS: CLEAN${NC}"
        echo "No critical threats detected."
        ;;
    1)
        echo -e "${YELLOW}⚠ SECURITY STATUS: WARNING${NC}"
        echo "Some warnings detected. Review findings."
        ;;
    2)
        echo -e "${RED}🚨 SECURITY STATUS: CRITICAL${NC}"
        echo "CRITICAL THREATS DETECTED! Immediate action required."
        ;;
esac

echo -e "\n${CYAN}📄 Detailed report saved to: $REPORT_FILE${NC}"
echo -e "${CYAN}🔍 Total files scanned: $(find "$SCAN_DIR" -type f | wc -l)${NC}"

# Add summary to report
echo "" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "SCAN SUMMARY" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "Threat Level: $THREAT_LEVEL" >> "$REPORT_FILE"
echo "Status: $(case $THREAT_LEVEL in 0) echo "CLEAN";; 1) echo "WARNING";; 2) echo "CRITICAL";; esac)" >> "$REPORT_FILE"
echo "Scan completed: $(date)" >> "$REPORT_FILE"

# Recommendations
echo -e "\n${PURPLE}🔒 RECOMMENDATIONS:${NC}"
if [ $THREAT_LEVEL -ge 1 ]; then
    echo "1. Review all warnings in the report"
    echo "2. Remove any exposed secrets immediately"
    echo "3. Audit prompt injection findings"
    echo "4. Review dark pattern usage"
    echo "5. Update configurations if needed"
fi

if [ $THREAT_LEVEL -eq 2 ]; then
    echo -e "\n${RED}🚨 IMMEDIATE ACTIONS REQUIRED:${NC}"
    echo "1. ISOLATE affected files"
    echo "2. REVOKE any exposed credentials"
    echo "3. AUDIT all AI interactions"
    echo "4. UPDATE security configurations"
    echo "5. MONITOR for suspicious activity"
fi

echo -e "\n${GREEN}✅ Security scan completed at $(date)${NC}"

# Exit with appropriate code
if [ $THREAT_LEVEL -eq 2 ]; then
    exit 2
elif [ $THREAT_LEVEL -eq 1 ]; then
    exit 1
else
    exit 0
fi