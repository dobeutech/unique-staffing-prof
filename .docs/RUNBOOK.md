# Operations Runbook

## Overview

Operational procedures and troubleshooting guide for the Unique Staffing Professionals application.

## Quick Reference

### Emergency Contacts
- **Development Team**: [Contact Info]
- **Supabase Support**: https://supabase.com/support
- **Netlify Support**: https://www.netlify.com/support/

### Critical URLs
- **Production**: https://uniquestaffingprofessionals.com
- **Admin Dashboard**: https://uniquestaffingprofessionals.com/admin/dashboard
- **Supabase Dashboard**: https://app.supabase.com
- **Netlify Dashboard**: https://app.netlify.com

## System Architecture

```
User → Netlify CDN → React App → Supabase → PostgreSQL
                                  ↓
                              Storage Bucket
```

## Monitoring

### Health Checks

#### Application Health
```bash
# Check if site is up
curl -I https://uniquestaffingprofessionals.com

# Expected: HTTP 200 OK
```

#### API Health
```bash
# Check Supabase connection
curl https://[project-id].supabase.co/rest/v1/

# Expected: 200 with API info
```

### Key Metrics

#### Performance
- **Page Load Time**: < 3 seconds
- **Time to Interactive**: < 5 seconds
- **Lighthouse Score**: > 90

#### Availability
- **Uptime Target**: 99.9%
- **Response Time**: < 500ms (p95)

#### Business Metrics
- **Applications per Day**: Track in admin dashboard
- **Conversion Rate**: Applications / Visitors
- **Bounce Rate**: < 40%

### Monitoring Tools

#### Netlify Analytics
1. Log into Netlify dashboard
2. Select site
3. View Analytics tab
4. Monitor:
   - Page views
   - Unique visitors
   - Top pages
   - Bandwidth usage

#### Supabase Dashboard
1. Log into Supabase dashboard
2. Select project
3. Monitor:
   - Database size
   - API requests
   - Storage usage
   - Active connections

## Common Operations

### Deployment

#### Production Deployment
```bash
# 1. Ensure all tests pass
npm run lint
npx tsc --noEmit

# 2. Build locally to verify
npm run build

# 3. Deploy to production
npx netlify deploy --prod

# 4. Verify deployment
curl -I https://uniquestaffingprofessionals.com
```

#### Rollback Deployment
```bash
# 1. Log into Netlify dashboard
# 2. Go to Deploys tab
# 3. Find previous working deployment
# 4. Click "Publish deploy"
```

### Database Operations

#### Backup Database
```sql
-- In Supabase Dashboard → Database → Backups
-- Or use pg_dump:
pg_dump -h [host] -U postgres -d postgres > backup.sql
```

#### Restore Database
```sql
-- In Supabase Dashboard → Database → Backups
-- Or use psql:
psql -h [host] -U postgres -d postgres < backup.sql
```

#### Check Database Size
```sql
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Storage Operations

#### Check Storage Usage
```sql
SELECT
  bucket_id,
  COUNT(*) as file_count,
  pg_size_pretty(SUM(metadata->>'size')::bigint) as total_size
FROM storage.objects
GROUP BY bucket_id;
```

#### Clean Old Files
```sql
-- Delete files older than 1 year
DELETE FROM storage.objects
WHERE bucket_id = 'resumes'
AND created_at < NOW() - INTERVAL '1 year';
```

### User Management

#### Create Admin User
```sql
-- In Supabase Dashboard → Authentication → Users
-- Click "Add user"
-- Or via SQL:
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at)
VALUES (
  'admin@example.com',
  crypt('password', gen_salt('bf')),
  NOW()
);
```

#### Reset User Password
```bash
# In Supabase Dashboard → Authentication → Users
# Find user → Click "..." → Send password recovery email
```

#### Disable User
```sql
UPDATE auth.users
SET banned_until = NOW() + INTERVAL '1 year'
WHERE email = 'user@example.com';
```

## Troubleshooting

### Application Issues

#### Site Not Loading

**Symptoms**: Site returns 404 or doesn't load

**Diagnosis**:
```bash
# Check DNS
nslookup uniquestaffingprofessionals.com

# Check SSL
curl -vI https://uniquestaffingprofessionals.com

# Check Netlify status
curl https://www.netlifystatus.com/api/v2/status.json
```

**Resolution**:
1. Check Netlify dashboard for deployment errors
2. Verify DNS settings
3. Check SSL certificate expiration
4. Redeploy if necessary

#### Slow Page Load

**Symptoms**: Pages take > 5 seconds to load

**Diagnosis**:
```bash
# Run Lighthouse audit
npx lighthouse https://uniquestaffingprofessionals.com --view

# Check bundle size
npm run build
ls -lh dist/assets/
```

**Resolution**:
1. Check Netlify CDN status
2. Optimize images
3. Review bundle size
4. Enable caching headers
5. Consider code splitting

#### JavaScript Errors

**Symptoms**: Console errors, broken functionality

**Diagnosis**:
1. Open browser DevTools
2. Check Console tab for errors
3. Check Network tab for failed requests

**Resolution**:
1. Check error message and stack trace
2. Verify environment variables
3. Check for API changes
4. Review recent deployments
5. Rollback if necessary

### Database Issues

#### Connection Errors

**Symptoms**: "Failed to connect to database"

**Diagnosis**:
```bash
# Check Supabase status
curl https://status.supabase.com/api/v2/status.json

