# Observability & Monitoring

## Overview

Monitoring, logging, and observability strategy for the Unique Staffing Professionals application.

## Current State

### Implemented
- Browser console logging (development)
- Netlify deployment logs
- Supabase database logs
- React Error Boundary

### Not Implemented
- Centralized error tracking
- Application performance monitoring
- User analytics
- Custom logging service
- Alerting system

## Monitoring Stack (Recommended)

### Error Tracking
**Sentry** - Application error tracking
- Real-time error notifications
- Stack traces and context
- Release tracking
- Performance monitoring

### Analytics
**Plausible** or **Google Analytics** - User analytics
- Privacy-friendly
- Page views and events
- User flow tracking
- Conversion tracking

### Performance
**Lighthouse CI** - Performance monitoring
- Automated performance audits
- Performance budgets
- Regression detection

### Uptime
**UptimeRobot** or **Pingdom** - Uptime monitoring
- HTTP/HTTPS monitoring
- SSL certificate monitoring
- Status page

## Implementation Guide

### 1. Error Tracking with Sentry

#### Installation
```bash
npm install @sentry/react @sentry/vite-plugin
```

#### Configuration
```typescript
// src/lib/sentry.ts
import * as Sentry from '@sentry/react'
import { BrowserTracing } from '@sentry/tracing'

if (import.meta.env.PROD) {
  Sentry.init({
    dsn: import.meta.env.VITE_SENTRY_DSN,
    integrations: [
      new BrowserTracing(),
      new Sentry.Replay({
        maskAllText: true,
        blockAllMedia: true,
      }),
    ],
    tracesSampleRate: 0.1,
    replaysSessionSampleRate: 0.1,
    replaysOnErrorSampleRate: 1.0,
    environment: import.meta.env.MODE,
    beforeSend(event, hint) {
      // Filter out sensitive data
      if (event.request) {
        delete event.request.cookies
      }
      return event
    },
  })
}
```

#### Usage
```typescript
// src/main.tsx
import './lib/sentry'
import { ErrorBoundary } from '@sentry/react'

root.render(
  <ErrorBoundary
    fallback={<ErrorFallback />}
    showDialog
  >
    <App />
  </ErrorBoundary>
)
```

#### Custom Error Logging
```typescript
import * as Sentry from '@sentry/react'

try {
  // risky operation
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      section: 'application-form',
    },
    extra: {
      formData: sanitizedFormData,
    },
  })
}
```

### 2. Analytics with Plausible

#### Installation
```bash
npm install plausible-tracker
```

#### Configuration
```typescript
// src/lib/analytics.ts
import Plausible from 'plausible-tracker'

const plausible = Plausible({
  domain: 'uniquestaffingprofessionals.com',
  trackLocalhost: false,
})

export const trackPageView = () => {
  plausible.trackPageview()
}

export const trackEvent = (
  eventName: string,
  props?: Record<string, string | number>
) => {
  plausible.trackEvent(eventName, { props })
}

export default plausible
```

#### Usage
```typescript
// Track page views
import { useEffect } from 'react'
import { useLocation } from 'react-router-dom'
import { trackPageView } from '@/lib/analytics'

function App() {
  const location = useLocation()
  
  useEffect(() => {
    trackPageView()
  }, [location])
  
  return <Router />
}

// Track custom events
import { trackEvent } from '@/lib/analytics'

function ApplyForm() {
  const handleSubmit = async (data) => {
    await submitApplication(data)
    trackEvent('Application Submitted', {
      position: data.position,
    })
  }
}
```

### 3. Performance Monitoring

#### Lighthouse CI Setup
```bash
npm install -D @lhci/cli
```

#### Configuration
```javascript
// lighthouserc.js
module.exports = {
  ci: {
    collect: {
      startServerCommand: 'npm run preview',
      url: ['http://localhost:4173'],
      numberOfRuns: 3,
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:best-practices': ['error', { minScore: 0.9 }],
        'categories:seo': ['error', { minScore: 0.9 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
}
```

#### Web Vitals Tracking
```typescript
// src/lib/webVitals.ts
import { onCLS, onFID, onFCP, onLCP, onTTFB } from 'web-vitals'
import { trackEvent } from './analytics'

function sendToAnalytics({ name, delta, id }: any) {
  trackEvent('Web Vitals', {
    metric: name,
    value: Math.round(delta),
    id,
  })
}

export function reportWebVitals() {
  onCLS(sendToAnalytics)
  onFID(sendToAnalytics)
  onFCP(sendToAnalytics)
  onLCP(sendToAnalytics)
  onTTFB(sendToAnalytics)
}
```

### 4. Custom Logging

#### Logger Utility
```typescript
// src/lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface LogContext {
  [key: string]: any
}

class Logger {
  private isDevelopment = import.meta.env.DEV

  private log(level: LogLevel, message: string, context?: LogContext) {
    const timestamp = new Date().toISOString()
    const logData = {
      timestamp,
      level,
      message,
      ...context,
    }

    // Console logging
    if (this.isDevelopment) {
      console[level === 'debug' ? 'log' : level](
        `[${timestamp}] ${level.toUpperCase()}: ${message}`,
        context
      )
    }

    // Send to external service in production
    if (!this.isDevelopment && level === 'error') {
      this.sendToService(logData)
    }
  }

  private sendToService(logData: any) {
    // Send to logging service (e.g., Sentry, LogRocket)
    if (window.Sentry) {
      window.Sentry.captureMessage(logData.message, {
        level: logData.level,
        extra: logData,
      })
    }
  }

  debug(message: string, context?: LogContext) {
    this.log('debug', message, context)
  }

  info(message: string, context?: LogContext) {
    this.log('info', message, context)
  }

  warn(message: string, context?: LogContext) {
    this.log('warn', message, context)
  }

  error(message: string, context?: LogContext) {
    this.log('error', message, context)
  }
}

export const logger = new Logger()
```

