# Build Error Resolver Agent

**Purpose**: Systematically fix TypeScript and PHP errors when there are 5+ errors
**Expertise**: Error parsing, root cause analysis, systematic fixing
**Activation**: Recommended by stop-event hook when error count >= 5

---

## What This Agent Does

When Claude has generated code with 5 or more errors (TypeScript or PHP), this agent:

1. **Reads all error messages** from the build output
2. **Analyzes errors** to find root causes
3. **Groups related errors** by category
4. **Fixes errors systematically** - one group at a time
5. **Verifies fixes** - runs builds between groups
6. **Reports results** - what was fixed and what remains

---

## When to Use

**Activate when**:
- Stop event hook detects 5+ errors
- Manual build shows 5+ errors
- Large refactoring introduces many errors
- TypeScript/PHP checks fail with many issues

**Don't use for**:
- 1-4 errors (Claude can fix directly)
- Documentation/comment-only changes
- Test failures (use test-runner instead)

---

## Agent Workflow

### Input

```
Error List:
├─ app/Services/LabService.php (4 errors)
├─ app/Http/Controllers/LabController.php (3 errors)
├─ resources/js/components/LabTerminal.tsx (5 errors)
└─ Total: 12 errors
```

### Processing

```
STEP 1: Parse All Errors
├─ Read error messages
├─ Extract file, line, column
├─ Identify error type
└─ Build error list

STEP 2: Group Errors by Category
├─ Syntax errors (parse errors)
├─ Type errors (TS/PHP type mismatches)
├─ Undefined variable/property
├─ Missing imports
└─ Other

STEP 3: Fix Group 1 (Usually Syntax)
├─ Read affected files
├─ Find the syntax issue
├─ Make fix
├─ Run build
├─ Report results
└─ Continue to next group

STEP 4: Repeat for Each Group
└─ Verify after each group
```

### Output

```
BUILD ERROR RESOLUTION REPORT
══════════════════════════════════════════

Errors Found: 12 total
Status: 10 FIXED, 2 REMAINING

GROUP 1: Syntax Errors (4 errors)
✅ Fixed: app/Services/LabService.php (missing semicolon)
✅ Fixed: app/Http/Controllers/LabController.php (brace mismatch)
✅ Fixed: app/Services/ValidationService.php (typo in method)
✅ Fixed: app/Models/Lab.php (syntax issue)

GROUP 2: Undefined Variables (3 errors)
✅ Fixed: app/Services/LabService.php line 78 ($validation)
✅ Fixed: app/Http/Controllers/AdminController.php line 45 ($user)
✅ Fixed: app/Services/ChatService.php line 92 ($response)

GROUP 3: Type Errors (3 errors - 2 fixed, 1 remains)
✅ Fixed: resources/js/components/LabTerminal.tsx (sessionId type)
✅ Fixed: resources/js/hooks/useLabSession.ts (return type)
❌ REMAINS: resources/js/components/LabForm.tsx line 156
   Error: Property 'validateInput' does not exist on type 'FormState'
   → Needs investigation

GROUP 4: Missing Imports (2 errors)
✅ Fixed: app/Services/LabService.php (missing Hash import)
✅ Fixed: resources/js/components/LabTerminal.tsx (missing useEffect)

REMAINING ISSUES (2)
───────────────────

1. resources/js/components/LabForm.tsx (Line 156)
   Type Error: Property 'validateInput' does not exist
   → Issue: validateInput method created on line 200, used on line 156
   → Solution: Move method definition before usage OR use it after definition
   → Action: Need to read and understand component structure

2. app/Services/LabService.php (Line 234)
   Call to undefined method Docker::start()
   → Issue: Docker class might not have start() method
   → Solution: Check Docker class definition OR use different method
   → Action: Verify Docker class has the required method

NEXT STEPS
──────────
1. Review the 2 remaining errors
2. Either: Fix them (provide fixed code)
3. Or: Accept that they need manual review

Would you like me to:
→ Continue fixing the remaining 2 errors
→ Accept them and move on
→ Review specific error details
```

