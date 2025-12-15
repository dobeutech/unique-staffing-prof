# Documentation Synchronization Guide

## Overview

This document outlines the process for keeping documentation synchronized with code changes.

## Documentation Files

### Core Documentation
- `README.md` - Project overview and quick start
- `CLAUDE.md` - AI assistant guidance
- `ARCHITECTURE.md` - System architecture diagrams
- `SYSTEM_ARCHITECTURE.md` - Mermaid diagrams
- `PRD.md` - Product requirements
- `DEPLOYMENT_GUIDE.md` - Deployment instructions

### Technical Documentation
- `SUPABASE_SETUP.md` - Database setup
- `SECURITY.md` - Security policies
- `MULTILINGUAL_DARK_MODE_GUIDE.md` - i18n and theming

### Process Documentation
- `.docs/REVIEWER.md` - Code review checklist
- `.docs/COMMIT_HELP.md` - Commit message guide
- `.docs/CHANGELOG.md` - Version history

## Sync Triggers

### When to Update Documentation

1. **Architecture Changes**
   - New components added
   - Context providers modified
   - Routing changes
   - Database schema updates
   → Update: `ARCHITECTURE.md`, `SYSTEM_ARCHITECTURE.md`

2. **Feature Additions**
   - New pages or major features
   - API changes
   - New dependencies
   → Update: `README.md`, `CLAUDE.md`, `CHANGELOG.md`

3. **Configuration Changes**
   - Environment variables
   - Build process
   - Deployment pipeline
   → Update: `DEPLOYMENT_GUIDE.md`, `README.md`

4. **Security Updates**
   - Authentication changes
   - RLS policy modifications
   - Storage bucket changes
   → Update: `SECURITY.md`, `SUPABASE_SETUP.md`

## Sync Checklist

### Pre-Commit
- [ ] Review changed files
- [ ] Identify affected documentation
- [ ] Update relevant docs
- [ ] Verify code examples in docs
- [ ] Check for broken links

### Post-Merge
- [ ] Update CHANGELOG.md
- [ ] Regenerate architecture diagrams if needed
- [ ] Update version numbers
- [ ] Notify team of doc changes

## Documentation Standards

### File Naming
- Use SCREAMING_SNAKE_CASE for root docs
- Use kebab-case for nested docs
- Include file extension (.md)

### Content Structure
```markdown
# Title

## Overview
Brief description

## Section 1
Content

## Section 2
Content

---
**Version**: X.Y.Z
**Last Updated**: Month Year
**Maintained By**: Team Name
```

### Code Examples
- Use fenced code blocks with language
- Keep examples up-to-date with actual code
- Include comments for clarity
- Test examples before committing

### Diagrams
- Use Mermaid for architecture diagrams
- Use ASCII art for simple flows
- Keep diagrams version-controlled
- Update diagrams when structure changes

## Automation

### Pre-commit Hook
```bash
#!/bin/bash
# Check if documentation needs updating

changed_files=$(git diff --cached --name-only)

# Check for architecture changes
if echo "$changed_files" | grep -q "src/contexts/\|src/pages/\|src/App.tsx"; then
  echo "⚠️  Context or routing changes detected"
  echo "   Consider updating ARCHITECTURE.md"
fi

# Check for component changes
if echo "$changed_files" | grep -q "src/components/"; then
  echo "⚠️  Component changes detected"
  echo "   Consider updating SYSTEM_ARCHITECTURE.md"
fi

# Check for config changes
if echo "$changed_files" | grep -q "package.json\|vite.config.ts\|netlify.toml"; then
  echo "⚠️  Configuration changes detected"
  echo "   Consider updating README.md and DEPLOYMENT_GUIDE.md"
fi
```

## Review Process

### Documentation Review
1. **Accuracy**: Does it match current code?
2. **Completeness**: Are all features documented?
3. **Clarity**: Is it easy to understand?
4. **Examples**: Are code samples correct?
5. **Links**: Do all links work?

### Quarterly Audit
- Review all documentation
- Remove outdated content
- Update screenshots
- Verify all commands work
- Check for consistency

## Tools

### Markdown Linting
```bash
# Install markdownlint
npm install -g markdownlint-cli

# Lint all markdown files
markdownlint '**/*.md' --ignore node_modules
```

### Link Checking
```bash
# Install markdown-link-check
npm install -g markdown-link-check

# Check links
markdown-link-check README.md
```

### Diagram Validation
```bash
# Install mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Validate diagrams
mmdc -i SYSTEM_ARCHITECTURE.md -o /dev/null
```

## Common Patterns

### Adding a New Feature
1. Implement feature
2. Add to CHANGELOG.md
3. Update README.md if user-facing
4. Update CLAUDE.md if affects development
5. Add to SYSTEM_ARCHITECTURE.md if architectural

### Deprecating a Feature
1. Mark as deprecated in code
2. Add deprecation notice to docs
3. Update CHANGELOG.md
4. Plan removal timeline
5. Update examples to use new approach

### Breaking Changes
1. Document in CHANGELOG.md with ⚠️
2. Update all affected documentation
3. Provide migration guide
4. Update version number (major bump)

## Contact

For documentation questions or suggestions:
- Create an issue in the repository
- Tag with `documentation` label
- Assign to documentation maintainer

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
