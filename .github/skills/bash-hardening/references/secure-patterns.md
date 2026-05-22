# Secure Bash Patterns

## 1. Script Header (ALWAYS start with this)

```bash
#!/bin/bash
set -euo pipefail

# Set umask for secure permissions
umask 0077

# Trap errors and exit
trap 'echo "Error on line $LINENO"; exit 1' ERR
```

**Why**:
- `set -e`: Exit on first error
- `set -u`: Error on undefined variables
- `set -o pipefail`: Return last error in pipeline
- `umask 0077`: Only user can read files (no world-readable)
- `trap`: Catch errors early

## 2. Variable Quoting

❌ **UNSAFE**:
```bash
RESULT=$(ls $DIR)        # Word splitting, globbing
echo $VAR                # Unquoted expansion
command $ARGS            # Argument injection
```

✅ **SAFE**:
```bash
RESULT=$(ls "$DIR")      # Quoted expansion
echo "$VAR"              # Always quote variables
command "$@"             # Array expansion
```

## 3. User Input Validation

✅ **SAFE**:
```bash
# Check for empty
[[ -z "$USER_INPUT" ]] && { echo "Empty input"; exit 1; }

# Validate alphanumeric only
[[ "$INPUT" =~ ^[a-zA-Z0-9_]+$ ]] || { echo "Invalid chars"; exit 1; }

# Restrict to expected values
case "$ACTION" in
    create|delete|update) ;;
    *) echo "Invalid action"; exit 1 ;;
esac
```

## 4. No Hardcoded Secrets

❌ **UNSAFE**:
```bash
API_KEY="sk-1234567890abcdef"
PASSWORD="SecurePass123"
```

✅ **SAFE**:
```bash
API_KEY="${API_KEY:-}"  # From environment only
[[ -z "$API_KEY" ]] && { echo "API_KEY not set"; exit 1; }

# Load from secure file (permissions: 600)
source /etc/app.conf || exit 1
```

## 5. Temporary Files (Secure)

❌ **UNSAFE**:
```bash
TMPFILE="/tmp/output.txt"  # Predictable, world-writable
```

✅ **SAFE**:
```bash
TMPFILE=$(mktemp)
trap "rm -f '$TMPFILE'" EXIT

# Or with custom dir
TMPDIR=$(mktemp -d)
trap "rm -rf '$TMPDIR'" EXIT
```

## 6. Error Handling

✅ **SAFE**:
```bash
# Explicit error checks
if ! command -v git &>/dev/null; then
    echo "git not found" >&2
    exit 1
fi

# Safe defaults
RESULT="${RESULT:-default_value}"

# Log before exit
cleanup() {
    [[ -f "$TMPFILE" ]] && rm -f "$TMPFILE"
}
trap cleanup EXIT
```

## 7. Command Substitution (Avoid eval)

❌ **UNSAFE**:
```bash
eval "result=$DYNAMIC"   # Command injection risk
result=$(eval echo "$VAR")
```

✅ **SAFE**:
```bash
result=$("$COMMAND" "$@")  # Direct command execution
result="${VARS[$KEY]}"     # Array lookup
```

## 8. Secure Logging

✅ **SAFE**:
```bash
# Log to file, never to stdout for secrets
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> /var/log/app.log
}

# Mask sensitive data
log "Action: create user"              # Good
# log "Password: $PASSWORD"            # Never log secrets
```

## 9. Command Existence Check

✅ **SAFE**:
```bash
# Before using a command
if ! command -v jq &>/dev/null; then
    echo "jq not installed" >&2
    exit 1
fi

# Use it
jq .[] < file.json
```

## 10. Safe Error Messages

✅ **SAFE**:
```bash
# Errors to stderr, not stdout
echo "Error: config not found" >&2
exit 1

# Include line number context
echo "Error on line ${LINENO}: $*" >&2
```
