# Contributing to Free Containerlab Network Labs

Thank you for your interest in contributing! 🎉

## How to Contribute

### Reporting Issues

Found a bug or have a suggestion?

1. Check if the issue already exists in [Issues](../../issues)
2. If not, create a new issue with:
   - Clear description of the problem
   - Steps to reproduce (if bug)
   - Expected vs actual behavior
   - Lab name and environment details

### Contributing New Labs

Want to add a new lab? Great!

**Lab Requirements**:
- ✅ Uses containerlab for topology
- ✅ Includes complete documentation (README.md)
- ✅ Has automated validation tests (scripts/validate.sh)
- ✅ Includes devcontainer configuration
- ✅ Follows existing lab structure

**Lab Structure Template**:
```
new-lab/
├── README.md                # Comprehensive guide
├── topology.clab.yml        # Containerlab topology
├── configs/                 # Device configurations
├── scripts/
│   ├── deploy.sh           # Deployment script
│   ├── validate.sh         # Automated tests
│   └── cleanup.sh          # Cleanup script
└── .devcontainer/
    └── devcontainer.json   # VS Code devcontainer
```

### Contributing Code Improvements

**Process**:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test in devcontainer:
   ```bash
   cd <lab-name>
   code .  # Reopen in Container
   ./scripts/deploy.sh
   ./scripts/validate.sh
   ```
5. Commit your changes (`git commit -m 'Add improvement'`)
6. Push to your fork (`git push origin feature/improvement`)
7. Open a Pull Request

### Testing Requirements

Before submitting a PR:

- [ ] Lab deploys successfully in devcontainer
- [ ] All validation tests pass (100% pass rate)
- [ ] README exercises work as documented
- [ ] No errors or warnings during deployment
- [ ] Clean shutdown with `./scripts/cleanup.sh`

### Documentation Guidelines

**README.md should include**:
- Lab objectives (what will students learn?)
- Topology diagram (ASCII art is fine)
- Quick start instructions
- Detailed exercises with expected outputs
- Validation tests explanation
- Common troubleshooting tips
- Resources/references

**Good documentation**:
- Is beginner-friendly
- Includes expected command outputs
- Has hands-on exercises
- Explains the "why" not just the "how"

### Code Style

**Bash Scripts**:
- Use `#!/bin/bash` shebang
- Include error handling
- Add comments for complex logic
- Use meaningful variable names

**Containerlab YAML**:
- Use consistent indentation (2 spaces)
- Include comments for non-obvious configuration
- Follow containerlab best practices

**FRR Configuration**:
- Use clear hostnames
- Document non-standard configurations
- Include comments for learning purposes

### Commit Message Guidelines

Use clear, descriptive commit messages:

**Good examples**:
- `Add MPLS L3VPN basic lab`
- `Fix OSPF validation test timeout issue`
- `Update BGP lab README with troubleshooting section`

**Bad examples**:
- `Update`
- `Fix bug`
- `Changes`

### Pull Request Guidelines

**PR Title**: Clear and descriptive (e.g., "Add IS-IS basics lab")

**PR Description should include**:
- What changes were made
- Why the changes were made
- How to test the changes
- Screenshots/output (if applicable)

**PR Checklist**:
- [ ] Tested in devcontainer
- [ ] All validation tests pass
- [ ] Documentation updated
- [ ] No unnecessary files added (.DS_Store, etc.)
- [ ] Follows existing code style

## Questions?

- Open a [Discussion](../../discussions)
- Tag issues with `question` label
- Check existing documentation first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be:
- Added to CONTRIBUTORS.md (if significant contribution)
- Mentioned in release notes
- Credited in lab README (if lab author)

Thank you for helping make network learning more accessible! 🚀
