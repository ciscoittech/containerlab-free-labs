# Stop Event Hook - Zero Errors Left Behind

**Event**: stop
**Timing**: AFTER Claude finishes responding
**Purpose**: Automatically check for errors and prevent mistakes from accumulating

---

## How It Works

When Claude finishes responding, this hook automatically:

1. **Files Modified**: Track which files were edited in this response
2. **Build Check**: Run TypeScript (frontend) and PHP (backend) builds
3. **Error Detection**: Parse and display any errors found
4. **Smart Response**:
   - If < 5 errors → Show errors to Claude for fixing
   - If ≥ 5 errors → Recommend launching build-error-resolver agent
5. **Error Reminder**: Show gentle self-checks for risky code patterns

---

## Implementation Details

### Step 1: File Edit Tracking

**What to track**:
```
For each file edited in this response:
├─ File path (relative to project root)
├─ Directory/repo (frontend or backend)
├─ File type (PHP, TypeScript/TSX, Migration, etc.)
└─ Timestamp of modification
```

**Storage**:
- Keep in-session log (reset each time Claude responds)
- Format: `{file_path, type, timestamp}`

**Example**:
```
[
  { path: "app/Services/LabValidationService.php", type: "php", timestamp: "2025-10-31T16:30:00Z" },
  { path: "resources/js/components/LabTerminal.tsx", type: "typescript", timestamp: "2025-10-31T16:30:15Z" },
  { path: "database/migrations/2025_10_31_create_labs_table.php", type: "php", timestamp: "2025-10-31T16:30:20Z" }
]
```

---

### Step 2: Build Checking

**TypeScript (Frontend)**:
```bash
npm run types
# Runs: tsc --noEmit
# Checks: resources/js/** for TypeScript errors
# Outputs: Error list with file:line:col format
```

**PHP (Backend)**:
```bash
php -l app/**/*.php
# Checks: app/ for syntax errors
# Outputs: Parse errors, warnings
```

**When to run**:
- ✅ Run if any PHP files edited
- ✅ Run if any TypeScript/TSX files edited
- ✅ Run if any migrations edited
- ❌ Skip if only documentation changed

---

### Step 3: Error Detection

**Parse errors from both builds**:

**TypeScript errors format**:
```
app/Services/LabService.ts(45,12): error TS2339:
Property 'notFound' does not exist on type 'LabService'.
```

**PHP errors format**:
```
Parse error: syntax error, unexpected '}' in
app/Services/LabService.php on line 45
```

**Extract**:
- Error count
- File paths affected
- Line numbers
- Error messages
- Error types (syntax, type, missing property, etc.)

---

### Step 4: Error Response Strategy

**If 0 errors detected**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ BUILD CLEAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
No TypeScript or PHP errors detected.
Code is ready for the next phase!
```

**If 1-4 errors detected**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 BUILD ERRORS DETECTED (3 errors)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FILE: resources/js/components/LabTerminal.tsx
ERROR: Property 'sessionId' does not exist (Line 45)
       └─ Change: session_id → sessionId

FILE: app/Services/LabService.php (2 errors)
ERROR: Undefined variable $validation (Line 78)
ERROR: Call to undefined method validate() (Line 82)

NEXT STEP: Fix these errors and resubmit.
```

**If 5+ errors detected**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 MANY ERRORS DETECTED (12 errors)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Too many errors to fix manually. Recommend:

LAUNCH AGENT:
→ build-error-resolver

This agent will:
1. Parse all errors
2. Group by category
3. Fix systematically
4. Verify fixes as it goes
5. Report results

Would you like me to launch the agent?
```

---

### Step 5: Error Handling Reminder

**Detect risky patterns in edited files**:

**Laravel patterns** (in app/Http/Controllers/*, app/Services/*, app/Jobs/*):
- ❓ Does it have try-catch blocks?
- ❓ Does it call external APIs (OpenRouter)?
- ❓ Does it use queue jobs (async)?
- ❓ Does it modify database (Eloquent)?
- ❓ Does it validate user input?

**React patterns** (in resources/js/**):
- ❓ Does it handle loading states?
- ❓ Does it handle error states?
- ❓ Does it validate form inputs?
- ❓ Does it use async/await?

**Show reminder if risky patterns found**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 ERROR HANDLING SELF-CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  RISKY PATTERNS DETECTED

Backend Changes:
   2 file(s) edited - app/Services/LabService.php, app/Http/Controllers/LabController.php

   ❓ Does error handling exist in catch blocks?
   ❓ Are external API calls wrapped in try-catch?
   ❓ Are database operations protected?
   ❓ Do queue jobs have retry logic?

   💡 Best Practice:
      - Wrap OpenRouter calls in try-catch (180s timeout)
      - Log errors with Sentry
      - Return meaningful error messages to frontend
      - Add retry logic with exponential backoff

Frontend Changes:
   1 file(s) edited - resources/js/components/LabTerminal.tsx

   ❓ Does component handle loading state?
   ❓ Does component handle error state?
   ❓ Are async operations properly awaited?

   💡 Best Practice:
      - Use React Suspense for loading states
      - Show error toasts for API failures
      - Implement retry buttons
      - Log errors to analytics
```

