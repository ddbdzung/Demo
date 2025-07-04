#!/usr/bin/env node

/**
 * Renovate Configuration Validator
 *
 * This script validates the renovate.json configuration file
 * for common issues and ensures it follows best practices.
 */

const fs = require('fs')
const path = require('path')

const CONFIG_FILES = [
  'renovate.json',
  '.renovaterc.json',
  '.github/renovate.json',
]
const REQUIRED_FIELDS = ['extends', 'packageRules']
const RECOMMENDED_EXTENDS = [
  'config:recommended',
  ':dependencyDashboard',
  ':semanticCommits',
]

function validateRenovateConfig() {
  console.log('🔍 Validating Renovate configuration...\n')

  // Find config file
  let configPath = null
  let config = null

  for (const file of CONFIG_FILES) {
    const fullPath = path.resolve(file)
    if (fs.existsSync(fullPath)) {
      configPath = fullPath
      try {
        const content = fs.readFileSync(fullPath, 'utf8')
        config = JSON.parse(content)
        console.log(`✅ Found and parsed config: ${file}`)
        break
      } catch (error) {
        console.error(`❌ Error parsing ${file}: ${error.message}`)
        process.exit(1)
      }
    }
  }

  if (!config) {
    console.error('❌ No Renovate configuration file found')
    console.error(`   Expected one of: ${CONFIG_FILES.join(', ')}`)
    process.exit(1)
  }

  // Validate required fields
  console.log('\n📋 Checking required fields...')
  for (const field of REQUIRED_FIELDS) {
    if (config[field]) {
      console.log(`✅ ${field}: Present`)
    } else {
      console.error(`❌ ${field}: Missing`)
    }
  }

  // Check recommended extends
  console.log('\n🎯 Checking recommended extends...')
  if (config.extends && Array.isArray(config.extends)) {
    for (const extend of RECOMMENDED_EXTENDS) {
      if (config.extends.includes(extend)) {
        console.log(`✅ ${extend}: Included`)
      } else {
        console.warn(`⚠️  ${extend}: Not included (recommended)`)
      }
    }
  }

  // Check package rules
  console.log('\n📦 Analyzing package rules...')
  if (config.packageRules && Array.isArray(config.packageRules)) {
    console.log(`✅ Package rules count: ${config.packageRules.length}`)

    const groupedRules = config.packageRules.filter((rule) => rule.groupName)
    console.log(`✅ Grouped rules: ${groupedRules.length}`)

    const autoMergeRules = config.packageRules.filter((rule) => rule.automerge)
    console.log(`✅ Auto-merge rules: ${autoMergeRules.length}`)
  }

  // Check scheduling
  console.log('\n⏰ Checking scheduling...')
  if (config.schedule) {
    console.log(`✅ Schedule configured: ${JSON.stringify(config.schedule)}`)
  } else {
    console.warn('⚠️  No custom schedule configured (will use default)')
  }

  // Check security settings
  console.log('\n🔒 Checking security settings...')
  if (config.vulnerabilityAlerts && config.vulnerabilityAlerts.enabled) {
    console.log('✅ Vulnerability alerts: Enabled')
  } else {
    console.warn('⚠️  Vulnerability alerts: Not explicitly enabled')
  }

  if (config.osvVulnerabilityAlerts) {
    console.log('✅ OSV vulnerability alerts: Enabled')
  }

  // Summary
  console.log('\n📊 Configuration Summary:')
  console.log(`   Config file: ${path.relative(process.cwd(), configPath)}`)
  console.log(`   Total extends: ${config.extends ? config.extends.length : 0}`)
  console.log(
    `   Package rules: ${config.packageRules ? config.packageRules.length : 0}`
  )
  console.log(`   Timezone: ${config.timezone || 'Default (UTC)'}`)
  console.log(
    `   Dependency dashboard: ${config.dependencyDashboard ? 'Enabled' : 'Disabled'}`
  )

  console.log('\n✅ Renovate configuration validation completed!')
  console.log('\n💡 Next steps:')
  console.log('   1. Install Renovate app on your GitHub repository')
  console.log('   2. Monitor the dependency dashboard issue')
  console.log('   3. Review and merge dependency update PRs')
}

// Run validation
if (require.main === module) {
  validateRenovateConfig()
}

module.exports = { validateRenovateConfig }
