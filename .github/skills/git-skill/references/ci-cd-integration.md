# CI/CD Integration

Automate security checks: secret scanning, signature verification, audit logging.

## Local Hooks

**Pre-commit** (scan staged changes):
```bash
git diff --cached | gitleaks detect --source stdin || exit 1
```

**Pre-push** (verify signed, check secrets):
```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
[[ $BRANCH == main ]] && {
  UNSIGNED=$(git log --pretty=format:"%G?" origin/$BRANCH..HEAD | grep -v G | wc -l)
  [ $UNSIGNED -eq 0 ] || exit 1
}
git diff origin/$BRANCH...HEAD | gitleaks detect --source stdin || exit 1
```

## GitHub Actions Workflow

### Comprehensive Security Scan Pipeline
```yaml
# .github/workflows/security.yml
name: Security Checks

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for gitleaks
      
      - name: Gitleaks Secret Scan
        run: |
          curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks-linux-x64 \
            -o gitleaks && chmod +x gitleaks
          ./gitleaks detect --source . --report-path leaks.json || true
          if [ -s leaks.json ]; then
            echo "Secrets detected:"
            cat leaks.json
            exit 1
          fi

  commit-verification:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Verify Signed Commits
        run: |
          UNSIGNED=$(git log --pretty=format:"%G?" ${{ github.event.pull_request.base.sha }}...HEAD | grep -v G | wc -l)
          echo "Unsigned commits: $UNSIGNED"
          if [ $UNSIGNED -gt 0 ]; then
            git log --pretty=format:"%h %G? %ae %s" ${{ github.event.pull_request.base.sha }}...HEAD
            exit 1
          fi

  audit-log:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Generate Audit Trail
        run: |
          git log --all --pretty=format:"%h|%ae|%ai|%s" > audit.csv
          echo "Audit generated:"
          head -20 audit.csv
      
      - name: Upload Audit
        uses: actions/upload-artifact@v3
        with:
          name: a

```yaml
name: Security
on: [push, pull_request]
jobs:
  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with: { fetch-depth: 0 }
      - run: |
          curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks-linux-x64 -o gitleaks && chmod +x gitleaks
          ./gitleaks detect --source . --exit-code 1
  
  signatures:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with: { fetch-depth: 0 }
      - run: |
          UNSIGNED=$(git log --pretty=format:"%G?" origin/main..HEAD | grep -v G | wc -l)
          [ $UNSIGNED -eq 0 ] || exit 1{
        script {
          sh '''
            

```yaml
secret_scan:
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --source . --exit-code 1

verify_sig:
  script:
    - UNSIGNED=$(git log --pretty=format:"%G?" main..HEAD | grep -v G | wc -l)
    - [ $UNSIGNED -eq 0 ] || exit 1

audit:
  script:
    - git log --all --pretty=format:"%h|%ae|%ai|%s" > audit.csv
  artifacts:
    paths: [audit.csv]
set -e

ENVIRONMENT=${1:-production}
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "[*] Pre-deployment security checks for $ENVIRONMENT"

# Only production deployments from main
if [[ "$ENVIRONMENT" == "production" && "$BRANCH" != "main" ]]; then
  echo "[!] Production deployments only from main branch"
  exit 1
fi

# Verify all commits are signed
echo "[*] Verifying signed commits..."
UNSIGNED=$(git log --pretty=format:"%G?" origin/main..HEAD | grep -v G | wc -l)
if [ $UNSIGNED -gt 0 ]; then
  echo "[!

```groovy
pipeline {
  stages {
    stage('Secrets') { steps { sh 'gitleaks detect --source . --exit-code 1' } }
    stage('Signatures') { steps { sh 'UNSIGNED=$(git log --pretty=format:"%G?" origin/main..HEAD | grep -v G | wc -l); [ $UNSIGNED -eq 0 ] || exit 1' } }
    stage('Audit') { steps { sh 'git log --all --pretty=format:"%h|%ae|%ai|%s" > audit.csv' } }
  }
}
```