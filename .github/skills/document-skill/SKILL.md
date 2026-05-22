---
name: document-skill
description: 'Create and maintain GitHub project documentation as single source of truth. Use when: writing READMEs, documenting workflows, updating project guides, establishing documentation structure.'
argument-hint: 'README or specific doc section to create/update'
user-invocable: true
---

# GitHub Project Documentation Skill

## Purpose

Establish clear, maintainable project documentation that serves as the authoritative reference for developers and contributors.

## When to Use

- Setting up initial project documentation
- Creating or updating README files
- Documenting workflows, setup, or architecture
- Establishing documentation structure and standards
- Adding runbooks or procedural guides

## Quick Checklist

- [ ] Clear purpose statement (what the project does)
- [ ] Setup/installation instructions
- [ ] Basic usage examples
- [ ] Contribution guidelines
- [ ] Project structure overview
- [ ] Links to detailed guides

## Documentation Structure

### 1. README.md (Primary)

**Required sections:**
- Project title and description
- Quick start / getting started
- Installation or setup steps
- Usage examples
- Contributing guidelines
- License

**Optional sections:**
- Architecture overview
- API documentation
- Configuration reference
- Troubleshooting

### 2. Supporting Documents

Organize additional docs by purpose:

```
.github/
├── CONTRIBUTING.md    # How to contribute
├── CODE_OF_CONDUCT.md # Community standards
└── docs/
    ├── SETUP.md       # Detailed setup guide
    ├── ARCHITECTURE.md # System design
    └── TROUBLESHOOTING.md
```

## Writing Guidelines

**Keep it simple:**
- Use clear, direct language
- Short paragraphs and sentences
- Active voice ("run this command" not "this command can be run")
- Use code blocks for commands/examples

**Be specific:**
- Exact commands, not descriptions
- Specific file paths and locations
- Version numbers when relevant
- Expected output or results

**Stay current:**
- Review and update when features change
- Note deprecations clearly
- Link to detailed guides, not inline walls of text
- Use tool references for generated content

## Common Sections

### Getting Started
```markdown
## Getting Started

1. Clone the repository
   \`\`\`bash
   git clone <repo-url>
   cd <project>
   \`\`\`

2. Install dependencies
   \`\`\`bash
   npm install  # or appropriate package manager
   \`\`\`

3. Run the project
   \`\`\`bash
   npm start
   \`\`\`
```

### Project Structure
```markdown
## Project Structure

- \`src/\` - Source code
- \`docs/\` - Documentation
- \`tests/\` - Test files
- \`scripts/\` - Utility scripts
```

### Contributing
```markdown
## Contributing

1. Fork the repository
2. Create a feature branch (\`git checkout -b feature/name\`)
3. Commit changes (\`git commit -am 'Description'\`)
4. Push to branch (\`git push origin feature/name\`)
5. Open a Pull Request
```

## Reference Files

Store detailed procedures in separate markdown files and link from README:
- Links should be descriptive and use markdown format: `[Link text](./path/to/file.md)`
- Keep README concise; detailed info in separate docs
- Update links when reorganizing documentation

## Verification Checklist

- [ ] README is in root of repository
- [ ] All links are valid and relative
- [ ] Code examples are tested/accurate
- [ ] Instructions are current with latest version
- [ ] No broken internal links
- [ ] Uses consistent formatting
- [ ] Explains not just "what" but "why" for complex topics