# Test connection
curl https://[project-id].supabase.co/rest/v1/
```

**Resolution**:
1. Check Supabase dashboard for outages
2. Verify connection string
3. Check RLS policies
4. Verify API keys
5. Check rate limits

#### Slow Queries

**Symptoms**: Database operations take > 1 second

**Diagnosis**:
```sql
-- Check slow queries
SELECT
  query,
  calls,
  total_time,
  mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

**Resolution**:
1. Add indexes to frequently queried columns
2. Optimize query structure
3. Review RLS policies
4. Consider caching
5. Upgrade database plan if needed

#### Storage Full

**Symptoms**: "Storage quota exceeded"

**Diagnosis**:
```sql
-- Check storage usage
SELECT pg_size_pretty(pg_database_size('postgres'));
```

**Resolution**:
1. Clean old data
2. Archive old records
3. Optimize file storage
4. Upgrade storage plan

### Authentication Issues

#### Users Can't Login

**Symptoms**: Login fails with valid credentials

**Diagnosis**:
1. Check Supabase Auth logs
2. Verify email confirmation
3. Check user status (banned, deleted)

**Resolution**:
1. Verify Supabase Auth configuration
2. Check email delivery
3. Reset user password
4. Verify RLS policies
5. Check session expiration

#### Email Verification Not Working

**Symptoms**: Verification emails not received

**Diagnosis**:
1. Check Supabase email logs
2. Verify email template configuration
3. Check spam folder

**Resolution**:
1. Configure custom SMTP (if needed)
2. Verify email template
3. Check email rate limits
4. Whitelist sender domain

### File Upload Issues

#### Upload Fails

**Symptoms**: Resume upload returns error

**Diagnosis**:
```javascript
// Check browser console for errors
// Check Network tab for failed requests
```

**Resolution**:
1. Verify file size < 5MB
2. Check file type (PDF, DOC, DOCX)
3. Verify storage bucket permissions
4. Check storage quota
5. Review RLS policies

#### Can't Download Resume

**Symptoms**: Resume download fails or returns 403

**Diagnosis**:
```sql
-- Check file exists
SELECT * FROM storage.objects
WHERE bucket_id = 'resumes'
AND name = 'filename.pdf';

-- Check RLS policies
SELECT * FROM storage.policies
WHERE bucket_id = 'resumes';
```

**Resolution**:
1. Verify file exists in storage
2. Check RLS policies
3. Verify signed URL generation
4. Check user authentication
5. Verify file permissions

## Maintenance

### Daily Tasks
- [ ] Check error logs
- [ ] Monitor application performance
- [ ] Review new applications

### Weekly Tasks
- [ ] Review analytics
- [ ] Check database size
- [ ] Review storage usage
- [ ] Check for security updates

### Monthly Tasks
- [ ] Update dependencies
- [ ] Review and archive old data
- [ ] Performance audit
- [ ] Security audit
- [ ] Backup verification

### Quarterly Tasks
- [ ] Review and update documentation
- [ ] Disaster recovery drill
- [ ] Capacity planning
- [ ] Security assessment

## Disaster Recovery

### Data Loss

**Scenario**: Database data lost or corrupted

**Recovery Steps**:
1. Stop all write operations
2. Assess extent of data loss
3. Restore from latest backup
4. Verify data integrity
5. Resume operations
6. Document incident

**Prevention**:
- Automated daily backups
- Point-in-time recovery enabled
- Regular backup testing

### Service Outage

**Scenario**: Application completely unavailable

**Recovery Steps**:
1. Check Netlify and Supabase status
2. Verify DNS configuration
3. Check SSL certificates
4. Review recent deployments
5. Rollback if necessary
6. Communicate with users

**Prevention**:
- Multiple deployment environments
- Automated health checks
- Incident response plan

### Security Breach

**Scenario**: Unauthorized access detected

**Recovery Steps**:
1. Isolate affected systems
2. Change all credentials
3. Review access logs
4. Assess data exposure
5. Notify affected users
6. Implement additional security measures
7. Document incident

**Prevention**:
- Regular security audits
- Strong authentication
- RLS policies
- Monitoring and alerting

## Escalation

### Level 1: Self-Service
- Check this runbook
- Review documentation
- Check status pages

### Level 2: Development Team
- Create issue in GitHub
- Contact via email/Slack
- Provide error logs and steps to reproduce

### Level 3: Vendor Support
- Supabase support for database issues
- Netlify support for hosting issues
- Provide account details and error logs

## Appendix

### Useful Commands

```bash
# Check environment
npm run env-check

# Run linter
npm run lint

# Type check
npx tsc --noEmit

# Build
npm run build

# Deploy
npx netlify deploy --prod

# Check dependencies
npm run deps-audit

# Accessibility check
npm run a11y-check
```

### Useful SQL Queries

```sql
-- Count applicants by status
SELECT status, COUNT(*) as count
FROM applicants
GROUP BY status;

-- Recent applications
SELECT full_name, email, created_at
FROM applicants
ORDER BY created_at DESC
LIMIT 10;

-- Storage usage
SELECT
  bucket_id,
  COUNT(*) as files,
  pg_size_pretty(SUM((metadata->>'size')::bigint)) as size
FROM storage.objects
GROUP BY bucket_id;
```

### Log Locations

- **Netlify Build Logs**: Netlify Dashboard → Deploys → [Deploy] → Deploy log
- **Netlify Function Logs**: Netlify Dashboard → Functions → [Function] → Logs
- **Supabase Logs**: Supabase Dashboard → Logs
- **Browser Console**: Browser DevTools → Console

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Operations Team
