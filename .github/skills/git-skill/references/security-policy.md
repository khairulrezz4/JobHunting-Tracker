# Access Control & Security Policy

Branch protection, permissions, audit logs, key management.

## Branch Protection

```bash
# Fast-forward merges only
git config --local receive.denyNonFastForwards true

# Prevent deletion of main
git config --local receive.denyDeletes true

# GitHub API: require 2 approvals + signed commits
gh api repos/{owner}/{repo}/branches/main/protection \
  -f 'required_pull_request_reviews={"required_approving_review_count":2}' \
  -f 'require_signed_commits=true'
```

## Access Control

```bash
# List collaborators
gh api repos/{owner}/{repo}/collaborators

# Add user (push access)
gh api -X PUT repos/{owner}/{repo}/collaborators/username -f permission=push

# List SSH keys
gh api user/keys --paginate

# Add SSH key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "user@example.com"
gh api user/keys -f title="DevSecOps" -f key="$(cat ~/.ssh/id_ed25519.pub)"
```

## Audit & Monitoring

```bash
# Repository events (GitHub Enterprise)
gh api repos/{owner}/{repo}/audit-log --paginate

# Push/pull events
gh api repos/{owner}/{repo}/events --paginate \
  --jq '.[] | select(.type | test("PushEvent|PullRequest"))'

# Member changes
gh api repos/{owner}/{repo}/events --paginate \
  --jq '.[] | select(.type == "MemberEvent")'
```

## Secret Scanning

```bash
# Enable (requires Advanced Security)
gh api repos/{owner}/{repo} -f secret_scanning=true

# Enable push protection
gh api repos/{owner}/{repo} -f secret_scanning_push_protection=true

# View alerts
gh api repos/{owner}/{repo}/secret-scanning/alerts --paginate

# Dismiss false positive
gh api repos/{owner}/{repo}/secret-scanning/alerts/{N} -X PATCH \
  -f state=dismissed -f resolution=false_positive
```

## Hooks

```bash
# Pre-receive: require signed commits on main
cat > .git/hooks/pre-receive <<'EOF'
#!/bin/bash
while read oldrev newrev refname; do
  [[ $refname != "refs/heads/main" ]] && continue
  for commit in $(git rev-list $oldrev..$newrev); do
    git verify-commit $commit 2>/dev/null || exit 1
  done
done
EOF

# Update: prevent main deletion
cat > .git/hooks/update <<'EOF'
#!/bin/bash
BRANCH=${1#refs/heads/}
[[ $BRANCH == main && $2 == 0000000000000000000000000000000000000000 ]] && exit 1
EOF

chmod +x .git/hooks/pre-receive .git/hooks/update
```
