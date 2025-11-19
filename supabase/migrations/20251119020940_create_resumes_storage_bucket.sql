/*
  # Create Storage Bucket for Resumes

  ## Summary
  Sets up secure file storage for applicant resumes with proper access policies.

  ## 1. Storage Buckets
    - `resumes` - Private bucket for storing applicant resume files
      - Not publicly accessible
      - Requires authentication to view/download

  ## 2. Storage Policies
    - Public (anon) users can upload resumes during application submission
    - Authenticated admin users can view/download resumes
    - Authenticated admin users can delete resumes if needed

  ## 3. Security Notes
    - Bucket is private (public = false) for data protection
    - Only authenticated users can access stored files
    - Public can only INSERT (upload) during application process
    - Files are not accessible via direct URLs without authentication
*/

-- Create storage bucket for resumes (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('resumes', 'resumes', false)
ON CONFLICT (id) DO NOTHING;

-- Policy: Anyone can upload resumes
CREATE POLICY "Anyone can upload resumes"
  ON storage.objects
  FOR INSERT
  TO anon
  WITH CHECK (bucket_id = 'resumes');

-- Policy: Authenticated users can view resumes
CREATE POLICY "Authenticated users can view resumes"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'resumes');

-- Policy: Authenticated users can delete resumes
CREATE POLICY "Authenticated users can delete resumes"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'resumes');