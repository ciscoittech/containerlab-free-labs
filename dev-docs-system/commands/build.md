# /build Command - TDD Workflow Enforcer

**Purpose**: Build features using strict Test-Driven Development (TDD) methodology with Red-Green-Refactor cycle.

---

## Usage

```bash
/build "Issue #X: Feature description"
```

**Example:**
```bash
/build "Issue #12: Student Practice Quiz API"
```

---

## TDD Workflow (RED → GREEN → REFACTOR)

### Phase 1: RED (Write Failing Tests First)

1. **Read the GitHub issue** from `docs/github-issues.md`
2. **Identify acceptance criteria** from the issue
3. **Write failing tests** that validate acceptance criteria:
   - Backend: PHPUnit/Pest tests in `tests/Feature/` or `tests/Unit/`
   - Frontend: Vitest tests in `tests/components/`
4. **Run tests** - they MUST fail (RED)
5. **Verify failure** - confirm tests fail for the right reason

**Stop here if tests don't fail!** Fix the test logic.

---

### Phase 2: GREEN (Minimum Code to Pass)

1. **Write minimum code** to make tests pass
   - Backend: Controllers, Models, Services in `app/`
   - Frontend: Components in `resources/js/components/`
2. **Run tests again** - they MUST pass (GREEN)
3. **Verify all tests pass** - no shortcuts, no hacks

**Stop here if tests still fail!** Debug and fix implementation.

---

### Phase 3: REFACTOR (Improve Code Quality)

1. **Keep tests green** while refactoring
2. **Improve code quality**:
   - Extract methods
   - Remove duplication
   - Improve naming
   - Add type hints (TypeScript/PHP)
3. **Run tests after each refactor** - ensure they stay green

---

## Commands You'll Use

```bash
# Backend tests
php artisan test

# Frontend tests
npm test -- --run

# Specific test file
php artisan test tests/Feature/Student/QuizControllerTest.php
npm test tests/components/Student/QuizCard.test.tsx

# Watch mode (optional)
npm test -- --watch
```

---

## Success Criteria

✅ **All phases completed**:
- [ ] RED: Tests written and failing
- [ ] GREEN: Implementation complete, tests passing
- [ ] REFACTOR: Code improved, tests still green

✅ **Test coverage**: Minimum 2-5 tests per feature (MVP level)

✅ **No skipped phases**: Must follow RED → GREEN → REFACTOR order

---

## Example Session

```
User: /build "Issue #15: Add XP badge system"