# /code-review Command

**Purpose**: Architectural code review against plan and guidelines
**Integrates**: Implementation plan validation, security review, performance analysis
**Output**: Review report with approval, suggestions, or required fixes

---

## What This Command Does

`/code-review` provides comprehensive architectural review by:

1. Comparing code to implementation plan
2. Checking against coding guidelines
3. Reviewing security best practices
4. Analyzing performance
5. Validating acceptance criteria
6. Identifying technical debt
7. Providing approval or revision recommendations

**Result**: Code quality validated before merge.

---

## Usage

### Basic Usage

```bash
/code-review "feature-name"

Examples:
/code-review "user-auth-oauth"
/code-review "iac-labs-terminal"
/code-review "database-migration"
```

### Detailed Review

```bash
/code-review
Feature: user-auth-oauth
Focus: security

This triggers deeper security review
```

### Review Specific Phase

```bash
/code-review
Feature: user-auth-oauth
Phase: Phase 2 (Frontend)

Reviews only Phase 2 code
```

---

## What Gets Reviewed

### 1. Architecture Conformance

**Does code match the plan?**

```
✅ YES                          ❌ NO
- Follows phase structure        - Files in wrong location
- Uses planned patterns          - Missing components
- Integrates as designed         - Deviates from design
- Component relationships right  - Wrong dependencies
```

### 2. Acceptance Criteria

**Does code meet requirements?**

```
From plan:
✅ OAuth works with Google
✅ OAuth works with GitHub
❌ Email verification not implemented
❌ Multi-device logout not working
```

### 3. Code Guidelines

**Does code follow standards?**

```
✅ Proper error handling
✅ Input validation
❌ Missing type hints (5 functions)
❌ Inconsistent naming (models vs services)
```

### 4. Security Review

**Are there security vulnerabilities?**

```
✅ No SQL injection risks
✅ CSRF protection enabled
❌ Token not rotating properly
❌ OAuth state parameter missing
```

### 5. Performance Analysis

**Is code performant?**

```
✅ Database queries optimized
❌ N+1 query problem detected (3 places)
❌ Session lookup happens on every request
```

### 6. Test Coverage

**Are tests adequate?**

```
✅ Happy path tested
✅ Error cases covered
❌ Edge cases missing
❌ Integration tests incomplete
```

---

## Review Example

### Input

```bash
/code-review "user-auth-oauth"
```

### Output

