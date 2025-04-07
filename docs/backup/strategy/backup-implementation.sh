#!/bin/bash
# Backup Implementation Script
# This script implements the backup strategy documented in backup-strategy.md
# Last updated: 2025-04-07

# Configuration variables
BORG_REPO=${BORG_REPO:-"/path/to/repo"}
BACKUP_SOURCE=${BACKUP_SOURCE:-"/home"}
LOG_DIR=${LOG_DIR:-"/var/log/backup"}
LOG_FILE="$LOG_DIR/backup-$(date +%Y-%m-%d).log"
EXCLUDE_FILE="/etc/borg/excludes"

# Email notification settings
EMAIL_NOTIFICATIONS=${EMAIL_NOTIFICATIONS:-"true"}
EMAIL_TO=${EMAIL_TO:-"admin@example.com"}
EMAIL_FROM=${EMAIL_FROM:-"backup@$(hostname -f)"}
EMAIL_SUBJECT_PREFIX=${EMAIL_SUBJECT_PREFIX:-"[Backup]"}
EMAIL_SMTP_SERVER=${EMAIL_SMTP_SERVER:-"smtp.example.com"}
EMAIL_SMTP_PORT=${EMAIL_SMTP_PORT:-"587"}
EMAIL_SMTP_USER=${EMAIL_SMTP_USER:-""}
EMAIL_SMTP_PASSWORD=${EMAIL_SMTP_PASSWORD:-""}
EMAIL_ALWAYS_NOTIFY=${EMAIL_ALWAYS_NOTIFY:-"false"}  # If true, send success emails too

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Email notification function
send_notification() {
    local subject="$1"
    local message="$2"
    local priority="$3" # "high" for errors, "normal" for success
    
    # Skip if notifications are disabled
    if [[ "$EMAIL_NOTIFICATIONS" != "true" ]]; then
        log "INFO" "Email notifications disabled, skipping notification"
        return 0
    fi
    
    # Skip success notifications unless EMAIL_ALWAYS_NOTIFY is true
    if [[ "$priority" != "high" && "$EMAIL_ALWAYS_NOTIFY" != "true" ]]; then
        log "INFO" "Skipping success notification (EMAIL_ALWAYS_NOTIFY is false)"
        return 0
    fi
    
    log "INFO" "Sending email notification to $EMAIL_TO"
    
    # Prepare email content
    local date_str=$(date "+%Y-%m-%d %H:%M:%S")
    local hostname=$(hostname -f)
    local email_content="
Host: $hostname
Date: $date_str
Repository: $BORG_REPO
Status: ${priority^^}

$message

--- 
Log Excerpt (last 10 lines):
$(tail -n 10 "$LOG_FILE")
"
    
    # Send email using appropriate method
    if [[ -n "$EMAIL_SMTP_USER" && -n "$EMAIL_SMTP_PASSWORD" ]]; then
        # Using authentication
        echo "$email_content" | mail -s "$EMAIL_SUBJECT_PREFIX $subject" \
            -S smtp="$EMAIL_SMTP_SERVER:$EMAIL_SMTP_PORT" \
            -S smtp-use-starttls \
            -S smtp-auth=login \
            -S smtp-auth-user="$EMAIL_SMTP_USER" \
            -S smtp-auth-password="$EMAIL_SMTP_PASSWORD" \
            -S from="$EMAIL_FROM" "$EMAIL_TO"
    else
        # No authentication
        echo "$email_content" | mail -s "$EMAIL_SUBJECT_PREFIX $subject" \
            -S smtp="$EMAIL_SMTP_SERVER:$EMAIL_SMTP_PORT" \
            -S from="$EMAIL_FROM" "$EMAIL_TO"
    fi
}

# Perform backup
perform_backup() {
    local backup_type="$1"  # "full" or "incremental"
    local archive_name="$(hostname)-$backup_type-$(date +%Y-%m-%d)"
    
    log "INFO" "Starting $backup_type backup to $BORG_REPO::$archive_name"
    
    # Set options based on backup type
    local backup_opts=""
    if [[ "$backup_type" == "full" ]]; then
        backup_opts="--stats --compression zstd"
    else
        backup_opts="--stats --compression lz4"
    fi
    
    # Create backup
    borg create \
        $backup_opts \
        --exclude-from "$EXCLUDE_FILE" \
        --exclude-caches \
        --one-file-system \
        "$BORG_REPO::$archive_name" \
        "$BACKUP_SOURCE" 2>> "$LOG_FILE"
    
    local backup_status=$?
    
    if [[ $backup_status -eq 0 ]]; then
        log "INFO" "$backup_type backup completed successfully"
        send_notification "$backup_type backup successful" "Backup to $BORG_REPO::$archive_name completed successfully." "normal"
    else
        log "ERROR" "$backup_type backup failed with status $backup_status"
        send_notification "$backup_type backup failed" "Backup to $BORG_REPO::$archive_name failed with status $backup_status." "high"
        return 1
    fi
    

