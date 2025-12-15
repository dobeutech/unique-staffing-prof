# Testing Guide

## Overview

Testing strategy and utilities for the Unique Staffing Professionals project.

## Current Status

⚠️ **No test suite currently implemented**

This document outlines the planned testing strategy and provides utilities for when testing is implemented.

## Testing Stack (Planned)

### Unit & Integration Testing
- **Vitest**: Fast unit test framework
- **React Testing Library**: Component testing
- **@testing-library/user-event**: User interaction simulation
- **@testing-library/jest-dom**: Custom matchers

### E2E Testing
- **Playwright**: End-to-end testing
- **@playwright/test**: Test runner

### Visual Testing
- **Storybook**: Component documentation and visual testing
- **Chromatic**: Visual regression testing (optional)

## Setup Instructions

### Install Dependencies

```bash
npm install -D vitest @vitest/ui @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
npm install -D playwright @playwright/test
npm install -D @storybook/react @storybook/react-vite
```

### Configure Vitest

Create `vitest.config.ts`:
```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/mockData',
      ],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### Test Setup File

Create `src/test/setup.ts`:
```typescript
import '@testing-library/jest-dom'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

// Cleanup after each test
afterEach(() => {
  cleanup()
})

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  takeRecords() {
    return []
  }
  unobserve() {}
}
```

### Update package.json

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

## Testing Patterns

### Component Testing

#### Basic Component Test
```typescript
// src/components/__tests__/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { Button } from '../ui/button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn()
    const user = userEvent.setup()
    
    render(<Button onClick={handleClick}>Click me</Button>)
    await user.click(screen.getByText('Click me'))
    
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>)
    expect(screen.getByText('Click me')).toBeDisabled()
  })
})
```

#### Form Component Test
```typescript
// src/components/__tests__/ApplyForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { ApplyForm } from '../ApplyForm'

describe('ApplyForm', () => {
  it('validates required fields', async () => {
    const user = userEvent.setup()
    render(<ApplyForm />)
    
    const submitButton = screen.getByRole('button', { name: /submit/i })
    await user.click(submitButton)
    
    expect(await screen.findByText(/name is required/i)).toBeInTheDocument()
    expect(await screen.findByText(/email is required/i)).toBeInTheDocument()
  })

  it('submits form with valid data', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()
    
    render(<ApplyForm onSubmit={onSubmit} />)
    
    await user.type(screen.getByLabelText(/name/i), 'John Doe')
    await user.type(screen.getByLabelText(/email/i), 'john@example.com')
    await user.type(screen.getByLabelText(/phone/i), '555-1234')
    
    await user.click(screen.getByRole('button', { name: /submit/i }))
    
    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        name: 'John Doe',
        email: 'john@example.com',
        phone: '555-1234',
      })
    })
  })
})
```

#### Context Provider Test
```typescript
// src/contexts/__tests__/LanguageContext.test.tsx
import { render, screen } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'
import { describe, it, expect } from 'vitest'
import { LanguageProvider, useLanguage } from '../LanguageContext'

const TestComponent = () => {
  const { language, setLanguage, t } = useLanguage()
  return (
    <div>
      <span data-testid="language">{language}</span>
      <span data-testid="translation">{t('hero.title')}</span>
      <button onClick={() => setLanguage('es')}>Change to Spanish</button>
    </div>
  )
}

describe('LanguageContext', () => {
  it('provides default language', () => {
    render(
      <LanguageProvider>
        <TestComponent />
      </LanguageProvider>
    )
    
    expect(screen.getByTestId('language')).toHaveTextContent('en')
  })

  it('changes language', async () => {
    const user = userEvent.setup()
    
    render(
      <LanguageProvider>
        <TestComponent />
      </LanguageProvider>
    )
    
    await user.click(screen.getByText('Change to Spanish'))
    
    expect(screen.getByTestId('language')).toHaveTextContent('es')
  })

  it('provides translations', () => {
    render(
      <LanguageProvider>
        <TestComponent />
      </LanguageProvider>
    )
    
    expect(screen.getByTestId('translation')).toHaveTextContent(/connecting talent/i)
  })
})
```

### Hook Testing

```typescript
// src/hooks/__tests__/useDebounce.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { useDebounce } from '../useDebounce'

describe('useDebounce', () => {
  it('debounces value changes', async () => {
    vi.useFakeTimers()
    
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      { initialProps: { value: 'initial', delay: 500 } }
    )
    
    expect(result.current).toBe('initial')
    
    rerender({ value: 'updated', delay: 500 })
    expect(result.current).toBe('initial')
    
    vi.advanceTimersByTime(500)
    
    await waitFor(() => {
      expect(result.current).toBe('updated')
    })
    
    vi.useRealTimers()
  })
})
```

### Utility Function Testing

```typescript
// src/lib/__tests__/utils.test.ts
import { describe, it, expect } from 'vitest'
import { cn } from '../utils'