```
CODE REVIEW REPORT
═════════════════════════════════════════════════════════════════

Feature: User Authentication with OAuth
Branch: feature/oauth-auth
Files Changed: 12
Lines Added: 890
Lines Removed: 145

DATE: Oct 31, 2025
REVIEWER: Code Review Agent

═════════════════════════════════════════════════════════════════

EXECUTIVE SUMMARY
─────────────────

Status: ⚠️  APPROVED WITH REQUIRED FIXES
Confidence: MEDIUM (70%)

Summary:
Architecture is sound and follows the plan well. Implementation is
mostly correct. However, there are 3 security issues and 2 performance
issues that must be fixed before merging.

Estimated Fix Time: 2-3 hours

═════════════════════════════════════════════════════════════════

ARCHITECTURE CONFORMANCE
────────────────────────

✅ PHASE 1 (Foundation) - APPROVED

Core OAuth Service:
✅ Follows planned architecture
✅ Supports Google and GitHub as designed
✅ Token management matches plan
✅ Session creation correct

Auth Routes:
✅ Routes match API contract from plan
✅ Request/response formats correct
✅ Error handling appropriate

Database:
✅ Schema matches migrations
✅ Relationships correct
✅ Indices in place

---

✅ PHASE 2 (Frontend) - APPROVED WITH NOTES

Login Component:
✅ Uses xterm.js correctly
✅ OAuth button placement good
⚠️  Note: Could add loading state animation

Profile Page:
✅ Shows OAuth user info
✅ Profile updates work
❌ ISSUE: Missing edit profile form validation (see below)

---

❌ PHASE 3 (Testing) - INCOMPLETE

Required Tests Not Found:
❌ OAuth callback tests
❌ Token refresh tests
❌ Session timeout tests
❌ Multi-device logout tests

═════════════════════════════════════════════════════════════════

ACCEPTANCE CRITERIA CHECKLIST
─────────────────────────────

From plan:

✅ OAuth works with Google
✅ OAuth works with GitHub
✅ Automatic user creation
✅ Session management
✅ Login page with OAuth buttons
⚠️  Email verification (not yet implemented - OK)
❌ Multi-device logout (not working)
❌ Account linking (not implemented)

Issues:
- Multi-device logout needs to invalidate all sessions
- Account linking UI not built (future phase)

═════════════════════════════════════════════════════════════════

CODE GUIDELINES & STANDARDS
────────────────────────────

✅ STYLE & FORMATTING

- PHP code follows PSR-12 ✅
- JavaScript/React follows Airbnb style ✅
- Consistent naming conventions ✅
- Well-organized file structure ✅

✅ DOCUMENTATION

- Classes have docblocks ✅
- Complex logic documented ✅
- API endpoints documented ✅
- Database schema documented ✅

✅ ERROR HANDLING

- Try-catch blocks present ✅
- Error messages useful ✅
- Logging in place ✅
- Graceful degradation ✅

❌ TYPE SAFETY

- Missing 3 type hints (see below)
- Some loose type comparisons
- Could be more strict

Specific Issues:
- OAuthService.php line 45: Missing return type
- AuthController.php line 78: Missing parameter type
- Session.php line 120: Loose type comparison (== vs ===)

═════════════════════════════════════════════════════════════════

SECURITY REVIEW
────────────────

🔒 STRONG SECURITY
✅ CSRF tokens present
✅ Input validation on all forms
✅ SQL injection protection (prepared statements)
✅ XSS prevention (content escaping)
✅ Password hashing correct
✅ HTTPS enforced

🔒 MEDIUM SECURITY
⚠️  Session storage unencrypted
⚠️  CORS configuration permissive
⚠️  Rate limiting not enforced on OAuth routes

⛔ CRITICAL SECURITY ISSUES

❌ ISSUE 1: OAuth State Parameter
Location: OAuthService.php, line 34
Severity: HIGH
Problem:
  OAuth state parameter not validated in callback
  Allows CSRF attacks on OAuth flow

Current Code:
  $state = $_GET['state'] ?? null;  // ❌ Not validated

Fix Required:
  Compare $_GET['state'] to $_SESSION['oauth_state']
  Reject if mismatch

Impact: Blocks user login until fixed
Estimated Time: 30 minutes

❌ ISSUE 2: Token Rotation
Location: OAuthService.php, line 156
Severity: MEDIUM
Problem:
  Refresh tokens not rotating
  Compromised token can be used indefinitely

Current Code:
  return $token;  // ❌ Same token reused

Fix Required:
  Generate new refresh token on each use
  Invalidate old token

Impact: Security risk, not critical
Estimated Time: 1 hour

❌ ISSUE 3: Session Fixation Risk
Location: app/Middleware/SessionMiddleware.php, line 42
Severity: MEDIUM
Problem:
  Session ID not regenerated on login
  Allows session fixation attacks

Current Code:
  session_start();  // ❌ Should regenerate

Fix Required:
  Call session_regenerate_id(true) after login

Impact: Security risk
Estimated Time: 15 minutes

═══════════════════════════════════════════════════════════════════

PERFORMANCE ANALYSIS
─────────────────────

⚡ GOOD PERFORMANCE
✅ Database queries optimized
✅ Efficient token lookup (indexed)
✅ Caching in place for user data

⚠️ PERFORMANCE CONCERNS

⛔ ISSUE 4: N+1 Query Problem
Location: AuthController.php, line 87 (getUserWithOAuthAccounts)
Severity: MEDIUM
Problem:
  Queries run in loop, causing N+1 queries
  100 users = 101 database queries

Current Code:
  foreach ($users as $user) {
    $accounts = OAuthAccount::where('user_id', $user->id)->get();
  }

Expected: 2 queries (1 user + 1 account lookup)
Actual: 101 queries (1 user + 100 account lookups)

Fix Required:
  Use eager loading: User::with('oauthAccounts')

Impact: Slow response times under load
Estimated Time: 30 minutes

⛔ ISSUE 5: Session Lookup Performance
Location: app/Middleware/SessionMiddleware.php, line 28
Severity: MEDIUM
Problem:
  Session lookup happens on every request
  No caching, hits database every time

Current Queries per Request:
  1. Get session
  2. Get user
  3. Get user preferences
  = 3 queries per request

Expected: Use cache (Redis)
Actual: All database queries

Fix Required:
  Cache session in Redis with 1-hour TTL
  Invalidate on logout

Impact: Scalability issue (10+ concurrent users)
Estimated Time: 1.5 hours

═══════════════════════════════════════════════════════════════════

TEST COVERAGE ANALYSIS
──────────────────────

Current Tests: 8/15 required

✅ IMPLEMENTED TESTS

[x] OAuth callback handler (4 tests)
    - Google callback
    - GitHub callback
    - Invalid provider
    - Invalid state

[x] User creation (2 tests)
    - New user creation
    - Existing user login

[x] Session management (2 tests)
    - Session creation
    - Session deletion

❌ MISSING TESTS

[ ] Token refresh (should have 2 tests)
    - Valid refresh
    - Invalid/expired token

[ ] Session timeout (should have 2 tests)
    - Automatic timeout
    - Manual logout

[ ] Multi-device logout (should have 2 tests)
    - Logout all sessions
    - Session invalidation

[ ] Edge cases (should have 5 tests)
    - Rapid login/logout
    - Concurrent requests
    - Token collision
    - Database errors
    - Network errors

Test Coverage: 53% (should be 80%+)

═══════════════════════════════════════════════════════════════════

TECHNICAL DEBT IDENTIFICATION
─────────────────────────────

Low Priority (Can defer):
⚠️  Logging could be more detailed
⚠️  Error messages could be more specific
⚠️  API response format could be standardized

Medium Priority (Should address soon):
⚠️  Refresh token rotation not implemented
⚠️  Email verification partially implemented
⚠️  Account linking not implemented

High Priority (Must address before merge):
⛔ OAuth state validation missing (SECURITY)
⛔ Session fixation risk (SECURITY)
⛔ N+1 query problem (PERFORMANCE)
⛔ Missing test coverage (QUALITY)

═══════════════════════════════════════════════════════════════════

SUMMARY OF REQUIRED FIXES
──────────────────────────

MUST FIX BEFORE MERGE (3 items):

1. ⛔ Add OAuth state validation
   File: OAuthService.php, line 34
   Time: 30 min
   Priority: CRITICAL (security)

2. ⛔ Fix N+1 query problem
   File: AuthController.php, line 87
   Time: 30 min
   Priority: HIGH (performance)

3. ⛔ Regenerate session on login
   File: app/Middleware/SessionMiddleware.php, line 42
   Time: 15 min
   Priority: HIGH (security)

SHOULD FIX BEFORE MERGE (2 items):

4. ⚠️  Add token rotation
   File: OAuthService.php, line 156
   Time: 1 hour
   Priority: MEDIUM (security)

5. ⚠️  Add session caching
   File: app/Middleware/SessionMiddleware.php
   Time: 1.5 hours
   Priority: MEDIUM (performance)

NICE TO HAVE (Can do after merge):

6. Add type hints (3 locations)
7. Improve logging
8. Standardize API responses
9. Add more edge case tests

═══════════════════════════════════════════════════════════════════

APPROVAL DECISION
─────────────────

Status: ⚠️  APPROVAL CONDITIONAL ON FIXES

Approval: NOT GRANTED until critical issues are addressed

Required Actions Before Merge:

CRITICAL (Do first):
[✓] Fix OAuth state validation - 30 min
[✓] Fix session fixation - 15 min
[✓] Fix N+1 queries - 30 min
Total: 1.25 hours

IMPORTANT (Then do these):
[✓] Implement token rotation - 1 hour
[✓] Add session caching - 1.5 hours
Total: 2.5 hours

After Fixes:
[✓] Re-run tests (should all pass)
[✓] Re-request review
[✓] Once approved → merge to main

═══════════════════════════════════════════════════════════════════

RECOMMENDATIONS
────────────────

What's Going Well:
✅ Architecture matches plan perfectly
✅ Code is readable and well-organized
✅ Good documentation
✅ Proper error handling
✅ User experience is good

What Needs Improvement:
⚠️  Security validation (OAuth state)
⚠️  Database query efficiency
⚠️  Session management (caching)
⚠️  Test coverage (missing 7 tests)
⚠️  Token lifecycle management

For Next Phase:
→ Consider caching strategy upfront
→ Add performance testing
→ Plan for multi-database scaling
→ Document security decisions

═══════════════════════════════════════════════════════════════════

CONCLUSION
──────────

Overall Assessment: ✅ SOLID FOUNDATION WITH IMPORTANT FIXES NEEDED

The OAuth implementation is well-architected and mostly correct. The
main issues are around security validation and query optimization.

With the 5 recommended fixes (~3.75 hours work), this code will be
production-ready and secure.

Estimated Timeline:
- 1.25 hours for critical fixes
- 2.5 hours for important improvements
- Total: 3.75 hours
- Can be done: 1-2 development sessions

Confidence After Fixes: HIGH (90%)

═══════════════════════════════════════════════════════════════════

NEXT STEPS
──────────

1. Address critical issues (ASAP)
   - Add OAuth state validation
   - Fix session fixation risk
   - Fix N+1 queries

2. Address important improvements
   - Implement token rotation
   - Add session caching
   - Improve logging

3. Add missing tests
   - Token refresh tests
   - Session timeout tests
   - Multi-device logout tests

4. Re-request review
   Once all fixes are done, run:
   /code-review "user-auth-oauth"

5. Merge to main
   Once approved, safe to merge

═══════════════════════════════════════════════════════════════════
```

