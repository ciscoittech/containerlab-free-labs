# Dev-Docs System - Installation Guide

**Portable strategic planning and context preservation system for any software project.**

---

## Quick Install (5 minutes)

```bash
# 1. Copy the system files to your project
cp -r dev-docs-system/commands/* .claude/commands/
cp -r dev-docs-system/hooks/* .claude/hooks/
cp -r dev-docs-system/agents/* .claude-library/agents/core/

# 2. Create dev folder structure
mkdir -p dev/active

# 3. Start using it
/dev-docs "Your feature description"
```

That's it! The system is ready to use.

---

## What You Get

After installation, you'll have:

✅ **11 Slash Commands** for planning, updating, and reviewing
✅ **2 Automation Hooks** for zero-errors-left-behind
✅ **7 Specialized Agents** for planning and error resolution
✅ **3 File Templates** for consistent dev docs
✅ **Complete Examples** showing real-world usage

---

## Detailed Installation

### Prerequisites

- Claude Code CLI installed
- Project with `.claude/` folder
- Git repository (recommended)

### Step 1: Copy Commands

```bash
# Create commands directory if it doesn't exist
mkdir -p .claude/commands

# Copy all command files
cp dev-docs-system/commands/*.md .claude/commands/
```

**Verify**:
```bash
ls .claude/commands/
# Should show: dev-docs.md, dev-docs-update.md, code-review.md, etc.
```

### Step 2: Copy Hooks

```bash
# Create hooks directory if it doesn't exist
mkdir -p .claude/hooks

# Copy hook files
cp dev-docs-system/hooks/stop-event.md .claude/hooks/
cp dev-docs-system/hooks/user-prompt-submit.md .claude/hooks/

# Copy and customize skill rules
cp dev-docs-system/hooks/skill-rules.json.template .claude/hooks/skill-rules.json
```

**Verify**:
```bash
ls .claude/hooks/
# Should show: stop-event.md, user-prompt-submit.md, skill-rules.json
```

### Step 3: Copy Agents

```bash
# Create agents directory if it doesn't exist
mkdir -p .claude-library/agents/core

# Copy all agent files
cp dev-docs-system/agents/*.md .claude-library/agents/core/
```

**Verify**:
```bash
ls .claude-library/agents/core/
# Should show: strategic-plan-architect.md, build-error-resolver.md, etc.
```

### Step 4: Create Dev Folder Structure

```bash
# Create folder for active development docs
mkdir -p dev/active
```

This is where your feature documentation will live:
```
dev/active/
├── feature-1/
│   ├── feature-1-plan.md
│   ├── feature-1-context.md
│   └── feature-1-tasks.md
└── feature-2/
    └── ... (same structure)
```

### Step 5: Configure for Your Stack

Edit `.claude/hooks/skill-rules.json` to match your technology stack:

**For Laravel/PHP Projects**:
- Use as-is (already configured for Laravel)

**For Next.js/React Projects**:
```json
{
  "frontend-guidelines": {
    "keywords": ["component", "React", "Next.js", "TypeScript", ...],
    "fileTriggers": {
      "pathPatterns": ["components/**/*.tsx", "app/**/*.tsx", ...]
    }
  }
}
```

**For Python/FastAPI Projects**:
```json
{
  "backend-guidelines": {
    "keywords": ["fastapi", "pydantic", "async", "endpoint", ...],
    "fileTriggers": {
      "pathPatterns": ["app/**/*.py", "api/**/*.py", ...]
    }
  }
}
```

See **SETUP.md** for complete configuration guide.

### Step 6: Test Installation

```bash
# Test the /dev-docs command
/dev-docs "Test feature for verifying installation"
```

**Expected Output**:
- Strategic plan architect agent launches
- Creates plan with phases and tasks
- Generates 3 dev docs files in `dev/active/test-feature/`

---

## Framework-Specific Setup

### Laravel

**Build Commands** (already configured):
```bash
# TypeScript: npm run types
# PHP: php -l app/**/*.php
# Tests: php artisan test
```

**Skills to Create**:
- `laravel-backend-guidelines` (patterns for services, controllers, jobs)
- `laravel-feature-test-scaffold` (PHPUnit test templates)
- `laravel-unit-test-scaffold` (unit test patterns)

### Next.js / React

**Build Commands**:
```bash
# TypeScript: npm run type-check
# Build: npm run build
# Tests: npm test
```

**Update stop-event hook**:
Replace PHP commands with Node.js commands:
```markdown
# In .claude/hooks/stop-event.md
# Change: php -l app/**/*.php
# To: npm run type-check
```

**Skills to Create**:
- `nextjs-guidelines` (App Router patterns, Server Components)
- `react-component-guidelines` (component best practices)
- `vitest-test-scaffold` (React Testing Library patterns)

### Python / FastAPI

**Build Commands**:
```bash
# Type Check: mypy app/
# Lint: ruff check app/
# Tests: pytest
```

**Update stop-event hook**:
```markdown
# In .claude/hooks/stop-event.md
# Change: npm run types && php -l
# To: mypy app/ && ruff check app/
```

