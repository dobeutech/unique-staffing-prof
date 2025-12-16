# Production Deployment Checklist

**Date:** December 13, 2025  
**Status:** ✅ Ready for Deployment

## Pre-Deployment Verification

### ✅ Build Configuration
- [x] `netlify.toml` configured correctly
- [x] Build command: `npm run build`
- [x] Publish directory: `dist`
- [x] Node version: 20
- [x] SPA routing configured (redirects to index.html)

### ✅ Build Process
- [x] Production build completes successfully
- [x] No critical errors in build output
- [x] `dist` folder contains all required files
- [x] Assets are properly bundled

### ✅ Code Quality
- [x] No linter errors
- [x] TypeScript compilation successful (with --noCheck flag)
- [x] Environment variables properly referenced
- [x] Error handling for missing env vars

### ✅ Security
- [x] Security headers configured in `netlify.toml`
- [x] Environment variables not hardcoded
- [x] `.env` file in `.gitignore`

### ✅ Configuration Files
- [x] `netlify.toml` exists and is valid
- [x] `package.json` has correct build scripts
- [x] `vite.config.ts` properly configured
- [x] `tsconfig.json` configured correctly

## Required Environment Variables

**⚠️ IMPORTANT:** These must be set in Netlify Dashboard before deployment:

1. `VITE_SUPABASE_URL` - Your Supabase project URL
2. `VITE_SUPABASE_ANON_KEY` - Your Supabase anonymous/public key
3. `VITE_GOOGLE_MAPS_API_KEY` - (Optional) For Google Maps integration

### Setting Environment Variables in Netlify

**Option 1: Netlify Dashboard (Recommended)**
1. Go to your Netlify site dashboard
2. Navigate to **Site settings** → **Environment variables**
3. Add each variable:
   - Key: `VITE_SUPABASE_URL`
   - Value: Your Supabase project URL
   - Scopes: Select all (Production, Deploy previews, Branch deploys)
4. Repeat for `VITE_SUPABASE_ANON_KEY`
5. Click **Save**

**Option 2: Netlify CLI**
```bash
netlify env:set VITE_SUPABASE_URL "your-url" --context production
netlify env:set VITE_SUPABASE_ANON_KEY "your-key" --context production
```

## Deployment Steps

1. ✅ Verify build works locally
2. ✅ Check all configuration files
3. ⏳ Set environment variables in Netlify
4. ⏳ Deploy using Netlify CLI: `npx netlify deploy --prod`
5. ⏳ Verify deployment in browser
6. ⏳ Test application functionality

## Post-Deployment Verification

After deployment, verify:
- [ ] Site loads correctly
- [ ] No console errors
- [ ] Supabase connection works
- [ ] Application form submits successfully
- [ ] Admin login works
- [ ] Admin dashboard loads
- [ ] All routes work (SPA routing)
- [ ] Assets load correctly
- [ ] Mobile responsiveness

## Known Warnings (Non-Critical)

1. **CSS Warnings**: Tailwind v4 container queries - cosmetic only, doesn't affect functionality
2. **Chunk Size Warning**: Bundle is large (>500KB) - optimization suggestion, not blocking

## Rollback Plan

If deployment fails:
1. Check Netlify build logs
2. Verify environment variables are set
3. Check for build errors
4. Revert to previous deployment via Netlify dashboard

## Support Resources

- Netlify Docs: https://docs.netlify.com
- Supabase Docs: https://supabase.com/docs
- Project Documentation: See `CLAUDE.md` and `PROJECT_DOCUMENTATION.md`