---

## How It Works

When you run `/code-review`:

```
1. You provide feature name
         ↓
2. System locates feature files and plan
         ↓
3. Agent analyzes:
         ├─ Implementation plan
         ├─ Code quality guidelines
         ├─ Security best practices
         ├─ Performance patterns
         ├─ Test coverage requirements
         └─ Project architecture patterns
         ↓
4. Agent reviews code against each area
         ├─ Architecture conformance
         ├─ Acceptance criteria
         ├─ Code standards
         ├─ Security vulnerabilities
         ├─ Performance issues
         ├─ Test coverage
         └─ Technical debt
         ↓
5. Agent generates detailed report with:
         ├─ Approval status
         ├─ Issues found (severity level)
         ├─ Security vulnerabilities
         ├─ Performance concerns
         ├─ Missing tests
         ├─ Required fixes
         ├─ Optional improvements
         └─ Next steps
         ↓
6. You address issues and re-run review
```

---

## Approval Levels

### ✅ APPROVED
```
All acceptance criteria met
No security issues
Performance acceptable
Good test coverage
Ready to merge
```

### ⚠️ APPROVED WITH NOTES
```
All critical items met
Minor improvements suggested
Not blocking merge
Can do improvements later
OK to merge
```

### ⚠️ APPROVED WITH REQUIRED FIXES
```
Critical issues found
Must be fixed before merge
Will re-review after fixes
Not OK to merge yet
```

