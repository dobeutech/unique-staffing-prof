#!/bin/bash
# Dependency audit and security check script

echo "🔒 Dependency Security Audit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track issues
ISSUES_FOUND=0

# Check 1: npm audit
echo -e "${BLUE}1. Running npm audit...${NC}"
echo ""

audit_output=$(npm audit --json 2>/dev/null)
audit_exit_code=$?

if [ $audit_exit_code -eq 0 ]; then
  echo -e "${GREEN}✅ No vulnerabilities found${NC}"
else
  vulnerabilities=$(echo "$audit_output" | grep -o '"vulnerabilities":{[^}]*}' | grep -o '"[a-z]*":[0-9]*' | grep -v '"total"')
  
  if [ -n "$vulnerabilities" ]; then
    echo -e "${RED}❌ Vulnerabilities found:${NC}"
    echo "$vulnerabilities" | while read line; do
      echo "   $line"
    done
    ISSUES_FOUND=1
    
    echo ""
    echo "Run 'npm audit' for detailed information"
    echo "Run 'npm audit fix' to attempt automatic fixes"
  fi
fi
echo ""

# Check 2: Outdated packages
echo -e "${BLUE}2. Checking for outdated packages...${NC}"
echo ""

outdated=$(npm outdated --json 2>/dev/null)

if [ -z "$outdated" ] || [ "$outdated" == "{}" ]; then
  echo -e "${GREEN}✅ All packages are up to date${NC}"
else
  echo -e "${YELLOW}⚠️  Outdated packages found:${NC}"
  echo "$outdated" | jq -r 'to_entries[] | "   \(.key): \(.value.current) → \(.value.latest)"' 2>/dev/null || echo "$outdated"
  echo ""
  echo "Run 'npm update' to update packages"
fi
echo ""

# Check 3: Unused dependencies
echo -e "${BLUE}3. Checking for unused dependencies...${NC}"
echo ""

if command -v depcheck &> /dev/null; then
  depcheck_output=$(depcheck --json 2>/dev/null)
  unused=$(echo "$depcheck_output" | jq -r '.dependencies[]' 2>/dev/null)
  
  if [ -z "$unused" ]; then
    echo -e "${GREEN}✅ No unused dependencies found${NC}"
  else
    echo -e "${YELLOW}⚠️  Unused dependencies:${NC}"
    echo "$unused" | while read dep; do
      echo "   - $dep"
    done
    echo ""
    echo "Consider removing unused dependencies"
  fi
else
  echo -e "${YELLOW}⚠️  depcheck not installed${NC}"
  echo "   Install with: npm install -g depcheck"
fi
echo ""

# Check 4: Package size
echo -e "${BLUE}4. Analyzing package sizes...${NC}"
echo ""

if [ -d "node_modules" ]; then
  node_modules_size=$(du -sh node_modules 2>/dev/null | cut -f1)
  echo "   node_modules size: $node_modules_size"
  
  # Find largest packages
  echo ""
  echo "   Largest packages:"
  du -sh node_modules/* 2>/dev/null | sort -rh | head -5 | while read size dir; do
    package=$(basename "$dir")
    echo "   - $package: $size"
  done
else
  echo -e "${YELLOW}⚠️  node_modules not found${NC}"
  echo "   Run 'npm install' first"
fi
echo ""

# Check 5: License compliance
echo -e "${BLUE}5. Checking licenses...${NC}"
echo ""

if command -v license-checker &> /dev/null; then
  # Check for problematic licenses
  problematic_licenses=("GPL" "AGPL" "LGPL")
  
  licenses=$(license-checker --json 2>/dev/null)
  found_problematic=false
  
  for license in "${problematic_licenses[@]}"; do
    if echo "$licenses" | grep -q "\"licenses\": \"$license"; then
      if [ "$found_problematic" = false ]; then
        echo -e "${YELLOW}⚠️  Potentially problematic licenses found:${NC}"
        found_problematic=true
      fi
      echo "$licenses" | jq -r "to_entries[] | select(.value.licenses | contains(\"$license\")) | \"   - \(.key): \(.value.licenses)\"" 2>/dev/null
    fi
  done
  
  if [ "$found_problematic" = false ]; then
    echo -e "${GREEN}✅ No problematic licenses found${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  license-checker not installed${NC}"
  echo "   Install with: npm install -g license-checker"
fi
echo ""

# Check 6: Duplicate dependencies
echo -e "${BLUE}6. Checking for duplicate dependencies...${NC}"
echo ""

if command -v npm-check-duplicates &> /dev/null; then
  duplicates=$(npm-check-duplicates 2>/dev/null)
  
  if [ -z "$duplicates" ]; then
    echo -e "${GREEN}✅ No duplicate dependencies found${NC}"
  else
    echo -e "${YELLOW}⚠️  Duplicate dependencies found:${NC}"
    echo "$duplicates"
    echo ""
    echo "Run 'npm dedupe' to remove duplicates"
  fi
else
  # Manual check using npm ls
  echo "   Checking with npm ls..."
  duplicates=$(npm ls --all 2>/dev/null | grep "deduped" | wc -l)
  
  if [ $duplicates -eq 0 ]; then
    echo -e "${GREEN}✅ No duplicate dependencies found${NC}"
  else
    echo -e "${YELLOW}⚠️  Found $duplicates deduped packages${NC}"
    echo "   Run 'npm dedupe' to optimize"
  fi
fi
echo ""

# Check 7: Check for known security issues in specific packages
echo -e "${BLUE}7. Checking critical packages...${NC}"
echo ""

critical_packages=("react" "react-dom" "@supabase/supabase-js" "vite")
all_critical_ok=true

for package in "${critical_packages[@]}"; do
  if npm list "$package" &>/dev/null; then
    version=$(npm list "$package" --depth=0 2>/dev/null | grep "$package@" | sed 's/.*@//')
    echo "   ✅ $package@$version"
  else
    echo -e "   ${RED}❌ $package not found${NC}"
    all_critical_ok=false
  fi
done

if [ "$all_critical_ok" = true ]; then
  echo ""
  echo -e "${GREEN}✅ All critical packages are installed${NC}"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ISSUES_FOUND -eq 0 ]; then
  echo -e "${GREEN}✅ Dependency audit complete - No critical issues found${NC}"
  echo ""
  echo "Recommendations:"
  echo "  - Keep dependencies updated regularly"
  echo "  - Run 'npm audit' before each release"
  echo "  - Review outdated packages monthly"
else
  echo -e "${RED}❌ Security vulnerabilities found${NC}"
  echo ""
  echo "Action required:"
  echo "  1. Run 'npm audit' for details"
  echo "  2. Run 'npm audit fix' to auto-fix"
  echo "  3. Manually update packages if needed"
  echo "  4. Review breaking changes before updating"
fi
echo ""

exit $ISSUES_FOUND
