---
layout: default
title: Comprehensive Backup Strategy
description: A detailed guide to our multi-layered backup approach with Duplicity, Borg, and cloud storage solutions
---

# Comprehensive Backup Strategy

<!--
PROJECT METADATA
----------------
Title: Comprehensive Backup Strategy
Version: 1.1.0
Created: 2025-04-06
Last Updated: 2025-04-07 11:07
Author: Donald Tanner
Status: Active - Implementation Phase
Framework Version: 2.1
Related Files: PROJECT_STATUS.md, README.md, backup-implementation.sh
Location: ~/Documents/backup-strategy
Document Type: Technical Documentation
Export Formats: md, txt, rtf
-->

## Table of Contents

1. [Introduction](#introduction)
2. [Primary Backup Systems](#primary-backup-systems)
   - [Duplicity Configuration](#duplicity-configuration)
   - [Borg Backup Management](#borg-backup-management)
   - [B2 Cloud Storage Integration](#b2-cloud-storage-integration)
   - [Combined System Benefits](#combined-system-benefits)
   - [Monitoring and Maintenance](#monitoring-and-maintenance)
3. [Dropbox Standalone System](#dropbox-standalone-system)
   - [Alias and Function Management](#alias-and-function-management)
   - [Which Command Integration](#which-command-integration)
   - [Shell Functions for Backup](#shell-functions-for-backup)
   - [Quick Reference](#quick-reference)
4. [Additional Backup Solutions](#additional-backup-solutions)
   - [DeJa Dup Google Drive Integration](#deja-dup-google-drive-integration)
5. [Comprehensive Maintenance Plan](#comprehensive-maintenance-plan)
   - [Daily Operations](#daily-operations)
   - [Weekly Verification](#weekly-verification)
   - [Monthly Testing](#monthly-testing)
   - [Quarterly Audit](#quarterly-audit)
6. [Troubleshooting](#troubleshooting)
   - [Primary Systems Issues](#primary-systems-issues)
   - [Dropbox Issues](#dropbox-issues)
   - [General Backup Problems](#general-backup-problems)

## Introduction

Modern data protection requires a comprehensive backup strategy that addresses multiple failure scenarios and recovery needs. This document outlines our multi-layered backup approach using:

1. **Primary Systems**: Duplicity, Borg, and B2 for comprehensive automated backups
2. **Standalone System**: Dropbox with shell functions and aliases for quick access
3. **Additional Solution**: DeJa Dup with Google Drive for supplementary coverage

By combining these diverse solutions, we create a robust backup strategy that provides quick local recovery, secure off-site storage, and convenient access across multiple devices.

## Primary Backup Systems

The core of our backup infrastructure combines Duplicity for incremental cloud backups, Borg for efficient local backups, and B2 as our primary cloud storage provider.

### Duplicity Configuration

Duplicity provides encrypted bandwidth-efficient backups using the rsync algorithm, designed specifically for cloud storage.

Key features:
- Incremental backups (only changed data is uploaded)
- Strong GPG encryption
- Support for multiple cloud providers
- Full and incremental backup modes
- Retention management

Configuration:
```bash
# ~/.duplicity-env
export PASSPHRASE="your-gpg-passphrase"
export B2_ACCOUNT_ID="your-b2-account-id"
export B2_APPLICATION_KEY="your-b2-app-key"
export BACKUP_URL="b2://bucket-name/backup-prefix"
export GPG_KEY="your-gpg-key-id"
export FULL_BACKUP_RETENTION="3M"  # Keep full backups for 3 months
export INCREMENTAL_RETENTION="1M"  # Keep incremental chains for 1 month
export RETENTION_PERIOD="3M"       # Overall retention period
```

Security considerations:

```bash
# Ensure environment file has proper permissions
chmod 600 ~/.duplicity-env

# Generate and verify GPG key for encryption
gpg --list-keys

# Generate B2 URL securely using URL encoding
B2_URL=$(python3 -c "from urllib.parse import quote_plus; key_id=quote_plus('$B2_ACCOUNT_ID'); app_key=quote_plus('$B2_APPLICATION_KEY'); bucket='bucket-name'; print(f'b2://{key_id}:{app_key}@{bucket}/backup')")
```

Implementation:
```bash
# Example duplicity backup script
#!/bin/bash
source ~/.duplicity-env

# Run incremental backup
duplicity \
    --encrypt-key $GPG_KEY \
    --exclude "**/.cache" \
    --exclude "**/node_modules" \
    --full-if-older-than 1M \
    $BACKUP_SOURCE $BACKUP_URL

# Clean up old backups
duplicity remove-older-than 6M --force $BACKUP_URL
```

Crontab configuration:
```bash
# Duplicity incremental backup (daily)
0 2 * * * . $HOME/.duplicity-env && $HOME/bin/duplicity-backup.sh --incremental

# Duplicity full backup (monthly)
0 3 1 * * . $HOME/.duplicity-env && $HOME/bin/duplicity-backup.sh --full

# Duplicity cleanup (monthly)
30 4 1 * * . $HOME/.duplicity-env && $HOME/bin/duplicity-cleanup.sh
```
```

### Borg Backup Management

Borg is a deduplicating backup program that supports compression and encryption, designed for efficient local backups with fast recovery.

Key features:
- Powerful deduplication (saves space by storing identical data only once)
- Multiple compression options
- Strong encryption
- Efficient incremental backups
- Flexible retention policies
- Repository consistency checking

Configuration:
```bash
export BORG_REPO="/path/to/repo"
export BORG_PASSPHRASE="your-secure-passphrase"
export RETENTION_DAYS=7
export RETENTION_WEEKS=4
export RETENTION_MONTHS=6
```

Security best practices for Borg:

```bash
# Create a secure environment file with proper permissions
cat > ~/.borg-env << 'EOF'
export BORG_PASSPHRASE="your-secure-passphrase"
export BORG_PASSCOMMAND=""  # Disable interactive prompts
EOF
chmod 600 ~/.borg-env

# Export repository encryption key for safekeeping
borg key export $BORG_REPO ~/code/borg-backup/code-backup-key.txt
chmod 600 ~/code/borg-backup/code-backup-key.txt

# Store this key in a secure location (preferably offline)
# Without this key, you won't be able to restore backups if the original repository is lost
```
```

The `BORG_REPO` variable can point to either a local path for on-site backups or a B2 bucket for cloud storage. For B2 cloud storage integration:

```bash
# B2 configuration for Borg
export BORG_REPO="b2:bucketname:path/to/repo"
export B2_ACCOUNT_ID="your-b2-account-id" 
export B2_APPLICATION_KEY="your-b2-app-key"
export BORG_PASSPHRASE="your-secure-passphrase"
export BORG_RSH="ssh -i /path/to/identity_file" # For custom SSH options if needed
```

For remote B2 operations, the connection syntax follows this pattern:

```bash
# Initialize a new B2 repository
borg init --encryption=repokey-blake2 b2:bucketname:path/to/repo

# Create backup to B2
borg create --stats --compression zlib,9 \
    b2:bucketname:path/to/repo::archive-name \
    ~/Documents ~/Projects
    
# List archives in B2 repository 
borg list b2:bucketname:path/to/repo
```

This B2 integration provides off-site storage for Borg backups alongside Duplicity, creating multiple layers of cloud protection using the same reliable B2 infrastructure.

Implementation:
```bash
#!/bin/bash
source ~/.borg-env

# Create unique archive name
ARCHIVE_NAME="backup-$(date +%Y-%m-%d-%H%M)"

# Create backup
borg create \
    --compression zlib,9 \
    --exclude '*.DS_Store' \
    --exclude '*/tmp/*' \
    --exclude '**/__pycache__/*' \
    "$BORG_REPO::$ARCHIVE_NAME" $HOME/Documents $HOME/Projects

# Prune old backups
borg prune \
    --keep-daily=$RETENTION_DAYS \
    --keep-weekly=$RETENTION_WEEKS \
    --keep-monthly=$RETENTION_MONTHS \
    "$BORG_REPO"
```

Crontab configuration:
```bash
# Borg Backup Jobs - Daily at 10 PM
0 22 * * * $HOME/code/borg-backup/code-backup.sh
```

This ensures that Borg backups run automatically every day at 10 PM, providing regular protection for your code directory without manual intervention.

### B2 Cloud Storage Integration

Backblaze B2 provides our primary cloud storage infrastructure, offering a cost-effective and reliable platform for our Duplicity backups.

Key features:
- S3-compatible API
- Cost-effective storage pricing
- Lifecycle policies
- High durability (99.999999%)
- Good integration with backup tools

Setup:
1. Create B2 account at backblaze.com
2. Create application key with appropriate permissions
3. Create dedicated bucket for backups
4. Configure Duplicity to use B2 credentials

Integration script:
```bash
#!/bin/bash
# b2-backup-check.sh

# Load credentials
source ~/.duplicity-env

# Check backup status
echo "Checking B2 backup status..."
duplicity collection-status $BACKUP_URL

# Verify latest backup
echo "Verifying latest backup..."
duplicity verify $BACKUP_URL $BACKUP_SOURCE
```

### Combined System Benefits

The integration of Duplicity, Borg, and B2 provides several advantages:
1. **Comprehensive Coverage**:
   - Borg: Fast local recovery with deduplication
   - Duplicity: Encrypted, incremental cloud backups
   - B2: Reliable, offsite storage with high durability

2. **Recovery Scenarios**:
   - Quick recovery (Borg): Immediate access to recent files with mountable archives
   - Point-in-time recovery (Duplicity): Restore files from specific dates
   - Disaster recovery (Duplicity+B2): Protection against hardware failure
   - Off-site redundancy (Borg+B2): Second cloud backup with different technology

3. **Storage Efficiency**:
   - Borg: Local deduplication reduces storage requirements by 30-50%
   - Duplicity: Incremental backups minimize cloud storage and bandwidth
   - B2: Cost-effective pricing model for long-term storage

4. **System Isolation**:
   - Separate backup chains protect against corruption
   - Different encryption methods (GPG vs. built-in)
   - Complementary retention policies
   - Independent verification procedures

5. **Backup Characteristics Comparison**:
   | Feature | Borg | Duplicity |
   |---------|------|-----------|
   | Deduplication | Block-level | File-level |
   | Compression | Multiple options (zlib, lz4, zstd) | Fixed |
   | Encryption | Built-in AES | GPG |
   | Repository Format | Custom append-only | TAR+GPG |
   | Mountable Archives | Yes | No |
   | Backup Chains | Single repo, multiple archives | Multiple chains |
   - B2: Cost-effective pricing model for long-term storage

### Monitoring and Maintenance

Regular maintenance ensures reliable operation of our primary backup systems:

```bash
# Create a unified monitoring script
#!/bin/bash

# Check Borg repository health
borg check --verbose $BORG_REPO

# Check Duplicity backup status
duplicity collection-status $BACKUP_URL

# Check log files for errors
grep -i "error\|warning\|fail" $BORG_LOG_FILE $DUPLICITY_LOG_FILE
```

Schedule:
- **Daily**: Verify successful completion of incremental backups
- **Weekly**: Run consistency checks and verify accessible archives
- **Monthly**: Perform recovery tests for both systems

## Dropbox Standalone System

In addition to our primary backup systems, we maintain Dropbox as a standalone solution for quick access, file sharing, and targeted synchronization with specialized shell functions and aliases.

### Alias and Function Management

Our Dropbox implementation includes custom shell functions and aliases for efficient management:

```bash
# In ~/.bashrc or equivalent
# Dropbox management aliases
alias dbox='dropbox'
alias dstatus='dropbox status'
alias dstart='dropbox start'
alias dstop='dropbox stop'
alias dexclude='dropbox exclude'

# Function to add multiple directories to Dropbox exclusion
function dbox_exclude_multi() {
    for dir in "$@"; do
        dropbox exclude add "$dir"
        echo "Excluded: $dir"
    done
}

# Function to sync a specific folder to Dropbox
function dbox_sync() {
    if [ -d "$1" ]; then
        dbox_exclude_multi *
        dropbox exclude remove "$1"
        echo "Now syncing only: $1"
    else
        echo "Directory not found: $1"
    fi
}
```

These functions can be easily loaded and verified using shell introspection:

```bash
# List all Dropbox-related functions
(alias; declare -f) | grep -i dropbox
```

### Which Command Integration

We leverage the extended `which` command to manage and document our Dropbox tools:

```bash
# Find all Dropbox-related commands with full paths and aliases
/usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot dropbox dbox dstatus dstart dstop
```

This integration allows for:
- Quick verification of command availability
- Documentation of command paths with user-friendly notation
- Discovery of both system and user-defined commands

Example output:
```
dropbox is /usr/bin/dropbox
dbox is an alias for dropbox
dstatus is an alias for dropbox status
dstart is an alias for dropbox start
dstop is an alias for dropbox stop
```

### Shell Functions for Backup

Our standalone Dropbox system includes specialized shell functions for backup operations:

```bash
# Function to perform a quick backup of important files
function quick_backup() {
    local dest="$HOME/Dropbox/QuickBackups/$(date +%Y-%m-%d)"
    mkdir -p "$dest"
    
    echo "Backing up important files to Dropbox..."
    cp -rv "$@" "$dest/"
    
    echo "Backup complete. Files copied to: $dest"
    ls -la "$dest"
}

# Function to check Dropbox sync status of critical files
function check_sync_status() {
    echo "Checking sync status of critical files..."
    for file in "$@"; do
        echo -n "$file: "
        dropbox filestatus "$file"
    done
}
```

These functions can be combined with the `which` command for documentation:

```bash
(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot quick_backup check_sync_status
```

### Quick Reference

For convenient access, here's a quick reference of essential Dropbox commands and functions:

```bash
# Basic Dropbox commands
dropbox status          # Check sync status
dropbox filestatus      # Check specific file status
dropbox ls              # List files in Dropbox
dropbox exclude list    # Show excluded files/folders
dropbox exclude add     # Exclude a folder
dropbox exclude remove  # Include a folder

# Custom functions
quick_backup FILE...    # Quickly backup files to Dropbox
check_sync_status FILE... # Check sync status of files
dbox_exclude_multi DIR... # Exclude multiple directories
dbox_sync DIR           # Sync only one specific directory
```

All these commands can be documented and verified using:
```bash
(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot
```

## Additional Backup Solutions

### DeJa Dup Google Drive Integration

As a supplementary backup solution, we leverage DeJa Dup with Google Drive for user-friendly graphical backups of selected personal data.

#### Overview

DeJa Dup provides:
- Simple graphical interface for configuring backups
- Incremental backups with encryption
- Integration with Google Drive for cloud storage
- Easy restoration through a GUI

#### Configuration

While we don't manage detailed configuration in this document, the basic setup includes:

1. Installing DeJa Dup:
   ```bash
   sudo dnf install deja-dup
   ```

2. Configuring Google Drive as the backup location
3. Setting up folders to include/exclude
4. Enabling encryption
5. Scheduling automatic backups

#### Integration with Primary Strategy

The DeJa Dup solution complements our primary backup systems by:
- Providing an easy GUI-based restore option for non-technical users
- Leveraging Google Drive storage allocation
- Creating an additional backup copy on a different cloud provider
- Covering personal files that might not be included in the primary backup sets

## Comprehensive Maintenance Plan

### Daily Operations

- Verify successful completion of Duplicity and Borg backup jobs
- Check Dropbox sync status for any errors
- Monitor disk space on all backup targets

### Weekly Verification
- Monitor storage usage trends
- Run verification checks on recent backups
- Update exclusion patterns as needed

### Monthly Testing
- Perform recovery tests for all systems
- Validate backup integrity with data verification
- Update documentation with any process improvements

### Quarterly Audit
- Review retention policies and storage usage
- Test disaster recovery procedures
- Evaluate backup strategy effectiveness
- Consider technology updates or improvements

## Troubleshooting

### Primary Systems Issues

1. **Duplicity Issues**: 
   - Check GPG key availability: `gpg --list-keys`
   - Verify B2 connectivity: `curl -I https://api.backblazeb2.com/b2api/v2/b2_authorize_account`
   - Check log files for detailed error messages
   - Collection status check: `duplicity collection-status $BACKUP_URL`
   - Verify backup integrity: `duplicity verify --path-to-restore Documents $BACKUP_URL ~/Documents`
   - Common error codes:
     - **Exit code 0**: Success
     - **Exit code 1**: Warning or minor issue
     - **Exit code 2**: Error during processing
     - **Exit code 44**: GPG decryption error

2. **Borg Issues**:
   - Fix repository locks: `borg break-lock $BORG_REPO`
   - Verify repository integrity: `borg check --verify-data $BORG_REPO`
   - Check disk space on local storage: `df -h`
   - List archives to verify availability: `borg list $BORG_REPO`
   - Repository corruption recovery: `borg check --repair $BORG_REPO`
   - Missing chunks check: `borg check -v --archives-only $BORG_REPO`
   - Test restoration: `mkdir ~/test-restore && cd ~/test-restore && borg extract $BORG_REPO::archive-name path/to/test/file`

3. **B2 Issues**:
   - Verify account authorization
   - Check bucket permissions
   - Review bandwidth usage limits
   - Test B2 API access: `curl -u "$B2_ACCOUNT_ID:$B2_APPLICATION_KEY" https://api.backblazeb2.com/b2api/v2/b2_authorize_account`
   - List buckets: `b2 list-buckets`
   - Check backup bucket contents: `b2 ls $B2_BUCKET_NAME`

4. **Cross-System Verification**:
   ```bash
   #!/bin/bash
   # Comprehensive backup verification script
   
   echo "=== Checking Borg Backup Status ==="
   borg list $BORG_REPO
   borg check --archives-only $BORG_REPO
   
   echo "=== Checking Duplicity Backup Status ==="
   source ~/.duplicity-env
   duplicity collection-status $BACKUP_URL
   
   echo "=== Checking B2 Storage Access ==="
   b2 list-buckets
   
   echo "=== Checking Disk Space ==="
   df -h | grep -E '(Filesystem|/dev/)'
   ```

### Dropbox Issues

1. **Sync Problems**:
   - Restart Dropbox client: `dropbox stop && dropbox start`
   - Clear cache: `rm -rf ~/.dropbox.cache/*`
   - Check internet connectivity
   - Verify excluded folders configuration

2. **Command Integration Issues**:
   - Verify aliases are loaded: `type dbox`
   - Check function availability: `declare -f dbox_sync`
   - Repair by re-sourcing configuration: `source ~/.bashrc`

### General Backup Problems

1. **Space Issues**:
   - Check available space: `df -h`
   - Review backup size trends: `du -sh /path/to/backups`
   - Adjust retention policies if needed

2. **Performance Concerns**:
   - Run backups during off-hours
   - Use bandwidth limiting: `--limit-rate=1000k`
   - Optimize exclusion patterns

---

**Note**: This document complements the automated backup scripts located in the system. Changes to the backup strategy should be documented here and reflected in the corresponding scripts.
