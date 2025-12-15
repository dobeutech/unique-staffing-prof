# Documentation Index

## Overview

Comprehensive documentation for the Unique Staffing Professionals project. This directory contains all technical, operational, and compliance documentation.

## Quick Links

### Getting Started
- [Project Summary](.docs/PROJECT_SUMMARY.md) - Executive overview and key information
- [Main README](../README.md) - Quick start guide
- [CLAUDE.md](../CLAUDE.md) - Development guidelines

### Architecture
- [System Architecture](../SYSTEM_ARCHITECTURE.md) - Mermaid diagrams and visual documentation
- [Architecture](../ARCHITECTURE.md) - Detailed architecture documentation
- [PRD](../PRD.md) - Product requirements document

### Development
- [Dotfiles Setup](DOTFILES_SETUP.md) - Development environment configuration
- [Code Review Checklist](REVIEWER.md) - Review guidelines
- [Testing Guide](TESTING_GUIDE.md) - Testing strategy and utilities
- [Documentation Sync](DOC_SYNC.md) - Documentation maintenance

### Operations
- [Runbook](RUNBOOK.md) - Operations and troubleshooting guide
- [Observability](OBSERVABILITY.md) - Monitoring and logging
- [Outstanding Items](OUTSTANDING_ITEMS.md) - Known issues and technical debt
- [Changelog](CHANGELOG.md) - Version history

### Compliance & Security
- [Compliance](COMPLIANCE.md) - Legal and regulatory compliance
- [Risk Assessment](RISK_ASSESSMENT.md) - Risk analysis and mitigation
- [Accessibility Review](A11Y_REVIEW.md) - WCAG compliance guide
- [Security](../SECURITY.md) - Security policies

## Documentation by Role

### For Developers

**Getting Started**
1. [Main README](../README.md) - Setup instructions
2. [CLAUDE.md](../CLAUDE.md) - Development guidelines
3. [Dotfiles Setup](DOTFILES_SETUP.md) - Environment configuration

**Development Workflow**
1. [Code Review Checklist](REVIEWER.md) - Before submitting PR
2. [Testing Guide](TESTING_GUIDE.md) - Writing tests
3. [Documentation Sync](DOC_SYNC.md) - Updating docs

**Reference**
1. [System Architecture](../SYSTEM_ARCHITECTURE.md) - System design
2. [Outstanding Items](OUTSTANDING_ITEMS.md) - Known issues
3. [Changelog](CHANGELOG.md) - Version history

### For Operations

**Day-to-Day Operations**
1. [Runbook](RUNBOOK.md) - Troubleshooting and procedures
2. [Observability](OBSERVABILITY.md) - Monitoring setup
3. [Project Summary](PROJECT_SUMMARY.md) - System overview

**Incident Response**
1. [Runbook](RUNBOOK.md) - Emergency procedures
2. [Risk Assessment](RISK_ASSESSMENT.md) - Risk mitigation
3. [Compliance](COMPLIANCE.md) - Legal requirements

### For Management

**Project Status**
1. [Project Summary](PROJECT_SUMMARY.md) - Executive overview
2. [Outstanding Items](OUTSTANDING_ITEMS.md) - Current issues
3. [Changelog](CHANGELOG.md) - Progress tracking

**Risk & Compliance**
1. [Risk Assessment](RISK_ASSESSMENT.md) - Risk analysis
2. [Compliance](COMPLIANCE.md) - Legal compliance
3. [Security](../SECURITY.md) - Security posture

### For QA/Testing

**Testing**
1. [Testing Guide](TESTING_GUIDE.md) - Test strategy
2. [Accessibility Review](A11Y_REVIEW.md) - A11y testing
3. [Code Review Checklist](REVIEWER.md) - Quality checks

**Validation**
1. [Outstanding Items](OUTSTANDING_ITEMS.md) - Known issues
2. [Runbook](RUNBOOK.md) - Test procedures
3. [Compliance](COMPLIANCE.md) - Compliance testing

## Documentation by Topic

### Architecture & Design
- [System Architecture](../SYSTEM_ARCHITECTURE.md) - Visual diagrams
- [Architecture](../ARCHITECTURE.md) - Detailed documentation
- [PRD](../PRD.md) - Requirements

### Development
- [CLAUDE.md](../CLAUDE.md) - Development guidelines
- [Dotfiles Setup](DOTFILES_SETUP.md) - Environment setup
- [Testing Guide](TESTING_GUIDE.md) - Testing strategy

