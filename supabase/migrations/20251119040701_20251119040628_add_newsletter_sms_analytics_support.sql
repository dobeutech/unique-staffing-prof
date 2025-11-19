/*
  # Add Newsletter, SMS, and Analytics Support

  ## Overview
  This migration adds comprehensive support for newsletter subscriptions, SMS notifications,
  cookie consent tracking, and visitor analytics to enable GDPR-compliant marketing and
  data collection capabilities.

  ## Changes

  ### 1. Update Applicants Table
  - Add `newsletter_subscribed` (boolean) - User opted in to receive newsletters
  - Add `job_notifications_enabled` (boolean) - User wants job opportunity emails
  - Add `sms_notifications_enabled` (boolean) - User consented to SMS notifications
  - Add `communication_preferences` (jsonb) - Store detailed preferences
  - Add `subscription_source` (text) - Track where user subscribed from
  - Add `last_communication_at` (timestamptz) - Track last contact date

  ### 2. Create visitor_analytics Table
  - Comprehensive visitor tracking for business intelligence
  - Stores IP address, location, device info, referrer, UTM parameters
  - Tracks page views, scroll depth, time on site
  - Mouse movement and click pattern tracking support

  ### 3. Create cookie_consent_log Table  
  - GDPR-compliant consent tracking
  - Records user preferences for necessary, functional, analytics, marketing cookies
  - Tracks when consent was given and from which IP/device

  ### 4. Create newsletter_subscriptions Table
  - Dedicated newsletter management separate from applicants
  - Tracks subscription status, source, and engagement
  - Supports double opt-in workflow

  ### 5. Create unsubscribe_log Table
  - Audit trail for all unsubscribe actions
  - Required for compliance and preventing re-subscription issues
  
  ## Security
  - RLS enabled on all new tables
  - Public can insert their own data (analytics, consent)
  - Only authenticated admin users can read/update
  - Applicants can update their own communication preferences
*/

-- Add communication preference fields to applicants table
ALTER TABLE applicants
ADD COLUMN IF NOT EXISTS newsletter_subscribed boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS job_notifications_enabled boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS sms_notifications_enabled boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS communication_preferences jsonb DEFAULT '{}',
ADD COLUMN IF NOT EXISTS subscription_source text,
ADD COLUMN IF NOT EXISTS last_communication_at timestamptz;

-- Create visitor analytics table
CREATE TABLE IF NOT EXISTS visitor_analytics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  
  -- Session tracking
  session_id text,
  visitor_id text,
  
  -- Device and location
  ip_address inet,
  user_agent text,
  device_type text,
  browser text,
  os text,
  country text,
  region text,
  city text,
  
  -- Referral tracking
  referrer text,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_term text,
  utm_content text,
  
  -- Page tracking
  page_url text,
  page_title text,
  time_on_page integer,
  scroll_depth integer,
  
  -- Interaction tracking
  clicks jsonb DEFAULT '[]',
  form_interactions jsonb DEFAULT '{}',
  
  -- Additional metadata
  metadata jsonb DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS visitor_analytics_session_id_idx ON visitor_analytics(session_id);
CREATE INDEX IF NOT EXISTS visitor_analytics_visitor_id_idx ON visitor_analytics(visitor_id);
CREATE INDEX IF NOT EXISTS visitor_analytics_created_at_idx ON visitor_analytics(created_at);
CREATE INDEX IF NOT EXISTS visitor_analytics_ip_address_idx ON visitor_analytics(ip_address);

ALTER TABLE visitor_analytics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert their analytics data"
  ON visitor_analytics FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Only admins can read analytics"
  ON visitor_analytics FOR SELECT
  TO authenticated
  USING (auth.jwt()->>'role' = 'admin');

