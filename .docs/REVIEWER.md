# Code Review Checklist

## Overview

Comprehensive checklist for reviewing code changes in the Unique Staffing Professionals project.

## Pre-Review Setup

- [ ] Pull latest changes from main branch
- [ ] Checkout the feature branch
- [ ] Run `npm install` to ensure dependencies are current
- [ ] Run `npm run dev` to verify application starts
- [ ] Review the PR description and linked issues

## Code Quality

### TypeScript
- [ ] No `any` types without justification
- [ ] Proper type definitions for props and state
- [ ] No TypeScript errors (`npx tsc --noEmit`)
- [ ] Interfaces/types are properly exported
- [ ] Enums used where appropriate

### React Best Practices
- [ ] Components follow single responsibility principle
- [ ] Proper use of hooks (no hooks in conditionals/loops)
- [ ] useEffect dependencies are correct
- [ ] No unnecessary re-renders
- [ ] Proper key props in lists
- [ ] Event handlers properly bound
- [ ] Cleanup functions in useEffect where needed

### Code Style
- [ ] Follows existing code conventions
- [ ] Consistent naming (camelCase for variables, PascalCase for components)
- [ ] No console.log statements (except intentional logging)
- [ ] ESLint passes (`npm run lint`)
- [ ] Proper indentation and formatting
- [ ] Comments explain "why" not "what"

## Functionality

### Feature Implementation
- [ ] Feature works as described in requirements
- [ ] Edge cases handled
- [ ] Error states handled gracefully
- [ ] Loading states implemented
- [ ] Success/failure feedback provided

### Forms
- [ ] Validation rules are correct
- [ ] Error messages are clear and helpful
- [ ] Form submission prevents default
- [ ] Loading state during submission
- [ ] Form resets after successful submission
- [ ] File uploads validated (type, size)

### Data Flow
- [ ] Props passed correctly
- [ ] Context used appropriately
- [ ] State updates are immutable
- [ ] No prop drilling (use context if needed)
- [ ] API calls have error handling

## UI/UX

### Design
- [ ] Matches design specifications
- [ ] Responsive on mobile, tablet, desktop
- [ ] Consistent with existing UI patterns
- [ ] Uses shadcn/ui components where appropriate
- [ ] Proper spacing and alignment

### Accessibility
- [ ] Semantic HTML elements used
- [ ] ARIA labels where needed
- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] Color contrast meets WCAG AA
- [ ] Screen reader tested (if possible)
- [ ] Alt text for images

### Internationalization
- [ ] All user-facing text uses translation keys
- [ ] No hardcoded strings
- [ ] Translation keys added to all languages (en, es, fr)
- [ ] RTL support considered (if applicable)

### Theme Support
- [ ] Works in both light and dark modes
- [ ] Uses CSS variables for colors
- [ ] No hardcoded colors
- [ ] Proper contrast in both themes

## Performance

### Optimization
- [ ] No unnecessary re-renders
- [ ] Large lists use virtualization if needed
- [ ] Images optimized
- [ ] Lazy loading implemented where appropriate
- [ ] No memory leaks (cleanup in useEffect)

### Bundle Size
- [ ] No unnecessary dependencies added
- [ ] Tree-shaking friendly imports
- [ ] Dynamic imports for large components

## Security

### Authentication
- [ ] Protected routes properly guarded
- [ ] Auth state checked before sensitive operations
- [ ] Tokens not exposed in logs or errors
- [ ] Session timeout handled

### Data Handling
- [ ] User input sanitized
- [ ] SQL injection prevented (using Supabase properly)
- [ ] XSS vulnerabilities addressed
- [ ] Sensitive data not logged
- [ ] File uploads validated

### Supabase
- [ ] RLS policies respected
- [ ] Proper error handling for auth failures
- [ ] No direct database queries bypassing RLS
- [ ] Storage bucket permissions correct

## Testing

### Manual Testing
- [ ] Feature tested in development
- [ ] Tested in both light and dark modes
- [ ] Tested in all supported languages
- [ ] Tested on different screen sizes
- [ ] Tested with keyboard navigation
- [ ] Tested error scenarios