describe('cn utility', () => {
  it('merges class names', () => {
    expect(cn('foo', 'bar')).toBe('foo bar')
  })

  it('handles conditional classes', () => {
    expect(cn('foo', false && 'bar', 'baz')).toBe('foo baz')
  })

  it('merges tailwind classes correctly', () => {
    expect(cn('px-2 py-1', 'px-4')).toBe('py-1 px-4')
  })
})
```

### E2E Testing

```typescript
// e2e/application-flow.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Application Flow', () => {
  test('user can submit application', async ({ page }) => {
    await page.goto('/')
    
    // Fill form
    await page.fill('[name="fullName"]', 'John Doe')
    await page.fill('[name="email"]', 'john@example.com')
    await page.fill('[name="phone"]', '555-1234')
    
    // Upload resume
    await page.setInputFiles('[name="resume"]', 'test-files/resume.pdf')
    
    // Submit
    await page.click('button[type="submit"]')
    
    // Verify success
    await expect(page.locator('text=Application submitted')).toBeVisible()
  })

  test('admin can view applications', async ({ page }) => {
    // Login
    await page.goto('/admin/login')
    await page.fill('[name="email"]', 'admin@example.com')
    await page.fill('[name="password"]', 'password')
    await page.click('button[type="submit"]')
    
    // Navigate to dashboard
    await expect(page).toHaveURL('/admin/dashboard')
    
    // Verify applications list
    await expect(page.locator('table')).toBeVisible()
    await expect(page.locator('tbody tr')).toHaveCount.greaterThan(0)
  })
})
```

## Test Utilities

### Custom Render Function

```typescript
// src/test/utils.tsx
import { ReactElement } from 'react'
import { render, RenderOptions } from '@testing-library/react'
import { ThemeProvider } from '@/contexts/ThemeProvider'
import { LanguageProvider } from '@/contexts/LanguageContext'
import { AuthProvider } from '@/contexts/AuthContext'

const AllProviders = ({ children }: { children: React.ReactNode }) => {
  return (
    <ThemeProvider>
      <LanguageProvider>
        <AuthProvider>
          {children}
        </AuthProvider>
      </LanguageProvider>
    </ThemeProvider>
  )
}

const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) => render(ui, { wrapper: AllProviders, ...options })

export * from '@testing-library/react'
export { customRender as render }
```

### Mock Data

```typescript
// src/test/mockData.ts
export const mockApplicant = {
  id: '123',
  full_name: 'John Doe',
  email: 'john@example.com',
  phone: '555-1234',
  position_interested: 'Software Engineer',
  experience_years: 5,
  resume_url: 'https://example.com/resume.pdf',
  resume_filename: 'resume.pdf',
  cover_letter: 'I am interested in this position...',
  status: 'new',
  notes: '',
  created_at: '2025-01-01T00:00:00Z',
  updated_at: '2025-01-01T00:00:00Z',
}

export const mockBusinessInfo = {
  id: '1',
  company_name: 'Unique Staffing Professionals',
  phone: '555-0000',
  email: 'info@example.com',
  address: '123 Main St',
  hours: { monday: '9-5', tuesday: '9-5' },
  description: 'Professional staffing agency',
  created_at: '2025-01-01T00:00:00Z',
  updated_at: '2025-01-01T00:00:00Z',
}
```

### Supabase Mocks

```typescript
// src/test/supabaseMocks.ts
import { vi } from 'vitest'

export const mockSupabaseClient = {
  from: vi.fn(() => ({
    select: vi.fn().mockReturnThis(),
    insert: vi.fn().mockReturnThis(),
    update: vi.fn().mockReturnThis(),
    delete: vi.fn().mockReturnThis(),
    eq: vi.fn().mockReturnThis(),
    single: vi.fn(),
  })),
  auth: {
    signIn: vi.fn(),
    signOut: vi.fn(),
    getSession: vi.fn(),
    onAuthStateChange: vi.fn(),
  },
  storage: {
    from: vi.fn(() => ({
      upload: vi.fn(),
      download: vi.fn(),
      createSignedUrl: vi.fn(),
    })),
  },
}
```

## Coverage Goals

### Target Coverage
- **Statements**: > 80%
- **Branches**: > 75%
- **Functions**: > 80%
- **Lines**: > 80%

### Priority Areas
1. Utility functions (100%)
2. Form validation (100%)
3. Context providers (90%)
4. UI components (80%)
5. Pages (70%)

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      
      - run: npm run lint
      
      - run: npm run type-check
      
      - run: npm run test:coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json

  e2e:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      
      - run: npx playwright install --with-deps
      
      - run: npm run build
      
      - run: npm run test:e2e
      
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

## Best Practices

### Do's
- ✅ Test user behavior, not implementation
- ✅ Use semantic queries (getByRole, getByLabelText)
- ✅ Test accessibility
- ✅ Mock external dependencies
- ✅ Keep tests simple and focused
- ✅ Use descriptive test names
- ✅ Test error states
- ✅ Test loading states

### Don'ts
- ❌ Don't test implementation details
- ❌ Don't use getByTestId unless necessary
- ❌ Don't test third-party libraries
- ❌ Don't make tests dependent on each other
- ❌ Don't use snapshots for everything
- ❌ Don't skip accessibility tests

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/react)
- [Playwright Documentation](https://playwright.dev/)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
