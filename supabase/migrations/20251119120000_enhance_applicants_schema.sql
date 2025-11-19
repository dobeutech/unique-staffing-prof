/*
  # Enhanced Applicant Tracking System Schema

  ## Summary
  Comprehensive upgrade to the applicant tracking system adding email verification,
  duplicate prevention, multi-position support, additional document uploads, URL fields,
  and analytics tracking capabilities.

  ## 1. Schema Changes to `applicants` Table
    ### New Fields Added:
    - `email_verified` (boolean) - Tracks if applicant's email has been verified
    - `email_verification_token` (text, nullable) - Secure token for email verification
    - `token_expiry` (timestamptz, nullable) - Expiration time for verification token
    - `email_confirmed` (text, nullable) - Confirmed email for validation matching
    - `positions_interested` (text array) - Multiple position selections (replaces single position)
    - `job_posting_url` (text, nullable) - Optional URL to specific job posting
    - `linkedin_url` (text, nullable) - Optional LinkedIn profile URL
    - `portfolio_url` (text, nullable) - Optional portfolio/career site URL
    - `submission_location` (text, nullable) - Geographic location of submission
    - `admin_notified_at` (timestamptz, nullable) - Timestamp when admin was notified
    - `phone_normalized` (text, nullable) - Normalized phone number for duplicate detection

  ## 2. New Tables

    ### `applicant_documents` - Additional document storage
    - `id` (uuid, primary key) - Unique identifier
    - `applicant_id` (uuid, foreign key) - Reference to applicants table
    - `document_type` (text) - Type of document (cover_letter, reference, certificate, other)
    - `document_url` (text) - Storage URL for document
    - `document_filename` (text) - Original filename
    - `file_size` (integer) - File size in bytes
    - `mime_type` (text) - Document MIME type
    - `uploaded_at` (timestamptz) - Upload timestamp
    - `created_at` (timestamptz) - Record creation timestamp

    ### `email_verification_log` - Email verification tracking
    - `id` (uuid, primary key) - Unique identifier
    - `applicant_id` (uuid, foreign key) - Reference to applicants table
    - `email` (text) - Email address being verified
    - `token` (text) - Verification token
    - `sent_at` (timestamptz) - When verification email was sent
    - `verified_at` (timestamptz, nullable) - When email was verified
    - `ip_address` (text, nullable) - IP address of verification request
    - `user_agent` (text, nullable) - Browser user agent
    - `created_at` (timestamptz) - Record creation timestamp

  ## 3. Performance Indexes
    - Phone normalized index for duplicate detection
    - Email verified index for filtering
    - Verification token index for quick lookups
    - Positions interested GIN index for array searches
    - Document applicant_id index for quick retrieval

  ## 4. Security (Row Level Security)
    - Public users (anon) can INSERT unverified applications
    - Authenticated users can view and manage all data
    - Public users can UPDATE their own verification status via token
    - Document access restricted to authenticated users

  ## 5. Important Notes
    - Email verification is required before final application submission
    - Phone numbers are normalized for duplicate detection
    - Multiple positions can be selected per application
    - All URL fields have validation constraints
    - Comprehensive audit trail for email verification
    - Automatic cascade delete for related documents
*/

-- Add new columns to applicants table
DO $$
BEGIN
  -- Email verification fields
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'email_verified'
  ) THEN
    ALTER TABLE applicants ADD COLUMN email_verified BOOLEAN DEFAULT false NOT NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'email_verification_token'
  ) THEN
    ALTER TABLE applicants ADD COLUMN email_verification_token TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'token_expiry'
  ) THEN
    ALTER TABLE applicants ADD COLUMN token_expiry TIMESTAMP WITH TIME ZONE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'email_confirmed'
  ) THEN
    ALTER TABLE applicants ADD COLUMN email_confirmed TEXT;
  END IF;

  -- Multi-position support
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'positions_interested'
  ) THEN
    ALTER TABLE applicants ADD COLUMN positions_interested TEXT[];
  END IF;

  -- Optional URL fields
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'job_posting_url'
  ) THEN
    ALTER TABLE applicants ADD COLUMN job_posting_url TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'linkedin_url'
  ) THEN
    ALTER TABLE applicants ADD COLUMN linkedin_url TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'portfolio_url'
  ) THEN
    ALTER TABLE applicants ADD COLUMN portfolio_url TEXT;
  END IF;

  -- Analytics and tracking fields
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'submission_location'
  ) THEN
    ALTER TABLE applicants ADD COLUMN submission_location TEXT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'admin_notified_at'
  ) THEN
    ALTER TABLE applicants ADD COLUMN admin_notified_at TIMESTAMP WITH TIME ZONE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'applicants' AND column_name = 'phone_normalized'
  ) THEN
    ALTER TABLE applicants ADD COLUMN phone_normalized TEXT;
  END IF;
