#!/bin/bash
# Setup gitleaks for secret scanning
# Run: bash .github/skills/git-skill/scripts/setup-gitleaks.sh

set -e
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS:$ARCH" in
  Linux:x86_64) URL="https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks-linux-x64"; DEST="/usr/local/bin/gitleaks" ;;
  Darwin:arm64) URL="https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks-darwin-arm64"; DEST="/usr/local/bin/gitleaks" ;;
  Darwin:*) URL="https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks-darwin-x64"; DEST="/usr/local/bin/gitleaks" ;;
  *) echo "Unsupported: $OS:$ARCH"; exit 1 ;;
esac

echo "[*] Downloading gitleaks..."
curl -sSL "$URL" -o /tmp/gitleaks && chmod +x /tmp/gitleaks
sudo mv /tmp/gitleaks "$DEST"
echo "[+] Installed: $DEST"
gitleaks version

# Setup pre-commit hook
[ -f ".git/hooks/pre-commit" ] || {
  echo "[*] Installing pre-commit hook..."
  cp .github/skills/git-skill/scripts/pre-push-security.sh .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
}

echo "[+] Setup complete!"
