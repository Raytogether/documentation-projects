# Git Journey Documentation

This documentation provides an overview of the Git and Borg backup implementation for code projects. It covers the setup, configuration, and best practices for maintaining a robust code backup system.

## Contents

- **git-journey.md**: Detailed implementation guide covering the entire setup process
- **backup-YYYYMMDD/**: Backup copies of the documentation

## Quick Reference

### Git Repositories

Local repositories are stored in `~/code/` with remote copies on GitHub.

### Borg Backup Repository

Borg backups are stored in `~/borg-repos/code-backup/` with automated daily backups.

### Backup Scripts

- `~/code/backup_code.sh`: Main backup script that runs daily at 1:00 AM
- `~/code/setup_github_repos.sh`: Script used to set up GitHub repositories

## Usage

Refer to `git-journey.md` for detailed instructions on how to use and maintain your code backup system.

