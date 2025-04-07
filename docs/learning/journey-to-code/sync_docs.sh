#!/bin/bash

# sync_docs.sh - Script to watch and automatically convert Markdown files to .txt and .rtf
# This script:
# 1. Watches for changes in .md files
# 2. Automatically converts them to .txt and .rtf using pandoc
# 3. Preserves file permissions
# 4. Includes error handling
# 5. Provides feedback on conversion status

# Color definitions for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check if required dependencies are installed
check_dependencies() {
    echo "Checking dependencies..."
    
    local missing_deps=0
    
    # Check for inotify-tools
    if ! command -v inotifywait &>/dev/null; then
        echo -e "${RED}Error: inotify-tools is not installed.${NC}"
        echo "Please install it using: sudo apt-get install inotify-tools"
        missing_deps=1
    fi
    
    # Check for pandoc
    if ! command -v pandoc &>/dev/null; then
        echo -e "${RED}Error: pandoc is not installed.${NC}"
        echo "Please install it using: sudo apt-get install pandoc"
        missing_deps=1
    fi
    
    if [ $missing_deps -eq 1 ]; then
        echo -e "${RED}Missing dependencies. Exiting.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All dependencies are installed.${NC}"
}

# Function to convert a markdown file to txt and rtf
convert_markdown() {
    local md_file="$1"
    local file_name=$(basename "$md_file" .md)
    local dir_name=$(dirname "$md_file")
    local txt_file="${dir_name}/${file_name}.txt"
    local rtf_file="${dir_name}/${file_name}.rtf"
    local original_perms=$(stat -c "%a" "$md_file")
    
    echo -e "${YELLOW}Converting${NC} $md_file to txt and rtf formats..."
    
    # Convert to txt
    if pandoc "$md_file" -o "$txt_file" 2>/dev/null; then
        # Preserve permissions
        chmod "$original_perms" "$txt_file"
        echo -e "${GREEN}Successfully converted${NC} to $txt_file"
    else
        echo -e "${RED}Failed to convert${NC} $md_file to txt format"
    fi
    
    # Convert to rtf
    if pandoc "$md_file" -o "$rtf_file" 2>/dev/null; then
        # Preserve permissions
        chmod "$original_perms" "$rtf_file"
        echo -e "${GREEN}Successfully converted${NC} to $rtf_file"
    else
        echo -e "${RED}Failed to convert${NC} $md_file to rtf format"
    fi
}

# Function to handle existing markdown files
process_existing_files() {
    echo "Processing existing Markdown files..."
    
    local count=0
    
    # Find all .md files in the current directory and subdirectories
    while IFS= read -r file; do
        convert_markdown "$file"
        ((count++))
    done < <(find . -type f -name "*.md")
    
    if [ $count -eq 0 ]; then
        echo "No existing Markdown files found."
    else
        echo -e "${GREEN}Processed $count existing Markdown files.${NC}"
    fi
}

# Function to watch for file changes
watch_markdown_files() {
    echo -e "${GREEN}Starting file watch service...${NC}"
    echo "Watching for changes in Markdown files. Press Ctrl+C to stop."
    
    # Watch the current directory and all subdirectories
    inotifywait -m -r -e modify -e create --format '%w%f' . | while read file; do
        if [[ "$file" == *.md ]]; then
            echo -e "${YELLOW}Change detected${NC} in $file"
            convert_markdown "$file"
        fi
    done
}

# Main function
main() {
    echo "=== Markdown File Sync Service ==="
    
    # Check dependencies
    check_dependencies
    
    # Process existing files
    process_existing_files
    
    # Start watching for changes
    watch_markdown_files
}

# Handle script interruption gracefully
trap 'echo -e "\n${YELLOW}Script terminated by user.${NC}"; exit 0' INT

# Run the main function
main

