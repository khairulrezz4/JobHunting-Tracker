#!/bin/bash
# Generate audit report
# Run: bash .github/skills/git-skill/scripts/audit-report.sh > audit-report.txt

set -e

echo "=== AUDIT REPORT: $(date) ==="
echo "Repository: $(git config --get remote.origin.url)"
echo ""

echo "--- STATISTICS ---"
echo "Total commits: $(git rev-list --count HEAD)"
echo "Contributors: $(git shortlog -sn --all | wc -l)"
echo "Last commit: $(git log -1 --format='%h %ae %ai')"
echo ""

echo "--- TOP 10 CONTRIBUTORS ---"
git shortlog -sn --all | head -10
echo ""

echo "--- MERGE HISTORY (20 recent) ---"
git log --all --merges --oneline -20
echo ""

echo "--- SIGNATURE STATUS ---"
TOTAL=$(git log --all --oneline | wc -l)
SIGNED=$(git log --all --pretty=format:"%G?" | grep G | wc -l)
echo "Total: $TOTAL | Signed: $SIGNED ($(( (SIGNED * 100) / TOTAL ))%)"
echo ""

echo "--- RECENT CHANGES (30 days) ---"
echo "Commits: $(git log --all --since='30 days ago' --oneline | wc -l)"
echo "Authors: $(git log --all --since='30 days ago' --format='%ae' | sort -u | wc -l)"
echo ""

echo "--- BRANCHES ---"
git branch -v --all | head -15
echo ""

echo "--- TOP 10 MODIFIED FILES ---"
git log --name-only --pretty=format: --all | grep -v '^$' | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== END REPORT ==="
