# Strategic Plan Architect Agent

**Purpose**: Create comprehensive implementation plans for large features or projects
**Expertise**: Planning, architecture, risk analysis, timeline estimation
**When to Use**: Before implementing major features, refactoring, or multi-week projects
**Output**: Complete project plan + dev docs structure (plan.md, context.md, tasks.md)

---

## What This Agent Does

The Strategic Plan Architect automatically creates detailed implementation plans by:

1. **Gathering Context** from the codebase
2. **Analyzing Requirements** from your description
3. **Designing Architecture** for the implementation
4. **Breaking Down Tasks** into manageable phases
5. **Identifying Risks** and mitigation strategies
6. **Estimating Timelines** with confidence levels
7. **Generating Dev Docs** (plan, context, tasks files)

---

## When to Activate

**Use this agent when**:
- Planning a major feature (1+ week of work)
- Planning a refactoring project
- Designing a new system
- Managing multi-component implementations
- Need comprehensive planning before coding

**Don't use for**:
- Small bug fixes (< 2 hours)
- Simple feature additions (< 1 day)
- Minor code improvements
- Routine maintenance

---

## Agent Workflow

### Input

```
USER: "Create a comprehensive plan for implementing the IaC Labs terminal system"

INFORMATION PROVIDED:
├─ High-level description
├─ Key requirements
├─ Constraints (timeline, budget, etc.)
└─ Success criteria
```

### Processing

```
STEP 1: Gather Codebase Context
├─ Analyze existing architecture
├─ Find similar implementations
├─ Check dependencies
├─ Review constraints in CLAUDE.md

STEP 2: Analyze Requirements
├─ Break down user description
├─ Identify all components needed
├─ Check for dependencies
├─ List acceptance criteria

STEP 3: Design Architecture
├─ Plan system structure
├─ Identify components
├─ Design data models
├─ Plan API contracts
├─ Design user workflows

STEP 4: Break Into Phases
├─ Phase 1: Foundation
├─ Phase 2: Core implementation
├─ Phase 3: Integration
├─ Phase 4: Testing/Refinement

STEP 5: Create Task Breakdown
├─ List all tasks in each phase
├─ Estimate hours per task
├─ Identify dependencies
├─ Order tasks logically

STEP 6: Identify Risks
├─ Technical risks
├─ Timeline risks
├─ Resource risks
├─ External dependencies

STEP 7: Generate Dev Docs
├─ Create [name]-plan.md
├─ Create [name]-context.md
├─ Create [name]-tasks.md
└─ Ready for session work
```

### Output

```
COMPREHENSIVE IMPLEMENTATION PLAN
═════════════════════════════════

1. EXECUTIVE SUMMARY (1-2 paragraphs)
   └─ High-level overview
   └─ Expected timeline
   └─ Success metrics

2. ARCHITECTURE DESIGN (2-3 pages)
   ├─ System design diagram
   ├─ Component breakdown
   ├─ Data models
   ├─ API contracts
   └─ Integration points

3. PHASE BREAKDOWN (3-5 pages)
   ├─ Phase 1: [Name] (X hours)
   │  ├─ Task 1: [description]
   │  ├─ Task 2: [description]
   │  └─ Deliverables: [list]
   │
   ├─ Phase 2: [Name] (Y hours)
   │  ├─ Task 1-N: [descriptions]
   │  └─ Deliverables: [list]
   │
   └─ Phase 3+: [Continues]

4. TASK LIST WITH ESTIMATES (2-3 pages)
   ├─ Total tasks: N
   ├─ Total hours: X-Y
   ├─ Timeline: X-Y days
   └─ Task-by-task breakdown with dependencies

5. RISK ANALYSIS (1-2 pages)
   ├─ Technical risks
   │  ├─ Risk: [description]
   │  ├─ Probability: Low/Medium/High
   │  ├─ Impact: Low/Medium/High
   │  └─ Mitigation: [strategy]
   │
   ├─ Timeline risks
   └─ Resource risks

6. SUCCESS METRICS (1 page)
   ├─ Definition of done
   ├─ Acceptance criteria
   ├─ Testing requirements
   └─ Deployment criteria

7. GENERATED DEV DOCS
   ├─ [name]-plan.md ← The approved plan
   ├─ [name]-context.md ← Key files and decisions
   └─ [name]-tasks.md ← Checklist of all work
```

---

## Real Example: IaC Labs Terminal System

### Input
```
Create a comprehensive plan for implementing the IaC Labs terminal system:
- Students should see real Docker/Kubernetes CLI output
- Need WebSocket connection from browser to container
- Isolated sandbox environments (30-min session timeout)
- Real-time validation of student actions (docker ps, etc.)
- Award points based on actual execution results
```

### Processing (Agent runs internally)
```
1. Analyzes existing IaC Labs system
2. Examines WebSocket server code
3. Checks Docker validation service
4. Reviews existing challenge structure
5. Plans terminal component (React)
6. Plans WebSocket integration
7. Plans validation system
8. Breaks into 4 phases
9. Identifies 47 tasks
10. Estimates 30-40 hours total
11. Identifies 8 risks with mitigations
12. Generates complete dev docs
```