#### Usage
```typescript
import { logger } from '@/lib/logger'

// Debug logging
logger.debug('Form validation started', { formId: 'apply-form' })

// Info logging
logger.info('Application submitted', {
  applicantId: '123',
  position: 'Software Engineer',
})

// Warning logging
logger.warn('Slow API response', {
  endpoint: '/api/applicants',
  duration: 3000,
})

// Error logging
logger.error('Failed to upload resume', {
  error: error.message,
  fileName: file.name,
  fileSize: file.size,
})
```

## Monitoring Dashboards

### Netlify Dashboard
**URL**: https://app.netlify.com

**Metrics**:
- Build status and history
- Deploy previews
- Bandwidth usage
- Form submissions
- Function invocations

**Alerts**:
- Build failures
- Deploy failures
- Bandwidth limits

### Supabase Dashboard
**URL**: https://app.supabase.com

**Metrics**:
- Database size and growth
- API request count
- Storage usage
- Active connections
- Query performance

**Alerts**:
- Database size limits
- API rate limits
- Storage limits

### Sentry Dashboard (Recommended)
**URL**: https://sentry.io

**Metrics**:
- Error rate
- Affected users
- Error trends
- Performance issues
- Release health

**Alerts**:
- New error types
- Error rate spikes
- Performance degradation

## Key Metrics to Track

### Application Metrics

#### Performance
- **Page Load Time**: < 3s (target)
- **Time to Interactive**: < 5s (target)
- **First Contentful Paint**: < 1.8s (target)
- **Largest Contentful Paint**: < 2.5s (target)
- **Cumulative Layout Shift**: < 0.1 (target)

#### Availability
- **Uptime**: 99.9% (target)
- **Error Rate**: < 1% (target)
- **API Success Rate**: > 99% (target)

#### Business
- **Applications per Day**: Track trend
- **Conversion Rate**: Visitors → Applications
- **Form Completion Rate**: Started → Submitted
- **Admin Login Success Rate**: > 95%

### User Metrics

#### Engagement
- **Page Views**: Track trend
- **Unique Visitors**: Track trend
- **Session Duration**: Track average
- **Bounce Rate**: < 40% (target)
- **Pages per Session**: Track average

#### Behavior
- **Most Viewed Pages**: Identify popular content
- **Exit Pages**: Identify problem areas
- **Click Patterns**: Understand user flow
- **Search Queries**: Understand user intent

## Alerting Strategy

### Critical Alerts (Immediate Response)
- Site down (5xx errors)
- Database connection failures
- Authentication system failures
- Payment processing errors (if applicable)

### High Priority Alerts (1 hour response)
- Error rate > 5%
- Performance degradation > 50%
- API rate limit approaching
- Storage quota > 90%

### Medium Priority Alerts (24 hour response)
- Error rate > 1%
- Performance degradation > 25%
- Unusual traffic patterns
- Failed background jobs

### Low Priority Alerts (Weekly review)
- Deprecated API usage
- Console warnings
- Accessibility issues
- SEO issues

## Alert Channels

### Email
- Critical: Immediate
- High: Digest every hour
- Medium: Daily digest
- Low: Weekly digest

### Slack (Recommended)
- Critical: @channel mention
- High: Team channel
- Medium: Team channel
- Low: Weekly summary

### SMS (Optional)
- Critical only
- On-call rotation

## Logging Best Practices

### Do's
- ✅ Log errors with context
- ✅ Log important business events
- ✅ Include timestamps
- ✅ Use structured logging
- ✅ Sanitize sensitive data
- ✅ Use appropriate log levels
- ✅ Include correlation IDs

### Don'ts
- ❌ Don't log passwords or tokens
- ❌ Don't log PII without consent
- ❌ Don't log in tight loops
- ❌ Don't log sensitive user data
- ❌ Don't use console.log in production
- ❌ Don't log everything

## Privacy Considerations

### Data Collection
- Only collect necessary data
- Anonymize user data where possible
- Respect Do Not Track headers
- Comply with GDPR/CCPA
- Provide opt-out mechanisms

### Data Retention
- Error logs: 90 days
- Analytics: 2 years
- Performance data: 1 year
- User sessions: 30 days

### Data Access
- Limit access to authorized personnel
- Audit access logs
- Encrypt sensitive data
- Regular security reviews

## Maintenance

### Daily
- [ ] Check error dashboard
- [ ] Review critical alerts
- [ ] Monitor uptime

### Weekly
- [ ] Review error trends
- [ ] Check performance metrics
- [ ] Review user analytics
- [ ] Update alert thresholds

### Monthly
- [ ] Performance audit
- [ ] Security review
- [ ] Cost analysis
- [ ] Capacity planning

### Quarterly
- [ ] Review monitoring strategy
- [ ] Update dashboards
- [ ] Review alert effectiveness
- [ ] Team training

## Resources

- [Sentry Documentation](https://docs.sentry.io/)
- [Plausible Analytics](https://plausible.io/docs)
- [Web Vitals](https://web.dev/vitals/)
- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci)

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
