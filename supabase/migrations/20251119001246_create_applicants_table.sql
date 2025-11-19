/*
  # Create Applicants Table and Configuration

  ## Summary
  Creates the complete applicant tracking system database schema with security policies
  and performance optimizations.

  ## 1. New Tables
    - `applicants` - Main table for storing job applicant information
      - `id` (uuid, primary key) - Unique identifier
      - `created_at` (timestamptz) - Application submission timestamp
      - `updated_at` (timestamptz) - Last modification timestamp
      - `full_name` (text) - Applicant's full name
      - `email` (text) - Contact email
      - `phone` (text) - Contact phone number
      - `position_interested` (text) - Desired position/role
      - `experience_years` (integer) - Years of professional experience
      - `resume_url` (text, nullable) - Storage URL for resume file
      - `resume_filename` (text, nullable) - Original resume filename
      - `cover_letter` (text, nullable) - Optional cover letter text
      - `status` (text) - Application status with constraint
      - `notes` (text, nullable) - Internal admin notes

  ## 2. Performance Indexes
    - Email index for faster applicant lookups
    - Status index for filtering applications by status
    - Created date index (descending) for sorting by newest first

  ## 3. Automated Triggers
    - Auto-update `updated_at` timestamp on any record modification

  ## 4. Security (Row Level Security)
    - RLS enabled on applicants table
    - Public users (anon) can INSERT applications only
    - Authenticated users can SELECT and UPDATE all applications
    - Ensures data protection while allowing public submissions

  ## 5. Important Notes
    - Status field has CHECK constraint for data integrity
    - All timestamps use UTC timezone
    - Indexes improve query performance for common operations
    - RLS policies follow principle of least privilege
*/

-- Create applicants table
CREATE TABLE IF NOT EXISTS applicants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  position_interested TEXT NOT NULL,
  experience_years INTEGER NOT NULL,
  resume_url TEXT,
  resume_filename TEXT,
  cover_letter TEXT,
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'reviewing', 'shortlisted', 'rejected', 'hired')),
  notes TEXT
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_applicants_email ON applicants(email);

-- Create index on status for filtering
CREATE INDEX IF NOT EXISTS idx_applicants_status ON applicants(status);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_applicants_created_at ON applicants(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE applicants ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert applicants (public form submission)
CREATE POLICY "Anyone can submit applications"
  ON applicants
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Authenticated users can view all applicants
CREATE POLICY "Authenticated users can view applicants"
  ON applicants
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Authenticated users can update applicants
CREATE POLICY "Authenticated users can update applicants"
  ON applicants
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_applicants_updated_at
  BEFORE UPDATE ON applicants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();