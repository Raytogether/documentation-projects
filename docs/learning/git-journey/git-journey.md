# Git and Borg Backup Implementation Guide

This document details the comprehensive code backup solution implemented on April 6, 2025. The system provides multiple layers of protection for code projects through Git version control, GitHub remote repositories, and local Borg backups.

## Table of Contents

1. [Overview](#overview)
2. [System Components](#system-components)
3. [Initial Setup](#initial-setup)
4. [GitHub Remote Repository Setup](#github-remote-repository-setup)
5. [Borg Backup Configuration](#borg-backup-configuration)
6. [Automation Setup](#automation-setup)
7. [File Organization](#file-organization)
8. [Usage Instructions](#usage-instructions)
9. [Learning Journey](#learning-journey)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

## Overview

The code backup system consists of three main layers:

1. **Git Version Control**: Local Git repositories for each code project
2. **GitHub Remote Repositories**: Remote copies of all repositories
3. **Borg Backup**: Local encrypted backup of all code directories

This multi-layered approach provides:
- Granular version history through Git
- Off-site backup through GitHub
- Point-in-time snapshots through Borg
- Automated daily backups

## System Components

- **Git repositories**: Located in `~/code/`
- **GitHub repositories**: Under username `Raytogether`
- **Borg repository**: Located at `~/borg-repos/code-backup`
- **Backup scripts**:
  - `~/code/backup_code.sh`: Main backup script
  - `~/code/setup_github_repos.sh`: GitHub repository setup script

## Initial Setup

### Git Repository Initialization

Git repositories were initialized for all code projects:

```bash
# For each project directory
cd ~/code/project-name
git init
git add .
git commit -m "Initial commit"
```

Projects initialized:
- `borg-backup`
- `borg-research`
- `duplicity-b2-backup`
- `git-practice`
- `git-utils`
- `warp-ai`

### Basic .gitignore Configuration

Each repository includes a .gitignore file to exclude:
- Log files
- Environment files
- Cache directories
- Build artifacts

## GitHub Remote Repository Setup

GitHub repositories were created using the GitHub CLI:

1. **Authentication Setup**:
   ```bash
   gh auth login --web
   ```

2. **Repository Creation Script**:
   Created and executed `~/code/git-utils/bin/setup_github_repos.sh` to:
   - Create README.md files if missing
   - Create GitHub repositories
   - Add remote origins
   - Push existing code

The script loops through each Git repository in `~/code/` and performs the setup automatically.

### GitHub Repository URLs

- https://github.com/Raytogether/borg-backup
- https://github.com/Raytogether/borg-backup
- https://github.com/Raytogether/borg-research
- https://github.com/Raytogether/duplicity-b2-backup
- https://github.com/Raytogether/git-practice
- https://github.com/Raytogether/git-utils
- https://github.com/Raytogether/warp-ai
## Borg Backup Configuration

### Borg Repository Creation

A dedicated Borg repository was created for code backups:

```bash
borg init --encryption=repokey ~/borg-repos/code-backup
```

### Backup Script Configuration

The backup script `~/code/borg-backup/bin/backup_code.sh` was created with:
- Automatic repository detection
- Exclusion of unnecessary files
- Timestamp naming
- Retention policy settings

### Key Backup

Borg repository key is backed up in `~/code/borg-backup/code-backup-key.txt`.

## Automation Setup

### Cron Configuration

A cron job was set up to run the backup script daily at 1:00 AM:

```bash
crontab -l | { cat; echo "0 1 * * * $HOME/code/borg-backup/bin/backup_code.sh"; } | crontab -
```

### Backup Retention Policy

The backup script automatically prunes old backups with the following retention policy:
- Daily backups for 7 days
- Weekly backups for 4 weeks
- Monthly backups for 6 months

## File Organization

```
~/code/
├── borg-backup/          # Git repository
│   └── bin/
│       └── backup_code.sh  # Borg backup script
├── borg-research/        # Git repository
├── duplicity-b2-backup/  # Git repository
├── git-practice/         # Git practice repository
├── git-utils/            # Git utilities repository
│   ├── bin/
│   │   ├── init_git_repos.sh     # Git initialization script
│   │   └── setup_github_repos.sh # GitHub setup script
│   └── README.md         # Documentation
└── warp-ai/              # Git repository

~/borg-repos/
└── code-backup/          # Borg repository for code

~/Documents/
└── git-journey/          # This documentation
    ├── README.md
    ├── git-journey.md
    └── backup-YYYYMMDD/  # Backup of documentation
```

## Usage Instructions

### Daily Git Workflow

```bash
# Initialize a new repository (first time only)
git init

# Check the status of your repository
git status

# See what changed in your files
git diff filename

# Navigate to your project
cd ~/code/project-name

# Make changes to your files
# ...

# Check which files changed
git status

# Stage specific file
git add filename
# Or stage all changes
git add .

# Commit changes
git commit -m "Description of changes"

# View commit history
git log
# Or view condensed history
git log --oneline

# Create a new branch
git checkout -b new-feature

# Switch between branches
git checkout main

# Push to GitHub
git push origin main

# Pull latest changes from GitHub
git pull origin main
```

### Manual Borg Backup (if needed)

```bash
# Run the backup script
~/code/borg-backup/bin/backup_code.sh
```

### Viewing Backups

```bash
# List all Borg backups
borg list ~/borg-repos/code-backup

# View details of a specific backup
borg info ~/borg-repos/code-backup::backup-name
```

### Restoring from Borg Backup

```bash
# Restore entire backup
borg extract ~/borg-repos/code-backup::backup-name

# Restore specific file or directory
borg extract ~/borg-repos/code-backup::backup-name path/to/file
```

## Learning Journey

### Git Practice Repository

On April 6, 2025, a dedicated Git practice repository was created to document and practice essential Git commands:

```
~/code/git-practice/
```

This repository contains:
- README.md: Basic repository information
- git_commands.md: Documentation of common Git commands

### Core Git Commands Learned

During the practice session, the following Git concepts and commands were thoroughly explored:

1. **Repository Initialization and Status**:
   ```bash
   git init
   git status
   ```

2. **Tracking Changes**:
   ```bash
   git diff
   git add .
   git commit -m "message"
   ```

3. **Commit History Visualization**:
   ```bash
   git log
   git log --oneline
   ```

4. **Branch Management**:
   ```bash
   git branch
   git checkout -b new-branch
   git checkout existing-branch
   git merge branch-name
   ```

5. **Remote Repository Operations**:
   ```bash
   git remote add origin https://github.com/YourUsername/repo-name.git
   git remote -v
   git push -u origin main
   git pull origin main
   ```

### Key Insights and Practices

The practice session highlighted several important Git workflow insights:

1. **Atomic Commits**: Make small, focused commits that accomplish a single logical change
2. **Meaningful Commit Messages**: Use clear, descriptive commit messages that explain the "why" not just the "what"
3. **Regular Checkpoints**: Use `git status` and `git diff` frequently to understand what changes will be committed
4. **Branch Strategy**: Create separate branches for new features or experiments
5. **Visualization**: Use `git log` to understand repository history

### GitHub Integration

The practice repository demonstrates the complete GitHub workflow:
- Local repository initialization
- Creating a GitHub repository
- Connecting local and remote repositories
- Pushing and pulling changes

## Git Utilities Organization

### Standardized Git Scripts Repository

On April 6, 2025, a dedicated Git utilities repository was created to centralize all Git-related scripts:

```
~/code/git-utils/
```

This repository organizes all Git-related utilities in a structured manner:

1. **Directory Structure**:
   ```
   git-utils/
   ├── bin/
   │   ├── init_git_repos.sh     # Automated Git initialization
   │   └── setup_github_repos.sh # GitHub repository setup
   └── README.md                 # Documentation
   ```

2. **Initialization Script (`init_git_repos.sh`)**:
   - Automatically initializes Git repositories in all project directories
   - Creates standardized .gitignore files
   - Performs initial commits
   - Skips directories that already have Git initialized

3. **GitHub Setup Script (`setup_github_repos.sh`)**:
   - Creates corresponding GitHub repositories
   - Ensures README.md files exist
   - Configures remotes and pushes initial code
   - Works with the GitHub CLI for automation

### Benefits of Centralization

The reorganization of Git utilities provides several benefits:

- **Maintainability**: All Git-related scripts are in one repository
- **Standardization**: Consistent approach to Git initialization across projects
- **Documentation**: Comprehensive documentation in the repository
- **Version Control**: The utilities themselves are version controlled
- **Portability**: Scripts can be easily reused for future projects

## Best Practices

1. **Commit Frequently**: Make small, focused commits with clear messages
2. **Push Regularly**: Push to GitHub at least daily
3. **Review Backups**: Periodically check that Borg backups are running
4. **Test Restores**: Occasionally test the restore process
5. **Update Documentation**: Keep this documentation up to date
6. **Secure Keys**: Keep the Borg repository key secure
7. **Handle Sensitive Data**: Do not commit sensitive data to Git

## Troubleshooting

### GitHub Authentication Issues

If you encounter GitHub authentication issues:
```bash
gh auth login --web
```

### Borg Backup Failures

If Borg backups fail, check:
1. Repository path
2. Available disk space
3. Repository permissions

### Manual Repository Pruning

To manually prune backups:
```bash
borg prune -v --list --keep-daily=7 --keep-weekly=4 --keep-monthly=6 ~/borg-repos/code-backup
```