### ❌ NOT APPROVED
```
Major issues or security vulnerabilities
Multiple failures
Requires significant rework
Cannot merge
Must redesign/rewrite
```

---

## Integration with Other Commands

### With `/dev-docs`

```bash
# Create plan
/dev-docs "feature description"

# Implement feature...

# Review against plan
/code-review "feature-name"
```

### With `/build-and-fix`

```bash
# Code review first
/code-review "feature-name"

# If approved, build and fix
/build-and-fix
```

### With Git Workflow

```bash
# On feature branch
/code-review "feature-name"

# If approved
git commit
git push

# If not approved
# Fix issues
# Re-run review
# Then commit
```

---

## Tips & Tricks

### Quick Review (Specific Focus)

```bash
/code-review
Feature: user-auth-oauth
Focus: security

Focuses on security issues only
Faster than full review
```

### Phase-Specific Review

```bash
/code-review
Feature: user-auth-oauth
Phase: Phase 2

Reviews only Phase 2 code
Useful during development
```

### Pre-Merge Review

```bash
/code-review "feature-name"

Before merging to main
Comprehensive review
Blocks merge if issues found
```

---

## FAQ

**Q: How long does code review take?**
A: 5-15 minutes depending on code size and complexity.

**Q: Can I ignore "nice to have" recommendations?**
A: Yes, if they're not blocking. But addressing them improves quality.

**Q: What if review finds major issues?**
A: You fix them and re-run `/code-review` to verify fixes.

**Q: Does this replace human code review?**
A: No, this is architectural review. Human code review is separate.

**Q: Can I review without a plan?**
A: It's less effective, but you can use /code-review without /dev-docs.

---

## Achievement

`/code-review` ensures code quality before merge:

**Without it**:
```
Write code
Merge to main
Discover issues in production
Emergency fixes
```

**With it**:
```
Write code
Run /code-review
Fix issues before merge
High-quality merge
No production surprises
```

**Result**: Better code quality, fewer production issues.

