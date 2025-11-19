/*
  # Fix Security Issues - Corrected

  ## Summary
  Addresses security concerns identified in the database audit including:
  - Removal of unused indexes to improve performance
  - Consolidation of multiple permissive RLS policies
  - Fixing mutable search_path issues in functions

  ## 1. Remove Unused Indexes
    All indexes that are not being utilized will be dropped

  ## 2. Fix Multiple Permissive Policies
    Consolidate overlapping policies to prevent unintended access

  ## 3. Fix Function Search Path Issues
    Update all functions to use SECURITY DEFINER with explicit search_path

  ## 4. Important Notes
    - Column names corrected: is_active, is_published, is_featured
    - Unused indexes are safe to remove as they're not being queried
    - Policy consolidation maintains same access levels
    - Function search_path fixes are critical security improvements
*/

-- ============================================================================
-- 1. REMOVE UNUSED INDEXES
-- ============================================================================

-- Drop unused indexes on testimonial_translations
DROP INDEX IF EXISTS idx_testimonial_translations_testimonial_id;
DROP INDEX IF EXISTS idx_testimonial_translations_language;

-- Drop unused indexes on service_translations
DROP INDEX IF EXISTS idx_service_translations_service_key;
DROP INDEX IF EXISTS idx_service_translations_language;

-- Drop unused indexes on applicants
DROP INDEX IF EXISTS idx_applicants_email;
DROP INDEX IF EXISTS idx_applicants_status;
DROP INDEX IF EXISTS idx_applicants_created_at;
DROP INDEX IF EXISTS idx_applicants_email_verified;
DROP INDEX IF EXISTS idx_applicants_verification_token;
DROP INDEX IF EXISTS idx_applicants_positions_interested;

-- Drop unused indexes on applicant_documents
DROP INDEX IF EXISTS idx_applicant_documents_applicant_id;

-- Drop unused indexes on email_verification_log
DROP INDEX IF EXISTS idx_email_verification_log_token;
DROP INDEX IF EXISTS idx_email_verification_log_applicant;
DROP INDEX IF EXISTS idx_email_verification_log_email;

-- Drop unused indexes on business_info
DROP INDEX IF EXISTS idx_business_info_active;

-- Drop unused indexes on service_areas
DROP INDEX IF EXISTS idx_service_areas_active;
DROP INDEX IF EXISTS idx_service_areas_state;

-- Drop unused indexes on local_testimonials
DROP INDEX IF EXISTS idx_local_testimonials_active;
DROP INDEX IF EXISTS idx_local_testimonials_featured;
DROP INDEX IF EXISTS idx_local_testimonials_service_area;

-- Drop unused indexes on local_content
DROP INDEX IF EXISTS idx_local_content_published;
DROP INDEX IF EXISTS idx_local_content_service_area;
DROP INDEX IF EXISTS idx_local_content_type;

-- ============================================================================
-- 2. FIX MULTIPLE PERMISSIVE POLICIES
-- ============================================================================

-- Fix business_info policies
DROP POLICY IF EXISTS "Anyone can view active business info" ON business_info;
DROP POLICY IF EXISTS "Authenticated users can view all business info" ON business_info;

CREATE POLICY "Public can view active business info"
  ON business_info
  FOR SELECT
  TO anon
  USING (is_active = true);

CREATE POLICY "Authenticated users can view all business info"
  ON business_info
  FOR SELECT
  TO authenticated
  USING (true);

-- Fix local_content policies
DROP POLICY IF EXISTS "Anyone can view published content" ON local_content;
DROP POLICY IF EXISTS "Authenticated users can view all content" ON local_content;

CREATE POLICY "Public can view published content"
  ON local_content
  FOR SELECT
  TO anon
  USING (is_published = true);

CREATE POLICY "Authenticated users can view all content"
  ON local_content
  FOR SELECT
  TO authenticated
  USING (true);

-- Fix local_testimonials policies
DROP POLICY IF EXISTS "Anyone can view active testimonials" ON local_testimonials;
DROP POLICY IF EXISTS "Authenticated users can view all testimonials" ON local_testimonials;

CREATE POLICY "Public can view active testimonials"
  ON local_testimonials
  FOR SELECT
  TO anon
  USING (is_active = true);

CREATE POLICY "Authenticated users can view all testimonials"
  ON local_testimonials
  FOR SELECT
  TO authenticated
  USING (true);

-- Fix service_areas policies
DROP POLICY IF EXISTS "Anyone can view active service areas" ON service_areas;
DROP POLICY IF EXISTS "Authenticated users can view all service areas" ON service_areas;

CREATE POLICY "Public can view active service areas"
  ON service_areas
  FOR SELECT
  TO anon
  USING (is_active = true);

CREATE POLICY "Authenticated users can view all service areas"
  ON service_areas
  FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================================
-- 3. FIX FUNCTION SEARCH PATH ISSUES
-- ============================================================================

-- Recreate update_updated_at_column with secure search_path
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$;

-- Recreate normalize_phone with secure search_path
CREATE OR REPLACE FUNCTION normalize_phone(phone_number TEXT)
RETURNS TEXT
SECURITY DEFINER
SET search_path = public, pg_temp
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  -- Remove all non-numeric characters
  RETURN regexp_replace(phone_number, '[^0-9]', '', 'g');
END;
$$;

-- Recreate update_phone_normalized with secure search_path
CREATE OR REPLACE FUNCTION update_phone_normalized()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public, pg_temp
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.phone_normalized = normalize_phone(NEW.phone);
  RETURN NEW;
END;
$$;

-- ============================================================================
-- 4. CREATE ONLY NECESSARY INDEXES (Optimized)
-- ============================================================================

-- Applicants table - keep phone_normalized for duplicate checks
CREATE INDEX IF NOT EXISTS idx_applicants_phone_normalized ON applicants(phone_normalized)
WHERE phone_normalized IS NOT NULL;

-- Email verification log - token lookup for verification (only unverified)
CREATE INDEX IF NOT EXISTS idx_email_verification_token ON email_verification_log(token)
WHERE verified_at IS NULL;

-- Applicant documents - for fetching documents by applicant
CREATE INDEX IF NOT EXISTS idx_applicant_docs_applicant ON applicant_documents(applicant_id);

-- Service areas - commonly filtered by state and active status
CREATE INDEX IF NOT EXISTS idx_service_areas_state_active ON service_areas(state, is_active)
WHERE is_active = true;

-- Local testimonials - featured ones for homepage
CREATE INDEX IF NOT EXISTS idx_testimonials_featured_active ON local_testimonials(is_featured, is_active)
WHERE is_active = true AND is_featured = true;

-- ============================================================================
-- 5. GRANT APPROPRIATE PERMISSIONS
-- ============================================================================

-- Ensure functions can be executed by appropriate roles
GRANT EXECUTE ON FUNCTION update_updated_at_column() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION normalize_phone(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_phone_normalized() TO anon, authenticated;
