#!/usr/bin/env node

/**
 * Test script to validate lint-staged configuration
 * Run with: node scripts/test-lint-staged.js
 */

const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')

console.log('🔍 Testing lint-staged configuration...\n')

// Test 1: Check if lint-staged config exists
const lintstagedPath = path.join(__dirname, '../.lintstagedrc.js')
if (fs.existsSync(lintstagedPath)) {
  console.log('✅ .lintstagedrc.js exists')
} else {
  console.log('❌ .lintstagedrc.js not found')
  process.exit(1)
}

// Test 2: Check if prettier config exists
const prettierPath = path.join(__dirname, '../.prettierrc')
if (fs.existsSync(prettierPath)) {
  console.log('✅ .prettierrc exists')
} else {
  console.log('❌ .prettierrc not found')
  process.exit(1)
}

// Test 3: Check if eslint config exists
const eslintPath = path.join(__dirname, '../eslint.config.mjs')
if (fs.existsSync(eslintPath)) {
  console.log('✅ eslint.config.mjs exists')
} else {
  console.log('❌ eslint.config.mjs not found')
  process.exit(1)
}

// Test 4: Check if husky pre-commit hook exists
const preCommitPath = path.join(__dirname, '../.husky/pre-commit')
if (fs.existsSync(preCommitPath)) {
  console.log('✅ .husky/pre-commit exists')

  // Check if it contains lint-staged
  const preCommitContent = fs.readFileSync(preCommitPath, 'utf8')
  if (preCommitContent.includes('lint-staged')) {
    console.log('✅ Pre-commit hook includes lint-staged')
  } else {
    console.log('❌ Pre-commit hook does not include lint-staged')
  }
} else {
  console.log('❌ .husky/pre-commit not found')
}

// Test 5: Check if dependencies are installed
try {
  execSync('npm ls lint-staged eslint prettier', { stdio: 'pipe' })
  console.log('✅ All required dependencies are installed')
} catch (error) {
  console.log('❌ Some dependencies are missing')
  console.log('   Run: pnpm install')
}

// Test 6: Test lint-staged configuration
console.log('\n🔧 Testing lint-staged configuration...')
try {
  const lintstagedConfig = require(lintstagedPath)
  console.log('✅ lint-staged configuration is valid')
  console.log('   File patterns configured:')
  Object.keys(lintstagedConfig).forEach((pattern) => {
    console.log(`   - ${pattern}`)
  })
} catch (error) {
  console.log('❌ lint-staged configuration is invalid')
  console.log('   Error:', error.message)
}

// Test 7: Test prettier configuration
console.log('\n🎨 Testing prettier configuration...')
try {
  const prettierConfig = JSON.parse(fs.readFileSync(prettierPath, 'utf8'))
  console.log('✅ Prettier configuration is valid')
  console.log('   Settings:')
  Object.entries(prettierConfig).forEach(([key, value]) => {
    console.log(`   - ${key}: ${value}`)
  })
} catch (error) {
  console.log('❌ Prettier configuration is invalid')
  console.log('   Error:', error.message)
}

// Test 8: Test ESLint configuration
console.log('\n📝 Testing ESLint configuration...')
try {
  execSync('npx eslint --print-config src/index.js', { stdio: 'pipe' })
  console.log('✅ ESLint configuration is valid')
} catch (error) {
  console.log('❌ ESLint configuration has issues')
  console.log('   Error:', error.message)
}

console.log('\n✨ Lint-staged setup validation complete!')
console.log('\n📖 Usage:')
console.log('  - Stage some files: git add .')
console.log('  - Test pre-commit: npx lint-staged')
console.log('  - Commit changes: git commit -m "Test commit"')
console.log(
  '  - Disable linting: HUSKY_LINT_STAGED_IGNORE=0 git commit -m "Skip linting"'
)
console.log('\n🎯 File patterns handled:')
console.log('  - JavaScript/TypeScript: *.{js,jsx,ts,tsx} (ESLint + Prettier)')
console.log('  - JSON: *.{json,jsonc} (Prettier only)')
console.log('  - Markdown: *.{md,markdown} (Prettier only)')
console.log('  - YAML: *.{yml,yaml} (Prettier only)')
console.log('  - CSS: *.{css,scss,sass,less} (Prettier only)')
console.log('  - HTML: *.{html,htm} (Prettier only)')
console.log('  - Config files: *.{rc,config} (Prettier only)')
console.log(
  '  - Package files: package.json, pnpm-lock.yaml, etc. (Prettier only)'
)
