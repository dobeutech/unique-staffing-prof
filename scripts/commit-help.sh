#!/bin/bash
# Commit message helper script

echo "📝 Commit Message Helper"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Show commit message format
echo -e "${BLUE}Format:${NC} <type>(<scope>): <subject>"
echo ""

# Show types
echo -e "${BLUE}Types:${NC}"
echo "  feat     - New feature"
echo "  fix      - Bug fix"
echo "  docs     - Documentation changes"
echo "  style    - Code style changes (formatting, etc.)"
echo "  refactor - Code refactoring"
echo "  test     - Adding or updating tests"
echo "  chore    - Maintenance tasks"
echo "  perf     - Performance improvements"
echo "  ci       - CI/CD changes"
echo "  build    - Build system changes"
echo "  revert   - Revert a previous commit"
echo ""

# Show scopes
echo -e "${BLUE}Common Scopes:${NC}"
echo "  auth     - Authentication related"
echo "  ui       - UI components"
echo "  api      - API integration"
echo "  db       - Database changes"
echo "  i18n     - Internationalization"
echo "  theme    - Theme/styling"
echo "  admin    - Admin dashboard"
echo "  form     - Form components"
echo "  deps     - Dependencies"
echo "  config   - Configuration"
echo ""

# Show examples
echo -e "${BLUE}Examples:${NC}"
echo "  feat(auth): add password reset functionality"
echo "  fix(ui): correct button alignment on mobile"
echo "  docs(readme): update installation instructions"
echo "  refactor(api): simplify error handling"
echo "  chore(deps): update react to v19"
echo ""

# Interactive mode
echo -e "${YELLOW}Interactive Mode${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Select type
echo "Select commit type:"
select type in "feat" "fix" "docs" "style" "refactor" "test" "chore" "perf" "ci" "build" "revert"; do
  if [ -n "$type" ]; then
    break
  fi
done

# Enter scope
echo ""
read -p "Enter scope (optional, press Enter to skip): " scope

# Enter subject
echo ""
read -p "Enter subject: " subject

# Validate subject
if [ -z "$subject" ]; then
  echo "❌ Subject cannot be empty"
  exit 1
fi

# Build commit message
if [ -n "$scope" ]; then
  commit_msg="$type($scope): $subject"
else
  commit_msg="$type: $subject"
fi

# Enter body (optional)
echo ""
echo "Enter commit body (optional, press Ctrl+D when done):"
body=$(cat)

# Build full commit message
full_msg="$commit_msg"
if [ -n "$body" ]; then
  full_msg="$full_msg

$body"
fi

# Add co-author
full_msg="$full_msg

Co-authored-by: Ona <no-reply@ona.com>"

# Show preview
echo ""
echo -e "${GREEN}Preview:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$full_msg"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Confirm
read -p "Commit with this message? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Stage all changes
  git add -A
  
  # Commit
  git commit -m "$full_msg"
  
  echo ""
  echo -e "${GREEN}✅ Committed successfully!${NC}"
else
  echo "❌ Commit cancelled"
  exit 1
fi
