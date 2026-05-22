# Bash Anti-Patterns to Avoid

## 1. Unquoted Variables (Command Injection Risk)

❌ **AVOID**:
```bash
FILENAME=$1
rm -rf $FILENAME/*    # If $FILENAME contains spaces or wildcards: disaster
ls $DIR               # Word splitting causes unexpected behavior
```

✅ **CORRECT**:
```bash
FILENAME="$1"
rm -rf "$FILENAME"/*
ls "$DIR"
```

**Risk**: Argument injection, globbing expansion, data loss.

---

## 2. Missing `set -euo pipefail`

❌ **AVOID**:
```bash
#!/bin/bash
cd /nonexistent
rm -rf *  # Runs in current dir, not /nonexistent!

status=$(command1 | command2)  # Pipeline error ignored
```

✅ **CORRECT**:
```bash
#!/bin/bash
set -euo pipefail
cd /nonexistent  # Script exits here, prevents disaster
status=$(command1 | command2)  # Errors propagate
```

**Risk**: Script continues after errors, data corruption, silent failures.

---

## 3. Hardcoded Credentials

❌ **AVOID**:
```bash
#!/bin/bash
API_KEY="sk-abc123xyz"
PASSWORD="MyPassword123"
SLACK_WEBHOOK="https://hooks.slack.com/services/..."
curl -H "Authorization: Bearer $API_KEY" https://api.example.com
```

✅ **CORRECT**:
```bash
#!/bin/bash
API_KEY="${API_KEY:?API_KEY not set}"  # From environment
[[ -f ~/.config/app ]] && source ~/.config/app  # Load from secure file
curl -H "Authorization: Bearer $API_KEY" https://api.example.com
```

**Risk**: Credential exposure in version control, accidental secret leaks.

---

## 4. Using `eval` or `source` with User Input

❌ **AVOID**:
```bash
#!/bin/bash
eval "$USER_INPUT"           # Arbitrary command execution
source "/tmp/$FILENAME"      # Untrusted file sourcing
```

✅ **CORRECT**:
```bash
#!/bin/bash
# Whitelist allowed actions
case "$ACTION" in
    start|stop|restart) systemctl "$ACTION" myapp ;;
    *) echo "Invalid action" >&2; exit 1 ;;
esac
```

**Risk**: Remote code execution, privilege escalation.

---

## 5. Temporary Files Without Security

❌ **AVOID**:
```bash
#!/bin/bash
TMPFILE="/tmp/output.txt"           # Predictable, world-writable
echo "$DATA" > "$TMPFILE"
process_file "$TMPFILE"
rm "$TMPFILE"
```

✅ **CORRECT**:
```bash
#!/bin/bash
TMPFILE=$(mktemp)
trap "rm -f '$TMPFILE'" EXIT  # Auto-cleanup
echo "$DATA" > "$TMPFILE"
process_file "$TMPFILE"
```

**Risk**: Race conditions, temporary file hijacking, sensitive data exposure.

---

## 6. No Error Handling

❌ **AVOID**:
```bash
#!/bin/bash
cd /app
docker build .
docker push myimage:latest
kubectl apply -f deploy.yaml
```

✅ **CORRECT**:
```bash
#!/bin/bash
set -euo pipefail

cd /app || { echo "Failed to cd"; exit 1; }
docker build . || { echo "Build failed"; exit 1; }
docker push myimage:latest || { echo "Push failed"; exit 1; }
kubectl apply -f deploy.yaml || { echo "Deploy failed"; exit 1; }
```

**Risk**: Partial deployments, inconsistent state, undetected failures.

---

## 7. Unvalidated User Input

❌ **AVOID**:
```bash
#!/bin/bash
USERNAME="$1"
DOMAIN="$2"
echo "CREATE USER $USERNAME@$DOMAIN" | psql  # SQL injection!
```

✅ **CORRECT**:
```bash
#!/bin/bash
USERNAME="$1"
DOMAIN="$2"

# Validate format
[[ "$USERNAME" =~ ^[a-zA-Z0-9_.-]+$ ]] || { echo "Invalid username"; exit 1; }
[[ "$DOMAIN" =~ ^[a-zA-Z0-9.-]+$ ]] || { echo "Invalid domain"; exit 1; }

# Use parameterized queries, never string interpolation
psql -v uname="$USERNAME" -v domain="$DOMAIN" <<SQL
CREATE USER :uname@:domain;
SQL
```

**Risk**: Command injection, SQL injection, data breaches.

---

## 8. Pipeline Errors Silently Ignored

❌ **AVOID**:
```bash
#!/bin/bash
RESULT=$(curl https://api.example.com | jq .status)
echo "Status: $RESULT"  # What if curl failed?
```

✅ **CORRECT**:
```bash
#!/bin/bash
set -euo pipefail
RESULT=$(curl https://api.example.com | jq .status)
# Script exits if curl or jq fails
echo "Status: $RESULT"
```

**Risk**: Unexpected behavior, invalid data processing.

---

## 9. Logging Sensitive Data

❌ **AVOID**:
```bash
#!/bin/bash
log_debug() {
    echo "[$(date)] $@" >> /var/log/app.log
}
log_debug "User: $USER, Password: $PASSWORD"  # Password in logs!
```

✅ **CORRECT**:
```bash
#!/bin/bash
log_debug() {
    echo "[$(date)] $@" >> /var/log/app.log
}
log_debug "User authenticated: $USER"  # Never log passwords/secrets
```

**Risk**: Credential exposure in logs, compliance violations.

---

## 10. Using Relative Paths in Production

❌ **AVOID**:
```bash
#!/bin/bash
jq --version  # Which jq? Could use malicious version in PATH
python script.py  # Wrong Python version or from $PATH injection
```

✅ **CORRECT**:
```bash
#!/bin/bash
/usr/bin/jq --version
/usr/bin/python3 script.py
# Or check and fail loudly:
command -v jq >/dev/null || { echo "jq not found"; exit 1; }
jq --version
```

**Risk**: PATH injection, wrong binary version, supply chain attacks.

---

## Quick Reference

| Anti-Pattern | Consequence | Fix |
|---|---|---|
| Unquoted `$VAR` | Injection, globbing | Use `"$VAR"` |
| No `set -euo pipefail` | Silent failures | Add to header |
| Hardcoded secrets | Credential leaks | Use env vars |
| `eval` with input | RCE | Whitelist actions |
| `/tmp/hardcoded` | Race conditions | Use `mktemp` |
| No error checks | Partial success | Add `set -e` + traps |
| Unvalidated input | Injection attacks | Whitelist/regex |
| No cleanup traps | Resource leaks | Add `trap ... EXIT` |
| Secrets in logs | Compliance risk | Filter output |
| Relative paths | Supply chain attack | Use full paths |
