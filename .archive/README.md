# Archive - Development Documentation

This folder contains internal development documentation, testing logs, and migration guides that were used during the project's creation with Claude Code.

**These files are kept for historical reference only** - they are not needed by users.

## Contents

### Development Process Documentation
- `FIRST-5-MINUTES.md` - Initial project setup notes
- `NEW-USER-JOURNEY.md` - UX testing and user experience notes
- `PITFALLS-AND-FIXES.md` - Development troubleshooting guide

### Testing & Quality Assurance
- `MANUAL-TESTING-LOG.md` - Manual testing session logs
- `TESTING-INSTRUCTIONS.md` - Internal testing procedures
- `TESTING-STATUS.md` - Testing progress tracking
- `JOURNEY-METRICS-REPORT.md` - User journey testing metrics
- `DOCS-HEALTH.md` - Documentation health audit (automated)
- `LINK-VALIDATION-REPORT.md` - Link validation report (automated)

### Migration Guides (Outdated)
- `CREDENTIALS-CHANGED.md` - SSH credential migration (admin/NokiaSrl1! → admin/cisco)
- `REBUILD-NOW.md` - Container rebuild instructions during development
- `VSCODE-SSH-WORKAROUND.md` - VS Code extension SSH issues (resolved)

### Implementation Notes
- `SSH-SETUP-COMPLETE.md` - Complete SSH implementation documentation
- `QUICK-START-GUIDE.md` - Early quick start draft (superseded by README.md)
- `DO-THIS-IN-CODESPACES.sh` - Early deployment script (superseded by auto-build)

## Why These Are Archived

These files documented the **development process** with Claude Code, including:
- Internal testing procedures
- Migration steps during development
- Troubleshooting guides for development issues
- Automated audit reports

**Users don't need these** - they just need:
- `README.md` - Main documentation
- `README-CODESPACES.md` - Codespaces quick start
- `CHANGELOG.md` - Version history
- `CONTRIBUTING.md` - How to contribute

## Historical Context

This project was built iteratively with Claude Code in October 2025:
1. Started with basic FRR labs
2. Added SSH access with multiple credential iterations
3. Migrated from docker-outside-of-docker to docker-in-docker
4. Implemented automated Codespaces deployment
5. Added comprehensive testing and documentation

These archived files tell that story but aren't needed for using the labs.

---

**For Users**: You can safely ignore this `.archive/` folder - it's not part of the lab experience!
