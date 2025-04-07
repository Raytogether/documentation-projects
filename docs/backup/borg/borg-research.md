# Borg Backup: Comprehensive Guide

## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Basic Concepts](#basic-concepts)
- [Command Line Usage](#command-line-usage)
- [Vorta GUI Usage](#vorta-gui-usage)
- [Best Practices](#best-practices)
- [Real-World Implementation](#real-world-implementation)
- [Remote Backup Options](#remote-backup-options)
- [Troubleshooting](#troubleshooting)

## Introduction

Borg is a deduplicating backup program that supports compression and encryption. It is designed to be efficient with large data sets and provides backup, restore, and archive management functionality.

Key features:
- Deduplication (saves space by storing identical data only once)
- Compression
- Encryption
- Incremental backups
- Mountable backups (can browse like a filesystem)
- Backup verification
- Client-server architecture for remote backups

## Installation

### Linux
```bash
# Fedora
sudo dnf install borgbackup

# Ubuntu/Debian
sudo apt install borgbackup

# Arch Linux
sudo pacman -S borg
```

### macOS
```bash
brew install borgbackup
```

### Windows
- Use WSL (Windows Subsystem for Linux) 
- Or use the experimental Windows port

### Vorta GUI Installation
```bash
# Fedora
sudo dnf install vorta

# Ubuntu/Debian
sudo apt install vorta

# macOS
brew install vorta
```

## Basic Concepts

### Repositories
A Borg repository is a storage location where your backup archives are stored.
```bash
# Initialize a new repository
borg init --encryption=repokey /path/to/repo
```

### Archives
Each backup operation creates a new archive in the repository.
```bash
# Create an archive
borg create /path/to/repo::archive-name /path/to/backup
```

### Encryption
Borg supports several encryption modes:
- `none` - No encryption
- `repokey` - Encryption with key stored in repository
- `keyfile` - Encryption with key stored in a separate file
- `repokey-blake2` and `keyfile-blake2` - Newer variants with improved hashing

### Deduplication
Borg automatically deduplicates data by:
- Breaking files into chunks
- Storing identical chunks only once
- Referencing existing chunks for duplicated data

## Command Line Usage

### Repository Management

#### Create a repository
```bash
borg init --encryption=repokey ~/backup-repo
```

#### Check repository health
```bash
borg check ~/backup-repo
```

### Backup Operations

#### Create a backup
```bash
borg create --progress --stats ~/backup-repo::archive-name ~/Documents
```

#### List all archives
```bash
borg list ~/backup-repo
```

#### Show archive info
```bash
borg info ~/backup-repo::archive-name
```

#### List archive contents
```bash
borg list --format="{mode} {user:6} {group:6} {size:8d} {isomtime} {path}{extra}{NL}" ~/backup-repo::archive-name
```

### Restore Operations

#### Extract specific files
```bash
borg extract ~/backup-repo::archive-name path/to/file
```

#### Extract entire archive
```bash
borg extract ~/backup-repo::archive-name
```

#### Mount an archive (browse like a filesystem)
```bash
mkdir ~/mount-point
borg mount ~/backup-repo::archive-name ~/mount-point
# When done
borg umount ~/mount-point
```

### Archive Management

#### Delete an archive
```bash
borg delete ~/backup-repo::archive-name
```

#### Prune archives according to retention policy
```bash
borg prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6 ~/backup-repo
```

## Vorta GUI Usage

Vorta is a desktop backup client for Borg that provides a user-friendly GUI.

### Setting Up Repositories

1. Launch Vorta
2. Click "Add" button in the Repository tab
3. Choose a repository mode:
   - Create new repository
   - Use existing repository
4. Set encryption type (recommended: repokey)
5. Set repository location (local or remote)

### Configuring Backups

1. Navigate to the "Sources" tab
2. Add directories to include in backup
3. Navigate to the "Exclude" tab
4. Configure patterns for exclusion
   - Common patterns: `*.pyc`, `node_modules`, `.git`, etc.

### Setting Schedule and Retention

1. Navigate to the "Schedule" tab
2. Set backup frequency (daily, weekly, etc.)
3. Navigate to the "Archive" tab
4. Configure retention policies:
   - How many hourly/daily/weekly/monthly/yearly archives to keep

### Running and Restoring Backups

1. Click "Create Backup Now" to run a manual backup
2. For restoration:
   - Navigate to the "Archives" tab
   - Select the archive to restore from
   - Click "Extract" and select files/directories to restore

## Best Practices
### Security

1. **Strong Passphrase**: Use a strong, unique passphrase for your repository
2. **Passphrase Management**: Store your passphrase securely (password manager)
   - For automated backups, use an environment file with restricted permissions:
   ```bash
   # Create a secure environment file (~/.borg-env)
   cat > ~/.borg-env << 'EOF'
   export BORG_PASSPHRASE="your-secure-passphrase"
   export BORG_PASSCOMMAND=""  # Disable interactive prompts
   EOF
   
   # Set restrictive permissions
   chmod 600 ~/.borg-env
   ```
3. **Backup Your Key**: Store your encryption key safely:
   ```bash
   borg key export ~/backup-repo key-backup-file
   ```

### Backup Strategy

1. **3-2-1 Backup Rule**:
   - 3 copies of your data
   - 2 different storage types
   - 1 copy offsite

2. **Regular Testing**: Periodically test restoration to ensure backups are valid:
   ```bash
   borg extract --dry-run ~/backup-repo::archive-name
   ```
3. **Automation**: Set up scheduled backups:
   - Use Vorta's scheduling feature
   - Or create a cron job/systemd timer for CLI:
   ```bash
   # Example cron entry for daily 1 AM backups
   0 1 * * * . $HOME/.borg-env && $HOME/bin/borg-backup
   
   # Using a separate environment file for credentials
   # This approach separates sensitive data from the backup script
   ```

### Performance Optimization

1. **Compression Levels**: Balance between speed and size:
   ```bash
   # Fast, less compression
   borg create --compression lz4 ~/backup-repo::archive-name ~/data

   # Slower, better compression
   borg create --compression zstd,3 ~/backup-repo::archive-name ~/data
   ```

2. **Exclude Patterns**: Exclude unnecessary files to speed up backups:
   ```bash
   borg create --exclude '*.iso' --exclude '*/node_modules' ~/backup-repo::archive-name ~/data
   ```
3. **Caching**: Use Borg's cache for better performance:
   ```bash
   export BORG_CACHE_DIR=~/.cache/borg
   ```
## Real-World Implementation

This section details a practical, production-ready Borg backup implementation with automation, error handling, email notifications, and proper organization.

### Directory Structure

### Monitoring and Verification

Regular monitoring ensures the backup system is functioning correctly. Our implementation includes email notifications for failures and (optionally) successful backups:
~/logs/                       # Backup logs directory
```

### Automated Backup Script

Here's a robust backup script with logging, error handling, and retention policies:

```bash
#!/bin/bash

# Configuration (can be overridden by environment variables)
BORG_REPO=${BORG_REPO:-"$HOME/test-backup"}
BACKUP_SOURCES=${BACKUP_SOURCES:-"$HOME/Documents"}
ARCHIVE_PREFIX=${ARCHIVE_PREFIX:-"cli-docs"}
LOG_DIR=${LOG_DIR:-"$HOME/logs"}
LOG_FILE="$LOG_DIR/borg-backup.log"
COMPRESSION=${COMPRESSION:-"zlib,9"}
RETENTION_DAYS=${RETENTION_DAYS:-7}
RETENTION_WEEKS=${RETENTION_WEEKS:-4}
RETENTION_MONTHS=${RETENTION_MONTHS:-6}

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Error handling
handle_error() {
    local exit_code=$?
    log "ERROR" "Backup failed with exit code $exit_code"
    log "ERROR" "Check the log file for details: $LOG_FILE"
    exit $exit_code
}

# Set trap for error handling
trap 'handle_error' ERR

# Create backup archive with current timestamp
ARCHIVE_NAME="${ARCHIVE_PREFIX}-$(date +%Y-%m-%d-%H%M%S)"
log "INFO" "Creating archive: $ARCHIVE_NAME"

# Create the backup
borg create \
    --verbose \
    --stats \
    --compression "$COMPRESSION" \
    --exclude '*.DS_Store' \
    --exclude '*/tmp/*' \
    --exclude '**/__pycache__/*' \
    --exclude '*/node_modules/*' \
    "$BORG_REPO::$ARCHIVE_NAME" \
    $BACKUP_SOURCES 2>> "$LOG_FILE"

# Prune old backups according to retention policy
log "INFO" "Pruning old backups"
borg prune \
    --verbose \
    --list \
    --prefix "${ARCHIVE_PREFIX}-" \
    --keep-daily=$RETENTION_DAYS \
    --keep-weekly=$RETENTION_WEEKS \
    --keep-monthly=$RETENTION_MONTHS \
    --stats \
    "$BORG_REPO" 2>> "$LOG_FILE"

log "INFO" "Backup process completed successfully"
```

### System Integration

For proper system integration:

1. **Executable Script Setup**:
   ```bash
   # Make the script executable
   chmod +x ~/code/borg-backup/borg-backup.sh
   
   # Create symlink in ~/bin
   mkdir -p ~/bin
   ln -sf ~/code/borg-backup/borg-backup.sh ~/bin/borg-backup
   
   # Make sure ~/bin is in PATH (add to .bashrc if needed)
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
   ```

2. **Automated Execution**:
   ```bash
   # Add to crontab
   crontab -e
   # Add line: 0 1 * * * . $HOME/.borg-env && $HOME/bin/borg-backup
   ```

### Monitoring and Verification

Regular monitoring ensures the backup system is functioning correctly:

1. **Check Latest Logs**:
   ```bash
   tail -n 50 ~/logs/borg-backup.log
   ```

2. **Verify Repository Health**:
   ```bash
   borg check --verbose $BORG_REPO
   ```
3. **Test Restoration**:
   ```bash
   # Create test directory
   mkdir ~/backup-restore-test
   cd ~/backup-restore-test
   
   # List archives
   borg list $BORG_REPO
   
   # Extract files to test restoration
   borg extract $BORG_REPO::archive-name path/to/test/file
   ```

4. **Email Notifications**:
   
   Our implementation includes email alerts for backup failures and optional notifications for successful backups:
   
   ```bash
   # Environment variables to configure notifications
   export EMAIL_NOTIFICATIONS="true"              # Enable notifications
   export EMAIL_TO="admin@example.com"            # Recipient address
   export EMAIL_SMTP_SERVER="smtp.example.com"    # SMTP server
   export EMAIL_SMTP_PORT="587"                   # SMTP port
   export EMAIL_SMTP_USER="username"              # For authenticated SMTP
   export EMAIL_SMTP_PASSWORD="password"          # For authenticated SMTP
   export EMAIL_ALWAYS_NOTIFY="true"              # Get success notifications too
   ```
   
   Notifications include:
   - Success/failure status
   - Repository and archive information
   - Duration and timestamp
   - Last 10 lines of logs for context
   
   This ensures administrators are immediately aware of any backup failures.

## Remote Backup Options

### Setting Up Remote Repositories

#### Self-Hosted Server
```bash
# Initialize remote repository
borg init --encryption=repokey user@server.com:/path/to/repo

# Backup to remote repository
borg create --progress user@server.com:/path/to/repo::archive-name ~/Documents
```

#### Borg-Specific Hosting Services

1. **BorgBase**:
   - Dedicated Borg hosting service
   - Web interface for repository management
   - Support for SSH keys and 2FA

2. **Rsync.net**:
   - General purpose storage with Borg support
   - Provides shell access and pre-installed Borg

### Bandwidth Considerations

For initial backups to remote repositories:
```bash
# Create initial backup locally, then copy
borg init --encryption=repokey ~/temp-repo
borg create ~/temp-repo::initial ~/Documents
rsync -av ~/temp-repo user@server.com:/path/to/
rm -rf ~/temp-repo  # Optional cleanup
```

## Troubleshooting

### Common Issues

1. **Repository Locking**:
   ```bash
   # If a backup was interrupted
   borg break-lock ~/backup-repo
   ```

2. **Repository Corruption**:
   ```bash
   borg check --repair ~/backup-repo
   ```

3. **Missing Chunks**:
   ```bash
   # Check archives for issues
   borg check -v --archives-only ~/backup-repo
   ```

### Environment Variables

Useful environment variables for Borg:
```bash
export BORG_REPO="/path/to/repo"  # Default repository
export BORG_PASSPHRASE="your-passphrase"  # Caution: Only use in secure scripts
export BORG_RSH="ssh -i /path/to/identity_file"  # For custom SSH options
```
---

This document summarizes our exploration and implementation of Borg backup systems. It was last updated on April 6, 2025, with the addition of practical implementation details, automation scripts, email notification capabilities, and enhanced security best practices based on real-world deployment experience.

For the most up-to-date and comprehensive information, refer to the [official Borg documentation](https://borgbackup.readthedocs.io/).
