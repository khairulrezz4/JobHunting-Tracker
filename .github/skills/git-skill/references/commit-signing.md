# Commit Signing

Ensure provenance with GPG or SSH keys; verify contributor identity.

## GPG Setup

```bash
# Generate key (RSA 4096-bit)
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format long

# Set default key
git config --global user.signingkey KEY_ID_16_CHAR

# Enable auto-sign
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

## Signing

```bash
# Sign single commit
git commit -S -m "message"

# Sign with specific key
git commit -S --gpg-sign=KEY_ID -m "message"

# Sign multiple commits
git rebase --exec 'git commit --amend --no-edit -n -S' -i HEAD~N

# Verify specific commit
git verify-commit COMMIT_HASH
```

## SSH Signing (GitHub/GitLab)

```bash
# Generate SSH key for signing
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_signing -C "user@example.com"

# Configure Git for SSH
git config --global gpg.format ssh
git config --global user.signingKey ~/.ssh/id_ed25519_signing.pub

# Sign commits
git commit -S -m "message"
```

## Verification & Audit

```bash
# Show all signature statuses (%G?=G(good),B(bad),U(unknown))
git log --all --pretty=format:"%h %G? %ae %s"

# Count signed vs unsigned
git log --pretty=format:"%G?" | grep -c G    # Signed
git log --pretty=format:"%G?" | grep -c ' '  # Unsigned

# List unsigned commits (risk)
git log --all --pretty=format:"%G? %h" | grep "^ "

# Generate compliance report
git log --all --since="2024-01-01" --pretty=format:"%G?|%ae|%ai|%s" > sign-audit.csv
```

## Enforcement

```bash
# Require signed commits locally
git config --local commit.gpgsign true

# Pre-commit hook
cat > .git/hooks/commit-msg <<'EOF'
#!/bin/bash
git verify-commit HEAD 2>/dev/null || { echo "Commit must be signed"; exit 1; }
EOF
chmod +x .git/hooks/commit-msg

# CI/CD block unsigned (GitHub Actions)
- run: |
    UNSIGNED=$(git log --pretty=format:"%G?" origin/main..HEAD | grep -v G | wc -l)
    [ $UNSIGNED -eq 0 ] || exit 1
```

## Key Management

```bash
# Backup key (encrypt!)
gpg --export-secret-keys --armor user@example.com > key.asc
gpg --symmetric key.asc

# Restore
gpg --import key.asc

# Rotate: mark old key as revoked, re-sign repo
gpg --edit-key OLD_KEY_ID  # revkey
git rebase --exec 'git commit --amend --no-edit -n -S' -i --root
```
