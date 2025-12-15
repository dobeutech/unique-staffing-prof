# Infrastructure Architecture

## Overview

Detailed infrastructure architecture for the Unique Staffing Professionals application, including hosting, database, storage, and deployment infrastructure.

## Table of Contents

1. [Infrastructure Stack](#infrastructure-stack)
2. [Network Architecture](#network-architecture)
3. [Hosting Infrastructure](#hosting-infrastructure)
4. [Database Infrastructure](#database-infrastructure)
5. [Storage Infrastructure](#storage-infrastructure)
6. [Security Infrastructure](#security-infrastructure)
7. [Monitoring Infrastructure](#monitoring-infrastructure)
8. [Disaster Recovery](#disaster-recovery)

---

## Infrastructure Stack

### Production Environment

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Netlify Edge Network                     │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                    Global CDN                         │ │
│  │  - DDoS Protection                                    │ │
│  │  - SSL/TLS Termination                               │ │
│  │  - Edge Caching                                       │ │
│  │  - Automatic HTTPS                                    │ │
│  └───────────────────────────────────────────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   React Application                         │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Static Assets (HTML, CSS, JS)                       │ │
│  │  - Minified and Optimized                            │ │
│  │  - Code Splitting                                     │ │
│  │  - Tree Shaking                                       │ │
│  └───────────────────────────────────────────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Platform                        │
│  ┌─────────────────┬─────────────────┬──────────────────┐  │
│  │   PostgreSQL    │   Auth Service  │  Storage Service │  │
│  │   Database      │                 │                  │  │
│  │  - RLS Enabled  │  - JWT Tokens   │  - Private       │  │
│  │  - Encrypted    │  - Email Auth   │    Buckets       │  │
│  │  - Backups      │  - Sessions     │  - Signed URLs   │  │
│  └─────────────────┴─────────────────┴──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | React 19 + TypeScript | UI Framework |
| **Build Tool** | Vite | Fast builds and HMR |
| **Styling** | Tailwind CSS 4 | Utility-first CSS |
| **UI Components** | shadcn/ui (Radix) | Accessible components |
| **Hosting** | Netlify | Static site hosting + CDN |
| **Database** | Supabase (PostgreSQL) | Relational database |
| **Authentication** | Supabase Auth | User authentication |
| **Storage** | Supabase Storage | File storage |
| **DNS** | Netlify DNS | Domain management |
| **SSL** | Let's Encrypt (via Netlify) | HTTPS certificates |

---

## Network Architecture

### DNS Configuration

```
uniquestaffingprofessionals.com
├── A Record → Netlify Load Balancer
├── AAAA Record → Netlify IPv6
├── CNAME (www) → uniquestaffingprofessionals.com
└── TXT Records
    ├── SPF (if email configured)
    └── Domain verification
```

### Traffic Flow

```
User Request
    │
    ▼
DNS Resolution
    │
    ▼
Netlify Edge (Closest POP)
    │
    ├─→ Cache Hit? → Serve from Edge
    │
    └─→ Cache Miss
        │
        ▼
    Origin Server (Netlify)
        │
        ▼
    Static Assets Served
        │
        ▼
    Browser Executes React App
        │
        ▼
    API Calls to Supabase
        │
        ├─→ Database Queries
        ├─→ Authentication
        └─→ File Storage
```

### Network Security

#### Firewall Rules
- **Inbound**: HTTPS (443) only
- **Outbound**: Supabase API endpoints only
- **Rate Limiting**: 100 req/min per IP

#### DDoS Protection
- Netlify Edge Network
- Automatic traffic filtering
- Rate limiting at edge
- Geographic blocking (if needed)

---

## Hosting Infrastructure

### Netlify Configuration

#### Build Settings
```toml
# netlify.toml
[build]
  command = "npm run build"
  publish = "dist"
  functions = "netlify/functions"

[build.environment]
  NODE_VERSION = "18"
  NPM_VERSION = "9"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "geolocation=(), microphone=(), camera=()"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

#### Deployment Pipeline
```
Git Push
    │
    ▼
GitHub Webhook
    │
    ▼
Netlify Build Trigger
    │
    ├─→ Install Dependencies (npm ci)
    ├─→ Run Build (npm run build)
    ├─→ Run Tests (if configured)
    └─→ Deploy to CDN
        │
        ├─→ Deploy Preview (PR)
        └─→ Deploy Production (main branch)
```

#### Environment Variables
```bash
# Production
VITE_SUPABASE_URL=https://[project-id].supabase.co
VITE_SUPABASE_ANON_KEY=[anon-key]

# Optional
VITE_GA_TRACKING_ID=[ga-id]
VITE_SENTRY_DSN=[sentry-dsn]
```

### CDN Configuration

#### Edge Locations
- Global distribution via Netlify Edge
- Automatic routing to nearest POP
- Edge caching for static assets

#### Cache Strategy
```
Asset Type          | Cache Duration | Strategy
--------------------|----------------|------------------
HTML                | No cache       | Always fresh
CSS/JS (hashed)     | 1 year         | Immutable
Images              | 1 year         | Immutable
API Responses       | No cache       | Always fresh
```

---

## Database Infrastructure

### Supabase PostgreSQL

#### Database Configuration
```
Instance Type: Shared (Free Tier) / Dedicated (Paid)
PostgreSQL Version: 15.x
Region: US East (or closest to users)
Storage: Auto-scaling
Backups: Daily automated
Point-in-Time Recovery: 7 days
```

#### Connection Pooling
```
Mode: Transaction
Pool Size: 15 (free tier) / Custom (paid)
Timeout: 30 seconds
Max Client Connections: 100
```

#### Database Schema

```sql
-- Tables
applicants
├── id (uuid, PK)
├── created_at (timestamp)
├── updated_at (timestamp)
├── full_name (varchar)
├── email (varchar)
├── phone (varchar)
├── position_interested (varchar)
├── experience_years (int)
├── resume_url (text)
├── resume_filename (varchar)
├── cover_letter (text)
├── status (enum)
└── notes (text)

business_info
├── id (uuid, PK)
├── created_at (timestamp)
├── updated_at (timestamp)
├── company_name (varchar)
├── phone (varchar)
├── email (varchar)
├── address (text)
├── hours (jsonb)
└── description (text)

testimonials
├── id (uuid, PK)
├── created_at (timestamp)
├── updated_at (timestamp)
├── author_name (varchar)
├── author_title (varchar)
├── rating (int)
├── content (text)
└── is_active (boolean)

testimonial_translations
├── id (uuid, PK)
├── testimonial_id (uuid, FK)
├── language (varchar)
├── content (text)
└── created_at (timestamp)

service_translations
├── id (uuid, PK)
├── service_key (varchar)
├── language (varchar)
├── title (varchar)
├── description (text)
└── created_at (timestamp)
```

#### Indexes
```sql
-- Performance indexes
CREATE INDEX idx_applicants_status ON applicants(status);
CREATE INDEX idx_applicants_created_at ON applicants(created_at DESC);
CREATE INDEX idx_applicants_email ON applicants(email);
CREATE INDEX idx_testimonials_active ON testimonials(is_active);
CREATE INDEX idx_translations_language ON testimonial_translations(language);
```

#### Row Level Security (RLS)

```sql
-- Public can insert applications
CREATE POLICY "Anyone can submit applications"
ON applicants FOR INSERT
TO anon
WITH CHECK (true);

-- Only authenticated users can view
CREATE POLICY "Authenticated users can view applicants"
ON applicants FOR SELECT
TO authenticated
USING (true);

-- Only authenticated users can update
CREATE POLICY "Authenticated users can update applicants"
ON applicants FOR UPDATE
TO authenticated
USING (true);

-- Only authenticated users can delete
CREATE POLICY "Authenticated users can delete applicants"
ON applicants FOR DELETE
TO authenticated
USING (true);
```

### Database Monitoring

#### Metrics to Track
- Connection pool usage
- Query performance
- Database size
- Table sizes
- Index usage
- Slow queries

#### Alerts
- Connection pool > 80%
- Database size > 80% of quota
- Slow queries > 1 second
- Failed queries > 1%

---

## Storage Infrastructure

### Supabase Storage

#### Bucket Configuration
```
Bucket: resumes
├── Public: false
├── File Size Limit: 5 MB
├── Allowed MIME Types:
│   ├── application/pdf
│   ├── application/msword
│   └── application/vnd.openxmlformats-officedocument.wordprocessingml.document
└── RLS Policies:
    ├── Upload: Public (with validation)
    └── Download: Authenticated only
```

#### Storage Policies

```sql
-- Anyone can upload resumes
CREATE POLICY "Anyone can upload resumes"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (
  bucket_id = 'resumes' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Only authenticated users can download
CREATE POLICY "Authenticated users can download resumes"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'resumes');
```

#### File Organization
```
resumes/
├── [applicant-id]/
│   └── resume.[ext]
└── [applicant-id]/
    └── resume.[ext]
```

### Storage Monitoring

#### Metrics
- Total storage used
- Number of files
- Upload success rate
- Download success rate
- Average file size

#### Alerts
- Storage > 80% of quota
- Upload failures > 5%
- Unusual file sizes

---

## Security Infrastructure

### SSL/TLS Configuration

#### Certificate Management
- **Provider**: Let's Encrypt (via Netlify)
- **Auto-renewal**: Yes
- **Protocol**: TLS 1.3
- **Cipher Suites**: Modern only

#### HTTPS Enforcement
```toml
# netlify.toml
[[redirects]]
  from = "http://*"
  to = "https://:splat"
  status = 301
  force = true
```

### Security Headers

```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'
```

### Authentication Security

#### Supabase Auth Configuration
```
Password Requirements:
├── Minimum Length: 8 characters
├── Complexity: Not enforced (Supabase default)
└── Breach Detection: Enabled

Session Management:
├── Session Duration: 24 hours
├── Refresh Token: 30 days
├── Token Rotation: Enabled
└── Concurrent Sessions: Allowed

Email Verification:
├── Required: Yes
├── Expiration: 24 hours
└── Resend Limit: 3 per hour
```

### API Security

#### Rate Limiting
```
Endpoint              | Rate Limit
----------------------|------------------
Public API            | 100 req/min/IP
Authenticated API     | 1000 req/hour/user
File Upload           | 10 req/min/IP
Authentication        | 5 req/min/IP
```

#### CORS Configuration
```typescript
// Supabase CORS (configured in dashboard)
Allowed Origins: https://uniquestaffingprofessionals.com
Allowed Methods: GET, POST, PUT, DELETE
Allowed Headers: Authorization, Content-Type
Credentials: true
```

---

## Monitoring Infrastructure

### Application Monitoring

#### Netlify Analytics
- Page views
- Unique visitors
- Top pages
- Bandwidth usage
- Build status

#### Supabase Monitoring
- Database metrics
- API requests
- Storage usage
- Active connections
- Query performance

### Recommended Monitoring (Not Implemented)

#### Error Tracking (Sentry)
```typescript
// Recommended configuration
Sentry.init({
  dsn: process.env.VITE_SENTRY_DSN,
  environment: process.env.MODE,
  tracesSampleRate: 0.1,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
})
```

#### Uptime Monitoring (UptimeRobot)
```
Monitors:
├── HTTPS Monitor
│   ├── URL: https://uniquestaffingprofessionals.com
│   ├── Interval: 5 minutes
│   └── Alert: Email + SMS
├── API Monitor
│   ├── URL: https://[project-id].supabase.co/rest/v1/
│   ├── Interval: 5 minutes
│   └── Alert: Email
└── SSL Monitor
    ├── Domain: uniquestaffingprofessionals.com
    ├── Check: Certificate expiration
    └── Alert: 30 days before expiry
```

---

## Disaster Recovery

### Backup Strategy

#### Database Backups
```
Type: Automated
Frequency: Daily
Retention: 7 days (free tier) / 30 days (paid)
Location: Supabase managed
Recovery Time Objective (RTO): 1 hour
Recovery Point Objective (RPO): 24 hours
```

#### Storage Backups
```
Type: Automated (Supabase managed)
Frequency: Continuous
Retention: 7 days
Location: Supabase managed
```

#### Code Backups
```
Type: Version Control (Git)
Location: GitHub
Retention: Indefinite
Branches: Protected main branch
```

### Recovery Procedures

#### Database Recovery
```bash
# 1. Access Supabase Dashboard
# 2. Navigate to Database → Backups
# 3. Select backup to restore
# 4. Click "Restore"
# 5. Verify data integrity
# 6. Update application if needed
```

#### Application Recovery
```bash
# 1. Identify last working deployment
# 2. Rollback via Netlify dashboard
# 3. Or redeploy from Git
git checkout [last-working-commit]
git push origin main --force

# 4. Verify deployment
curl -I https://uniquestaffingprofessionals.com
```

### Business Continuity

#### Service Level Objectives (SLO)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Uptime | 99.9% | Monthly |
| Response Time | < 500ms | p95 |
| Error Rate | < 1% | Hourly |
| Recovery Time | < 1 hour | Per incident |

#### Incident Response
See `.docs/RUNBOOK.md` for detailed incident response procedures.

---

## Infrastructure Costs

### Current Costs (Estimated)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| Netlify | Free | $0 |
| Supabase | Free | $0 |
| Domain | Varies | ~$12/year |
| **Total** | | **~$1/month** |

### Scaling Costs (Estimated)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| Netlify | Pro | $19 |
| Supabase | Pro | $25 |
| Sentry | Team | $26 |
| UptimeRobot | Pro | $7 |
| **Total** | | **~$77/month** |

---

## Infrastructure Improvements

### Short-term (1-3 months)
- [ ] Implement error tracking (Sentry)
- [ ] Set up uptime monitoring (UptimeRobot)
- [ ] Configure custom SMTP for emails
- [ ] Implement rate limiting at application level
- [ ] Add performance monitoring

### Medium-term (3-6 months)
- [ ] Upgrade to paid Supabase tier
- [ ] Implement CDN caching strategy
- [ ] Add database read replicas
- [ ] Implement automated testing in CI/CD
- [ ] Set up staging environment

### Long-term (6-12 months)
- [ ] Multi-region deployment
- [ ] Advanced monitoring and alerting
- [ ] Automated scaling
- [ ] Disaster recovery drills
- [ ] Performance optimization

---

## References

### Documentation
- [Netlify Documentation](https://docs.netlify.com/)
- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Related Documents
- [OPERATIONAL_STANDARDS.md](.docs/OPERATIONAL_STANDARDS.md)
- [RUNBOOK.md](.docs/RUNBOOK.md)
- [SECURITY.md](../SECURITY.md)
- [DISASTER_RECOVERY.md](.docs/RUNBOOK.md#disaster-recovery)

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Next Review**: March 2026  
**Maintained By**: Infrastructure Team
