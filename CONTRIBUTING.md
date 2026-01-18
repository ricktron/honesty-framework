# Contributing to the Honesty Framework

Thank you for your interest in contributing to the Honesty Framework! This document provides guidelines for contributing to this project.

## Our Commitment

The Honesty Framework is built on principles of:
- **Transparency**: All decisions and changes are documented and communicated openly
- **Integrity**: Code and processes maintain the highest standards
- **Honesty**: We acknowledge mistakes and learn from them
- **Accountability**: Clear ownership and responsibility for all contributions

## Getting Started

### Before You Contribute

1. **Read the Documentation**
   - [README.md](README.md) - Project overview
   - [Transparency Guidelines](docs/TRANSPARENCY_GUIDELINES.md)
   - [Verification Process](docs/VERIFICATION_PROCESS.md)
   - [Integrity Standards](docs/INTEGRITY_STANDARDS.md)

2. **Check Existing Issues**
   - Search existing issues to avoid duplicates
   - Comment on issues you'd like to work on
   - Wait for assignment before starting work

3. **Set Up Your Environment**
   ```bash
   # Clone the repository
   git clone https://github.com/ricktron/honesty-framework.git
   cd honesty-framework
   
   # Set up git hooks (optional but recommended)
   chmod +x scripts/*.sh
   ```

## How to Contribute

### Reporting Issues

Use our specialized issue templates:

1. **Honesty Concern** - For ethical or transparency issues
2. **Transparency Issue** - For requesting clarification
3. **Integrity Violation** - For serious integrity issues
4. **General Issues** - For bugs, features, or improvements

### Suggesting Enhancements

1. **Check if it aligns with project goals**
2. **Open an issue to discuss the enhancement**
3. **Provide clear use cases and benefits**
4. **Wait for feedback before implementing**

### Contributing Code

#### 1. Fork and Branch

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/honesty-framework.git
cd honesty-framework

# Add upstream remote
git remote add upstream https://github.com/ricktron/honesty-framework.git

# Create a feature branch
git checkout -b feature/your-feature-name
```

#### 2. Make Your Changes

**Follow these guidelines:**

- Write clear, descriptive commit messages
- Keep commits focused and atomic
- Follow existing code style
- Add tests for new functionality
- Update documentation as needed
- Run local verification scripts

**Commit Message Format:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(workflows): Add Python security scanning

Adds Bandit security scanner for Python code.
Integrates with existing code integrity workflow.

Closes #42
```

#### 3. Test Your Changes

```bash
# Run integrity check
./scripts/check-integrity.sh

# Verify commits
./scripts/verify-commits.sh

# Run any project-specific tests
# (Add commands here as the project grows)
```

#### 4. Commit and Push

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat(workflows): Add Python security scanning"

# Push to your fork
git push origin feature/your-feature-name
```

#### 5. Create a Pull Request

1. **Go to your fork on GitHub**
2. **Click "New Pull Request"**
3. **Fill out the PR template completely**
4. **Link related issues**
5. **Request reviewers**
6. **Wait for review**

### Pull Request Guidelines

**Your PR must:**

- [ ] Have a clear, descriptive title
- [ ] Fill out the PR template completely
- [ ] Reference related issues
- [ ] Pass all automated checks
- [ ] Include tests (if applicable)
- [ ] Update documentation
- [ ] Follow coding standards
- [ ] Have no merge conflicts

**During review:**

- Respond to feedback promptly
- Make requested changes
- Keep the PR updated with main branch
- Be open to suggestions
- Explain your reasoning when disagreeing

### Contributing Documentation

Documentation improvements are always welcome!

**Guidelines:**

- Use clear, concise language
- Include examples where helpful
- Keep formatting consistent
- Update table of contents if needed
- Check for broken links
- Verify accuracy of information

**Documentation types:**

- **Guides**: Step-by-step instructions
- **Reference**: API documentation, configuration
- **Tutorials**: Learning-focused content
- **Explanations**: Conceptual understanding

## Code Review Process

### What to Expect

1. **Automated Checks** (< 10 minutes)
   - Commit verification
   - Integrity checks
   - Code quality scans
   - Security scanning

2. **Human Review** (1-3 days)
   - Code review by maintainers
   - Feedback and suggestions
   - Approval or request for changes

3. **Merge** (after approval)
   - Final checks pass
   - PR is merged
   - Branch is deleted

### Review Criteria

Reviewers will check:

- **Correctness**: Does it work as intended?
- **Quality**: Is the code well-written?
- **Tests**: Are changes adequately tested?
- **Documentation**: Is documentation updated?
- **Style**: Does it follow conventions?
- **Security**: Are there security concerns?
- **Performance**: Does it impact performance?

## Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Set `set -e` for error handling
- Use descriptive variable names
- Add comments for complex logic
- Follow ShellCheck recommendations

### Markdown

- Use ATX-style headers (`#`)
- Keep line length reasonable (< 120 chars)
- Use code fences with language tags
- Include table of contents for long docs

### YAML

- Use 2 spaces for indentation
- Use quotes for strings with special chars
- Add comments for non-obvious settings
- Keep consistent formatting

### Commit Messages

- Use imperative mood ("Add feature" not "Added feature")
- Keep subject line < 72 characters
- Separate subject and body with blank line
- Explain what and why, not how
- Reference issues in footer

## Community Guidelines

### Code of Conduct

**We expect all contributors to:**

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

**Unacceptable behavior includes:**

- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information
- Other unprofessional conduct

### Communication Channels

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: Questions, ideas, general discussion
- **Pull Requests**: Code review, technical discussion

### Getting Help

**If you need help:**

1. Check existing documentation
2. Search closed issues
3. Ask in GitHub Discussions
4. Tag maintainers if urgent

## Recognition

### Contributors

All contributors are recognized:

- Listed in commit history
- Mentioned in release notes (significant contributions)
- Added to CONTRIBUTORS file (if created)
- Acknowledged in documentation (major contributions)

### Maintainers

Maintainers are responsible for:

- Reviewing pull requests
- Maintaining code quality
- Managing releases
- Guiding project direction
- Enforcing guidelines

## Legal

### License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

### Copyright

You retain copyright to your contributions. By submitting a pull request, you grant the project permission to use your contribution under the project license.

### Developer Certificate of Origin

By contributing, you certify that:

1. The contribution was created in whole or part by you
2. You have the right to submit it under the project license
3. You understand and agree your contribution is public

## Questions?

If you have questions about contributing:

1. Check this document
2. Review other documentation
3. Ask in GitHub Discussions
4. Contact maintainers

---

**Thank you for contributing to the Honesty Framework!**

Your contributions help build a more transparent, honest, and integrity-focused development ecosystem.