**Skills to Create**:
- `fastapi-guidelines` (async patterns, Pydantic models)
- `pytest-test-scaffold` (test fixtures, parametrization)

### Ruby / Rails

**Build Commands**:
```bash
# Lint: rubocop
# Tests: rspec
```

**Update stop-event hook**:
```markdown
# In .claude/hooks/stop-event.md
# Change: npm run types && php -l
# To: rubocop && standardrb
```

**Skills to Create**:
- `rails-guidelines` (ActiveRecord patterns, service objects)
- `rspec-test-scaffold` (RSpec test templates)

---

## Optional: Enable Hooks

Hooks are automatically enabled by Claude Code when they exist in `.claude/hooks/`.

**To configure hook settings**, create `.claude/settings.local.json`:

```json
{
  "hooks": {
    "stop": {
      "enabled": true,
      "fileEditTracking": true,
      "buildChecking": {
        "typescript": true,
        "php": true
      },
      "errorThreshold": 5,
      "showReminders": true
    }
  }
}
```

---

## Verification Checklist

After installation, verify:

- [ ] `/dev-docs` command exists (type `/dev` and autocomplete shows it)
- [ ] `/dev-docs-update` command exists
- [ ] `/code-review` command exists
- [ ] `dev/active/` folder created
- [ ] Hooks are in `.claude/hooks/`
- [ ] Agents are in `.claude-library/agents/core/`
- [ ] Test `/dev-docs` creates plan successfully

---

## First Usage

### Create Your First Plan

```bash
/dev-docs "Add user authentication with email/password"
```

**Agent will**:
1. Analyze your codebase
2. Create 4-phase implementation plan
3. Generate dev docs in `dev/active/user-authentication/`

**You'll get**:
- `user-authentication-plan.md` - Complete architecture
- `user-authentication-context.md` - Key decisions tracker
- `user-authentication-tasks.md` - Task checklist

### Start Development

1. Open `user-authentication-plan.md` - Read architecture
2. Open `user-authentication-tasks.md` - See first task
3. Implement first task
4. Mark task complete in `tasks.md`
5. Update discoveries in `context.md`

### End of Session

```bash
/dev-docs-update "user-authentication"
```

**This updates**:
- `context.md` with session work summary
- `tasks.md` with completed task marks
- Preserves context for next session

### Before Merge

```bash
/code-review "user-authentication"
```

**Agent validates**:
- Code matches plan architecture
- Security best practices followed
- Performance acceptable
- Test coverage adequate

---

## Troubleshooting

### Commands Don't Show Up

**Problem**: `/dev-docs` command not found

**Solution**:
```bash
# Verify files are in correct location
ls .claude/commands/dev-docs.md

# If missing, re-copy
cp dev-docs-system/commands/dev-docs.md .claude/commands/
```

### Agents Don't Launch

**Problem**: Strategic plan architect doesn't activate

**Solution**:
```bash
# Verify agent file exists
ls .claude-library/agents/core/strategic-plan-architect.md

# Check agent file has correct format
head .claude-library/agents/core/strategic-plan-architect.md
```

### Hooks Don't Run

**Problem**: Stop event hook not catching errors

**Solution**:
```bash
# Verify hook file exists
ls .claude/hooks/stop-event.md

# Check hook configuration in settings
cat .claude/settings.local.json
```

### Build Commands Fail

**Problem**: `npm run types` or `php -l` not found

**Solution**:
Edit `.claude/hooks/stop-event.md` and change build commands to match your project:

```markdown
# For Python project:
mypy app/

# For Ruby project:
rubocop

# For Go project:
go build ./...
```

---

## Customization

After installation works, customize for your workflow:

1. **Edit skill-rules.json** - Add your keywords and file patterns
2. **Customize agents** - Edit agent prompts for your patterns
3. **Adjust commands** - Modify commands for your team's workflow
4. **Create new skills** - Add project-specific guidelines

See **SETUP.md** for detailed customization guide.

---

## Uninstallation

To remove the system:

```bash
# Remove commands
rm .claude/commands/dev-docs*.md
rm .claude/commands/code-review.md
rm .claude/commands/create-dev-docs.md
rm .claude/commands/build*.md
rm .claude/commands/test.md

# Remove hooks
rm .claude/hooks/stop-event.md
rm .claude/hooks/user-prompt-submit.md
rm .claude/hooks/skill-rules.json

# Remove agents
rm .claude-library/agents/core/strategic-plan-architect.md
rm .claude-library/agents/core/build-error-resolver.md
# ... (remove other agents)

# Optional: Remove dev docs (if no longer needed)
rm -rf dev/active/
```

---

## What's Next?

1. **Read SETUP.md** - Configure for your specific project
2. **Review examples/** - See OAuth feature example
3. **Try `/dev-docs`** - Create your first plan
4. **Customize** - Adjust for your team's workflow

---

## Support

**Questions?**
- Check `CLAUDE.md` for system overview
- Review `SETUP.md` for configuration
- See `examples/` for real-world usage

**Found a bug or have a suggestion?**
- Customize the system for your needs
- This is your copy to modify

---

**Installation Complete!** 🎉

Run `/dev-docs "your feature"` to get started.
