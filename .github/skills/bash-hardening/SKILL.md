---
name: bash-hardening
description: 'Bash script hardening for DevSecOps: detect security risks, enforce shift-left validation, verify-before-apply patterns. Use when: writing bash scripts, auditing existing scripts, integrating security checks into CI/CD, implementing secure coding patterns.'
argument-hint: 'Specify script path or pattern (e.g., ./script.sh, scripts/*.sh)'
---

# Bash Hardening & Secure Scripting

Shift-left security framework for bash scripts. Detects anti-patterns, enforces validation gates, and prevents credential exposure before deployment.

## When to Use

- ✅ Writing or reviewing bash scripts for production
- ✅ Pre-commit validation before pushing to repository
- ✅ Hardening CI/CD pipeline scripts
- ✅ Auditing scripts for credential/secret exposure
- ✅ Enforcing consistent security patterns across shell codebase

## Core Principles

1. **Verify Before Apply**: Always validate script correctness + security before execution
2. **Shift-Left**: Catch issues early in development, not in production
3. **Token-Optimized**: Fast CLI checks, minimal context overhead
4. **Fail Loud**: Non-zero exit codes for security violations

## Quick Check

```bash
# Run security audit on a script
./scripts/audit-bash.sh myscript.sh

# Verify and harden in one pass
./scripts/verify-and-harden.sh ./pipeline.sh
```

## Procedure: Hardening a Script

### 1. Audit for Issues
Run the [audit script](./scripts/audit-bash.sh) to detect common vulnerabilities:
```bash
./scripts/audit-bash.sh path/to/script.sh
```

**Reports**:
- Unquoted variables
- Unsafe pipefail settings
- Command injection risks
- Credential/secret exposure patterns
- Missing error handling

### 2. Review & Apply Fixes
Use the audit output to manually review and apply [secure patterns](./references/secure-patterns.md).

### 3. Validate Hardening
Run [validator](./scripts/validator.sh) post-hardening:
```bash
./scripts/validator.sh path/to/script.sh
```

Returns exit code 0 if all checks pass.

### 4. Pre-Commit Integration
Add to `.git/hooks/pre-commit` to enforce before pushes:
```bash
#!/bin/bash
scripts/validator.sh scripts/*.sh || exit 1
```

## Security Checks Reference

| Check | Category | What It Detects |
|-------|----------|-----------------|
| `set -euo pipefail` | Error Handling | Missing safety flags |
| `"$var"` quoting | Injection | Unquoted variable expansion |
| `shellcheck` patterns | Linting | SC2086, SC2181, SC2129 |
| Secret patterns | Credentials | Hardcoded API keys, passwords, tokens |
| `eval` / `$()` unsafe | Code Injection | Dangerous dynamic evaluation |
| Comment-only validation | Documentation | Missing security notes |

## Reference Files

- [Secure Patterns Guide](./references/secure-patterns.md) — Code examples for common patterns
- [Checklist](./references/checklist.md) — Manual review items
- [Anti-Patterns](./references/anti-patterns.md) — Common mistakes to avoid

## Exit Codes

- **0**: All checks passed, script is hardened
- **1**: Security issues found, review audit output
- **2**: Script not found or permission denied

---

**Next Steps**: Run `/bash-hardening <script>` to audit your first script.
