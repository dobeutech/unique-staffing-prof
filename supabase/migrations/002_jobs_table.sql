-- Jobs table migration
-- Run this in Supabase SQL Editor

-- Create jobs table
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT,
    location_city TEXT NOT NULL,
    location_state TEXT NOT NULL,
    location_zip TEXT NOT NULL,
    job_type TEXT NOT NULL CHECK (job_type IN ('full-time', 'part-time', 'contract', 'temporary')),
    category TEXT NOT NULL,
    salary_min INTEGER,
    salary_max INTEGER,
    salary_type TEXT CHECK (salary_type IN ('hourly', 'annual')),
    is_active BOOLEAN DEFAULT true NOT NULL,
    featured BOOLEAN DEFAULT false NOT NULL,
    expires_at TIMESTAMPTZ
);

-- Create index for common queries
CREATE INDEX IF NOT EXISTS idx_jobs_is_active ON public.jobs(is_active);
CREATE INDEX IF NOT EXISTS idx_jobs_location_zip ON public.jobs(location_zip);
CREATE INDEX IF NOT EXISTS idx_jobs_category ON public.jobs(category);
CREATE INDEX IF NOT EXISTS idx_jobs_featured ON public.jobs(featured);

-- Enable RLS
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;

-- Public can read active jobs
CREATE POLICY "Public can view active jobs"
    ON public.jobs
    FOR SELECT
    USING (is_active = true);

-- Authenticated users can manage all jobs
CREATE POLICY "Authenticated users can manage jobs"
    ON public.jobs
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Update trigger for updated_at
CREATE OR REPLACE FUNCTION update_jobs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER jobs_updated_at_trigger
    BEFORE UPDATE ON public.jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_jobs_updated_at();

-- Insert sample jobs for testing
INSERT INTO public.jobs (title, description, requirements, location_city, location_state, location_zip, job_type, category, salary_min, salary_max, salary_type, is_active, featured)
VALUES
    ('Warehouse Associate', 'Join our team as a warehouse associate. Responsibilities include picking, packing, and shipping orders.', 'Ability to lift 50 lbs, reliable transportation', 'Riverdale', 'MD', '20737', 'full-time', 'Industrial & Manufacturing', 15, 18, 'hourly', true, true),
    ('Office Administrator', 'Seeking an organized office administrator to manage daily operations and support staff.', 'Proficiency in Microsoft Office, 2+ years experience', 'College Park', 'MD', '20740', 'full-time', 'Human Resources', 40000, 50000, 'annual', true, false),
    ('Retail Sales Associate', 'Customer-focused individual needed for retail sales position. Evening and weekend availability required.', 'Previous retail experience preferred', 'Hyattsville', 'MD', '20781', 'part-time', 'Retail & Sales', 14, 16, 'hourly', true, false),
    ('Call Center Representative', 'Handle inbound customer inquiries and provide excellent service in our call center.', 'Excellent communication skills, bilingual Spanish a plus', 'Lanham', 'MD', '20706', 'full-time', 'Call Center & Customer Service', 35000, 42000, 'annual', true, true),
    ('Janitorial Technician', 'Maintain cleanliness in commercial buildings. Flexible hours available.', 'Must pass background check', 'Bowie', 'MD', '20715', 'contract', 'Janitorial', 13, 15, 'hourly', true, false);
