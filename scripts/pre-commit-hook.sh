#!/bin/bash
################################################################################
# Pre-commit Hook: Bash Hardening Validation
# Enforces security checks before commits to repository
# Install: cp scripts/pre-commit-hook.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="${SCRIPT_DIR}/.github/skills/bash-hardening/scripts/audit-bash.sh"
VALIDATOR_SCRIPT="${SCRIPT_DIR}/.github/skills/bash-hardening/scripts/validator.sh"

# Initialize exit code
EXIT_CODE=0

echo "================================"
echo "Pre-commit Bash Hardening Check"
echo "================================"

# Find all bash scripts staged for commit
BASH_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(sh|bash)$' || true)

if [[ -z "$BASH_FILES" ]]; then
    echo "✓ No bash scripts to check"
    exit 0
fi

echo "Checking bash scripts: $BASH_FILES"
echo ""

# Check each file
for file in $BASH_FILES; do
    if [[ ! -f "$file" ]]; then
        continue
    fi

    echo "🔍 Auditing: $file"

    # Run audit check (warnings only)
    if [[ -f "$AUDIT_SCRIPT" ]]; then
        if ! bash "$AUDIT_SCRIPT" "$file" 2>/dev/null; then
            echo -e "${YELLOW}⚠ Security warnings found in $file${NC}"
            echo "  Consider fixing before commit"
        fi
    fi

    # Run validator (strict check)
    if [[ -f "$VALIDATOR_SCRIPT" ]]; then
        if ! bash "$VALIDATOR_SCRIPT" "$file" 2>/dev/null; then
            echo -e "${RED}✗ FAILED: Security issues in $file${NC}"
            EXIT_CODE=1
        else
            echo -e "${GREEN}✓ PASSED: $file${NC}"
        fi
    fi

    echo ""
done

if (( EXIT_CODE == 0 )); then
    echo -e "${GREEN}✓ All bash scripts passed security checks${NC}"
else
    echo -e "${RED}✗ Fix security issues before committing${NC}"
    exit 1
fi

# Check for hardcoded secrets
echo ""
echo "🔍 Checking for hardcoded secrets..."

if git diff --cached | grep -iE '(password|api_key|secret|token|api.key)\s*=' | grep -v '^[[:space:]]*#'; then
    echo -e "${RED}✗ Possible hardcoded secrets detected${NC}"
    echo "  Remove secrets and use environment variables instead"
    EXIT_CODE=1
else
    echo -e "${GREEN}✓ No obvious secrets detected${NC}"
fi

exit "$EXIT_CODE"
