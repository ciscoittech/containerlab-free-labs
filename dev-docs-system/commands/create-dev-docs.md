# Create Dev Docs

Create development documentation files for large tasks to prevent losing context.

## When to Use

After exiting plan mode with an approved plan, create dev docs:

```bash
/create-dev-docs phase-2-refactoring
```

## What Gets Created

Three files in `~/dev/active/[task-name]/`:

### 1. `[task-name]-plan.md`
Contains the approved implementation plan from planning mode.

**Auto-generated structure**:
```markdown
# [Task Name] - Implementation Plan

**Created**: [Date]
**Status**: IN PROGRESS

## Executive Summary
[Brief overview]

## Phases
[Breakdown of work]

## Success Criteria
[What defines completion]

## Timeline
[Expected duration]
```

### 2. `[task-name]-context.md`
Key information for resuming work.

**Contains**:
- Key files and their purposes
- Important architectural decisions
- Dependencies and blockers
- Last updated timestamp
- Next steps when resuming

### 3. `[task-name]-tasks.md`
Checklist of all tasks to complete.

**Structure**:
```markdown
# [Task Name] - Task Checklist

**Last Updated**: [Timestamp]

## Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

## Phase 2: [Name]
- [ ] Task 1

## Instructions
- Mark tasks complete immediately after finishing
- Update context.md with new findings
- Update this file with new tasks discovered
```

---

## How to Use

### 1. Create Directory
```bash
mkdir -p ~/dev/active/phase-2-refactoring
```

### 2. Create Files

Copy the approved plan into `phase-2-refactoring-plan.md`

Create `phase-2-refactoring-context.md`:
```markdown
# Phase 2 Refactoring - Context

**Last Updated**: 2025-10-31 14:30 UTC

## Key Files Affected
- `app/Services/ContainerValidationScript.php` - Security fix
- `app/Services/LabValidationService.php` - Escaping implementation
- `app/Services/QuestionGenerationService.php` - Merge candidate
- `app/Services/EnhancedQuestionGenerationService.php` - Will be deleted

## Important Decisions Made
1. **Security Fix Strategy**: Use escapeshellarg() for all shell commands
2. **Service Merge**: Add feature flag to QuestionGenerationService
3. **Rate Limiting**: 10 messages per student per day
4. **Timeline**: 3 weeks (Weeks 1-3 of Phase 2)

## Next Steps When Resuming
1. Read this file + plan.md
2. Check which tasks are complete in tasks.md
3. Resume from where we left off
4. Update "Last Updated" timestamp

## Blockers
- None currently

## Open Questions
- Should we merge services or use feature flag permanently?
- Progress service consolidation: separate or merged?
```

Create `phase-2-refactoring-tasks.md`:
```markdown
# Phase 2 Refactoring - Task Checklist

**Last Updated**: 2025-10-31 14:30 UTC
**Current Phase**: Week 1

## Week 1: Critical Security & Cost Clarity (15 hours)

### Task 1: Fix Command Injection Vulnerability (4 hours)
- [ ] Research escapeshellarg() usage
- [ ] Update LabValidationService (7 check types)
- [ ] Write security tests
- [ ] Manual validation
- [ ] Deploy to production

### Task 2: Query Database for Real Costs (3 hours)
- [ ] Connect to production database
- [ ] Run cost queries
- [ ] Calculate monthly averages
- [ ] Update OPENROUTER-USAGE.md

### Task 3: Clarify Mystery Services (2 hours)
- [ ] Review ChatContextBuilder code
- [ ] Review ModelUsageService code
- [ ] Update SERVICE-INVENTORY.md

### Task 4: Test Security Fix (2 hours)
- [ ] Write unit tests
- [ ] Write E2E tests
- [ ] Manual testing

### Task 5: Deploy & Validate (2 hours)
- [ ] Deploy to production
- [ ] Monitor for errors
- [ ] Confirm validation working

## Week 2: Service Consolidation & Optimization (18 hours)

### Task 6: Merge Question Generation Services (6 hours)
- [ ] Analyze EnhancedQuestionGenerationService
- [ ] Add feature flag to QuestionGenerationService
- [ ] Update controllers
- [ ] Write tests
- [ ] Delete EnhancedQuestionGenerationService

### Task 7: Analyze Progress Services (4 hours)
- [ ] Read all 3 progress services
- [ ] Map usage patterns
- [ ] Create consolidation recommendation

### Task 8: Implement Chat Rate Limiting (4 hours)
- [ ] Create UserChatLimit migration
- [ ] Create middleware
- [ ] Update routes
- [ ] Write tests
- [ ] Deploy

## Week 3: Testing & Validation (10 hours)

### Task 9: Performance Testing (3 hours)
- [ ] Load test with 10 concurrent users
- [ ] Monitor OpenRouter costs
- [ ] Check memory stability

### Task 10: Documentation & QA (4 hours)
- [ ] Update all docs with real data
- [ ] Create integration diagrams
- [ ] Final QA sign-off

---

## Progress Tracking

**Completion**: 0/28 tasks (0%)

**Week 1**: 0/6 (0%)
**Week 2**: 0/10 (0%)
**Week 3**: 0/10 (0%)

---

## How to Update

1. **After completing a task**: Check it off immediately
2. **Discovered new tasks**: Add them with [NEW] prefix
3. **Context changes**: Update context.md
4. **Every work session**: Update "Last Updated" timestamp

```

### 3. Update CLAUDE.md

Add this to your CLAUDE.md to remember where dev docs are stored:

```markdown
## Current Development Tasks

**Phase 2 Refactoring**: `~/dev/active/phase-2-refactoring/`
- Plan: `phase-2-refactoring-plan.md`
- Context: `phase-2-refactoring-context.md`
- Tasks: `phase-2-refactoring-tasks.md`
```

---

## Benefits

✅ **Prevents Context Loss**: All critical info in one place
✅ **Easy Resume**: Know exactly where you left off
✅ **Progress Tracking**: See checklist of completed work
✅ **Shared Understanding**: Other developers can continue work
✅ **Decision Log**: Understand why decisions were made

---

## Pro Tips

1. **Update immediately after completing tasks**
   - Don't wait until end of session
   - Mark complete as soon as done

2. **Use timestamps**
   - Update "Last Updated" frequently
   - Helps know when context was last refreshed

3. **Keep files lightweight**
   - 500-1000 lines each
   - Less to read when resuming

4. **Link to full documentation**
   - Plan references detailed specs
   - Context references architectural docs
   - Tasks reference dev docs

5. **During auto-compaction**
   - Read all three files first
   - Copy important findings to context.md
   - Mark completed tasks
   - Run `/update-dev-docs` if available

---

## Next: Update Dev Docs During Work

As you work on tasks, remember to:
1. Mark tasks complete in `tasks.md`
2. Add discoveries to `context.md`
3. Update "Last Updated" timestamp
4. Reference these files when resuming

This system keeps you organized and prevents "where was I?" moments during large multi-day projects.
