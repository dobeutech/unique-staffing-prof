#!/bin/bash
# Pre-commit validation script

set -e

echo "🔍 Running pre-commit checks..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any checks fail
CHECKS_FAILED=0

# Function to print status
print_status() {
  if [ $1 -eq 0 ]; then
    echo -e "${GREEN}✅ $2${NC}"
  else
    echo -e "${RED}❌ $2${NC}"
    CHECKS_FAILED=1
  fi
}

# Function to print warning
print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check 1: ESLint
echo "📝 Running ESLint..."
if npm run lint > /dev/null 2>&1; then
  print_status 0 "ESLint passed"
else
  print_status 1 "ESLint failed"
  echo "   Run 'npm run lint' to see errors"
fi
echo ""

# Check 2: TypeScript type checking
echo "🔍 Running TypeScript type check..."
if npx tsc --noEmit > /dev/null 2>&1; then
  print_status 0 "TypeScript type check passed"
else
  print_status 1 "TypeScript type check failed"
  echo "   Run 'npx tsc --noEmit' to see errors"
fi
echo ""

# Check 3: Check for console.log statements
echo "🔍 Checking for console.log statements..."
CONSOLE_LOGS=$(git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n "console\.log" 2>/dev/null || true)
if [ -z "$CONSOLE_LOGS" ]; then
  print_status 0 "No console.log statements found"
else
  print_warning "console.log statements found:"
  echo "$CONSOLE_LOGS"
  echo ""
fi

# Check 4: Check for TODO/FIXME comments
echo "🔍 Checking for TODO/FIXME comments..."
TODOS=$(git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n -E "(TODO|FIXME)" 2>/dev/null || true)
if [ -z "$TODOS" ]; then
  print_status 0 "No TODO/FIXME comments in staged files"
else
  print_warning "TODO/FIXME comments found:"
  echo "$TODOS"
  echo ""
fi

# Check 5: Check for debugger statements
echo "🔍 Checking for debugger statements..."
DEBUGGERS=$(git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n "debugger" 2>/dev/null || true)
if [ -z "$DEBUGGERS" ]; then
  print_status 0 "No debugger statements found"
else
  print_status 1 "debugger statements found"
  echo "$DEBUGGERS"
  echo ""
fi

# Check 6: Check for large files
echo "🔍 Checking for large files..."
LARGE_FILES=$(git diff --cached --name-only | while read file; do
  if [ -f "$file" ]; then
    size=$(wc -c < "$file")
    if [ $size -gt 1048576 ]; then # 1MB
      echo "$file ($(numfmt --to=iec-i --suffix=B $size))"
    fi
  fi
done)
if [ -z "$LARGE_FILES" ]; then
  print_status 0 "No large files (>1MB) found"
else
  print_warning "Large files found:"
  echo "$LARGE_FILES"
  echo ""
fi

# Check 7: Check for .env file
echo "🔍 Checking for .env file in staged changes..."
if git diff --cached --name-only | grep -q "^\.env$"; then
  print_status 1 ".env file is staged"
  echo "   Remove .env from staging: git reset HEAD .env"
else
  print_status 0 ".env file not staged"
fi
echo ""

# Check 8: Check for package-lock.json changes
echo "🔍 Checking package-lock.json..."
if git diff --cached --name-only | grep -q "package-lock.json"; then
  if git diff --cached --name-only | grep -q "package.json"; then
    print_status 0 "package.json and package-lock.json both changed"
  else
    print_warning "package-lock.json changed without package.json"
  fi
else
  print_status 0 "No package-lock.json changes"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed!${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}❌ Some checks failed. Please fix the issues before committing.${NC}"
  echo ""
  exit 1
fi