### Browser Testing
- [ ] Chrome/Edge
- [ ] Firefox
- [ ] Safari (if available)
- [ ] Mobile browsers

## Database

### Schema Changes
- [ ] Migration scripts provided
- [ ] RLS policies updated
- [ ] Indexes added where needed
- [ ] Foreign keys properly defined
- [ ] Backward compatible (if applicable)

### Queries
- [ ] Efficient queries (no N+1 problems)
- [ ] Proper use of indexes
- [ ] Pagination implemented for large datasets
- [ ] Error handling for failed queries

## Documentation

### Code Documentation
- [ ] Complex logic has comments
- [ ] JSDoc comments for exported functions
- [ ] README updated if needed
- [ ] CLAUDE.md updated if patterns changed

### User Documentation
- [ ] User-facing changes documented
- [ ] Screenshots updated if UI changed
- [ ] Migration guide if breaking changes

## Git

### Commits
- [ ] Commit messages follow convention
- [ ] Commits are logical and atomic
- [ ] No merge commits (rebased)
- [ ] No sensitive data in commits

### Branch
- [ ] Branch name follows convention
- [ ] Based on latest main
- [ ] No merge conflicts
- [ ] Clean commit history

## Deployment

### Build
- [ ] `npm run build` succeeds
- [ ] No build warnings
- [ ] Bundle size reasonable
- [ ] Environment variables documented

### Configuration
- [ ] .env.example updated if new vars added
- [ ] netlify.toml updated if needed
- [ ] No hardcoded environment-specific values

## Checklist by File Type

### New Component
- [ ] Proper TypeScript types
- [ ] Uses existing UI components
- [ ] Responsive design
- [ ] Accessibility features
- [ ] Theme support
- [ ] Internationalization
- [ ] Added to appropriate index file

### New Page
- [ ] Route added to router
- [ ] SEO metadata included
- [ ] Protected if admin page
- [ ] Responsive layout
- [ ] Loading state
- [ ] Error boundary

### Context Provider
- [ ] Proper TypeScript types
- [ ] Default values defined
- [ ] Error handling
- [ ] Performance optimized (useMemo/useCallback)
- [ ] Added to provider hierarchy correctly

### API Integration
- [ ] Error handling
- [ ] Loading states
- [ ] Type definitions
- [ ] Retry logic if needed
- [ ] Timeout handling

## Common Issues to Watch For

### React
- Missing dependencies in useEffect
- Infinite render loops
- Memory leaks from uncleared intervals/timeouts
- Stale closures
- Improper key props

### TypeScript
- Overly broad types
- Missing null checks
- Type assertions without validation
- Unused imports

### Supabase
- Missing RLS policies
- Exposed sensitive data
- Inefficient queries
- Missing error handling

### CSS/Styling
- Hardcoded colors
- Missing responsive breakpoints
- Z-index conflicts
- Specificity issues

## Review Comments

### Providing Feedback
- Be constructive and specific
- Explain the "why" behind suggestions
- Distinguish between blocking issues and suggestions
- Provide code examples when helpful
- Acknowledge good work

### Comment Categories
- 🔴 **Blocking**: Must be fixed before merge
- 🟡 **Suggestion**: Should be considered
- 🟢 **Nitpick**: Optional improvement
- 💡 **Idea**: Future enhancement
- ✅ **Approval**: Looks good

## Approval Criteria

### Must Have
- [ ] All blocking issues resolved
- [ ] Build passes
- [ ] Lint passes
- [ ] Manual testing completed
- [ ] No security vulnerabilities
- [ ] Documentation updated

### Should Have
- [ ] Most suggestions addressed
- [ ] Performance acceptable
- [ ] Accessibility features present
- [ ] Tests pass (when test suite exists)

## Post-Review

- [ ] Approve PR if criteria met
- [ ] Request changes if blocking issues
- [ ] Follow up on addressed comments
- [ ] Verify fixes before final approval

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
