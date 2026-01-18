# Quick Start Guide

Get started with the Honesty Framework in minutes.

## 🚦 Prerequisites

- Git installed
- GitHub account
- Basic understanding of Git workflows
- (Optional) GPG for commit signing

## 🚀 Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ricktron/honesty-framework.git
cd honesty-framework
```

### 2. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### 3. Test the Verification Scripts

```bash
# Verify the last commit
./scripts/verify-commits.sh

# Run integrity check
./scripts/check-integrity.sh

# Validate signatures (optional)
./scripts/validate-signatures.sh --info
```

### 4. Review the Documentation

- [README.md](README.md) - Project overview
- [Transparency Guidelines](docs/TRANSPARENCY_GUIDELINES.md) - How to maintain transparency
- [Verification Process](docs/VERIFICATION_PROCESS.md) - Understanding verification
- [Integrity Standards](docs/INTEGRITY_STANDARDS.md) - Code and process standards

## 📝 Using the Framework

### For Contributors

#### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the coding standards
   - Write clear commit messages
   - Don't commit sensitive data

3. **Verify locally**
   ```bash
   ./scripts/verify-commits.sh HEAD
   ./scripts/check-integrity.sh
   ```

4. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: Add your feature description"
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**
   - Fill out the PR template
   - Link related issues
   - Wait for automated checks
   - Address review feedback

#### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example:**
```
feat(workflows): Add commit verification

Implements automated commit verification to detect sensitive data
and validate commit message format.

Closes #123
```

### For Reviewers

#### Reviewing Pull Requests

1. **Check automated verifications**
   - All workflows must pass
   - No security violations
   - No integrity issues

2. **Review the code**
   - Code quality
   - Security considerations
   - Documentation updates
   - Test coverage

3. **Provide feedback**
   - Be constructive
   - Explain reasoning
   - Suggest improvements

4. **Approve or request changes**
   - Use GitHub review features
   - Leave clear comments
   - Follow up on conversations

### For Maintainers

#### Setting Up Branch Protection

1. **Go to Repository Settings**
2. **Click "Branches"**
3. **Add protection rule for `main`:**
   - Require pull request reviews
   - Require status checks:
     - Commit Verification
     - Integrity Check
     - Code Integrity
   - Require branches to be up to date
   - Do not allow bypassing

#### Configuring Notifications

**For GitHub Issues (Automatic):**
- Critical/High failures create issues automatically
- Issues are labeled appropriately
- Assignees can be configured in workflow files

**For Slack/Teams (Manual Setup):**

1. Create a webhook in Slack/Teams
2. Add webhook URL to GitHub Secrets:
   ```
   SLACK_WEBHOOK_URL=your-webhook-url
   ```
3. Update `.github/workflows/notification-system.yml`:
   - Enable Slack notifications
   - Configure channels

**For Email (GitHub Settings):**
- Configure in GitHub notification preferences
- Can watch specific workflows
- Digest options available

#### Managing Security

1. **Review security alerts regularly**
   - Check Dependabot alerts
   - Review workflow failures
   - Monitor integrity violations

2. **Respond to vulnerability reports**
   - Follow SECURITY.md guidelines
   - Use responsible disclosure
   - Coordinate with reporters

3. **Keep dependencies updated**
   - Review and merge Dependabot PRs
   - Test updates thoroughly
   - Document breaking changes

## 📖 Common Tasks

### Reporting an Issue

1. **Choose the right template:**
   - **Honesty Concern** - Ethical/transparency issues
   - **Transparency Issue** - Need clarification
   - **Integrity Violation** - Security/integrity issues
   - **Bug/Feature** - General issues

2. **Fill out the template completely**
3. **Provide examples and evidence**
4. **Submit and respond to questions**

### Creating a Transparency Report

1. **Copy the template:**
   ```bash
   cp templates/transparency-report.md reports/YYYY-MM-DD-topic.md
   ```

2. **Fill out all sections:**
   - Executive summary
   - Context and background
   - Decision-making process
   - Impact analysis
   - Follow-up actions

3. **Commit and create PR:**
   ```bash
   git add reports/YYYY-MM-DD-topic.md
   git commit -m "docs: Add transparency report for [topic]"
   git push
   ```

### Handling Verification Failures

#### Commit Verification Failed

**If sensitive data detected:**
```bash
# Remove sensitive data from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch PATH/TO/FILE" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (only on feature branches!)
git push --force
```

**If commit message invalid:**
```bash
# Amend last commit message
git commit --amend

