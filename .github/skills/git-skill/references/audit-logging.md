# Audit Logging

Track all changes for compliance, accountability, and forensic analysis.

## Export Logs

```bash
# CSV format: hash|author|date|message
git log --all --pretty=format:"%h|%ae|%ai|%s" > audit.csv

# With changed files
git log --all --name-status --pretty=format:"%h|%ae|%ai|%s" > audit-files.csv

# JSON format
git log --all --pretty=format:'{"hash":"%h","author":"%ae","date":"%ai"}' | jq -s . > audit.json
```

## Track Changes

```bash
# File history
git log --all --oneline -- path/to/file

# Author commits
git log --all --author="user@example.com" --oneline

# Date range
git log --all --since="2024-01-01" --until="2024-12-31" --oneline

# Sensitive files
git log --all -- "**/*.key" "**/*.secret"
```

## Compliance Reports

```bash
# Commits by author (ranked)
git log --all --format='%ae' | sort | uniq -c | sort -rn

# Merge history
git log --all --merges --pretty=format:"%h %ae %ai %s"

# Signed commits (%G?=G(good),B(bad),U(unknown))
git log --all --pretty=format:"%h %G? %ae"

# Unsigned commits (compliance risk)
git log --all --pretty=format:"%G? %h" | grep "^ "

# Force pushes (dangerous)
git reflog | grep -i "reset\|force"
```

## Archive & Retention

```bash
# Enable reflog preservation
git config core.logallrefupdates true

# Archive for compliance (7+ years)
tar -czf audit-$(date +%Y%m%d).tar.gz .git/logs/

# Integrity check
sha256sum audit.csv > audit.csv.sha256
```
