# /build-and-fix Command

**Purpose**: One-command error fixing integrated with Phase 3A
**Integrates**: Stop event hook, build-error-resolver agent
**Output**: Clean build or systematic error fixes

---

## What This Command Does

`/build-and-fix` provides end-to-end build validation and automated error fixing:

1. Runs all builds (TypeScript + PHP)
2. Parses and reports errors
3. Routes errors smartly:
   - **0 errors**: ✅ Build clean
   - **1-4 errors**: Show for manual fixing
   - **5+ errors**: Launch build-error-resolver agent automatically
4. Verifies tests still pass
5. Reports final status

**Result**: Clean, tested code ready to commit.

---

## Usage

### Basic Usage

```bash
/build-and-fix

Runs all builds and fixes errors
```

### Target Specific Build

```bash
/build-and-fix typescript

Only checks TypeScript (npm run types)
```

```bash
/build-and-fix php

Only checks PHP (php -l)
```

### Force Rebuild

```bash
/build-and-fix --rebuild

Clears cache and rebuilds everything
```

### Verbose Output

```bash
/build-and-fix --verbose

Shows detailed output from each build step
```

---

## What Happens

### Scenario 1: Clean Build ✅

```bash
/build-and-fix

Output:
───────────────────────────────────────
✅ BUILD CLEAN

TypeScript:  0 errors   ✅
PHP:         0 errors   ✅

All tests:   23 passing ✅

Ready to commit!
───────────────────────────────────────
```

### Scenario 2: Minor Errors (1-4)

```bash
/build-and-fix

Output:
───────────────────────────────────────
🔴 BUILD ERRORS (3 errors)

File: resources/js/components/Modal.tsx
ERROR: Property 'open' is not assignable
       → Add 'open: boolean' to props interface

File: app/Services/UserService.php
ERROR: Undefined variable $email
       → Initialize before use on line 45

ERROR: Call to undefined method validate()
       → Method doesn't exist on User class

NEXT STEP: Fix these errors manually
───────────────────────────────────────
```

### Scenario 3: Many Errors (5+)

```bash
/build-and-fix

Output:
───────────────────────────────────────
🚨 BUILD ERRORS (8 errors)

Files affected:
- resources/js/components/Modal.tsx (4 errors)
- app/Services/UserService.php (3 errors)
- database/migrations/2025_10_31.php (1 error)

RECOMMEND: Launch build-error-resolver agent

This agent will:
1. Parse all error messages
2. Group by category
3. Fix each group systematically
4. Verify after each fix
5. Report final status

Launch build-error-resolver? [Yes/No]
───────────────────────────────────────
```

---

## Integration with Build-Error-Resolver

When 5+ errors are found, `/build-and-fix` can launch the agent:

```
/build-and-fix
         ↓
Found 8 errors
         ↓
Recommend build-error-resolver agent
         ↓
[You accept]
         ↓
Agent Launches:
├─ Groups errors by type
├─ Fixes category 1 (TypeScript types)
├─ Verifies build (passes)
├─ Fixes category 2 (PHP functions)
├─ Verifies build (passes)
├─ Fixes category 3 (Database)
├─ Verifies build (passes)
└─ Reports: 8/8 errors fixed ✅
         ↓
Back to /build-and-fix
         ↓
Re-verify: 0 errors ✅
```

---

## Complete Workflow Example

### Step 1: After Implementation

You've just finished implementing a feature. Code compiles but has errors:

```bash
/build-and-fix
```

### Step 2: Build Runs

```
Running TypeScript check...
  Found 6 errors

Running PHP check...
  Found 2 errors

Total: 8 errors
```

### Step 3: Agent Offers to Fix

```
🚨 MANY ERRORS FOUND (8)

Would you like me to launch build-error-resolver agent?
It will fix them systematically and report status.

→ Yes, launch agent
→ No, I'll fix manually
```

### Step 4: Agent Fixes Errors