# For older commits, use interactive rebase
git rebase -i HEAD~N
```

#### Integrity Check Failed

1. **Review the workflow logs**
2. **Identify the issue**
3. **Fix the problem**
4. **Re-run the check**
   ```bash
   ./scripts/check-integrity.sh
   ```

#### Code Integrity Failed

1. **Check the specific failure**
   - Security vulnerability?
   - Code quality issue?
   - Documentation missing?

2. **Address the issue**
   - Update dependencies
   - Fix code issues
   - Add documentation

3. **Verify locally if possible**
4. **Push and re-trigger workflow**

## 📊 Monitoring

### View Workflow Status

**In Repository:**
1. Go to "Actions" tab
2. View recent workflow runs
3. Check for failures
4. Review logs for details

**Status Badges:**
- Displayed in README.md
- Green = passing
- Red = failing
- Click for details

### Review Integrity Reports

**Workflow Artifacts:**
1. Go to completed workflow run
2. Scroll to "Artifacts" section
3. Download reports
4. Review findings

**Local Reports:**
```bash
# Generate local integrity report
./scripts/check-integrity.sh

# View the report
cat .integrity/integrity-report-*.md
```

### Check for Issues

**Automated Issues:**
- Critical/High failures create issues automatically
- Labeled with `verification-failure`
- Assigned to relevant team members

**Manual Review:**
1. Go to "Issues" tab
2. Filter by labels:
   - `honesty-framework`
   - `verification-failure`
   - `integrity-violation`
3. Review and address

## ⚙️ Customization

### Adjusting Verification Rules

Edit `config/integrity-rules.yml`:

```yaml
# Example: Change minimum commit message length
commit_verification:
  min_message_length: 20  # Changed from 10

# Example: Add custom sensitive data pattern
sensitive_data:
  patterns:
    - name: "Custom Secret"
      pattern: "MY_SECRET_[A-Z0-9]+"
      severity: "critical"
```

### Configuring Workflows

Edit `config/verification-config.yml`:

```yaml
# Example: Disable commit signature checking
commit_verification:
  checks:
    signature_check:
      enabled: false

# Example: Change notification severity
notifications:
  channels:
    github_issues:
      create_for_severity: ["critical"]  # Only critical
```

### Adding Language-Specific Checks

Edit `.github/workflows/code-integrity.yml`:

```yaml
# Example: Add Python linting
- name: Run Pylint
  if: hashFiles('**/*.py') != ''
  run: |
    pip install pylint
    pylint **/*.py
```

## 🎓 Learning Resources

### Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [SECURITY.md](SECURITY.md) - Security policy
- [CHANGELOG.md](CHANGELOG.md) - Version history

### Templates

- [Transparency Report](templates/transparency-report.md)
- [Verification Log](templates/verification-log.md)
- [Integrity Checklist](templates/integrity-checklist.md)

### External Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GPG Signing Guide](https://docs.github.com/en/authentication/managing-commit-signature-verification)

## ❓ Troubleshooting

### Common Issues

**Q: Workflows are not running**
- Check if workflows are enabled in repository settings
- Verify branch name matches workflow triggers
- Check GitHub Actions quotas

**Q: Scripts fail with permission denied**
```bash
chmod +x scripts/*.sh
```

**Q: Verification fails but I don't know why**
- Check workflow logs in Actions tab
- Run verification scripts locally
- Review error messages carefully

**Q: How do I exclude files from checks?**
- Update patterns in `config/integrity-rules.yml`
- Add to `.gitignore` for git-based checks
- Modify workflow files for specific exclusions

### Getting Help

1. **Check documentation** - Start with README and guides
2. **Search issues** - Someone may have had the same problem
3. **Ask in Discussions** - Community can help
4. **Create an issue** - Use appropriate template
5. **Contact maintainers** - For urgent matters

## 🎯 Next Steps

### Immediate
1. ✅ Clone repository
2. ✅ Run verification scripts
3. ✅ Review documentation
4. ✅ Test with a sample commit

### Short Term
5. [ ] Customize configuration for your needs
6. [ ] Set up branch protection
7. [ ] Configure notifications
8. [ ] Train team members

### Long Term
9. [ ] Integrate into existing projects
10. [ ] Develop custom checks
11. [ ] Build reporting dashboards
12. [ ] Share learnings with community

## 💬 Feedback

We value your feedback!

- **Found a bug?** Open an issue
- **Have a suggestion?** Start a discussion
- **Want to contribute?** Read CONTRIBUTING.md
- **Need help?** Ask in Discussions

---

**Welcome to the Honesty Framework!**

We're excited to have you join us in building more transparent, honest, and integrity-focused development practices.

**Repository**: https://github.com/ricktron/honesty-framework
