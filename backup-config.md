# Documentation Project Backup Configuration

## Overview

This document outlines the integration strategy for backing up the GitHub-based documentation repository alongside our existing backup systems. The goal is to ensure our documentation is protected by multiple redundant systems while leveraging the benefits of git-based version control.

## 1. Git-Based Version Control (Primary)

GitHub serves as the primary storage and version control for all documentation:

- **Repository URL**: https://github.com/Raytogether/documentation-projects
- **Branch Strategy**:
  - `main`: Stable, production-ready documentation
  - `gh-pages`: Rendered documentation for GitHub Pages
  - Feature branches for major documentation updates

### Local Git Configuration

```bash
# Ensure your git identity is properly configured
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Add GitHub repository as remote (if creating a new local copy)
git clone git@github.com:Raytogether/documentation-projects.git
```

## 2. Integration with Borg Backup System

The local documentation repository is automatically included in the daily Borg backups:

```bash
# Location in Borg backup
~/Documents/documentation-projects/
```

### Borg Backup Details:
- **Schedule**: Daily backups at 22:00
- **Backed Up To**:
  - Local Borg repository
  - Remote Backblaze B2 bucket
- **Monitoring**: Weekly backup status checks via cron job

## 3. Integration with Duplicity Backup System

Duplicity provides additional cloud backup protection for our documentation:

### Duplicity Backup Details:
- **Schedule**:
  - Daily Incremental: 02:00
  - Monthly Full: 03:00 (1st of month)
  - Monthly Cleanup: 04:30 (1st of month)
- **Storage**: Backblaze B2 bucket
- **Path Included**: `~/Documents/documentation-projects/`

## 4. Manual Dropbox Backup Guidelines

For sharing documentation with team members who don't have GitHub access or for offline access:

### Process:
1. **Quarterly Export**: Create a ZIP archive of the documentation-projects folder
   ```bash
   cd ~/Documents
   zip -r documentation-export-$(date +%Y-%m-%d).zip documentation-projects/
   ```

2. **Manual Upload to Dropbox**:
   - Place in: `Dropbox/Documentation-Backups/`
   - Naming convention: `documentation-export-YYYY-MM-DD.zip`

3. **Version Retention**:
   - Keep the last 4 quarterly backups
   - Delete older backups to save space

## 5. Documentation Update Workflow

### Regular Updates:

1. **Pull latest changes**:
   ```bash
   cd ~/Documents/documentation-projects
   git pull origin main
   ```

2. **Make changes to documentation**:
   ```bash
   # Edit files using your preferred editor
   # Add new files if needed
   git add .
   ```

3. **Commit and push changes**:
   ```bash
   git commit -m "Descriptive message about changes"
   git push origin main
   ```

4. **Update GitHub Pages** (if needed):
   ```bash
   git checkout gh-pages
   git pull origin main
   # Make any gh-pages specific changes
   git add .
   git commit -m "Update GitHub Pages"
   git push origin gh-pages
   git checkout main
   ```

### Major Documentation Revisions:

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/documentation-update
   ```

2. **Make comprehensive changes**

3. **Commit and push to branch**:
   ```bash
   git add .
   git commit -m "Major documentation update"
   git push origin feature/documentation-update
   ```

4. **Create pull request on GitHub**:
   - Navigate to: https://github.com/Raytogether/documentation-projects/pulls
   - Create new pull request from your branch

5. **Merge after review**

## Backup Verification

Monthly backup verification process:

1. **Check GitHub repository**:
   ```bash
   gh repo view Raytogether/documentation-projects
   ```

2. **Verify local Borg backup**:
   ```bash
   # List archives containing documentation-projects
   borg list /path/to/borg/repo | grep -i documentation
   ```

3. **Verify Duplicity backup**:
   ```bash
   # List backups containing documentation-projects
   duplicity list-current-files --time 1D b2://bucket-name/ | grep -i documentation
   ```

4. **Check Dropbox backup**:
   - Manually verify presence of latest quarterly backup in Dropbox/Documentation-Backups/

---

*Last Updated: April 7, 2025*

