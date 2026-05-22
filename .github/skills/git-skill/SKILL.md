---
name: git-skill
description: 'DevSecOps Git: secret scanning, credential mgmt, audit logging, commit signing, CI/CD integration. Use when scanning credentials, auditing history, managing access, enforcing signatures.'
user-invocable: true
---

# DevSecOps Git Bash

## Commands

| Task | Command |
|------|---------|
| Scan secrets (staged) | `git diff --cached \| gitleaks detect --source stdin` |
| Audit log (CSV) | `git log --all --pretty=format:"%h\|%ae\|%ai\|%s" > audit.csv` |
| Verify signatures | `git log --all --pretty=format:"%h %G? %ae"` |
| Sign commit | `git commit -S -m "msg"` |
| Setup GPG | `git config --global user.signingkey KEY_ID` |
| Auto-sign | `git config --global commit.gpgsign true` |
| Require FF merge | `git config --local receive.denyNonFastForwards true` |

## Guides

- [Secret Scanning](./references/secret-scanning.md) — Detect hardcoded keys, tokens
- [Audit Logging](./references/audit-logging.md) — Track changes, compliance
- [Commit Signing](./references/commit-signing.md) — GPG/SSH setup
- [Access Control](./references/security-policy.md) — Branch protection
- [CI/CD Checks](./references/ci-cd-integration.md) — Pipeline automation

## Quick Start

```bash
# Pre-commit security
git diff --cached | gitleaks detect --source stdin
git commit -S -m "message"

# Recent changes audit
git log --all --since="30 days ago" --pretty=format:"%h|%ae|%ai|%s"

# Verify signed commits
git log --all --pretty=format:"%G? %h %s" main

# Install pre-push hook
cp .github/skills/git-skill/scripts/pre-push-security.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push
```
