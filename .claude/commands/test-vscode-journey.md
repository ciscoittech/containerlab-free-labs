# /test-vscode-journey Command

## Purpose
Execute the complete VS Code + Docker Desktop user journey test, measure real performance, and update documentation with validated results.

## Usage
```
/test-vscode-journey
```

## Workflow Overview

This command orchestrates a multi-agent workflow to test the VS Code local development path from the user journey documentation.

```
Stage 1: PARALLEL Setup (2 agents, ~30 sec)
├── environment-checker → Verify prerequisites
└── journey-parser → Load expected journey steps

Stage 2: SEQUENTIAL Execution (1 agent, user-driven)
└── devcontainer-executor → Execute journey commands with timing

Stage 3: PARALLEL Analysis (1 agent, ~20 sec)
└── results-analyzer → Compare actual vs predicted

Stage 4: SEQUENTIAL Documentation (1 agent, ~30 sec)
└── doc-updater → Update all journey markdown files
```

## Agent Workflow

### Stage 1: Setup & Analysis (Parallel)

**Agent 1: environment-checker**
- Load from: `.claude-library/agents/journey-testing/environment-checker.md`
- Responsibilities:
  - Verify VS Code, Docker Desktop, Remote-Containers extension
  - Capture system specs (macOS version, RAM, CPU)
  - Document baseline Docker container count
  - Return environment JSON
- Tools: Bash, Read
- Expected duration: 15 seconds
- Return to launcher: Environment data JSON

**Agent 2: journey-parser**
- Load from: `.claude-library/agents/journey-testing/journey-parser.md`
- Responsibilities:
  - Parse NEW-USER-JOURNEY.md for VS Code path (PATH 2)
  - Extract expected timings from JOURNEY-METRICS-REPORT.md
  - Load success criteria and expected outputs
  - Load known pitfalls from PITFALLS-AND-FIXES.md
  - Create testable specification
- Tools: Read, Grep
- Expected duration: 20 seconds
- Return to launcher: Journey specification JSON

### Stage 2: Execution (Sequential, User-Driven)

**Agent 3: devcontainer-executor**
- Load from: `.claude-library/agents/journey-testing/devcontainer-executor.md`
- Responsibilities:
  - Execute journey stages 1-7 with timing
  - Stage 1: Clone repository (automated)
  - Stage 2-7: Guide user through manual steps (devcontainer, deploy, validate)
  - Capture full outputs and timing for each stage
  - Handle errors with recovery attempts
  - Monitor container creation/cleanup
- Tools: Bash, Read, Grep
- Expected duration: Variable (user manual steps + 5 min automated)
- Return to launcher: Execution results JSON with all timings

**NOTE**: Some stages require manual user interaction:
- Opening VS Code and clicking "Reopen in Container"
- Timing the devcontainer build process
- User reports these timings back to executor agent

### Stage 3: Analysis (Parallel)

**Agent 4: results-analyzer**
- Load from: `.claude-library/agents/journey-testing/results-analyzer.md`
- Responsibilities:
  - Compare actual timings vs predicted (from journey-parser)
  - Calculate timing accuracy (% difference per stage)
  - Validate success rate vs predicted 92%
  - Cross-reference encountered issues vs documented pitfalls
  - Generate recommendations for documentation updates
- Tools: Read, Grep
- Expected duration: 20 seconds
- Return to launcher: Analysis report JSON

### Stage 4: Documentation (Sequential)

**Agent 5: doc-updater**
- Load from: `.claude-library/agents/journey-testing/doc-updater.md`
- Responsibilities:
  - Update NEW-USER-JOURNEY.md with ✅ TESTED badges
  - Add actual timing comparison tables
  - Update FIRST-5-MINUTES.md with real performance data
  - Add new issues to PITFALLS-AND-FIXES.md (if any)
  - Update JOURNEY-METRICS-REPORT.md with actual vs predicted
  - Create test report in test-results/
- Tools: Read, Edit, Write
- Expected duration: 30 seconds
- Return to launcher: Summary of updates made

## Execution Instructions

### For the Command Launcher:

**Stage 1 Parallel Launch**:
```javascript
// Launch both agents simultaneously in ONE message
Task(environment-checker, "Verify prerequisites and capture environment data")
Task(journey-parser, "Parse journey documentation and create test specification")
```

**Wait for Stage 1 completion, then Stage 2 Sequential**:
```javascript
// Launch executor with results from Stage 1
Task(devcontainer-executor, "Execute journey with timing, use environment data and journey spec")
```

**Wait for Stage 2, then Stage 3 Parallel**:
```javascript
// Launch analyzer with execution results
Task(results-analyzer, "Compare results vs predictions, analyze discrepancies")
```

**Wait for Stage 3, then Stage 4 Sequential**:
```javascript
// Launch doc updater with analysis results
Task(doc-updater, "Update all journey documentation with test results")
```

## Expected Outcomes

### Success Criteria
✅ All prerequisites verified
✅ Journey specification loaded
✅ All journey stages executed
✅ Lab deploys successfully
✅ All 5 validation tests pass
✅ Cleanup successful
✅ Timing data captured
✅ Analysis completed
✅ Documentation updated

### Deliverables

1. **test-results/vscode-journey-test-YYYY-MM-DD.md**
   - Complete test report
   - Environment details
   - Full timing breakdown
   - All terminal outputs
   - Issues encountered
   - Analysis summary

2. **Updated Documentation**:
   - NEW-USER-JOURNEY.md (✅ TESTED badges, actual timings)
   - FIRST-5-MINUTES.md (real performance data)
   - PITFALLS-AND-FIXES.md (confirmed/new issues)
   - JOURNEY-METRICS-REPORT.md (actual vs predicted comparison)

## Error Handling

If any stage fails:
1. Agent reports failure with details
2. Launcher asks user if they want to:
   - Retry the failed stage
   - Skip to documentation (partial results)
   - Abort test

Critical failures (stop execution):
- Prerequisites not met (no Docker/VS Code)
- Repository clone failed
- Lab deployment failed with unrecoverable error

## Example Output

After completion, user sees:

```markdown
# VS Code Journey Test Complete ✅

## Summary
- Environment: macOS 15.1.1, VS Code 1.104.2, Docker 28.3.3, 16GB RAM
- Journey: VS Code + Docker Desktop (First Time)
- Lab: linux-network-namespaces
- Result: SUCCESS ✅

## Timing Comparison
| Stage | Expected | Actual | Status |
|-------|----------|--------|--------|
| Clone | 60s | 45s | ✅ Faster |
| Devcontainer Build | 180s | 195s | ✅ Close |
| Lab Deploy | 25s | 22s | ✅ Faster |
| Validation | 5s | 4s | ✅ |
| **Total** | **17 min** | **7.5 min** | ✅ Much faster |

## Test Details
- Tests Passed: 5/5
- Errors: 0
- Issues Encountered: None

## Documentation Updated
✅ NEW-USER-JOURNEY.md
✅ FIRST-5-MINUTES.md
✅ PITFALLS-AND-FIXES.md
✅ JOURNEY-METRICS-REPORT.md
✅ Test report created

Full report: test-results/vscode-journey-test-2025-10-03.md
```

## Notes for Users

- **Total workflow time**: ~15 minutes (including manual devcontainer steps)
- **Manual steps required**: Opening VS Code, clicking "Reopen in Container", timing build
- **Best run when**: Docker Desktop already running, good network connection
- **Results**: Real-world validated timings to improve documentation accuracy

---

*This command uses the Claude Agent Framework multi-agent pattern for parallel analysis and sequential execution.*
