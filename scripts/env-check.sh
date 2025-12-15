#!/bin/bash
# Environment variables validation script

set -e

echo "🔍 Environment Variables Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
  echo -e "${RED}❌ .env file not found${NC}"
  echo ""
  echo "Creating .env from .env.example..."
  
  if [ -f .env.example ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Please edit .env and add your configuration${NC}"
    echo ""
    exit 1
  else
    echo -e "${RED}❌ .env.example not found${NC}"
    exit 1
  fi
fi

# Load .env file
export $(cat .env | grep -v '^#' | xargs)

# Required variables
required_vars=(
  "VITE_SUPABASE_URL"
  "VITE_SUPABASE_ANON_KEY"
)

# Optional variables
optional_vars=(
  "VITE_GA_TRACKING_ID"
  "VITE_SENTRY_DSN"
)

# Track missing variables
missing_vars=()
empty_vars=()

# Check required variables
echo -e "${BLUE}Required Variables:${NC}"
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
    echo -e "  ${RED}❌ $var${NC} - Not set"
  else
    # Check if it's a placeholder
    if [[ "${!var}" == *"your-"* ]] || [[ "${!var}" == *"example"* ]]; then
      empty_vars+=("$var")
      echo -e "  ${YELLOW}⚠️  $var${NC} - Placeholder value detected"
    else
      echo -e "  ${GREEN}✅ $var${NC} - Set"
    fi
  fi
done
echo ""

# Check optional variables
echo -e "${BLUE}Optional Variables:${NC}"
for var in "${optional_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo -e "  ${YELLOW}⚠️  $var${NC} - Not set (optional)"
  else
    echo -e "  ${GREEN}✅ $var${NC} - Set"
  fi
done
echo ""

# Validate Supabase URL format
if [ -n "$VITE_SUPABASE_URL" ]; then
  if [[ ! "$VITE_SUPABASE_URL" =~ ^https://[a-z0-9-]+\.supabase\.co$ ]]; then
    echo -e "${YELLOW}⚠️  VITE_SUPABASE_URL format may be incorrect${NC}"
    echo "   Expected format: https://your-project.supabase.co"
    echo "   Current value: $VITE_SUPABASE_URL"
    echo ""
  fi
fi

# Validate Supabase anon key format
if [ -n "$VITE_SUPABASE_ANON_KEY" ]; then
  key_length=${#VITE_SUPABASE_ANON_KEY}
  if [ $key_length -lt 100 ]; then
    echo -e "${YELLOW}⚠️  VITE_SUPABASE_ANON_KEY seems too short${NC}"
    echo "   Supabase anon keys are typically 100+ characters"
    echo "   Current length: $key_length"
    echo ""
  fi
fi

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo -e "${RED}❌ Missing required variables:${NC}"
  printf '   - %s\n' "${missing_vars[@]}"
  echo ""
  echo "Please add these variables to your .env file"
  exit 1
fi

if [ ${#empty_vars[@]} -ne 0 ]; then
  echo -e "${YELLOW}⚠️  Placeholder values detected:${NC}"
  printf '   - %s\n' "${empty_vars[@]}"
  echo ""
  echo "Please replace placeholder values with actual configuration"
  exit 1
fi

echo -e "${GREEN}✅ All required environment variables are properly configured!${NC}"
echo ""

# Show next steps
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Run 'npm run dev' to start development server"
echo "  2. Visit http://localhost:5173 to view the application"
echo ""
