# Dotfiles and Configuration Setup

## Overview

Configuration files and setup scripts for consistent development environment.

## Git Configuration

### .gitignore
Already configured with:
```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Production
build/
dist/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
```

### .gitattributes
Create for consistent line endings:
```gitattributes
* text=auto eol=lf
*.{cmd,[cC][mM][dD]} text eol=crlf
*.{bat,[bB][aA][tT]} text eol=crlf
```

## Editor Configuration

### .editorconfig
```editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2
```

### VSCode Settings (.vscode/settings.json)
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ]
}
```

### VSCode Extensions (.vscode/extensions.json)
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "usernamehw.errorlens",
    "christian-kohler.path-intellisense",
    "formulahendry.auto-rename-tag",
    "dsznajder.es7-react-js-snippets"
  ]
}
```

## Git Hooks

### Pre-commit Hook (.git/hooks/pre-commit)
```bash
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Run linter
echo "📝 Running ESLint..."
npm run lint
if [ $? -ne 0 ]; then
  echo "❌ ESLint failed. Please fix errors before committing."
  exit 1
fi

# Type check
echo "🔍 Running TypeScript type check..."
npx tsc --noEmit
if [ $? -ne 0 ]; then
  echo "❌ TypeScript errors found. Please fix before committing."
  exit 1
fi

# Check for console.log
echo "🔍 Checking for console.log statements..."
if git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n "console\.log" 2>/dev/null; then
  echo "⚠️  Warning: console.log statements found. Consider removing them."
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check for TODO/FIXME
echo "🔍 Checking for TODO/FIXME comments..."
if git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n -E "(TODO|FIXME)" 2>/dev/null; then
  echo "⚠️  Warning: TODO/FIXME comments found."
fi

echo "✅ Pre-commit checks passed!"
```

### Commit Message Hook (.git/hooks/commit-msg)
```bash
#!/bin/bash

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# Check commit message format
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .+"; then
  echo "❌ Invalid commit message format."
  echo ""
  echo "Format: <type>(<scope>): <subject>"
  echo ""
  echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
  echo ""
  echo "Example: feat(auth): add password reset functionality"
  exit 1
fi

# Check commit message length
subject_length=$(echo "$commit_msg" | head -n 1 | wc -c)
if [ $subject_length -gt 72 ]; then
  echo "⚠️  Warning: Commit subject is longer than 72 characters."
fi

echo "✅ Commit message format is valid!"
```

## Environment Setup

### .env.example
```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Optional: Analytics
# VITE_GA_TRACKING_ID=

# Optional: Error Tracking
# VITE_SENTRY_DSN=
```

### Environment Validation Script
```bash
#!/bin/bash
# scripts/check-env.sh

required_vars=(
  "VITE_SUPABASE_URL"
  "VITE_SUPABASE_ANON_KEY"
)

missing_vars=()

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    missing_vars+=("$var")
  fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  printf '   - %s\n' "${missing_vars[@]}"
  echo ""
  echo "Please copy .env.example to .env and fill in the values."
  exit 1
fi

echo "✅ All required environment variables are set!"
```

## NPM Scripts Enhancement

Add to package.json:
```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b --noCheck && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "type-check": "tsc --noEmit",
    "format": "prettier --write \"src/**/*.{ts,tsx,js,jsx,json,css,md}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,js,jsx,json,css,md}\"",
    "check-env": "bash scripts/check-env.sh",
    "setup": "npm install && npm run check-env",
    "clean": "rm -rf node_modules dist .vite",
    "reinstall": "npm run clean && npm install"
  }
}
```

## Development Setup Script

### scripts/setup-dev.sh
```bash
#!/bin/bash

echo "🚀 Setting up development environment..."

# Check Node version
required_node_version="18"
current_node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)

if [ "$current_node_version" -lt "$required_node_version" ]; then
  echo "❌ Node.js version $required_node_version or higher is required."
  echo "   Current version: $(node -v)"
  exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check environment variables
echo "🔍 Checking environment variables..."
if [ ! -f .env ]; then
  echo "⚠️  .env file not found. Copying from .env.example..."
  cp .env.example .env
  echo "📝 Please edit .env and add your Supabase credentials."
  exit 1
fi

# Run environment check
npm run check-env

# Setup git hooks
echo "🔗 Setting up git hooks..."
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

# Type check
echo "🔍 Running type check..."
npm run type-check

echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .env with your Supabase credentials"
echo "  2. Run 'npm run dev' to start development server"
```

## Prettier Configuration

### .prettierrc
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "avoid",
  "endOfLine": "lf"
}
```

### .prettierignore
```
node_modules
dist
build
.vite
coverage
*.min.js
*.min.css
```

## Installation Instructions

### Automated Setup
```bash
# Clone repository
git clone <repository-url>
cd unique-staffing-prof

# Run setup script
chmod +x scripts/setup-dev.sh
./scripts/setup-dev.sh
```

### Manual Setup
```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your credentials
nano .env

# Setup git hooks
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

# Verify setup
npm run type-check
npm run lint
```

## Troubleshooting

### Git Hooks Not Running
```bash
# Make hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

# Verify hooks exist
ls -la .git/hooks/
```

### ESLint Errors
```bash
# Auto-fix issues
npm run lint:fix

# If issues persist, check eslint.config.js
```

### TypeScript Errors
```bash
# Clear cache and rebuild
rm -rf node_modules/.vite
npm run type-check
```

### Environment Variables Not Loading
```bash
# Verify .env file exists
ls -la .env

# Check file contents (don't commit this!)
cat .env

# Restart dev server
npm run dev
```

## Maintenance

### Update Dependencies
```bash
# Check for outdated packages
npm outdated

# Update all dependencies
npm update

# Update specific package
npm update <package-name>
```

### Clean Install
```bash
# Remove everything and reinstall
npm run reinstall
```

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
