# /dev-docs Command

**Purpose**: Create development docs with strategic planning
**Integrates**: strategic-plan-architect agent (Phase 3B)
**Output**: Complete plan + dev docs structure (plan.md, context.md, tasks.md)

---

## What This Command Does

`/dev-docs` is a one-command workflow that:

1. Launches strategic-plan-architect automatically
2. Creates comprehensive implementation plan
3. Generates dev docs structure
4. Sets up `dev/active/[feature-name]/` folder
5. Auto-generates plan.md, context.md, tasks.md

**Result**: Feature is fully planned with clear success criteria before any code is written.

---

## Usage

### Basic Usage

```
/dev-docs "Feature description"

Examples:
/dev-docs "Add user authentication with OAuth"
/dev-docs "Migrate database from MySQL to PostgreSQL"
/dev-docs "Implement real-time notifications with WebSocket"
```

### Full Workflow Syntax

```
/dev-docs
Title: [Feature Name]
Description: [Complete feature description]

Requirements:
- [requirement 1]
- [requirement 2]
- [requirement 3]

Constraints:
- [constraint 1]
- [constraint 2]

Timeline: [1-2 weeks / 3-4 weeks / etc]
```

### Example

```
/dev-docs
Title: IaC Labs Terminal System
Description: Build real terminal experience for IaC Labs students

Requirements:
- Students see actual Docker/Kubernetes CLI output
- WebSocket connection from browser to container
- Isolated sandbox environments (30-min timeout)
- Real-time validation of student actions
- Award points based on actual execution

Constraints:
- Must integrate with existing IaC Labs
- Security isolated from main platform
- Support 10+ concurrent students

Timeline: 4 weeks
```

---

## What You Get

### Immediate Output (From Agent)

Strategic-plan-architect creates:

```
COMPREHENSIVE IMPLEMENTATION PLAN
═════════════════════════════════

1. EXECUTIVE SUMMARY
   - High-level overview
   - Timeline estimate
   - Success metrics

2. ARCHITECTURE DESIGN (2-3 pages)
   - System overview diagram
   - Component breakdown
   - Data models
   - API contracts
   - Integration points

3. PHASE BREAKDOWN (4-5 pages)
   - Phase 1: [Name] (X hours)
   - Phase 2: [Name] (Y hours)
   - Phase 3: [Name] (Z hours)
   - Phase 4: [Name] (W hours)
   - Deliverables for each phase

4. TASK LIST (2-3 pages)
   - All tasks listed by phase
   - Hour estimates per task
   - Task dependencies
   - Total hours estimate
   - Timeline projection

5. RISK ANALYSIS (1-2 pages)
   - Technical risks identified
   - Probability and impact
   - Mitigation strategies
   - Resource risks

6. SUCCESS METRICS (1 page)
   - Definition of done
   - Acceptance criteria
   - Testing requirements
   - Deployment criteria
```

### Generated Files

After `/dev-docs` completes, you'll have:

**Location**: `dev/active/[feature-name]/`

```
dev/active/iac-labs-terminal/
├── iac-labs-terminal-plan.md
│   └── Complete implementation plan (4-6 pages)
├── iac-labs-terminal-context.md
│   └── Key decisions and architecture notes (2-3 pages)
└── iac-labs-terminal-tasks.md
    └── Checklist of all tasks (organized by phase)
```

### Using Generated Files

**plan.md**: Reference during entire implementation
```
- Architecture decisions
- Phase structure
- Risk analysis
- Success criteria
```

**context.md**: Keep updated as you work
```
- Key files and locations
- Architecture decisions made
- Next steps
- Discoveries during implementation
```

**tasks.md**: Track progress
```
Phase 1: Foundation
  [x] Task 1.1: Create model
  [ ] Task 1.2: Create migration
  [ ] Task 1.3: Create service
  [ ] Task 1.4: Create API

Phase 2: Integration
  [ ] Task 2.1: Create component
  ...
```

---

## Workflow Example

### Step 1: Create Plan

```bash
/dev-docs
Title: User Authentication System
Description: Add OAuth authentication to platform

Requirements:
- Support Google, GitHub, Microsoft login
- Automatic user creation on first login
- User profile management
- Session management with 24-hour timeout

Constraints:
- Must not break existing email/password auth
- Must integrate with existing user database
- Must support teams/organizations

Timeline: 2-3 weeks
```

### Step 2: Agent Creates Plan (5-10 minutes)

Agent analyzes:
- Existing auth system
- User database schema
- Current middleware
- Integration points

Agent outputs:
```
COMPREHENSIVE PLAN GENERATED
───────────────────────────

Architecture:
├─ OAuth provider integrations (Google, GitHub, Microsoft)
├─ OAuth callback handler
├─ User creation/matching logic
├─ Session management
└─ Profile management UI

Phase 1: Foundation (8 hours)
├─ Create OAuth integration service
├─ Create auth routes
└─ Create session management

Phase 2: Frontend (6 hours)
├─ Create login page with OAuth buttons
├─ Create profile page
└─ Add logout functionality

Phase 3: Testing (4 hours)
├─ Test OAuth flows
├─ Test user creation
└─ End-to-end testing

Total: 18 hours, 2-3 weeks
```

### Step 3: Generated Files Ready

```
dev/active/user-auth-oauth/
├── user-auth-oauth-plan.md (complete plan)
├── user-auth-oauth-context.md (decisions made)
└── user-auth-oauth-tasks.md (checklist)
```

### Step 4: Start Implementation

1. Open `user-auth-oauth-plan.md` to understand architecture
2. Open `user-auth-oauth-tasks.md` to see what's next
3. Implement Phase 1 Task 1
4. Mark complete as you go
5. Update `user-auth-oauth-context.md` with discoveries

