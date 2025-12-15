#!/bin/bash
# Accessibility audit script

echo "♿ Accessibility Audit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if dev server is running
check_server() {
  if curl -s http://localhost:5173 > /dev/null; then
    return 0
  else
    return 1
  fi
}

# Start dev server if not running
if ! check_server; then
  echo -e "${YELLOW}⚠️  Dev server not running. Starting...${NC}"
  npm run dev > /dev/null 2>&1 &
  DEV_PID=$!
  
  echo "Waiting for server to start..."
  for i in {1..30}; do
    if check_server; then
      echo -e "${GREEN}✅ Server started${NC}"
      break
    fi
    sleep 1
  done
  
  if ! check_server; then
    echo -e "${RED}❌ Failed to start dev server${NC}"
    exit 1
  fi
  echo ""
fi

# Manual checks
echo -e "${BLUE}Manual Accessibility Checks${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check 1: Semantic HTML
echo "1. Checking for semantic HTML..."
if grep -r "role=\"button\"" src/ | grep -v "node_modules" > /dev/null; then
  echo -e "   ${YELLOW}⚠️  Found role=\"button\" - consider using <button> element${NC}"
else
  echo -e "   ${GREEN}✅ No role=\"button\" found${NC}"
fi

if grep -r "<div.*onClick" src/ | grep -v "node_modules" | grep -v "// OK" > /dev/null; then
  echo -e "   ${YELLOW}⚠️  Found div with onClick - consider using <button>${NC}"
else
  echo -e "   ${GREEN}✅ No div onClick patterns found${NC}"
fi
echo ""

# Check 2: Alt text
echo "2. Checking for images without alt text..."
missing_alt=$(grep -r "<img" src/ | grep -v "node_modules" | grep -v "alt=" | wc -l)
if [ $missing_alt -gt 0 ]; then
  echo -e "   ${RED}❌ Found $missing_alt images without alt text${NC}"
  grep -rn "<img" src/ | grep -v "node_modules" | grep -v "alt=" | head -5
else
  echo -e "   ${GREEN}✅ All images have alt text${NC}"
fi
echo ""

# Check 3: Form labels
echo "3. Checking for inputs without labels..."
unlabeled=$(grep -r "<input" src/ | grep -v "node_modules" | grep -v "aria-label" | grep -v "id=" | wc -l)
if [ $unlabeled -gt 0 ]; then
  echo -e "   ${YELLOW}⚠️  Found $unlabeled inputs that may be unlabeled${NC}"
else
  echo -e "   ${GREEN}✅ All inputs appear to be labeled${NC}"
fi
echo ""

# Check 4: ARIA labels
echo "4. Checking for icon buttons without labels..."
unlabeled_icons=$(grep -r "<button" src/ | grep -v "node_modules" | grep -v "aria-label" | grep -v "children" | wc -l)
if [ $unlabeled_icons -gt 0 ]; then
  echo -e "   ${YELLOW}⚠️  Found $unlabeled_icons buttons that may need aria-label${NC}"
else
  echo -e "   ${GREEN}✅ Buttons appear to have labels${NC}"
fi
echo ""

# Check 5: Heading hierarchy
echo "5. Checking heading hierarchy..."
echo "   Analyzing heading structure..."

# Count headings
h1_count=$(grep -r "<h1" src/ | grep -v "node_modules" | wc -l)
h2_count=$(grep -r "<h2" src/ | grep -v "node_modules" | wc -l)
h3_count=$(grep -r "<h3" src/ | grep -v "node_modules" | wc -l)

echo "   H1: $h1_count, H2: $h2_count, H3: $h3_count"

if [ $h1_count -eq 0 ]; then
  echo -e "   ${RED}❌ No H1 headings found${NC}"
elif [ $h1_count -gt 1 ]; then
  echo -e "   ${YELLOW}⚠️  Multiple H1 headings found - ensure only one per page${NC}"
else
  echo -e "   ${GREEN}✅ Heading structure looks good${NC}"
fi
echo ""

# Check 6: Color contrast (basic check)
echo "6. Checking for hardcoded colors..."
hardcoded_colors=$(grep -r "color: #" src/ | grep -v "node_modules" | grep -v ".css" | wc -l)
if [ $hardcoded_colors -gt 0 ]; then
  echo -e "   ${YELLOW}⚠️  Found $hardcoded_colors hardcoded colors${NC}"
  echo "   Consider using CSS variables for theme support"
else
  echo -e "   ${GREEN}✅ No hardcoded colors found${NC}"
fi
echo ""

# Check 7: Focus indicators
echo "7. Checking for focus styles..."
if grep -r "outline: none" src/ | grep -v "node_modules" > /dev/null; then
  echo -e "   ${RED}❌ Found 'outline: none' - ensure focus indicators are visible${NC}"
else
  echo -e "   ${GREEN}✅ No 'outline: none' found${NC}"
fi
echo ""

# Check 8: Language attribute
echo "8. Checking for language attributes..."
if grep -r "lang=" index.html > /dev/null; then
  echo -e "   ${GREEN}✅ Language attribute found in HTML${NC}"
else
  echo -e "   ${RED}❌ No language attribute in HTML${NC}"
fi
echo ""

# Automated tools check
echo ""
echo -e "${BLUE}Automated Tool Checks${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if pa11y is installed
if command -v pa11y &> /dev/null; then
  echo "Running Pa11y audit..."
  echo ""
  
  pa11y http://localhost:5173 --standard WCAG2AA --reporter cli
  pa11y_exit=$?
  
  echo ""
  if [ $pa11y_exit -eq 0 ]; then
    echo -e "${GREEN}✅ Pa11y audit passed${NC}"
  else
    echo -e "${RED}❌ Pa11y audit found issues${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Pa11y not installed${NC}"
  echo "   Install with: npm install -g pa11y"
  echo ""
  echo "   Other recommended tools:"
  echo "   - axe DevTools (browser extension)"
  echo "   - WAVE (browser extension)"
  echo "   - Lighthouse (Chrome DevTools)"
fi
echo ""

# Recommendations
echo ""
echo -e "${BLUE}Recommendations${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Manual Testing:"
echo "  1. Test keyboard navigation (Tab, Enter, Escape)"
echo "  2. Test with screen reader (NVDA, JAWS, VoiceOver)"
echo "  3. Test at 200% zoom"
echo "  4. Test in high contrast mode"
echo "  5. Test with browser extensions (axe, WAVE)"
echo ""
echo "Browser Extensions:"
echo "  - axe DevTools: https://www.deque.com/axe/devtools/"
echo "  - WAVE: https://wave.webaim.org/extension/"
echo "  - Lighthouse: Built into Chrome DevTools"
echo ""
echo "Documentation:"
echo "  - See .docs/A11Y_REVIEW.md for detailed checklist"
echo "  - WCAG 2.1: https://www.w3.org/WAI/WCAG21/quickref/"
echo ""

# Cleanup
if [ -n "$DEV_PID" ]; then
  echo "Stopping dev server..."
  kill $DEV_PID 2>/dev/null
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Accessibility audit complete${NC}"
echo ""
