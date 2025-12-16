# Operational Standards & Best Practices

## Overview

Operational standards, best practices, and procedures for the Unique Staffing Professionals application. This document establishes guidelines for development, deployment, monitoring, and maintenance.

## Table of Contents

1. [Development Standards](#development-standards)
2. [Code Quality Standards](#code-quality-standards)
3. [Security Standards](#security-standards)
4. [Deployment Standards](#deployment-standards)
5. [Monitoring Standards](#monitoring-standards)
6. [Documentation Standards](#documentation-standards)
7. [Incident Response Standards](#incident-response-standards)
8. [Change Management](#change-management)

---

## Development Standards

### Version Control

#### Branch Naming Convention
```
<type>/<description>

Types:
- feat/     - New features
- fix/      - Bug fixes
- docs/     - Documentation changes
- refactor/ - Code refactoring
- test/     - Test additions/changes
- chore/    - Maintenance tasks
- perf/     - Performance improvements

Examples:
- feat/job-listings-management
- fix/resume-download-security
- docs/api-documentation
```

#### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>

Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert

Example:
feat(auth): add multi-factor authentication

Implement MFA using TOTP for admin users. Includes:
- QR code generation for setup
- Backup codes
- Remember device option

Co-authored-by: Ona <no-reply@ona.com>
```

#### Pull Request Requirements
- [ ] Descriptive title following commit convention
- [ ] Detailed description of changes
- [ ] Link to related Linear issue
- [ ] Screenshots for UI changes
- [ ] Tests added/updated (when test suite exists)
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] All CI checks passing
- [ ] At least one approval required
- [ ] Signed commits

### Code Organization

#### File Structure
```
src/
├── components/
│   ├── ui/              # Reusable UI primitives
│   ├── admin/           # Admin-specific components
│   ├── seo/             # SEO components
│   └── [feature]/       # Feature-specific components
├── contexts/            # React Context providers
├── hooks/               # Custom React hooks
├── lib/                 # Utilities and helpers
├── pages/               # Route pages
├── types/               # TypeScript type definitions
└── locales/             # Translation files
```

#### Naming Conventions
- **Components**: PascalCase (e.g., `ApplyForm.tsx`)
- **Hooks**: camelCase with 'use' prefix (e.g., `useLanguage.ts`)
- **Utilities**: camelCase (e.g., `formatDate.ts`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `API_ENDPOINTS`)
- **Types/Interfaces**: PascalCase (e.g., `ApplicantData`)

### Development Workflow

#### Daily Workflow
1. **Start of Day**
   ```bash
   git checkout main
   git pull origin main
   npm install  # If package.json changed
   npm run env-check
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feat/feature-name
   ```

3. **Development**
   ```bash
   npm run dev  # Start dev server
   # Make changes
   npm run lint  # Check code quality
   npm run type-check  # Verify types
   ```

4. **Before Commit**
   ```bash
   npm run pre-commit  # Run all checks
   git add .
   npm run commit  # Interactive commit helper
   ```

5. **Push Changes**
   ```bash
   git push -u origin feat/feature-name
   ```

6. **Create Pull Request**
   - Use GitHub UI or CLI
   - Fill out PR template
   - Request reviews
   - Address feedback

#### Code Review Process
1. **Self-Review**
   - Review your own changes first
   - Check for console.logs, debuggers
   - Verify all tests pass
   - Update documentation

2. **Peer Review**
   - At least one approval required
   - Use `.docs/REVIEWER.md` checklist
   - Provide constructive feedback
   - Approve or request changes

3. **Merge**
   - Squash and merge (preferred)
   - Delete branch after merge
   - Verify deployment

---

## Code Quality Standards

### TypeScript Standards

#### Type Safety
```typescript
// ✅ Good - Explicit types
interface ApplicantData {
  id: string
  full_name: string
  email: string
  phone: string
  status: 'new' | 'reviewing' | 'shortlisted' | 'rejected' | 'hired'
}

// ❌ Bad - Using any
function processData(data: any) {
  return data.name
}

// ✅ Good - Proper typing
function processData(data: ApplicantData): string {
  return data.full_name
}
```

#### Null Safety
```typescript
// ✅ Good - Handle null/undefined
function getApplicantName(applicant: ApplicantData | null): string {
  return applicant?.full_name ?? 'Unknown'
}

// ❌ Bad - No null check
function getApplicantName(applicant: ApplicantData): string {
  return applicant.full_name  // May crash if null
}
```

### React Standards

#### Component Structure
```typescript
// ✅ Good - Proper component structure
import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { useLanguage } from '@/contexts/LanguageContext'

interface ApplyFormProps {
  onSubmit: (data: FormData) => Promise<void>
  initialData?: FormData
}

export function ApplyForm({ onSubmit, initialData }: ApplyFormProps) {
  const { t } = useLanguage()
  const [isSubmitting, setIsSubmitting] = useState(false)

  // Hooks at top
  useEffect(() => {
    // Effect logic
  }, [])

  // Event handlers
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)
    try {
      await onSubmit(formData)
    } finally {
      setIsSubmitting(false)
    }
  }

  // Render
  return (
    <form onSubmit={handleSubmit}>
      {/* JSX */}
    </form>
  )
}
```

#### Hook Usage
```typescript
// ✅ Good - Proper hook usage
function useApplicants() {
  const [applicants, setApplicants] = useState<Applicant[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    let cancelled = false

    async function fetchApplicants() {
      try {
        const data = await getApplicants()
        if (!cancelled) {
          setApplicants(data)
        }
      } catch (err) {
        if (!cancelled) {
          setError(err as Error)
        }
      } finally {
        if (!cancelled) {
          setLoading(false)
        }
      }
    }

    fetchApplicants()

    return () => {
      cancelled = true
    }
  }, [])

  return { applicants, loading, error }
}
```

### Performance Standards

#### Optimization Techniques
```typescript
// ✅ Good - Memoization
import { useMemo, useCallback } from 'react'

function ApplicantList({ applicants, onSelect }) {
  // Memoize expensive calculations
  const sortedApplicants = useMemo(() => {
    return applicants.sort((a, b) => 
      new Date(b.created_at) - new Date(a.created_at)
    )
  }, [applicants])

  // Memoize callbacks
  const handleSelect = useCallback((id: string) => {
    onSelect(id)
  }, [onSelect])

  return (
    <div>
      {sortedApplicants.map(applicant => (
        <ApplicantCard
          key={applicant.id}
          applicant={applicant}
          onSelect={handleSelect}
        />
      ))}
    </div>
  )
}
```

### Error Handling Standards

#### Try-Catch Pattern
```typescript
// ✅ Good - Proper error handling
async function submitApplication(data: FormData) {
  try {
    const result = await supabase
      .from('applicants')
      .insert(data)
      .select()
      .single()

    if (result.error) throw result.error

    logger.info('Application submitted', { id: result.data.id })
    return result.data
  } catch (error) {
    logger.error('Failed to submit application', {
      error: error.message,
      data: sanitizeData(data)
    })
    throw new Error('Failed to submit application. Please try again.')
  }
}
```

#### Error Boundaries
```typescript
// ✅ Good - Error boundary usage
<ErrorBoundary
  fallback={<ErrorFallback />}
  onError={(error, errorInfo) => {
    logger.error('Component error', { error, errorInfo })
  }}
>
  <App />
</ErrorBoundary>
```

---

## Security Standards

### Authentication & Authorization

#### Password Requirements
- Minimum 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- No common passwords
- Password strength indicator
- Secure password reset flow

#### Session Management
- Secure session tokens
- HttpOnly cookies
- Session timeout: 24 hours
- Refresh token rotation
- Logout on all devices option

#### Multi-Factor Authentication (Planned)
- TOTP-based (Google Authenticator, Authy)
- Backup codes
- Remember device option
- Required for admin users

### Data Protection

#### Sensitive Data Handling
```typescript
// ✅ Good - Sanitize before logging
function logError(error: Error, context: any) {
  const sanitized = {
    ...context,
    password: undefined,
    token: undefined,
    ssn: undefined,
  }
  logger.error(error.message, sanitized)
}

// ❌ Bad - Logging sensitive data
function logError(error: Error, context: any) {
  logger.error(error.message, context)  // May contain passwords
}
```

#### Input Validation
```typescript
// ✅ Good - Validate and sanitize
import { z } from 'zod'

const applicantSchema = z.object({
  full_name: z.string().min(2).max(100).trim(),
  email: z.string().email().toLowerCase(),
  phone: z.string().regex(/^\d{10}$/),
  resume: z.instanceof(File).refine(
    file => file.size <= 5 * 1024 * 1024,
    'File must be less than 5MB'
  )
})

function validateApplicant(data: unknown) {
  return applicantSchema.parse(data)
}
```

### API Security

#### Rate Limiting
- 100 requests per minute per IP
- 1000 requests per hour per user
- Exponential backoff on failures

#### CORS Configuration
```typescript
// ✅ Good - Restrictive CORS
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
  credentials: true,
  optionsSuccessStatus: 200
}
```

---

## Deployment Standards

### Pre-Deployment Checklist

#### Code Quality
- [ ] All tests passing
- [ ] Lint checks passing
- [ ] Type checks passing
- [ ] No console.log statements
- [ ] No debugger statements
- [ ] Code reviewed and approved

#### Security
- [ ] No hardcoded secrets
- [ ] Environment variables configured
- [ ] Dependencies up to date
- [ ] Security scan passing
- [ ] RLS policies verified

#### Documentation
- [ ] CHANGELOG.md updated
- [ ] README.md updated (if needed)
- [ ] API docs updated (if applicable)
- [ ] Migration guide (if breaking changes)

### Deployment Process

#### Staging Deployment
```bash
# 1. Build and test
npm run build
npm run preview

# 2. Deploy to staging
npx netlify deploy

# 3. Verify deployment
curl -I https://staging-url.netlify.app

# 4. Run smoke tests
npm run test:e2e -- --base-url=https://staging-url.netlify.app
```

#### Production Deployment
```bash
# 1. Final checks
npm run lint
npm run type-check
npm run build

# 2. Deploy to production
npx netlify deploy --prod

# 3. Verify deployment
curl -I https://uniquestaffingprofessionals.com

# 4. Monitor for errors
# Check Netlify logs
# Check Supabase logs
# Check error tracking (if configured)
```

### Rollback Procedure

#### Quick Rollback
1. Go to Netlify dashboard
2. Navigate to Deploys
3. Find last working deployment
4. Click "Publish deploy"
5. Verify rollback successful

#### Database Rollback
1. Identify migration to rollback
2. Create rollback migration
3. Test in staging
4. Apply to production
5. Verify data integrity

---

## Monitoring Standards

### Health Checks

#### Application Health
- **Endpoint**: `/health`
- **Frequency**: Every 60 seconds
- **Timeout**: 5 seconds
- **Expected Response**: 200 OK

#### Database Health
- **Check**: Connection pool status
- **Frequency**: Every 60 seconds
- **Alert**: If connections > 80% of pool

#### Storage Health
- **Check**: Storage quota usage
- **Frequency**: Daily
- **Alert**: If usage > 80%

### Logging Standards

#### Log Levels
- **DEBUG**: Detailed information for debugging
- **INFO**: General informational messages
- **WARN**: Warning messages for potential issues
- **ERROR**: Error messages for failures

#### Log Format
```json
{
  "timestamp": "2025-12-15T10:00:00Z",
  "level": "INFO",
  "message": "Application submitted",
  "context": {
    "applicant_id": "123",
    "position": "Software Engineer"
  }
}
```

#### What to Log
- ✅ Authentication events
- ✅ Authorization failures
- ✅ Application errors
- ✅ Performance issues
- ✅ Security events
- ❌ Passwords or tokens
- ❌ Personal data (unless necessary)
- ❌ Sensitive information

### Alerting Standards

#### Alert Severity Levels

**P0 - Critical**
- Service completely down
- Data breach
- Security compromise
- **Response Time**: Immediate
- **Notification**: SMS + Email + Slack

**P1 - High**
- Partial service outage
- Performance degradation > 50%
- Security vulnerability
- **Response Time**: 1 hour
- **Notification**: Email + Slack

**P2 - Medium**
- Non-critical bugs
- Performance degradation < 50%
- **Response Time**: 24 hours
- **Notification**: Email

**P3 - Low**
- Minor issues
- Enhancement requests
- **Response Time**: 1 week
- **Notification**: Email (digest)

---

## Documentation Standards

### Code Documentation

#### Component Documentation
```typescript
/**
 * Application form component for job applicants
 * 
 * @component
 * @example
 * ```tsx
 * <ApplyForm
 *   onSubmit={handleSubmit}
 *   initialData={savedData}
 * />
 * ```
 */
export function ApplyForm({ onSubmit, initialData }: ApplyFormProps) {
  // Implementation
}
```

#### Function Documentation
```typescript
/**
 * Validates and submits an application to Supabase
 * 
 * @param data - The application form data
 * @returns The created applicant record
 * @throws {ValidationError} If data is invalid
 * @throws {DatabaseError} If submission fails
 */
async function submitApplication(data: FormData): Promise<Applicant> {
  // Implementation
}
```

### Documentation Files

#### Required Documentation
- **README.md**: Project overview and quick start
- **CLAUDE.md**: Development guidelines
- **ARCHITECTURE.md**: System architecture
- **SECURITY.md**: Security policies
- **CHANGELOG.md**: Version history

#### Documentation Updates
- Update when code changes affect behavior
- Update when adding new features
- Update when fixing bugs (if user-facing)
- Review quarterly for accuracy

---

## Incident Response Standards

### Incident Classification

#### Severity Levels
- **SEV-1**: Critical - Service down, data breach
- **SEV-2**: High - Major functionality impaired
- **SEV-3**: Medium - Minor functionality impaired
- **SEV-4**: Low - Cosmetic issues

### Response Procedures

#### SEV-1 Response
1. **Immediate Actions** (0-15 minutes)
   - Acknowledge incident
   - Notify team
   - Begin investigation
   - Update status page

2. **Mitigation** (15-60 minutes)
   - Identify root cause
   - Implement fix or rollback
   - Verify resolution
   - Monitor for recurrence

3. **Post-Incident** (24-48 hours)
   - Write incident report
   - Conduct post-mortem
   - Implement preventive measures
   - Update runbooks

#### Incident Communication
- **Internal**: Slack channel + Email
- **External**: Status page + Email (if applicable)
- **Updates**: Every 30 minutes during active incident
- **Resolution**: Final update with summary

---

## Change Management

### Change Types

#### Standard Changes
- Bug fixes
- Documentation updates
- Minor UI improvements
- **Approval**: Team lead
- **Testing**: Standard testing

#### Major Changes
- New features
- Architecture changes
- Database schema changes
- **Approval**: Team lead + Stakeholder
- **Testing**: Extended testing + Staging

#### Emergency Changes
- Security patches
- Critical bug fixes
- Service restoration
- **Approval**: On-call engineer
- **Testing**: Minimal (post-deployment verification)

### Change Process

1. **Planning**
   - Create Linear issue
   - Define scope and impact
   - Identify risks
   - Plan rollback strategy

2. **Development**
   - Create feature branch
   - Implement changes
   - Write tests
   - Update documentation

3. **Review**
   - Code review
   - Security review (if applicable)
   - Performance review (if applicable)

4. **Testing**
   - Unit tests
   - Integration tests
   - E2E tests (if applicable)
   - Manual testing

5. **Deployment**
   - Deploy to staging
   - Verify in staging
   - Deploy to production
   - Verify in production

6. **Monitoring**
   - Monitor for errors
   - Check performance metrics
   - Verify user feedback
   - Document lessons learned

---

## Compliance Standards

### Data Privacy

#### GDPR Compliance
- Data minimization
- Purpose limitation
- Storage limitation
- Data subject rights
- Privacy by design

#### CCPA Compliance
- Right to know
- Right to delete
- Right to opt-out
- Non-discrimination

### Accessibility

#### WCAG 2.1 Level AA
- Perceivable
- Operable
- Understandable
- Robust

#### Testing Requirements
- Automated testing (Pa11y, axe)
- Manual testing (keyboard, screen reader)
- Regular audits (quarterly)

---

## Review Schedule

### Daily
- Monitor error logs
- Check deployment status
- Review critical alerts

### Weekly
- Review open issues
- Check performance metrics
- Update documentation (if needed)

### Monthly
- Security review
- Dependency updates
- Performance audit
- Documentation review

### Quarterly
- Comprehensive security audit
- Accessibility audit
- Architecture review
- Process improvement review

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Next Review**: March 2026  
**Maintained By**: Development Team
