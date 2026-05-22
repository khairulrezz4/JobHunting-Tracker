#!/bin/bash
# validator.sh - Post-hardening validation
# Verify script meets security baseline before deployment
# Usage: ./validator.sh <script-path>

set -euo pipefail

SCRIPT="${1:-.}"

[[ -f "$SCRIPT" ]] || { echo "❌ File not found: $SCRIPT"; exit 2; }

# Baseline security checks
declare -a CHECKS=(
    'set -euo pipefail'
    '^\s*#!\/bin\/bash'
)

PASSED=0
FAILED=0

for check in "${CHECKS[@]}"; do
    if grep -q "$check" "$SCRIPT"; then
        ((PASSED++))
    else
        echo "❌ Failed: $check"
        ((FAILED++))
    fi
done

# Negative checks (should NOT exist)
declare -a NEG_CHECKS=(
    'eval'
    'source /tmp'
)

for check in "${NEG_CHECKS[@]}"; do
    if grep -q "$check" "$SCRIPT" 2>/dev/null; then
        echo "❌ Security violation: contains '$check'"
        ((FAILED++))
    fi
done

if (( FAILED == 0 )); then
    echo "✅ Validation passed: $SCRIPT"
    exit 0
else
    echo "❌ Validation failed: $FAILED check(s)"
    exit 1
fi