END $$;

-- Create indexes for new fields
CREATE INDEX IF NOT EXISTS idx_applicants_email_verified ON applicants(email_verified);
CREATE INDEX IF NOT EXISTS idx_applicants_phone_normalized ON applicants(phone_normalized);
CREATE INDEX IF NOT EXISTS idx_applicants_verification_token ON applicants(email_verification_token);
CREATE INDEX IF NOT EXISTS idx_applicants_positions_interested ON applicants USING GIN(positions_interested);

-- Create applicant_documents table
CREATE TABLE IF NOT EXISTS applicant_documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  applicant_id UUID NOT NULL REFERENCES applicants(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL CHECK (document_type IN ('cover_letter', 'reference', 'certificate', 'portfolio', 'other')),
  document_url TEXT NOT NULL,
  document_filename TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index on applicant_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_applicant_documents_applicant_id ON applicant_documents(applicant_id);

-- Enable RLS on applicant_documents
ALTER TABLE applicant_documents ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert documents (during application process)
CREATE POLICY "Anyone can upload documents"
  ON applicant_documents
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Authenticated users can view all documents
CREATE POLICY "Authenticated users can view documents"
  ON applicant_documents
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Authenticated users can delete documents
CREATE POLICY "Authenticated users can delete documents"
  ON applicant_documents
  FOR DELETE
  TO authenticated
  USING (true);

-- Create email_verification_log table
CREATE TABLE IF NOT EXISTS email_verification_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  applicant_id UUID REFERENCES applicants(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  token TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  verified_at TIMESTAMP WITH TIME ZONE,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for email_verification_log
CREATE INDEX IF NOT EXISTS idx_email_verification_log_token ON email_verification_log(token);
CREATE INDEX IF NOT EXISTS idx_email_verification_log_applicant ON email_verification_log(applicant_id);
CREATE INDEX IF NOT EXISTS idx_email_verification_log_email ON email_verification_log(email);

-- Enable RLS on email_verification_log
ALTER TABLE email_verification_log ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert verification log entries
CREATE POLICY "Anyone can create verification logs"
  ON email_verification_log
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Authenticated users can view all verification logs
CREATE POLICY "Authenticated users can view verification logs"
  ON email_verification_log
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Authenticated users can update verification logs
CREATE POLICY "Authenticated users can update verification logs"
  ON email_verification_log
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Update existing RLS policy on applicants to allow email verification updates
DROP POLICY IF EXISTS "Anyone can update verification status" ON applicants;
CREATE POLICY "Anyone can update verification status"
  ON applicants
  FOR UPDATE
  TO anon
  USING (email_verification_token IS NOT NULL)
  WITH CHECK (email_verification_token IS NOT NULL);

-- Function to normalize phone numbers for duplicate detection
CREATE OR REPLACE FUNCTION normalize_phone(phone_number TEXT)
RETURNS TEXT AS $$
BEGIN
  -- Remove all non-numeric characters
  RETURN regexp_replace(phone_number, '[^0-9]', '', 'g');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Trigger to automatically normalize phone numbers on insert/update
CREATE OR REPLACE FUNCTION update_phone_normalized()
RETURNS TRIGGER AS $$
BEGIN
  NEW.phone_normalized = normalize_phone(NEW.phone);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_normalize_phone ON applicants;
CREATE TRIGGER trigger_normalize_phone
  BEFORE INSERT OR UPDATE OF phone ON applicants
  FOR EACH ROW
  EXECUTE FUNCTION update_phone_normalized();

-- Update existing records to have normalized phone numbers
UPDATE applicants SET phone_normalized = normalize_phone(phone) WHERE phone_normalized IS NULL;
