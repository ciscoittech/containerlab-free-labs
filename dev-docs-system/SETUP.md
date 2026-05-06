# Dev-Docs System - Configuration Guide

**Complete guide to customizing the dev-docs system for your project.**

---

## Table of Contents

1. [Build Commands Configuration](#build-commands-configuration)
2. [Skill Rules Configuration](#skill-rules-configuration)
3. [Agent Customization](#agent-customization)
4. [Hook Settings](#hook-settings)
5. [Project-Specific Setup](#project-specific-setup)
6. [Advanced Configuration](#advanced-configuration)

---

## Build Commands Configuration

### Overview

The stop-event hook runs build commands after each Claude response. Configure these commands to match your project's tech stack.

### Location

Edit: `.claude/hooks/stop-event.md`

### Default Configuration (Laravel + React)

```markdown
**TypeScript (Frontend)**:
npm run types  # Runs: tsc --noEmit

**PHP (Backend)**:
php -l app/**/*.php  # Syntax check
```

### Configuration for Other Stacks

#### Next.js / TypeScript

```markdown
**TypeScript Check**:
npm run type-check  # or: npx tsc --noEmit

**Build Check**:
npm run build --dry-run  # Test build without output

**Lint Check**:
npm run lint
```

#### Python / FastAPI

```markdown
**Type Check**:
mypy app/  # Type checking with mypy

**Lint Check**:
ruff check app/  # Fast Python linter

**Import Check**:
isort --check-only app/  # Import sorting
```

#### Ruby / Rails

```markdown
**Ruby Syntax**:
ruby -c app/**/*.rb  # Syntax check

**Lint Check**:
rubocop app/  # Ruby style guide

**Type Check** (if using Sorbet):
srb tc  # Sorbet type checker
```

#### Go

```markdown
**Build Check**:
go build ./...  # Build all packages

**Lint Check**:
golangci-lint run  # Comprehensive linter

**Format Check**:
gofmt -l .  # Check formatting
```

### Error Threshold

In `.claude/hooks/stop-event.md`, find this section:

```markdown
### Step 4: Error Response Strategy

**If 0 errors detected**: [...]
**If 1-4 errors detected**: [...]
**If 5+ errors detected**: [...]  ← Change this number
```

**Recommended Thresholds**:
- **Small projects**: 3+ errors triggers agent
- **Medium projects**: 5+ errors (default)
- **Large projects**: 10+ errors

---

## Skill Rules Configuration

### Overview

Skill rules control when skills are auto-activated based on keywords, file edits, and intent patterns.

### Location

Edit: `.claude/hooks/skill-rules.json`

### Template Structure

```json
{
  "skill-name": {
    "type": "domain",  // or "reference"
    "enforcement": "suggest",  // or "require"
    "priority": "high",  // "high", "medium", "low"
    "promptTriggers": {
      "keywords": ["list", "of", "keywords"],
      "intentPatterns": ["regex", "patterns"]
    },
    "fileTriggers": {
      "pathPatterns": ["path/**/*.ext"]
    }
  }
}
```

### Example: Laravel Project

```json
{
  "laravel-backend-guidelines": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "promptTriggers": {
      "keywords": [
        "controller", "service", "model", "migration",
        "artisan", "eloquent", "Laravel"
      ],
      "intentPatterns": [
        "(create|add|build).*?(controller|service|model)",
        "(implement|integrate).*?(API|endpoint)"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "app/Http/Controllers/**/*.php",
        "app/Services/**/*.php",
        "app/Models/**/*.php"
      ]
    }
  }
}
```

### Example: React Project

```json
{
  "react-guidelines": {
    "type": "domain",
    "enforcement": "suggest",
    "priority": "high",
    "promptTriggers": {
      "keywords": [
        "component", "React", "hook", "useState",
        "useEffect", "context", "props"
      ],
      "intentPatterns": [
        "(create|add|build).*?component",
        "(implement|add).*?hook"
      ]
    },
    "fileTriggers": {
      "pathPatterns": [
        "components/**/*.tsx",
        "hooks/**/*.ts",
        "app/**/*.tsx"
      ]
    }
  }
}
```

### Keyword Matching

**Case-Insensitive**: "React" matches "react", "REACT", "React"

**Partial Match**: "component" matches "components", "MyComponent"

**Best Practices**:
- Add technology names ("Laravel", "React", "FastAPI")
- Add common patterns ("controller", "service", "model")
- Add domain terms specific to your project

### Intent Patterns (Regex)

**Common Patterns**:
```javascript
"(create|add|build|implement).*?X"  // Creating X
"(how to|best practice).*?X"       // Learning about X
"(fix|debug|troubleshoot).*?X"     // Fixing X
"(test|testing).*?X"                // Testing X
```

**Examples**:
```json
"intentPatterns": [
  "(create|add).*?service",        // "create user service"
  "(implement|integrate).*?API",    // "implement REST API"
  "how.*?authenticate",             // "how to authenticate users"
  "(test|testing).*?endpoint"       // "testing API endpoint"
]
```

### File Triggers

**Path Patterns**:
```json
"pathPatterns": [
  "app/**/*.php",           // All PHP in app/
  "components/**/*.tsx",     // All TSX in components/
  "**/*.test.ts"            // All test files
]
```

**Glob Syntax**:
- `*` - Matches any characters except /
- `**` - Matches any characters including /
- `{a,b}` - Matches a or b
- `[abc]` - Matches a, b, or c

**Examples**:
```json
"src/**/*.{ts,tsx}",          // TypeScript files in src/
"app/{Services,Models}/**",   // Services or Models
"tests/**/*.test.{js,ts}"     // Test files
```

---

## Agent Customization

### Overview

Agents are specialized AI assistants for specific tasks. Customize their prompts for your project patterns.

### Strategic Plan Architect

**Location**: `.claude-library/agents/core/strategic-plan-architect.md`

**Customize**:
1. **Project Context** - Add your architecture patterns
2. **Tech Stack** - Specify your frameworks
3. **Best Practices** - Add your coding standards

**Example Customization**:
```markdown
# Strategic Plan Architect Agent

## Project-Specific Context

**Tech Stack**:
- Backend: Laravel 12 + PostgreSQL
- Frontend: React 19 + TypeScript + Tailwind
- Infrastructure: Docker + Vultr VPS

**Architecture Patterns**:
- Services for business logic
- Controllers for HTTP handling
- Repositories for data access
- Jobs for async processing

**Best Practices**:
- TDD approach (write tests first)
- API-first design
- Mobile-responsive UI
- Cost-conscious (budget: $X/month)
```

### Build Error Resolver

**Location**: `.claude-library/agents/core/build-error-resolver.md`

**Customize**:
1. **Error Patterns** - Add common errors in your stack
2. **Fix Strategies** - Document your team's approaches
3. **Tool Configuration** - Specify your linters/checkers

**Example**:
```markdown
# Build Error Resolver Agent

## Project-Specific Error Patterns

**TypeScript**:
- Missing type hints → Add to interface
- Import errors → Check barrel exports
- Prop type mismatches → Update component props

**Python**:
- Type errors → Add type annotations
- Import errors → Check circular imports
- Pydantic errors → Update model schema
```

### Other Agents

**Architect, Engineer, Reviewer**:
- Add project-specific patterns
- Document code structure
- Specify testing requirements

---

## Hook Settings

### Location

Create/edit: `.claude/settings.local.json`

### Stop Event Hook Configuration

```json
{
  "hooks": {
    "stop": {
      "enabled": true,
      "fileEditTracking": true,
      "buildChecking": {
        "typescript": true,      // Enable TypeScript checks
        "php": true,             // Enable PHP checks
        "python": false,         // Disable Python checks
        "go": false              // Disable Go checks
      },
      "errorThreshold": 5,       // Launch agent at 5+ errors
      "showReminders": true,     // Show error handling reminders
      "patterns": {
        "risky": {
          "backend": [
            "try-catch",         // Check for error handling
            "external-api",      // Check for API calls
            "database"           // Check for DB operations
          ],
          "frontend": [
            "async",             // Check for async operations
            "error-state",       // Check for error states
            "loading-state"      // Check for loading states
          ]
        }
      }
    }
  }
}
```

### User Prompt Submit Hook Configuration

```json
{
  "hooks": {
    "user-prompt-submit": {
      "enabled": true,
      "rulesFile": ".claude/hooks/skill-rules.json",
      "deduplication": true,     // Remove duplicate skills
      "prioritization": true     // Show high-priority first
    }
  }
}
```

---

## Project-Specific Setup

### Laravel Project

```bash
# 1. Install dependencies
npm install --save-dev typescript
composer require --dev phpstan/phpstan

# 2. Configure build commands
# Edit .claude/hooks/stop-event.md:
npm run types && php -l app/**/*.php

# 3. Create skills
mkdir -p .claude/skills/laravel-guidelines
# Add Laravel-specific patterns

# 4. Update skill-rules.json
# Add Laravel keywords and file patterns
```

### Next.js Project

```bash
# 1. Ensure type checking script exists
# In package.json:
"scripts": {
  "type-check": "tsc --noEmit"
}

# 2. Configure build commands
# Edit .claude/hooks/stop-event.md:
npm run type-check && npm run lint

# 3. Create skills
mkdir -p .claude/skills/nextjs-guidelines
# Add Next.js App Router patterns

# 4. Update skill-rules.json
# Add Next.js, React, TypeScript keywords
```

### Python / FastAPI Project

```bash
# 1. Install type checker
pip install mypy ruff

# 2. Configure build commands
# Edit .claude/hooks/stop-event.md:
mypy app/ && ruff check app/

# 3. Create skills
mkdir -p .claude/skills/fastapi-guidelines
# Add FastAPI async patterns

# 4. Update skill-rules.json
# Add Python, FastAPI, Pydantic keywords
```

---

## Advanced Configuration

### Custom Command Creation

Create new commands in `.claude/commands/`:

```markdown
# /custom-command.md

**Purpose**: [What this command does]

## Usage

/custom-command "argument"

## What This Command Does

[Description]

## Example

/custom-command "example usage"
```

### Custom Agent Creation

Create agents in `.claude-library/agents/`:

```markdown
# custom-agent.md

**Purpose**: [Agent purpose]
**Expertise**: [Domain knowledge]
**When to Use**: [Use cases]

## Agent Workflow

[Step-by-step process]
```

### Custom Skill Creation

Create skills in `.claude/skills/`:

```
.claude/skills/
└── custom-skill/
    ├── SKILL.md           # Skill documentation
    ├── examples/          # Code examples
    │   └── example.ext
    └── templates/         # Code templates
        └── template.ext
```

### Environment-Specific Configuration

**Development**:
```json
{
  "hooks": {
    "stop": {
      "errorThreshold": 3,
      "showReminders": true
    }
  }
}
```

**Production**:
```json
{
  "hooks": {
    "stop": {
      "errorThreshold": 1,
      "showReminders": false
    }
  }
}
```

---

## Configuration Examples

### Minimal Setup (Get Started Fast)

```bash
# 1. Copy core files only
cp dev-docs-system/commands/dev-docs.md .claude/commands/
cp dev-docs-system/agents/strategic-plan-architect.md .claude-library/agents/core/

# 2. Create dev folder
mkdir -p dev/active

# 3. Start using
/dev-docs "feature description"
```

### Full Setup (Complete System)

```bash
# 1. Copy everything
cp -r dev-docs-system/commands/* .claude/commands/
cp -r dev-docs-system/hooks/* .claude/hooks/
cp -r dev-docs-system/agents/* .claude-library/agents/core/

# 2. Configure for your stack
# Edit .claude/hooks/stop-event.md (build commands)
# Edit .claude/hooks/skill-rules.json (keywords)

# 3. Create project skills
mkdir -p .claude/skills/project-guidelines

# 4. Create settings
cat > .claude/settings.local.json << 'EOF'
{
  "hooks": {
    "stop": { "enabled": true },
    "user-prompt-submit": { "enabled": true }
  }
}
EOF

# 5. Create dev folder
mkdir -p dev/active
```

---

## Testing Configuration

### Test Build Commands

```bash
# Run build commands manually to verify
npm run types  # Should run successfully
php -l app/**/*.php  # Should check syntax

# If errors, update .claude/hooks/stop-event.md
```

### Test Skill Rules

```bash
# Trigger skill with keyword
# Type prompt with your keywords
# Check if skill is suggested

# If not working, check:
# 1. Keywords match your prompt
# 2. File patterns match your files
# 3. Skill rules file is valid JSON
```

### Test Agents

```bash
# Test strategic plan architect
/dev-docs "test feature"

# Should:
# 1. Launch agent
# 2. Create plan
# 3. Generate 3 dev docs files
```

---

## Troubleshooting Configuration

### Build Commands Not Running

**Symptom**: No build errors shown after editing files

**Check**:
1. `.claude/hooks/stop-event.md` exists
2. Build commands are correct for your project
3. Commands run successfully when executed manually

**Fix**:
```bash
# Test command manually
npm run types  # Should work

# If fails, update command in stop-event.md
```

### Skills Not Auto-Activating

**Symptom**: Skills not suggested when expected

**Check**:
1. `.claude/hooks/skill-rules.json` exists
2. Keywords match your prompts
3. File patterns match edited files
4. JSON is valid

**Fix**:
```bash
# Validate JSON
cat .claude/hooks/skill-rules.json | jq .

# If invalid, fix JSON syntax
```

### Agents Not Launching

**Symptom**: Agent doesn't start when command runs

**Check**:
1. Agent file exists in `.claude-library/agents/core/`
2. Agent file has correct format
3. Command references correct agent name

**Fix**:
```bash
# Verify agent file
ls .claude-library/agents/core/strategic-plan-architect.md

# Check first few lines for format
head .claude-library/agents/core/strategic-plan-architect.md
```

---

## Next Steps

1. **Test your configuration** - Run `/dev-docs` on a real feature
2. **Iterate based on results** - Adjust keywords, build commands, etc.
3. **Create project-specific skills** - Document your patterns
4. **Share with team** - Commit configuration to git

---

**Configuration Complete!**

Your dev-docs system is now customized for your project.