### Output (What you see)

```
═══════════════════════════════════════════════════════════════════
   IaC LABS TERMINAL SYSTEM - COMPREHENSIVE IMPLEMENTATION PLAN
═══════════════════════════════════════════════════════════════════

EXECUTIVE SUMMARY
─────────────────
Build real terminal experience for IaC Labs students by integrating WebSocket
connection to isolated Docker containers. Students see actual CLI output, not
simulated feedback. System validates real container state and awards points
based on actual execution results.

Timeline: 4 weeks (30-40 hours)
Success Metric: Students can interact with real terminals, validation works, zero security issues

ARCHITECTURE DESIGN
───────────────────

System Flow:
    Student Browser
         ↓ (WebSocket)
    LabTerminal Component (xterm.js)
         ↓ (ws://localhost:8080)
    Node.js WebSocket Server
         ↓ (Docker API)
    Lab Sandbox Container (Ubuntu + Docker + kubectl)

Components:
1. Frontend: LabTerminal React component with xterm.js
2. Backend: LabValidationService (real-time checks)
3. Server: Node.js WebSocket server
4. Infrastructure: Docker container sandbox

Data Models:
- LabSession: Tracks student session (30-min timeout)
- TerminalCommand: Records command history
- ValidationResult: Stores Docker state checks
- StudentProgress: Awards points

API Contracts:
- POST /api/labs/{id}/sessions → Create lab session
- WebSocket ws://server:8080 → Terminal I/O
- POST /api/labs/{id}/validate → Check Docker state

PHASE BREAKDOWN
───────────────

PHASE 1: Foundation & Setup (8 hours)
├─ Task 1: Create LabSession model + migration (2 hrs)
├─ Task 2: Create LabSessionService (2 hrs)
├─ Task 3: Create API endpoint for session creation (2 hrs)
├─ Task 4: Set up WebSocket server locally (2 hrs)
└─ Deliverables: Sessions tracked, server running

PHASE 2: Terminal UI & Integration (10 hours)
├─ Task 1: Create LabTerminal React component (3 hrs)
├─ Task 2: Integrate xterm.js library (2 hrs)
├─ Task 3: Connect to WebSocket server (3 hrs)
├─ Task 4: Handle connection lifecycle (2 hrs)
└─ Deliverables: Terminal visible, connects to server

PHASE 3: Validation & Docker Integration (12 hours)
├─ Task 1: Create Docker validation service (3 hrs)
├─ Task 2: Implement 7 validation check types (4 hrs)
├─ Task 3: Real-time Docker state inspection (3 hrs)
├─ Task 4: Point award system integration (2 hrs)
└─ Deliverables: Validation works, points awarded

PHASE 4: Testing & Refinement (10 hours)
├─ Task 1: Write unit tests (3 hrs)
├─ Task 2: Write integration tests (3 hrs)
├─ Task 3: Manual E2E testing (2 hrs)
├─ Task 4: Performance optimization (2 hrs)
└─ Deliverables: All tests passing, optimized

TASK BREAKDOWN WITH DEPENDENCIES
─────────────────────────────────
Total Tasks: 47
Total Hours: 30-40 hours
Timeline: 4 weeks
Dependencies:
- Phase 1 must complete before Phase 2
- Phase 2 must complete before Phase 3
- Phases 3-4 can partially overlap

Task List:
Phase 1 (Foundation & Setup)
  [  ] Task 1.1: Create LabSession model (2 hrs) - No dependencies
  [  ] Task 1.2: Write LabSession migration (1 hr) - After 1.1
  [  ] Task 1.3: Create LabSessionService (2 hrs) - After 1.2
  [  ] Task 1.4: POST /api/labs/{id}/sessions endpoint (2 hrs) - After 1.3
  [  ] Task 1.5: Add session expiry cleanup job (1 hr) - After 1.4
  [  ] Task 1.6: Set up Node.js WebSocket server locally (2 hrs) - No dependencies
  [  ] Task 1.7: Configure WebSocket authentication (1 hr) - After 1.6

[... continues for all 47 tasks ...]

RISK ANALYSIS
─────────────

Technical Risks (8 identified):

Risk 1: Docker API communication failures
├─ Probability: Medium
├─ Impact: High (students can't see terminal)
└─ Mitigation: Implement retry logic with exponential backoff

Risk 2: WebSocket connection drops
├─ Probability: Medium
├─ Impact: Medium (interrupted session)
└─ Mitigation: Auto-reconnect with session recovery

Risk 3: Validation checks give false positives
├─ Probability: Medium
├─ Impact: Medium (students get points incorrectly)
└─ Mitigation: Thorough testing + manual verification

Risk 4: Resource exhaustion (containers don't cleanup)
├─ Probability: Low
├─ Impact: High (out of memory)
└─ Mitigation: Aggressive timeout + automatic cleanup

[... continues for all 8 risks ...]

SUCCESS METRICS
───────────────

Definition of Done:
✓ Terminal component renders
✓ WebSocket connects to server
✓ Docker validation works
✓ Points awarded correctly
✓ All tests passing
✓ Documentation complete
✓ No security vulnerabilities
✓ Timeout cleanup working

Acceptance Criteria:
✓ Students see real Docker output
✓ Validation checks actual container state
✓ Points awarded based on real actions
✓ Sessions timeout after 30 minutes
✓ Resources cleaned up automatically

Testing Requirements:
✓ 15 unit tests
✓ 8 integration tests
✓ 6 E2E tests
✓ Manual testing with 3 students

Deployment Criteria:
✓ All tests passing
✓ Performance benchmarked
✓ Security review complete
✓ Documentation updated
✓ Rollback plan ready

═══════════════════════════════════════════════════════════════════

AUTO-GENERATED DEV DOCS (Ready to use immediately):

1. iac-labs-terminal-plan.md
   └─ Contains: Approved plan from above

2. iac-labs-terminal-context.md
   └─ Contains: Key files, decisions, next steps

3. iac-labs-terminal-tasks.md
   └─ Contains: Checklist of all 47 tasks

These 3 files are ready in dev/active/iac-labs-terminal/
Start work, update tasks as you complete them!
```

