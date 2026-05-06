# Dev-Docs System

**Purpose**: Portable development documentation system for strategic planning, context preservation, and systematic code review across any project.

**Version**: 1.0
**Extracted From**: PingToPass Laravel Project
**Compatible With**: Laravel, Next.js, Python, Ruby, Go, and any software project

---

## What Is This?

The Dev-Docs System is a complete framework for managing large development tasks with:

1. **Strategic Planning** - Comprehensive implementation plans before coding
2. **Context Preservation** - Never lose progress across sessions
3. **Automated Quality** - Build validation and error detection
4. **Code Review** - Architecture validation against plans
5. **Task Tracking** - Clear checklists for complex features

---

## What's Included

### Commands (11 files in `commands/`)
- `/dev-docs` - Create strategic plans with dev docs
- `/dev-docs-update` - Update docs at session boundaries
- `/code-review` - Validate code against architecture
- `/create-dev-docs` - Generate plan/context/tasks files
- `/build-and-fix` - Build validation + error fixing
- `/test` - Run test suites
- `/build` - TDD workflow enforcer
- Plus 4 supporting commands

### Hooks (2 files in `hooks/`)
- `stop-event.md` - Zero-errors-left-behind system
- `user-prompt-submit.md` - Skill auto-activation
- `skill-rules.json.template` - Configuration template

### Agents (7 files in `agents/`)
- `strategic-plan-architect` - Creates comprehensive plans
- `plan-reviewer` - Validates plans before execution
- `documentation-architect` - Auto-generates docs
- `build-error-resolver` - Fixes 5+ errors systematically
- `architect`, `engineer`, `reviewer` - Core development agents

### Templates (3 files in `templates/`)
- `plan.md.template` - Implementation plan structure
- `context.md.template` - Development context tracking
- `tasks.md.template` - Task checklist format

### Examples (`examples/sample-feature/`)
- Complete OAuth authentication feature example
- Shows plan/context/tasks in action
- Real-world demonstration

---

## How It Works

### 1. Strategic Planning Phase

```bash
/dev-docs "Add user authentication with OAuth"
```

**What Happens**:
- `strategic-plan-architect` agent analyzes your codebase
- Creates comprehensive 4-6 page implementation plan
- Generates 3 dev docs files:
  - `[feature]-plan.md` - Complete architecture & phases
  - `[feature]-context.md` - Key decisions & discoveries
  - `[feature]-tasks.md` - Checklist of all tasks

**Output Location**: `dev/active/[feature-name]/`

### 2. Development Phase

**As you work**:
- Mark tasks complete in `tasks.md`
- Update discoveries in `context.md`
- Reference `plan.md` for architecture

**Automated Quality Checks**:
- Stop event hook runs after each Claude response
- Detects build errors immediately
- 0 errors → ✅ Clean
- 1-4 errors → Shows for fixing
- 5+ errors → Launches `build-error-resolver` agent

### 3. Session Boundary

```bash
/dev-docs-update "feature-name"
```

**What Happens**:
- Updates `context.md` with session work
- Marks completed tasks
- Documents blockers and discoveries
- Preserves context for next session

### 4. Code Review

```bash
/code-review "feature-name"
```

**What Happens**:
- Validates code matches plan architecture
- Checks security best practices
- Analyzes performance
- Reviews test coverage
- Provides approval or fix list

---

## Key Features

### Zero Errors Left Behind
- Stop event hook catches errors immediately
- Build validation after every response
- Agent recommendation for large error batches
- No surprises at commit time

### Context Preservation
- Three-file pattern (plan/context/tasks)
- Session summaries survive compaction
- Clear next steps for resuming
- Development history tracked

### Strategic Planning
- Comprehensive plans before coding
- Risk analysis and mitigation
- Timeline estimation with confidence levels
- Phase-based task breakdown

### Automated Workflows
- Skill auto-activation based on keywords
- Build error resolution with agents
- Test suite integration
- Code review automation

---

## Installation

See **`README.md`** for complete installation instructions.

**Quick Start**:
1. Copy files to your project
2. Configure for your stack
3. Run `/dev-docs "your feature"`
4. Start building with confidence

---

## Configuration

See **`SETUP.md`** for detailed configuration guide.

**Customize**:
- Build commands for your language/framework
- Skill rules for your tech stack
- Agent prompts for your patterns
- Hook settings for your workflow

---

## Use Cases

### Perfect For:
- **Large Features** (1+ week implementation)
- **Refactoring Projects** (multi-component changes)
- **System Design** (architecture planning)
- **Team Collaboration** (shared understanding)
- **Context Management** (long-running projects)

### Not Ideal For:
- Simple bug fixes (<2 hours)
- Minor code improvements
- Routine maintenance tasks

---

## Philosophy

### 1. Plan Before Code
Strategic planning saves time by catching issues early.

### 2. Preserve Context
Documentation survives session boundaries and team changes.

### 3. Automate Quality
Hooks and agents catch errors immediately.

### 4. Systematic Approach
Phases and tasks provide clear structure.

### 5. Portability First
Works with any language, framework, or team size.

---

## Success Stories

**From PingToPass Project**:
- ✅ Zero errors left in code between sessions
- ✅ 30% faster feature development
- ✅ Clear handoff between developers
- ✅ Comprehensive documentation maintained
- ✅ Strategic planning prevents scope creep

---

## Support & Customization

### Getting Help
1. Check `SETUP.md` for configuration
2. Review `examples/` for real-world usage
3. Read command documentation in `commands/`

### Customizing for Your Project
1. Update `skill-rules.json` with your keywords
2. Modify agent prompts for your patterns
3. Adjust build commands in hooks
4. Create project-specific skills

---

## What Makes This Different?

**Compared to traditional documentation**:
- ✅ Active during development (not after)
- ✅ Integrated with Claude Code workflow
- ✅ Automated quality checks
- ✅ Context preservation across sessions

**Compared to project management tools**:
- ✅ Lives in your codebase
- ✅ Git-tracked and version-controlled
- ✅ Developer-friendly (markdown)
- ✅ No external services required

---

## Files Structure

```
dev-docs-system/
├── CLAUDE.md               ← You are here
├── README.md               ← Installation guide
├── SETUP.md                ← Configuration guide
├── commands/               ← 11 slash commands
│   ├── dev-docs.md
│   ├── dev-docs-update.md
│   ├── code-review.md
│   └── ... (8 more)
├── hooks/                  ← 2 automation hooks
│   ├── stop-event.md
│   ├── user-prompt-submit.md
│   └── skill-rules.json.template
├── agents/                 ← 7 core agents
│   ├── strategic-plan-architect.md
│   ├── build-error-resolver.md
│   └── ... (5 more)
├── templates/              ← 3 dev docs templates
│   ├── plan.md.template
│   ├── context.md.template
│   └── tasks.md.template
└── examples/               ← Sample feature
    └── sample-feature/
        ├── sample-plan.md
        ├── sample-context.md
        └── sample-tasks.md
```

---

## Next Steps

1. **Read README.md** - Installation instructions
2. **Read SETUP.md** - Configuration guide
3. **Review examples/** - See it in action
4. **Install in your project** - Copy and configure
5. **Run `/dev-docs`** - Create your first plan

---

## License

Extracted from PingToPass project for reuse across any software project.

**Attribution**: Based on dev-docs system developed for PingToPass Laravel platform.

---

**Last Updated**: 2025-01-08
