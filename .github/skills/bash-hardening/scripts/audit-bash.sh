#!/bin/bash
# audit-bash.sh - Security audit for bash scripts
# DevSecOps shift-left validation
# Usage: ./audit-bash.sh <script-path>

set -euo pipefail

SCRIPT="${1:-.}"
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

[[ -f "$SCRIPT" ]] || { echo "❌ File not found: $SCRIPT"; exit 2; }

echo "🔍 Auditing: $SCRIPT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ISSUES=0

# Check 1: set -euo pipefail
if ! grep -q "set -euo pipefail" "$SCRIPT"; then
    echo -e "${RED}✗ Missing 'set -euo pipefail'${NC}"
    ((ISSUES++))
else
    echo -e "${GREEN}✓ set -euo pipefail${NC}"
fi

# Check 2: Unquoted variables
if grep -E '\$[a-zA-Z_][a-zA-Z0-9_]*[^"]' "$SCRIPT" | grep -v '^[[:space:]]*#' | head -3 | grep -q .; then
    echo -e "${YELLOW}⚠ Unquoted variables detected (use \"\$VAR\")${NC}"
    grep -n '\$[a-zA-Z_]' "$SCRIPT" | grep -v '^[[:space:]]*#' | head -2 | sed "s/^/${YELLOW}  /;s/$/${NC}/"
    ((ISSUES++))
else
    echo -e "${GREEN}✓ Variables properly quoted${NC}"
fi

# Check 3: Shellcheck patterns (if available)
if command -v shellcheck &>/dev/null; then
    if ! shellcheck -x "$SCRIPT" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Shellcheck issues found${NC}"
        ((ISSUES++))
    else
        echo -e "${GREEN}✓ Shellcheck passed${NC}"
    fi
fi

# Check 4: Credential patterns
if grep -iE '(password|api_key|secret|token).*=' "$SCRIPT" | grep -v '^[[:space:]]*#' | head -2 | grep -q .; then
    echo -e "${RED}✗ Possible hardcoded credentials${NC}"
    grep -in 'password\|api_key\|secret\|token' "$SCRIPT" | grep -v '^[[:space:]]*#' | head -2 | sed "s/^/${RED}  /;s/$/${NC}/"
    ((ISSUES++))
else
    echo -e "${GREEN}✓ No obvious credential exposure${NC}"
fi

# Check 5: eval / dangerous patterns
if grep -E '(eval|source)' "$SCRIPT" | grep -v '^[[:space:]]*#' | head -2 | grep -q .; then
    echo -e "${YELLOW}⚠ Dangerous patterns (eval/source) detected${NC}"
    ((ISSUES++))
else
    echo -e "${GREEN}✓ No eval/source patterns${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if (( ISSUES == 0 )); then
    echo -e "${GREEN}✅ All checks passed${NC}"
    exit 0
else
    echo -e "${RED}⚠ $ISSUES issue(s) found${NC}"
    exit 1
fi
