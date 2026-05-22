# Secret Scanning

Detect hardcoded secrets, API keys, tokens, private keys before commits reach main.

## Scanning

```bash
# Before commit (staged changes)
git diff --cached | gitleaks detect --source stdin

# Scan all files
gitleaks detect --source . --report-path leaks.json

# Search patterns (API keys, private keys, AWS creds)
git log -p | grep -E '(AKIA|ghp_|BEGIN RSA|aws_access_key)' -i
```

## Setup

```bash
# Pre-commit hook
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/bash
git diff --cached | gitleaks detect --source stdin || exit 1
EOF
chmod +x .git/hooks/pre-commit

# CI/CD: GitHub Actions
- name: Secret Scan
  run: gitleaks detect --source . --exit-code 1
```

## Remediation

```bash
# Remove secret from history
git filter-repo --invert-paths --path secret-file.txt

# Force push (after team coordination)
git push --force-with-lease

# Rotate exposed credentials immediately
```