### Operations
- [Runbook](RUNBOOK.md) - Operations guide
- [Observability](OBSERVABILITY.md) - Monitoring
- [Deployment Guide](../DEPLOYMENT_GUIDE.md) - Deployment

### Quality
- [Code Review Checklist](REVIEWER.md) - Review process
- [Testing Guide](TESTING_GUIDE.md) - Testing
- [Accessibility Review](A11Y_REVIEW.md) - A11y compliance

### Compliance
- [Compliance](COMPLIANCE.md) - Legal compliance
- [Risk Assessment](RISK_ASSESSMENT.md) - Risk management
- [Security](../SECURITY.md) - Security policies

### Project Management
- [Project Summary](PROJECT_SUMMARY.md) - Overview
- [Outstanding Items](OUTSTANDING_ITEMS.md) - Issues tracking
- [Changelog](CHANGELOG.md) - Version history
- [Documentation Sync](DOC_SYNC.md) - Doc maintenance

## Automation Scripts

Located in `/scripts/`:

### Quality Assurance
- **pre-commit-check.sh** - Pre-commit validation
  - ESLint, TypeScript, console.log check
  - Usage: `npm run pre-commit`

- **commit-help.sh** - Interactive commit helper
  - Conventional commits, co-author
  - Usage: `npm run commit`

### Environment
- **env-check.sh** - Environment validation
  - Validates required variables
  - Usage: `npm run env-check`

### Security
- **deps-audit.sh** - Dependency audit
  - Security vulnerabilities, outdated packages
  - Usage: `npm run deps-audit`

### Accessibility
- **a11y-check.sh** - Accessibility audit
  - WCAG compliance checks
  - Usage: `npm run a11y-check`

## Document Status

### Complete ✅
- Project Summary
- System Architecture (Mermaid)
- Code Review Checklist
- Dotfiles Setup
- Testing Guide
- Observability Guide
- Runbook
- Compliance Documentation
- Risk Assessment
- Accessibility Review
- Outstanding Items
- Changelog
- Documentation Sync

### In Progress ⚠️
- None

### Planned 📋
- API Documentation
- Component Library Documentation
- Deployment Automation Guide
- Performance Optimization Guide

## Maintenance

### Update Frequency

**Weekly**
- Outstanding Items
- Changelog (as needed)

**Monthly**
- Risk Assessment review
- Compliance checklist
- Runbook updates

**Quarterly**
- Full documentation review
- Architecture updates
- Process improvements

**Annually**
- Comprehensive audit
- Strategy updates
- Major revisions

### Review Schedule

| Document | Last Updated | Next Review | Owner |
|----------|-------------|-------------|-------|
| Project Summary | Dec 2025 | Jan 2026 | Dev Team |
| System Architecture | Dec 2025 | Mar 2026 | Dev Team |
| Runbook | Dec 2025 | Jan 2026 | Ops Team |
| Compliance | Dec 2025 | Mar 2026 | Legal |
| Risk Assessment | Dec 2025 | Mar 2026 | Management |
| Outstanding Items | Dec 2025 | Weekly | Dev Team |

## Contributing to Documentation

### Adding New Documentation
1. Create file in appropriate location
2. Follow existing format and style
3. Add to this index
4. Update relevant cross-references
5. Submit PR with documentation changes

### Updating Existing Documentation
1. Make changes to relevant file
2. Update "Last Updated" date
3. Add entry to CHANGELOG.md
4. Update cross-references if needed
5. Submit PR

### Documentation Standards
- Use Markdown format
- Include version and date
- Add table of contents for long docs
- Use code blocks with language tags
- Include examples where helpful
- Keep language clear and concise

## Support

### Questions or Issues
- Create issue in GitHub repository
- Tag with `documentation` label
- Assign to appropriate team member

### Suggestions
- Create issue with `enhancement` label
- Describe improvement clearly
- Provide examples if applicable

## Version Control

All documentation is version controlled in Git:
- Track changes over time
- Review documentation changes in PRs
- Maintain documentation history
- Rollback if needed

## External Resources

### Technology Documentation
- [React](https://react.dev/)
- [TypeScript](https://www.typescriptlang.org/docs/)
- [Supabase](https://supabase.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Vite](https://vitejs.dev/)

### Standards & Compliance
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/)
- [GDPR](https://gdpr.eu/)
- [CCPA](https://oag.ca.gov/privacy/ccpa)

### Tools
- [Netlify](https://docs.netlify.com/)
- [Linear](https://linear.app/docs)
- [GitHub](https://docs.github.com/)

---

**Index Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Documentation Team