```
BUILD ERROR RESOLUTION
═════════════════════════════════════

GROUP 1: TypeScript Type Errors (6 errors)
─────────────────────────────────────
Error 1: Property missing on interface
→ Reading code...
→ Found issue
→ Adding property...
→ npm run types ✅ (Error 1 fixed)

Error 2: Type mismatch
→ Analyzing...
→ Fixing...
→ npm run types ✅ (Error 2 fixed)

[...continues for all 6...]

GROUP 2: PHP Errors (2 errors)
─────────────────────────────────────
Error 7: Undefined function
→ Reading code...
→ Adding function...
→ php -l ✅ (Error 7 fixed)

Error 8: Syntax error
→ Analyzing...
→ Fixing...
→ php -l ✅ (Error 8 fixed)

RESULT: 8/8 ERRORS FIXED ✅
```

### Step 5: Verification

```
Re-running builds...

TypeScript:  0 errors ✅
PHP:         0 errors ✅
Tests:       23 passing ✅

Status: READY TO COMMIT ✅
```

---

## Build Steps Explained

### Step 1: File Tracking

```bash
# Determine which files changed
├─ TypeScript files? → Need npm run types
├─ PHP files? → Need php -l
└─ Database migrations? → Need schema validation
```

### Step 2: Run Builds

```bash
# TypeScript check
npm run types
├─ Checks all TypeScript files
├─ Checks React components
├─ Validates types
└─ Reports any type errors

# PHP linting
php -l app/**/*.php
├─ Checks all PHP files
├─ Validates syntax
├─ Reports any syntax errors
└─ Does NOT execute code
```

### Step 3: Parse Errors

```
Raw output from builds:
  src/components/Modal.tsx(45,12): error TS2339: Property 'open' does not exist

Parsed:
{
  file: "src/components/Modal.tsx",
  line: 45,
  column: 12,
  code: "TS2339",
  message: "Property 'open' does not exist"
}
```

### Step 4: Route and Display

```
0 errors     → ✅ Success message
1-4 errors   → 🔴 Show directly
5+ errors    → 🚨 Offer agent help
```

### Step 5: Verify Tests

```bash
# Run all tests
php artisan test
npm run test

# Check results
├─ Unit tests
├─ Integration tests
├─ E2E tests
└─ All must pass
```

---

## Error Categories Handled by Agent

### TypeScript Errors

```
✅ Missing properties
✅ Type mismatches
✅ Undefined variables
✅ Missing return types
✅ Import errors
```

### PHP Errors

```
✅ Parse errors (syntax)
✅ Undefined variables
✅ Undefined functions
✅ Undefined classes
✅ Type errors
```

### Build Errors

```
✅ Compilation failures
✅ Missing dependencies
✅ Configuration issues
✅ Asset compilation
```

---

## Integration Points

### With /dev-docs

```bash
# Create plan
/dev-docs "feature"

# Implement...

# Before commit, ensure clean
/build-and-fix
```

### With /code-review

```bash
# Code review
/code-review "feature"

# If approved, ensure clean
/build-and-fix

# Then commit
```

### With /dev-docs-update

```bash
# Ensure clean before session update
/build-and-fix

# If clean, update docs
/dev-docs-update "feature"
```

### Pre-Commit Hook

```bash
# Recommended workflow before commit
/build-and-fix

# If returns clean → safe to commit
git commit
git push

# If returns errors → agent fixes → then commit
```

---

## Workflow Examples

### Daily Development

```bash
# Morning: Start working
Work on features...

# Mid-day: Check status
/build-and-fix
├─ If errors: Agent fixes or manual fix
└─ If clean: Continue

# End of day: Ensure clean
/build-and-fix
# If clean, commit
git commit
```

### Feature Completion

```bash
# Feature mostly done
/build-and-fix
├─ 5+ errors? Agent fixes systematically
└─ 1-4 errors? Manual quick fix

# Code review
/code-review "feature"

# Final verification
/build-and-fix
# Should return ✅ CLEAN

# Safe to merge
git push
```