### Step 5: Development Continues

Track progress:
```
Phase 1: Foundation (8 hours)
[x] Task 1.1: Create OAuth integration service
[x] Task 1.2: Create auth routes
[ ] Task 1.3: Create session management (in progress)
```

---

## Integration with Other Commands

### With `/dev-docs-update`

After implementation:
```bash
/dev-docs-update "user-auth-oauth"

Updates:
- Refreshes context.md with discoveries
- Marks completed tasks
- Logs next steps and blockers
- Stores work session notes
```

### With `/code-review`

After implementation:
```bash
/code-review "user-auth-oauth"

Validates:
- Code matches plan architecture
- All acceptance criteria met
- Security best practices followed
- Performance meets requirements
```

### With `/build-and-fix`

Before committing:
```bash
/build-and-fix

Ensures:
- TypeScript builds clean
- PHP linter passes
- All tests passing
- No errors left undetected
```

---

## Success Criteria

`/dev-docs` is successful when:

✅ **Plan is comprehensive**
- All requirements captured
- Architecture clearly designed
- Phases are logical
- Tasks are specific
- Risks identified
- Timeline is realistic

✅ **Files are generated**
- plan.md contains complete plan
- context.md is ready for updates
- tasks.md is a clear checklist

✅ **Team understands scope**
- New developers can read plan
- Success criteria are clear
- Acceptance conditions are defined
- Architecture is documented

---

## Common Use Cases

### New Feature Development

```bash
/dev-docs "Add invoice export to admin panel"

Result:
- Complete plan for invoice feature
- Architecture for PDF export
- Database schema changes
- API endpoints
- 3-phase implementation schedule
```

### Refactoring Project

```bash
/dev-docs
Title: Refactor question generation system
Description: Separate concerns - validation, generation, storage

Timeline: 3 weeks

Result:
- Clear refactoring strategy
- No-downtime migration plan
- Rollback procedures
- 3-week implementation plan
```

### System Upgrade

```bash
/dev-docs
Title: Upgrade to Laravel 12
Description: Full framework upgrade with zero downtime

Timeline: 2 weeks

Result:
- Detailed upgrade steps
- Compatibility check plan
- Testing strategy
- Deployment procedure
```

---

## Behind the Scenes

When you run `/dev-docs`, here's what happens:

```
1. You provide feature description
         ↓
2. Command triggers strategic-plan-architect agent
         ↓
3. Agent analyzes current codebase
         ├─ Reviews existing files
         ├─ Checks database schema
         ├─ Identifies similar implementations
         └─ Notes integration points
         ↓
4. Agent creates comprehensive plan
         ├─ Designs architecture
         ├─ Breaks into phases
         ├─ Identifies risks
         ├─ Estimates hours
         └─ Defines success metrics
         ↓
5. Agent generates 3 dev docs
         ├─ plan.md (approved plan)
         ├─ context.md (key decisions)
         └─ tasks.md (checklist)
         ↓
6. Files appear in dev/active/[feature]/
         ↓
7. You're ready to start implementation!
```

---

## Tips & Tricks

### For Complex Features

If your feature is large (4+ weeks):

```bash
/dev-docs
Title: Complex Multi-Component System
Description: [detailed description]

Please break into 5-6 phases instead of 4
Estimate total hours carefully
Identify all integration points
```

The agent will create more detailed phases and smaller tasks.

### For Refactoring

If refactoring existing code:

```bash
/dev-docs
Title: Refactor [component]
Description: Current implementation has [issue], need [improvement]

Show current state vs desired state
Include compatibility concerns
Plan zero-downtime migration
```

The agent will include rollback strategies and compatibility plans.

### For High-Risk Features

If feature has significant risks:

```bash
/dev-docs
Title: High-risk feature
Description: [feature description]

Known risks:
- [risk 1]
- [risk 2]
- [risk 3]

Constraints:
- [constraint]
```

The agent will create more comprehensive risk analysis and mitigation strategies.

---

## Related Commands

- **`/dev-docs-update`** - Update docs after development
- **`/code-review`** - Review code against plan
- **`/build-and-fix`** - Run builds and fix errors
- **`/test`** - Run test suite

---

## Quick Reference

| Task | Command |
|------|---------|
| Create plan | `/dev-docs "feature description"` |
| Update docs | `/dev-docs-update "feature-name"` |
| Review code | `/code-review "feature-name"` |
| Build & Fix | `/build-and-fix` |
| Run tests | `/test` |

---

## FAQ

**Q: How long does `/dev-docs` take?**
A: Usually 5-15 minutes depending on feature complexity. Agent analyzes code, creates plan, generates files.

**Q: Can I modify the generated plan?**
A: Yes! The plan.md is yours to edit. Update it if new information emerges during implementation.

**Q: What if requirements change?**
A: Update plan.md with new requirements, update context.md with the change reason, and adjust tasks.md.

**Q: Do I have to follow the plan exactly?**
A: No, but the plan represents the best strategy based on analysis. Deviation should be documented in context.md.

**Q: Can I use `/dev-docs` for small features?**
A: Yes, but it's most valuable for features 1+ week of work. For small 2-4 hour tasks, basic planning may be faster.

---

## Achievement

`/dev-docs` transforms feature development from ad-hoc to strategic:

**Before `/dev-docs`**:
```
Day 1: Start coding
Day 5: Realize scope creep
Day 10: Major refactoring
Day 15: Still building
```

**With `/dev-docs`**:
```
Day 1: Create plan (1 hour)
Day 2-12: Code with clear direction
Day 13: Review & test
Day 14: Complete with docs
```

**Result**: 30% faster, higher quality, documented, team aligned.