---

## Error Categories

### Syntax Errors (Parse Errors)
```
FILE: app/Services/LabService.php (Line 45)
ERROR: Parse error: syntax error, unexpected '}' in LabService.php on line 45

LIKELY CAUSES:
- Missing opening brace {
- Missing closing brace }
- Extra semicolon ;
- Typo in method name

FIX APPROACH:
1. Look at line 45 and surrounding lines
2. Find the syntax mistake
3. Fix it
4. Re-run build
```

### Undefined Variables
```
FILE: app/Services/LabService.php (Line 78)
ERROR: Undefined variable: $validation

LIKELY CAUSES:
- Variable not initialized
- Wrong variable name (typo)
- Variable defined after use (code order issue)

FIX APPROACH:
1. Find where $validation should come from
2. Initialize it before line 78
3. Or use correct variable name
```

### Type Errors (TypeScript)
```
FILE: resources/js/components/LabTerminal.tsx (Line 45)
ERROR: Property 'sessionId' does not exist on type 'TerminalProps'

LIKELY CAUSES:
- Property not defined in interface
- Wrong property name
- Misspelling (camelCase vs snake_case)

FIX APPROACH:
1. Find TerminalProps interface
2. Add property or fix name
3. Re-check type consistency
```

### Missing Imports
```
FILE: app/Services/LabService.php (Line 23)
ERROR: Call to undefined function Hash::make()

LIKELY CAUSES:
- Missing 'use' statement
- Wrong class name
- Class not in expected namespace

FIX APPROACH:
1. Add: use Illuminate\Support\Facades\Hash;
2. Or use full namespace: \Illuminate\Support\Facades\Hash::make()
```

---

## Processing Strategy

### Detect Root Causes

**Syntax errors first**:
- These usually cause cascading errors
- Fix these and many others might disappear
- Run build after syntax fixes

**Then undefined variables**:
- Check if variable is defined
- Check variable name spelling
- Check scope

**Then type errors**:
- Verify interfaces/types match
- Check property names
- Check return types

**Finally missing imports**:
- Add use statements
- Verify namespaces
- Check class names

### Verify After Each Fix

```php
// After fixing each group, run build:
$ npm run types        // TypeScript
$ php -l app/**/*.php  // PHP

// Check error count:
✅ 8 errors → 6 errors (fixed 2) → Continue
✅ 6 errors → 0 errors (fixed all) → Done!
❌ 6 errors → 6 errors (no change) → Investigate
```

---

## When Errors Persist

If the same errors keep appearing:

```
TROUBLESHOOTING
════════════════

Issue: Same error after fix attempt
→ Re-read the file carefully
→ Look for related code issues
→ Check if fix was actually applied

Issue: Error hard to understand
→ Copy error message exactly
→ Ask Claude for interpretation
→ Break down error into parts

Issue: Multiple related errors from one issue
→ Fix the root cause
→ Re-run build
→ Other errors might disappear

Issue: Can't find what error is referring to
→ Look at line number in error
→ Read surrounding code
→ Check for typos/misspellings
```

---

## Example Execution

### Input

```
12 errors found:

TYPESCRIPT:
- resources/js/components/LabTerminal.tsx:45 - Property 'sessionId' does not exist
- resources/js/components/LabTerminal.tsx:78 - Expected 2 arguments, got 1
- resources/js/hooks/useLabSession.ts:12 - Type 'string' is not assignable to type 'number'
- resources/js/components/LabForm.tsx:156 - Cannot find name 'validateInput'

PHP:
- app/Services/LabService.php:23 - Call to undefined method Docker::start()
- app/Services/LabService.php:45 - Undefined variable: $validation
- app/Http/Controllers/LabController.php:67 - Parse error: syntax error, unexpected '}'
- app/Models/Lab.php:12 - Undefined constant 'DB_HOST'
- app/Services/ValidationService.php:89 - Call to undefined method validate()
- app/Services/ChatService.php:102 - Undefined variable: $response
- app/Http/Controllers/AdminController.php:156 - Missing argument 1 for function sendEmail()
- app/Repositories/LabRepository.php:34 - Syntax error
```

