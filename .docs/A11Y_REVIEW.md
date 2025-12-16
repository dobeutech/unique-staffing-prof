# Accessibility (A11Y) Review Guide

## Overview

Accessibility compliance checklist and testing procedures for WCAG 2.1 Level AA standards.

## Quick Reference

### WCAG 2.1 Principles (POUR)
- **Perceivable**: Information must be presentable to users in ways they can perceive
- **Operable**: Interface components must be operable
- **Understandable**: Information and operation must be understandable
- **Robust**: Content must be robust enough for assistive technologies

## Current Implementation Status

### ✅ Implemented Features

#### Semantic HTML
- Proper heading hierarchy (h1 → h2 → h3)
- Semantic elements (nav, main, section, article, footer)
- Form labels associated with inputs
- Button elements for interactive actions

#### Keyboard Navigation
- All interactive elements keyboard accessible
- Visible focus indicators
- Logical tab order
- Skip to main content link
- Escape key closes modals/dropdowns

#### ARIA Support
- ARIA labels for icon buttons
- ARIA live regions for announcements
- ARIA expanded/collapsed states
- ARIA hidden for decorative elements
- ARIA describedby for form errors

#### Color & Contrast
- WCAG AA contrast ratios (4.5:1 for text)
- Color not sole indicator of information
- Focus indicators visible in both themes
- High contrast mode support

#### Forms
- Labels for all inputs
- Error messages associated with fields
- Required fields indicated
- Validation feedback
- Clear instructions

#### Internationalization
- Language attribute on HTML element
- Direction (LTR/RTL) support
- Language announcements for screen readers

### ⚠️ Areas for Improvement

#### Images
- [ ] Ensure all images have alt text
- [ ] Decorative images have empty alt=""
- [ ] Complex images have long descriptions

#### Tables
- [ ] Add table headers (th)
- [ ] Use scope attribute
- [ ] Add captions for data tables

#### Dynamic Content
- [ ] Ensure ARIA live regions announce changes
- [ ] Loading states announced
- [ ] Error states announced

#### Mobile
- [ ] Touch targets at least 44x44px
- [ ] Pinch-to-zoom not disabled
- [ ] Orientation support

## Testing Checklist

### Automated Testing

#### Tools
- [ ] axe DevTools browser extension
- [ ] WAVE browser extension
- [ ] Lighthouse accessibility audit
- [ ] Pa11y CLI tool

#### Running Automated Tests
```bash
# Install Pa11y
npm install -g pa11y

# Test homepage
pa11y http://localhost:5173

# Test with specific standard
pa11y --standard WCAG2AA http://localhost:5173

# Test multiple pages
pa11y-ci --sitemap http://localhost:5173/sitemap.xml
```

### Manual Testing

#### Keyboard Navigation
- [ ] Tab through all interactive elements
- [ ] Shift+Tab moves backward
- [ ] Enter/Space activates buttons
- [ ] Arrow keys navigate menus/dropdowns
- [ ] Escape closes modals/dropdowns
- [ ] No keyboard traps
- [ ] Focus visible at all times
- [ ] Skip link works (Tab on page load)

#### Screen Reader Testing

**NVDA (Windows - Free)**
```
Download: https://www.nvaccess.org/download/

Basic Commands:
- NVDA + Down Arrow: Read next item
- NVDA + Up Arrow: Read previous item
- NVDA + Space: Toggle focus/browse mode
- Insert + F7: List all links
- Insert + F5: List all form fields
```

**JAWS (Windows - Commercial)**
```
Trial: https://www.freedomscientific.com/downloads/jaws

Basic Commands:
- Down Arrow: Read next item
- Up Arrow: Read previous item
- Insert + F5: List all form fields
- Insert + F6: List all headings
- Insert + F7: List all links
```

**VoiceOver (macOS - Built-in)**
```
Enable: System Preferences → Accessibility → VoiceOver

Basic Commands:
- VO + Right Arrow: Next item
- VO + Left Arrow: Previous item
- VO + U: Open rotor
- VO + H: Next heading
- VO + L: Next link
- VO + J: Next form control

(VO = Control + Option)
```

#### Screen Reader Checklist
- [ ] Page title announced
- [ ] Headings read in order
- [ ] Links have descriptive text
- [ ] Form labels read correctly
- [ ] Error messages announced
- [ ] Button purposes clear
- [ ] Images have alt text
- [ ] Language changes announced
- [ ] Theme changes announced
- [ ] Loading states announced

#### Visual Testing
- [ ] Zoom to 200% - content still readable
- [ ] Text spacing increased - no overlap
- [ ] Windows High Contrast Mode works
- [ ] Focus indicators visible
- [ ] Color contrast sufficient
- [ ] No information by color alone

#### Mobile Testing
- [ ] Touch targets large enough (44x44px)
- [ ] Pinch-to-zoom works
- [ ] Landscape and portrait work
- [ ] Screen reader on mobile works
- [ ] Voice control works

## Component-Specific Checks

### Navigation
```tsx
// ✅ Good
<nav aria-label="Main navigation">
  <ul>
    <li><a href="/">Home</a></li>
  </ul>
</nav>

// ❌ Bad
<div className="nav">
  <span onClick={goHome}>Home</span>
</div>
```

### Buttons
```tsx
// ✅ Good
<button aria-label="Close dialog" onClick={close}>
  <X aria-hidden="true" />
</button>

// ❌ Bad
<div onClick={close}>
  <X />
</div>
```

### Forms
```tsx
// ✅ Good
<label htmlFor="email">Email</label>
<input
  id="email"
  type="email"
  aria-required="true"
  aria-describedby="email-error"
/>
<span id="email-error" role="alert">
  {error}
</span>

// ❌ Bad
<input type="email" placeholder="Email" />
<span>{error}</span>
```

