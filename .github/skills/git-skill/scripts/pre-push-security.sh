#!/bin/bash
# Pre-push security validation hook
# Install: cp .github/skills/git-skill/scripts/pre-push-security.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push

set -e
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "[*] Pre-push checks: $BRANCH"

# Verify signed commits (main only)
[[ $BRANCH == main ]] && {
  UNSIGNED=$(git log --pretty=format:"%G?" origin/$BRANCH..HEAD | grep -v G | wc -l)
  [ $UNSIGNED -eq 0 ] || { echo "[!] $UNSIGNED unsigned commits"; exit 1; }
}

# Scan for secrets
git diff origin/$BRANCH...HEAD | gitleaks detect --source stdin --exit-code 1 || exit 1

echo "[+] Pre-push checks passed"