### Emergency Bug Fix

```bash
# Quick hot-fix
/code-review "hot-fix" --fast

# Ensure clean
/build-and-fix

# Deploy
git commit && git push
```

---

## Best Practices

### Do

✅ **Run before committing**
```bash
/build-and-fix
# If clean → commit
```

✅ **Run before code review**
```bash
/build-and-fix
# If clean → /code-review
```

✅ **Run after agent work**
```bash
# Agent fixed errors
/build-and-fix
# Verify all fixed
```

✅ **Accept agent help for 5+ errors**
```bash
Found 8 errors
# Use agent, don't fix manually
# Agent is faster and more systematic
```

### Don't

❌ **Skip for "quick" fixes**
```bash
# Always run, no exceptions
# Errors compound
```

❌ **Commit with known errors**
```bash
# Even "minor" errors cause problems
# Fix them first
```

❌ **Ignore agent recommendations**
```bash
# 5+ errors? Use agent
# It's faster than manual fixing
```

---

## Error Resolution Strategy

### Manual Fix (1-4 errors)

```
Error 1: TypeScript type
Error 2: PHP undefined function
Error 3: TypeScript missing prop

You fix these:
1. Add type to interface
2. Add function definition
3. Add prop to component

Faster to do manually for small count
```

### Agent Fix (5+ errors)

```
Error 1: TypeScript type
Error 2: TypeScript import
Error 3: TypeScript return type
Error 4: PHP undefined function
Error 5: PHP syntax error
Error 6: PHP variable error
Error 7: TypeScript interface
Error 8: Database migration

Agent:
1. Groups by category
2. Fixes all TypeScript (4)
3. Verifies build
4. Fixes all PHP (3)
5. Verifies build
6. Fixes migration (1)
7. Verifies build
8. Reports complete

Much faster than manual
More organized approach
```

---

## Tips & Tricks

### Quick Syntax Check (No Agent)

```bash
/build-and-fix --no-agent

Runs builds, shows errors, no agent involvement
Useful for quick checks
```

### Check Specific Files

```bash
/build-and-fix
TypeScript only

or

/build-and-fix
PHP only
```

### Rebuild Without Cache

```bash
/build-and-fix --rebuild

Forces full rebuild
Useful if in doubt
```

### Verbose Debugging

```bash
/build-and-fix --verbose

Shows all build output
Helpful for debugging
```

---

## FAQ

**Q: How long does /build-and-fix take?**
A: Typically 30 seconds to 2 minutes depending on code size. Agent fixes take 5-15 minutes for 5+ errors.

**Q: Will it modify my code?**
A: Only if 5+ errors are found AND you approve agent help. Otherwise, just shows errors.

**Q: What if tests fail?**
A: Build errors are fixed first. If tests fail after, run `/test` command to fix.

**Q: Can I skip the build check?**
A: Not recommended, but you can manually skip. But errors will surface later.

**Q: Does this run automatically?**
A: Only if you run it. Use as pre-commit check manually.

---

## Common Errors and Fixes

### TypeScript Errors

```
❌ "Property 'X' does not exist"
✅ Add property to interface

❌ "Type 'X' is not assignable to type 'Y'"
✅ Fix type mismatch

❌ "Cannot find module 'X'"
✅ Fix import path or install package
```

### PHP Errors

```
❌ "Parse error: syntax error"
✅ Fix syntax (missing semicolon, bracket, etc.)

❌ "Undefined variable $X"
✅ Initialize variable before use

❌ "Call to undefined function X()"
✅ Add function or check import
```

---

## Achievement

`/build-and-fix` ensures code quality automatically:

**Without it**:
```
Commit code with errors
Push to repository
CI/CD catches errors
Emergency fix needed
Deploy delayed
```

**With it**:
```
Commit code
/build-and-fix first
Errors found and fixed
Clean code committed
CI/CD passes
Deploy on schedule
```

**Result**: No broken commits, faster deployments, better code quality.