-- Create cookie consent log table
CREATE TABLE IF NOT EXISTS cookie_consent_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- User identification
  visitor_id text NOT NULL,
  email text,
  ip_address inet,
  user_agent text,
  
  -- Consent preferences
  necessary_cookies boolean DEFAULT true,
  functional_cookies boolean DEFAULT false,
  analytics_cookies boolean DEFAULT false,
  marketing_cookies boolean DEFAULT false,
  
  -- Metadata
  consent_version text DEFAULT '1.0',
  metadata jsonb DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS cookie_consent_visitor_id_idx ON cookie_consent_log(visitor_id);
CREATE INDEX IF NOT EXISTS cookie_consent_email_idx ON cookie_consent_log(email);

ALTER TABLE cookie_consent_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert their consent preferences"
  ON cookie_consent_log FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own consent"
  ON cookie_consent_log FOR UPDATE
  TO anon, authenticated
  USING (visitor_id = current_setting('app.visitor_id', true))
  WITH CHECK (visitor_id = current_setting('app.visitor_id', true));

CREATE POLICY "Users can read their own consent"
  ON cookie_consent_log FOR SELECT
  TO anon, authenticated
  USING (visitor_id = current_setting('app.visitor_id', true) OR auth.jwt()->>'role' = 'admin');

-- Create newsletter subscriptions table
CREATE TABLE IF NOT EXISTS newsletter_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  email text UNIQUE NOT NULL,
  full_name text,
  
  -- Status tracking
  is_subscribed boolean DEFAULT true,
  is_verified boolean DEFAULT false,
  verification_token text,
  verification_sent_at timestamptz,
  verified_at timestamptz,
  
  -- Source tracking
  subscription_source text,
  referrer text,
  utm_params jsonb DEFAULT '{}',
  
  -- Engagement tracking
  last_email_sent_at timestamptz,
  last_email_opened_at timestamptz,
  total_emails_sent integer DEFAULT 0,
  total_emails_opened integer DEFAULT 0,
  
  -- Preferences
  preferences jsonb DEFAULT '{}',
  
  CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX IF NOT EXISTS newsletter_subscriptions_email_idx ON newsletter_subscriptions(email);
CREATE INDEX IF NOT EXISTS newsletter_subscriptions_is_subscribed_idx ON newsletter_subscriptions(is_subscribed);

ALTER TABLE newsletter_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can subscribe to newsletter"
  ON newsletter_subscriptions FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own subscription"
  ON newsletter_subscriptions FOR UPDATE
  TO anon, authenticated
  USING (email = current_setting('app.user_email', true))
  WITH CHECK (email = current_setting('app.user_email', true));

CREATE POLICY "Only admins can read all subscriptions"
  ON newsletter_subscriptions FOR SELECT
  TO authenticated
  USING (auth.jwt()->>'role' = 'admin' OR email = current_setting('app.user_email', true));

-- Create unsubscribe log table
CREATE TABLE IF NOT EXISTS unsubscribe_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  
  email text NOT NULL,
  unsubscribe_type text NOT NULL, -- 'newsletter', 'job_notifications', 'sms', 'all'
  reason text,
  
  -- Context
  ip_address inet,
  user_agent text,
  referrer text,
  
  -- Re-subscription tracking
  resubscribed_at timestamptz,
  
  metadata jsonb DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS unsubscribe_log_email_idx ON unsubscribe_log(email);
CREATE INDEX IF NOT EXISTS unsubscribe_log_created_at_idx ON unsubscribe_log(created_at);

ALTER TABLE unsubscribe_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can log unsubscribes"
  ON unsubscribe_log FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Only admins can read unsubscribe logs"
  ON unsubscribe_log FOR SELECT
  TO authenticated
  USING (auth.jwt()->>'role' = 'admin');

-- Add RLS policy for applicants to update their own communication preferences
CREATE POLICY "Applicants can update their own communication preferences"
  ON applicants FOR UPDATE
  TO anon, authenticated
  USING (email = current_setting('app.user_email', true))
  WITH CHECK (email = current_setting('app.user_email', true));