---

## Configuration

Add to `.claude/settings.local.json`:

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
      "showReminders": true,
      "patterns": {
        "risky": {
          "backend": ["try-catch", "OpenRouter", "queue", "database"],
          "frontend": ["async", "error-state", "loading-state"]
        }
      }
    }
  }
}
```

---

## Integration with Build Error Resolver

When 5+ errors detected, recommend:

```
Would you like me to launch the build-error-resolver agent?

This specialized agent:
1. Reads all error messages
2. Analyzes root causes
3. Groups related errors
4. Fixes errors systematically
5. Verifies fixes after each group
6. Reports final results

Usage:
→ Launch build-error-resolver agent for PHP/TypeScript errors
```

When user approves, trigger:
```
@Agent: build-error-resolver
Context: These errors from build checker [error list]
Task: Fix all errors and report fixes
```

---

## Examples

### Example 1: Clean Build

```
Response: "Created LabTerminal component with WebSocket integration"

Hook runs:
- Detects: resources/js/components/LabTerminal.tsx modified
- Runs: npm run types
- Result: ✅ No TypeScript errors

Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ BUILD CLEAN - Ready to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Example 2: Few Errors

```
Response: "Added user authentication service"

Hook runs:
- Detects: app/Services/AuthService.php, app/Http/Controllers/AuthController.php
- Runs: php -l app/**/*.php
- Result: 2 PHP errors

Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 BUILD ERRORS DETECTED (2 errors)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FILE: app/Services/AuthService.php
ERROR: Call to undefined method hash() (Line 23)
       └─ Use: Hash::make() instead

FILE: app/Http/Controllers/AuthController.php
ERROR: Undefined variable $user (Line 45)
       └─ Variable initialized on line 48, move before use

NEXT: Fix these errors and resubmit.
```

### Example 3: Many Errors

```
Response: "Refactored entire validation system"

Hook runs:
- Detects: app/Services/ValidationService.php (400 lines), 8 controllers
- Runs: php -l app/**/*.php
- Result: 12 PHP errors

Output:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 MANY ERRORS DETECTED (12 errors)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files affected:
- app/Services/ValidationService.php (6 errors)
- app/Http/Controllers/AdminController.php (3 errors)
- app/Http/Controllers/StudentController.php (2 errors)
- app/Http/Controllers/LabController.php (1 error)

RECOMMEND: Launch build-error-resolver agent

Would you like me to launch it? (Yes/No)
```

---

## What Makes This Powerful

✅ **Zero Errors Left Behind**
- Every response triggers build check
- Errors caught immediately
- Claude sees them and fixes
- No surprises later

✅ **Developer Peace of Mind**
- Know code is clean after each response
- Prevent error accumulation
- Gentle reminders catch oversight
- Auto-agent for large error batches

✅ **Time Savings**
- No manual build running
- No copying/pasting errors
- No "wait, did I catch all errors?"
- Automatic error summary

✅ **Perfect for Large Codebases**
- Critical for refactoring
- Essential for parallel changes
- Prevents regression
- Maintains code quality

---

## How to Use

### As a Developer

You don't need to do anything! The hook:
- Runs automatically after each Claude response
- Shows errors or success messages
- Recommends agents when needed
- Provides gentle reminders

### If Hook Recommends Agent

```
🚨 MANY ERRORS DETECTED (12 errors)

RECOMMEND: Launch build-error-resolver agent

Yes, launch it → @Agent: build-error-resolver
No, fix manually → I'll fix these errors...
```

---

## Performance Considerations

**Expected timing**:
- File tracking: < 100ms
- TypeScript check: 2-5 seconds (depends on project size)
- PHP check: 1-3 seconds
- Error parsing: < 500ms
- **Total: 3-9 seconds per response**

**Optimization**:
- Only run builds if files were edited
- Skip checks for documentation-only changes
- Cache build results for unchanged files
- Run in background if possible

---

## Success Metrics

This hook is working well when:
- ✅ Errors are caught immediately (within 5 seconds)
- ✅ Claude sees and fixes errors before moving on
- ✅ Build checker catches syntax errors 100% of the time
- ✅ Gentle reminders catch oversight patterns
- ✅ Agent recommendation triggers correctly (5+ errors)
- ✅ No errors slip through to end of session

**Their achievement**: "I've not had a single instance where Claude has left errors in the code for me to find later"

**Our goal**: Match or exceed this achievement