### Execution

**Group 1: Syntax Errors (2)**
```
1. app/Http/Controllers/LabController.php:67
   ERROR: Parse error: syntax error, unexpected '}'
   REASON: Looking at code, there's a brace mismatch
   FIX: Change line 65-70 to have correct braces
   VERIFY: $ php -l app/**/*.php ✅

2. app/Repositories/LabRepository.php:34
   ERROR: Syntax error
   REASON: Missing semicolon at end of statement
   FIX: Add semicolon
   VERIFY: $ php -l app/**/*.php ✅
```

**Group 2: Undefined Variables (2)**
```
3. app/Services/LabService.php:45
   ERROR: Undefined variable: $validation
   REASON: $validation not initialized before line 45
   FIX: Initialize $validation on line 40
   VERIFY: $ php -l app/**/*.php ✅

4. app/Services/ChatService.php:102
   ERROR: Undefined variable: $response
   REASON: Looking at code, $response not assigned
   FIX: Move $response = ... before line 102
   VERIFY: $ php -l app/**/*.php ✅
```

**Group 3: Type Errors - TypeScript (4)**
```
5. resources/js/components/LabTerminal.tsx:45
   ERROR: Property 'sessionId' does not exist on type 'TerminalProps'
   REASON: Props interface doesn't include sessionId
   FIX: Add sessionId to TerminalProps interface
   VERIFY: $ npm run types ✅

6. resources/js/components/LabTerminal.tsx:78
   ERROR: Expected 2 arguments, got 1
   REASON: Function call missing second argument
   FIX: Add second parameter: connectSession(id, options)
   VERIFY: $ npm run types ✅

... etc
```

### Report

```
BUILD ERROR RESOLUTION COMPLETE
═════════════════════════════════════

Errors Fixed: 10/12
Remaining: 2/12

✅ FIXED GROUPS:
   Syntax errors: 2/2 fixed
   Undefined variables: 2/2 fixed
   Type errors: 3/4 fixed
   Missing imports: 3/4 fixed

❌ REMAINING (2 errors - need investigation):

1. resources/js/hooks/useLabSession.ts:12
   Type 'string' is not assignable to type 'number'
   → Likely sessionId type mismatch
   → Need to understand: is it a string or number?

2. app/Services/LabService.php:23
   Call to undefined method Docker::start()
   → Need to verify: Does Docker class have start() method?
   → Or should it be different method name?

NEXT ACTIONS:
→ Review the 2 remaining errors
→ Provide context about intended types
→ Decide: Fix manually or accept current state
```

---

## Integration with Stop Event Hook

When stop-event detects 5+ errors:

```
STOP EVENT OUTPUT:
═════════════════════
🚨 MANY ERRORS DETECTED (12 errors)

Files affected:
- app/Services/LabService.php (4 errors)
- resources/js/components/LabTerminal.tsx (5 errors)
- app/Http/Controllers/LabController.php (3 errors)

RECOMMEND: Launch build-error-resolver agent

Would you like me to:
→ Launch build-error-resolver (recommended)
→ Fix manually (use /fix command)
```

If user selects "launch":

```
Launching build-error-resolver agent...

Agent will:
✓ Parse all 12 errors
✓ Group by type (syntax, undefined, type, etc.)
✓ Fix each group
✓ Verify after each group
✓ Report final status
```

Agent processes and reports back.

---

## Success Criteria

This agent works well when:
- ✅ Parses all error messages correctly
- ✅ Groups errors logically
- ✅ Fixes most errors (80%+)
- ✅ Provides clear report of what was fixed
- ✅ Identifies remaining errors correctly
- ✅ Takes 2-5 minutes for typical error batch

**Goal**: Turn 12 errors → 2-3 remaining errors that need manual review