### Modals
```tsx
// ✅ Good
<Dialog
  role="dialog"
  aria-labelledby="dialog-title"
  aria-modal="true"
>
  <h2 id="dialog-title">Confirm Action</h2>
  {/* content */}
</Dialog>

// ❌ Bad
<div className="modal">
  <div>Confirm Action</div>
</div>
```

### Images
```tsx
// ✅ Good - Informative
<img src="logo.png" alt="Unique Staffing Professionals" />

// ✅ Good - Decorative
<img src="decoration.png" alt="" aria-hidden="true" />

// ❌ Bad
<img src="logo.png" />
```

### Dynamic Content
```tsx
// ✅ Good
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

// ❌ Bad
<div>{statusMessage}</div>
```

## Common Issues & Fixes

### Issue: Missing Alt Text
```tsx
// Before
<img src="team.jpg" />

// After
<img src="team.jpg" alt="Team members collaborating in office" />
```

### Issue: Non-Semantic Buttons
```tsx
// Before
<div onClick={handleClick}>Click me</div>

// After
<button onClick={handleClick}>Click me</button>
```

### Issue: Missing Form Labels
```tsx
// Before
<input type="text" placeholder="Name" />

// After
<label htmlFor="name">Name</label>
<input id="name" type="text" />
```

### Issue: Poor Color Contrast
```css
/* Before */
.text {
  color: #999; /* 2.8:1 - Fails */
  background: #fff;
}

/* After */
.text {
  color: #666; /* 5.7:1 - Passes AA */
  background: #fff;
}
```

### Issue: Keyboard Trap
```tsx
// Before
<Modal>
  <input /> {/* Focus can't escape */}
</Modal>

// After
<Modal onEscapeKey={close}>
  <input />
  <button onClick={close}>Close</button>
</Modal>
```

## Testing Tools

### Browser Extensions

#### axe DevTools
- Chrome/Edge/Firefox
- Free tier available
- Automated scanning
- Detailed issue reports

#### WAVE
- Chrome/Firefox
- Free
- Visual feedback
- Color contrast checker

#### Lighthouse
- Built into Chrome DevTools
- Accessibility score
- Performance metrics

### Command Line Tools

#### Pa11y
```bash
npm install -g pa11y

# Test single page
pa11y http://localhost:5173

# Test with specific standard
pa11y --standard WCAG2AA http://localhost:5173

# Generate report
pa11y --reporter html http://localhost:5173 > report.html
```

#### axe-core CLI
```bash
npm install -g @axe-core/cli

# Test page
axe http://localhost:5173

# Test with specific rules
axe http://localhost:5173 --rules color-contrast,label
```

### Online Tools

#### WebAIM Contrast Checker
https://webaim.org/resources/contrastchecker/

#### WAVE Web Accessibility Evaluation Tool
https://wave.webaim.org/

#### AChecker
https://achecker.achecks.ca/checker/index.php

## Continuous Monitoring

### Pre-commit Hook
```bash
#!/bin/bash
# Add to .git/hooks/pre-commit

echo "Running accessibility checks..."

# Run axe on dev server
npm run dev &
DEV_PID=$!
sleep 5

axe http://localhost:5173 --exit

kill $DEV_PID
```

### CI/CD Integration
```yaml
# .github/workflows/a11y.yml
name: Accessibility Tests

on: [push, pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm install
      - run: npm run build
      - run: npm run preview &
      - run: sleep 5
      - run: npx pa11y-ci --sitemap http://localhost:4173/sitemap.xml
```

## Resources

### Documentation
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)

### Testing
- [WebAIM](https://webaim.org/)
- [Deque University](https://dequeuniversity.com/)
- [Accessibility Insights](https://accessibilityinsights.io/)

### Screen Readers
- [NVDA](https://www.nvaccess.org/) - Free (Windows)
- [JAWS](https://www.freedomscientific.com/products/software/jaws/) - Commercial (Windows)
- [VoiceOver](https://www.apple.com/accessibility/voiceover/) - Built-in (macOS/iOS)
- [TalkBack](https://support.google.com/accessibility/android/answer/6283677) - Built-in (Android)

## Compliance Checklist

### Level A (Must Have)
- [ ] Text alternatives for non-text content
- [ ] Captions for audio/video
- [ ] Content can be presented in different ways
- [ ] Color not sole indicator
- [ ] Keyboard accessible
- [ ] No keyboard traps
- [ ] Adjustable time limits
- [ ] Pause/stop/hide moving content
- [ ] No seizure-inducing flashes
- [ ] Skip navigation links
- [ ] Page titles
- [ ] Focus order logical
- [ ] Link purpose clear
- [ ] Language of page identified
- [ ] Focus visible
- [ ] Form labels/instructions
- [ ] Error identification
- [ ] Error suggestions
- [ ] Error prevention

### Level AA (Should Have)
- [ ] Captions for live audio
- [ ] Audio descriptions for video
- [ ] Contrast ratio 4.5:1 (text)
- [ ] Contrast ratio 3:1 (large text)
- [ ] Text can be resized 200%
- [ ] Images of text avoided
- [ ] Multiple ways to find pages
- [ ] Headings and labels descriptive
- [ ] Focus visible
- [ ] Language of parts identified
- [ ] Consistent navigation
- [ ] Consistent identification
- [ ] Error suggestions provided
- [ ] Error prevention (legal/financial)

### Level AAA (Nice to Have)
- [ ] Sign language for audio
- [ ] Extended audio descriptions
- [ ] Contrast ratio 7:1 (text)
- [ ] Contrast ratio 4.5:1 (large text)
- [ ] No images of text
- [ ] Reading level appropriate
- [ ] Pronunciation provided
- [ ] Context-sensitive help

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
