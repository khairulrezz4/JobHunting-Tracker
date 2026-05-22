# Bash Hardening Checklist

Use this checklist before committing bash scripts to the repository.

## Header & Safety Flags

- [ ] Script starts with `#!/bin/bash` shebang
- [ ] `set -euo pipefail` present early in script
- [ ] `umask` set appropriately (e.g., 0077 for sensitive scripts)
- [ ] Error trap configured: `trap 'echo "Error line $LINENO"; exit 1' ERR`

## Variable & Quoting

- [ ] All variable expansions quoted: `"$VAR"` not `$VAR`
- [ ] Array expansions use `"${array[@]}"` not `${array[*]}`
- [ ] Command substitutions quoted: `"$(command)"` not `$(command)`
- [ ] No glob expansions in variable assignments

## User Input & Validation

- [ ] User inputs validated before use (length, character set, range)
- [ ] Whitelist approach (check what IS allowed, not what isn't)
- [ ] Empty input explicitly checked with `[[ -z "$VAR" ]]`
- [ ] Special characters escaped or rejected

## Secrets & Credentials

- [ ] No hardcoded API keys, passwords, or tokens
- [ ] No credentials in log output
- [ ] Sensitive data marked as SENSITIVE or from environment variables only
- [ ] Temporary files containing secrets cleaned up on exit
- [ ] `.env` or config files marked as 600 (not world-readable)

## Error Handling

- [ ] All command substitutions checked for success: `if ! command; then`
- [ ] Meaningful error messages sent to stderr (`>&2`)
- [ ] Exit codes are explicit (0 for success, >0 for failure)
- [ ] Cleanup code in trap handlers runs on EXIT

## File & Permission Handling

- [ ] Temporary files created with `mktemp` not `/tmp/hardcoded`
- [ ] Temporary files cleaned up: trap "rm -f '$TMPFILE'" EXIT`
- [ ] Log files have secure permissions (644 or less open)
- [ ] Working with paths uses quotes: `"$HOME/$DIR"`

## Command Safety

- [ ] No use of `eval` or `source` with untrusted input
- [ ] `command -v` used to verify command availability
- [ ] Commands use full paths when possible: `/usr/bin/jq` vs `jq`
- [ ] Dangerous commands (rm, dd) have safeguards or explicit user confirmation

## CI/CD & Pipelines

- [ ] Script passes `shellcheck` with no errors
- [ ] Script runs successfully once with test inputs
- [ ] Script passes custom validation: `./scripts/validator.sh script.sh`
- [ ] Script documented with purpose and usage comment at top

## Review Checklist

Before marking as complete:
- [ ] Passed local audit: `./scripts/audit-bash.sh`
- [ ] Passed validator: `./scripts/validator.sh`
- [ ] Peer-reviewed for security patterns
- [ ] No credentials, API keys, or PII in code
- [ ] Ready for production deployment
