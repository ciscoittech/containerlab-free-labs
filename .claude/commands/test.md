# /test Command - Run Test Suites

**Purpose**: Run PHPUnit (backend) and Vitest (frontend) test suites with intelligent reporting.

---

## Usage

```bash
/test                    # Run all tests (backend + frontend)
/test backend            # Run only backend tests
/test frontend           # Run only frontend tests
/test <file_path>        # Run specific test file
```

---

## What This Command Does

1. **Runs Backend Tests** (PHPUnit):
   ```bash
   php artisan test
   ```

2. **Runs Frontend Tests** (Vitest):
   ```bash
   npm test -- --run
   ```

3. **Reports Results**:
   - Pass/fail counts
   - Duration
   - Failure summaries

---

## Output Format

```
🧪 Running Test Suites...

Backend Tests (PHPUnit)
├─ Total: 175
├─ Passed: 132 (75.4%)
├─ Failed: 42 (24.6%)
└─ Duration: 26.55s

Frontend Tests (Vitest)
├─ Total: 47
├─ Passed: 15 (31.9%)
├─ Failed: 32 (68.1%)
└─ Duration: 7.27s

Overall: 147/222 passing (66.2%)
```

---

## When to Use

- ✅ After completing TDD GREEN phase
- ✅ After refactoring code
- ✅ Before committing changes
- ✅ Before creating pull requests
- ✅ When validating a fix

---

## Related Commands

- `/build` - TDD workflow with tests
- `/debug` - Analyze test failures
- `/test-cleanup` - Fix failing tests interactively