---

## Key Features

### 1. Context Gathering
- Analyzes existing code
- Finds similar implementations
- Reviews project constraints
- Identifies available patterns

### 2. Comprehensive Planning
- Multi-phase breakdown
- Task-level detail
- Time estimates
- Dependency mapping

### 3. Risk Identification
- Technical risks
- Timeline risks
- Resource risks
- Mitigation strategies

### 4. Automatic Dev Docs
- Plan file with complete details
- Context file with key decisions
- Tasks file with checklist

### 5. Clear Deliverables
- Architecture diagrams
- Task breakdown
- Success metrics
- Risk analysis

---

## Integration Points

### With /create-dev-docs Command
```
WORKFLOW:
1. User describes feature
2. Strategic Plan Architect creates comprehensive plan
3. User reviews and approves plan
4. /create-dev-docs command auto-generates 3 files
5. Work begins with perfect context
```

### With Dev Docs System
```
STORAGE:
dev/active/[task-name]/
├─ [task-name]-plan.md ← From this agent
├─ [task-name]-context.md ← Auto-generated
└─ [task-name]-tasks.md ← Checklist

USAGE:
Work on tasks, update them as you go
Mark complete immediately
Update context.md with discoveries
Reference plan.md for architecture details
```

### With Plan Reviewer Agent
```
WORKFLOW:
1. Strategic Plan Architect creates plan
2. Plan Reviewer validates it
3. Identifies missing requirements
4. Suggests improvements
5. Approves for implementation
```

---

## Prompt Examples

### Example 1: Small Feature
```
Create a comprehensive plan for adding a "Retry Failed Questions" feature.
Admins should be able to select failed questions and retry generation.

Requirements:
- Admin UI to select questions
- Backend job to regenerate
- Show retry status
- Store new questions

Timeline: 1-2 weeks
```

### Example 2: Large System
```
Create comprehensive plan for implementing user preferences system:
- Database models for preferences
- Admin UI for configuration
- Student UI for settings
- API endpoints
- Real-time sync across devices

Include architecture, 4-phase breakdown, risks, success metrics.
Auto-generate dev docs after approval.
```

### Example 3: Refactoring
```
Create plan for refactoring the question generation system:
- Current: Mixed concerns (validation, generation, storage)
- Target: Separate into distinct services
- Keep all tests passing
- Zero downtime migration

Timeline: 2-3 weeks
```

---

## Success Criteria

This agent works well when it:
- ✅ Creates realistic timelines (± 20%)
- ✅ Identifies major components
- ✅ Breaks down tasks logically
- ✅ Identifies real risks
- ✅ Auto-generates correct dev docs
- ✅ Provides architectural guidance
- ✅ Covers all edge cases

---

## Output Quality Check

Good plan has:
✅ Clear executive summary
✅ Detailed architecture design
✅ Realistic phase breakdown
✅ Specific, measurable tasks
✅ Time estimates for each task
✅ Clear success metrics
✅ Risk analysis with mitigations
✅ Auto-generated dev docs ready to use

---

## Integration with Phase 3B

This agent is one of three in Phase 3B:

1. **strategic-plan-architect** (this agent)
   └─ Creates comprehensive plans

2. **plan-reviewer** (next)
   └─ Validates and improves plans

3. **documentation-architect** (next)
   └─ Auto-generates project documentation

Together, they enable:
- ✅ Better planning prevents errors
- ✅ Reduced scope creep
- ✅ Accurate timelines
- ✅ Clear success metrics
- ✅ Zero context loss across sessions

---

## Next: plan-reviewer Agent

After Strategic Plan Architect creates a plan, the plan-reviewer will:
- Validate completeness
- Check for missing requirements
- Verify technical approach
- Suggest improvements
- Approve for implementation
