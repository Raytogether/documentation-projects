#!/bin/bash
#
# Git integration for Warp AI Sessions
# This script provides automatic git version control for session files
#

# Function to verify git is installed
verify_git() {
    if ! command -v git > /dev/null 2>&1; then
        echo "Error: Git is not installed. Please install git to use the backup feature."
        return 1
    fi
    return 0
}

# Function to verify SSH keys if remote operations are enabled
verify_ssh_key() {
    if [ "$WARP_GIT_USE_SSH" = "true" ] && [ -n "$WARP_GIT_REMOTE" ]; then
        # Check if ssh-agent is running
        if ! ssh-add -l &>/dev/null; then
            echo "Warning: ssh-agent is not running or no keys loaded."
            echo "You may need to start ssh-agent or run 'ssh-add' to add your SSH key."
            return 1
        fi
        
        # Try to connect to GitHub (or other git provider)
        if [[ "$WARP_GIT_REMOTE" == *"github.com"* ]]; then
            if ! ssh -T git@github.com -o BatchMode=yes -o StrictHostKeyChecking=no &>/dev/null; then
                echo "Warning: SSH connection to GitHub failed."
                echo "Please check your SSH key configuration."
                return 1
            fi
        fi
    fi
    return 0
}

# Initialize repository if it doesn't exist
init_repo() {
    local repo_dir="$1"
    
    # If .git doesn't exist, initialize repo
    if [ ! -d "${repo_dir}/.git" ]; then
        echo "Initializing git repository in ${repo_dir}..."
        
        # First create gitignore
        cat > "${repo_dir}/.gitignore" << EOL
# Warp AI Session Git Integration
#
# Gitignore for session files

# Ignore temporary files
*.tmp
*.swp
*~

# Ignore backup directory if it exists locally
/backups/

# Ignore config files that might contain sensitive data
.session_backup_config
EOL
        
        # Initialize the repository
        (cd "${repo_dir}" && git init && git add .gitignore && git commit -m "Initial commit: Setup Warp AI Session repository")
        
        # Set up remote if provided
        if [ -n "$WARP_GIT_REMOTE" ]; then
            echo "Setting up remote repository..."
            (cd "${repo_dir}" && git remote add origin "$WARP_GIT_REMOTE")
            
            # Set up branch if provided
            if [ -n "$WARP_GIT_BRANCH" ]; then
                (cd "${repo_dir}" && git checkout -b "$WARP_GIT_BRANCH")
            fi
            
            # Push to remote if auto-push is enabled
            if [ "$WARP_GIT_AUTO_PUSH" = "true" ]; then
                echo "Pushing to remote repository..."
                (cd "${repo_dir}" && git push -u origin "$(git symbolic-ref --short HEAD)")
            fi
        fi
        
        return 0
    else
        # Repository already exists
        echo "Git repository already exists in ${repo_dir}"
        return 0
    fi
}

# Stage changes for a session
stage_session() {
    local repo_dir="$1"
    local filename="$2"
    local readme="$3"
    
    # Add the session file and README
    (cd "${repo_dir}" && git add "${filename}" "${readme}")
    
    return $?
}

# Commit changes with proper message
commit_session() {
    local repo_dir="$1"
    local topic="$2"
    local commit_msg="$3"
    
    # If no commit message template is provided, use default
    if [ -z "$commit_msg" ]; then
        commit_msg="Add session: ${topic}"
    else
        # Replace template variables
        commit_msg=$(echo "$commit_msg" | sed "s/%TOPIC%/${topic}/g")
        commit_msg=$(echo "$commit_msg" | sed "s/%DATE%/$(date +%Y-%m-%d)/g")
        commit_msg=$(echo "$commit_msg" | sed "s/%TIME%/$(date +%H:%M)/g")
    fi
    
    # Commit the changes
    (cd "${repo_dir}" && git commit -m "${commit_msg}")
    
    return $?
}

# Push changes to remote if configured
push_changes() {
    local repo_dir="$1"
    
    # Check if remote exists and auto-push is enabled
    if [ "$WARP_GIT_AUTO_PUSH" = "true" ] && [ -n "$WARP_GIT_REMOTE" ]; then
        # Get current branch
        local current_branch
        current_branch=$(cd "${repo_dir}" && git symbolic-ref --short HEAD 2>/dev/null)
        
        # Use configured branch if available, otherwise current branch
        local push_branch="${WARP_GIT_BRANCH:-$current_branch}"
        
        echo "Pushing changes to remote repository..."
        (cd "${repo_dir}" && git push origin "${push_branch}")
        
        if [ $? -eq 0 ]; then
            echo "Successfully pushed changes to remote."
            return 0
        else
            echo "Warning: Failed to push changes to remote."
            return 1
        fi
    fi
    
    return 0
}

# Handle conflicts
handle_conflicts() {
    local repo_dir="$1"
    local filename="$2"
    
    # Check if there are conflicts
    if (cd "${repo_dir}" && git status --porcelain | grep -q "^UU ${filename}"); then
        echo "Conflict detected in ${filename}"
        echo "Please resolve the conflict manually."
        return 1
    fi
    
    return 0
}

# Main backup function
backup_session() {
    local repo_dir="$1"
    local filename="$2"
    local topic="$3"
    local readme="$4"
    
    # Verify git is installed
    verify_git || return 1
    
    # Initialize repository if needed
    init_repo "${repo_dir}" || return 1
    
    # Verify SSH key if using SSH
    if [ "$WARP_GIT_USE_SSH" = "true" ]; then
        verify_ssh_key || echo "Warning: SSH verification failed but continuing..."
    fi
    
    # Stage files
    echo "Staging session files for commit..."
    stage_session "${repo_dir}" "${filename}" "${readme}" || return 1
    
    # Commit changes
    echo "Committing session changes..."
    commit_session "${repo_dir}" "${topic}" "${WARP_GIT_COMMIT_TEMPLATE}" || return 1
    
    # Push changes if configured
    push_changes "${repo_dir}" || echo "Warning: Push failed but session was saved locally."
    
    echo "Git backup completed successfully."
    return 0
}

# Function to show git status
show_git_status() {
    local repo_dir="$1"
    
    if [ -d "${repo_dir}/.git" ]; then
        echo "Git Repository Status:"
        echo "----------------------"
        (cd "${repo_dir}" && git status -s)
        
        echo ""
        echo "Recent Commits:"
        echo "--------------"
        (cd "${repo_dir}" && git log --oneline -n 5)
        
        if [ -n "$WARP_GIT_REMOTE" ]; then
            echo ""
            echo "Remote Repository:"
            echo "------------------"
            (cd "${repo_dir}" && git remote -v)
            
            echo ""
            echo "Current Branch:"
            echo "--------------"
            (cd "${repo_dir}" && git branch)
        fi
    else
        echo "No git repository found in ${repo_dir}"
    fi
}

