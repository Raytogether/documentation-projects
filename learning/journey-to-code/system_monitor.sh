#!/usr/bin/env bash
#
# system_monitor.sh - A simple system monitoring script with fan monitoring
#
# Description:
#   This script displays key system resource information including memory usage,
#   CPU-consuming processes, disk space, and fan speeds for Apple SMC devices.
#   It updates periodically and can be terminated with Ctrl+C.
#
# Usage:
#   ./system_monitor.sh [OPTIONS]
#
# Options:
#   -h, --help     Display this help message and exit
#   -i, --interval Set the update interval in seconds (default: 5)
#
# Author: Donald tanner
# Date: April 6, 2025
# License: MIT

# Exit on error, undefined vars, and propagate pipe failures
set -euo pipefail

# Default update interval (seconds)
INTERVAL=3

# Paths for hardware monitoring
SYS_HWMON="/sys/class/hwmon"
SYS_DRM="/sys/class/drm"
SYS_DEVICES="/sys/devices"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Debug mode (set to true to show additional information)
DEBUG=false

# ====== Helper Functions ======

# Function to display error messages
error() {
    echo -e "${RED}ERROR:${NC} $*" >&2
}

# Function to display warning messages
warning() {
    echo -e "${YELLOW}WARNING:${NC} $*" >&2
}

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Display this help message and exit"
    echo "  -d, --debug    Enable debug output for troubleshooting"
    echo "  -i, --interval Set the update interval in seconds (default: 3)"
    echo
    exit 0
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print debug information
debug_info() {
    if [ "$DEBUG" = true ]; then
        echo -e "${BLUE}DEBUG:${NC} $*" >&2
    fi
}

# ====== System Monitoring Functions ======

# Function to display memory usage information
show_memory_info() {
    echo -e "${BOLD}${BLUE}Memory Usage:${NC}"
    if command_exists free; then
        free -h | awk '
            /^Mem/ {
                printf "  Total: %s, Used: %s, Free: %s, Available: %s\n", $2, $3, $4, $7
                used_percent = ($3/$2)*100
                printf "  Memory Usage: %.1f%%", used_percent
                if (used_percent > 80) {
                    printf " [HIGH]"
                }
                printf "\n"
            }'
    else
        error "Command 'free' not found"
        return 1
    fi
    echo
}

# Function to display top CPU-consuming processes
show_cpu_info() {
    echo -e "${BOLD}${GREEN}Top CPU-Consuming Processes:${NC}"
    if command_exists ps; then
        # Display top 5 CPU-consuming processes
        ps aux --sort=-%cpu | head -6 | awk '
            NR==1 {
                printf "  %-10s %-10s %-6s %-6s %-25s\n", "USER", "PID", "%CPU", "%MEM", "COMMAND"
            }
            NR>1 {
                cpu = $3
                printf "  %-10s %-10s %5.1f%% %5.1f%% %-25.25s", $1, $2, cpu, $4, $11
                if (cpu > 20) {
                    printf " [HIGH CPU]"
                }
                printf "\n"
            }'
    else
        error "Command 'ps' not found"
        return 1
    fi
    echo
}

# Function to display disk space usage
show_disk_info() {
    echo -e "${BOLD}${PURPLE}Disk Space Usage:${NC}"
    if command_exists df; then
        df -h | awk '
            NR==1 {
                printf "  %-15s %-8s %-8s %-8s %-6s %s\n", $1, $2, $3, $4, $5, $6
            }
            NR>1 && $1 ~ /^\/dev/ {
                printf "  %-15s %-8s %-8s %-8s %-6s", $1, $2, $3, $4, $5
                used_percent = substr($5, 1, length($5)-1)
                if (used_percent+0 > 80) {
                    printf " %s [HIGH]", $6
                } else {
                    printf " %s", $6
                }
                printf "\n"
            }'
    else
        error "Command 'df' not found"
        return 1
    fi
    echo
}

# Function to display system uptime
show_uptime_info() {
    echo -e "${BOLD}${YELLOW}System Uptime:${NC}"
    if command_exists uptime; then
        uptime | awk '{
            print "  " $0
        }'
    else
        error "Command 'uptime' not found"
        return 1
    fi
    echo
}

# Function to read fan speeds directly from sysfs
show_fan_info() {
    echo -e "${BOLD}${CYAN}Fan Speeds:${NC}"
    
    FOUND_FANS=false
    
    # First, check for Apple SMC fans in platform devices (direct path)
    for SMC_PATH in "$SYS_DEVICES"/platform/applesmc*; do
        if [ ! -d "$SMC_PATH" ]; then
            continue
        fi
        
        debug_info "Checking Apple SMC device at: $SMC_PATH"
        
        # Look for fan input files directly
        FAN_FILES=()
        for FAN_FILE in "$SMC_PATH"/fan*_input; do
            if [ -f "$FAN_FILE" ]; then
                FAN_FILES+=("$FAN_FILE")
            fi
        done
        
        if [ ${#FAN_FILES[@]} -gt 0 ]; then
            FOUND_FANS=true
            echo "  Apple SMC Fans:"
            
            for FAN_FILE in "${FAN_FILES[@]}"; do
                # Extract fan number
                FAN_NUM=$(echo "$FAN_FILE" | grep -oE 'fan([0-9]+)_input' | sed 's/fan\([0-9]*\)_input/\1/')
                FAN_BASE_PATH="${FAN_FILE%_input}"
                
                # Get fan data
                FAN_SPEED=$(cat "$FAN_FILE" 2>/dev/null || echo "0")
                FAN_MIN=$(cat "${FAN_BASE_PATH}_min" 2>/dev/null || echo "N/A")
                FAN_MAX=$(cat "${FAN_BASE_PATH}_max" 2>/dev/null || echo "N/A")
                
                # Get fan label if available, otherwise use generic name
                if [ -f "${FAN_BASE_PATH}_label" ]; then
                    FAN_LABEL=$(cat "${FAN_BASE_PATH}_label" 2>/dev/null || echo "Fan $FAN_NUM")
                else
                    FAN_LABEL="Fan $FAN_NUM"
                fi
                
                # Display fan info
                echo -n "  ▶ $FAN_LABEL: $FAN_SPEED RPM"
                
                # Add min/max if available
                if [ "$FAN_MIN" != "N/A" ] || [ "$FAN_MAX" != "N/A" ]; then
                    echo -n " (Min: $FAN_MIN, Max: $FAN_MAX)"
                fi
                
                # Calculate and display percentage if max is available
                if [ "$FAN_MAX" != "N/A" ] && [ "$FAN_MAX" -gt 0 ]; then
                    PERCENT=$((FAN_SPEED * 100 / FAN_MAX))
                    echo -n " - Usage: "
                    
                    if [ "$PERCENT" -gt "85" ]; then
                        echo -e "${RED}${PERCENT}%${NC} [HIGH]"
                    elif [ "$PERCENT" -gt "65" ]; then
                        echo -e "${YELLOW}${PERCENT}%${NC}"
                    else
                        echo -e "${GREEN}${PERCENT}%${NC}"
                    fi
                else
                    echo ""
                fi
            done
        fi
    done
    
    # List all hwmon devices if in debug mode
    if [ "$DEBUG" = true ]; then
        echo "  Detected hwmon devices:"
        for dir in "$SYS_HWMON"/*; do
            if [ -d "$dir" ]; then
                name=$(cat "$dir/name" 2>/dev/null || echo "unknown")
                echo "    - $(basename "$dir"): $name"
            fi
        done
        echo ""
    fi
    
    # Look for fan sensors in all hwmon devices
    for HWMON_DIR in "$SYS_HWMON"/*; do
        if [ ! -d "$HWMON_DIR" ]; then
            continue
        fi
        
        # Check if this is an applesmc device or has fan inputs
        HWMON_NAME=$(cat "$HWMON_DIR/name" 2>/dev/null || echo "unknown")
        debug_info "Checking hwmon device: $HWMON_NAME ($(basename "$HWMON_DIR"))"
        
        # Look for fan inputs in this hwmon device
        FAN_INPUTS=()
        for FAN_INPUT in "$HWMON_DIR"/fan*_input; do
            if [ -f "$FAN_INPUT" ]; then
                FAN_INPUTS+=("$FAN_INPUT")
            fi
        done
        
        # Skip if no fan inputs found
        if [ ${#FAN_INPUTS[@]} -eq 0 ]; then
            continue
        fi
        
        # Found fans in this device
        FOUND_FANS=true
        echo "  $HWMON_NAME Fans:"
        
        # Process each fan input
        for FAN_INPUT in "${FAN_INPUTS[@]}"; do
            # Extract fan number
            FAN_NUM=$(echo "$FAN_INPUT" | grep -oE 'fan([0-9]+)_input' | sed 's/fan\([0-9]*\)_input/\1/')
            
            # Get fan speed
            FAN_SPEED=$(cat "$FAN_INPUT" 2>/dev/null || echo "0")
            
            # Get min and max if available
            FAN_MIN_FILE="${FAN_INPUT%_input}_min"
            FAN_MAX_FILE="${FAN_INPUT%_input}_max"
            FAN_LABEL_FILE="${FAN_INPUT%_input}_label"
            
            FAN_MIN=$(cat "$FAN_MIN_FILE" 2>/dev/null || echo "N/A")
            FAN_MAX=$(cat "$FAN_MAX_FILE" 2>/dev/null || echo "N/A")
            
            # Get fan label if available, otherwise use fan number
            if [ -f "$FAN_LABEL_FILE" ]; then
                FAN_LABEL=$(cat "$FAN_LABEL_FILE" 2>/dev/null)
            else
                if [ "$HWMON_NAME" == "applesmc" ]; then
                    FAN_LABEL="Main"
                else
                    FAN_LABEL="Fan $FAN_NUM"
                fi
            fi
            
            # Display fan info
            echo -n "  ▶ $FAN_LABEL: $FAN_SPEED RPM"
            
            # Add min/max if available
            if [ "$FAN_MIN" != "N/A" ] || [ "$FAN_MAX" != "N/A" ]; then
                echo -n " (Min: $FAN_MIN, Max: $FAN_MAX)"
            fi
            
            # Calculate percentage if max is available
            if [ "$FAN_MAX" != "N/A" ] && [ "$FAN_MAX" -gt 0 ]; then
                PERCENT=$((FAN_SPEED * 100 / FAN_MAX))
                echo -n " - Usage: "
                
                if [ "$PERCENT" -gt "85" ]; then
                    echo -e "${RED}${PERCENT}%${NC} [HIGH]"
                elif [ "$PERCENT" -gt "65" ]; then
                    echo -e "${YELLOW}${PERCENT}%${NC}"
                else
                    echo -e "${GREEN}${PERCENT}%${NC}"
                fi
            else
                echo ""
            fi
        done
    done
    
    # Check for fans in standard hwmon directories only if no fans were found in SMC
    if [ "$FOUND_FANS" = false ]; then
        debug_info "No fans found in Apple SMC path, trying other sources"
        
        # Look for fans in virtual hwmon directories
        for HWMON_DIR in "$SYS_DEVICES"/virtual/hwmon/* "$SYS_HWMON"/* ; do
            if [ ! -d "$HWMON_DIR" ]; then
                continue
            fi
            
            # Skip directories already checked
            if [[ "$HWMON_DIR" == *"applesmc"* ]]; then
                continue
            fi
            
            debug_info "Checking additional fan path: $HWMON_DIR"
            
            # Look for fan input files directly
            FAN_INPUTS=()
            for FAN_INPUT in "$HWMON_DIR"/fan*_input; do
                if [ -f "$FAN_INPUT" ]; then
                    FAN_INPUTS+=("$FAN_INPUT")
                fi
            done
            
            # Skip if no fan inputs found
            if [ ${#FAN_INPUTS[@]} -eq 0 ]; then
                continue
            fi
            
            # Get hwmon name
            HWMON_NAME=$(cat "$HWMON_DIR/name" 2>/dev/null || echo "unknown")
            
            # Found fans in this device
            FOUND_FANS=true
            echo "  $HWMON_NAME Fans:"
            
            # Process each fan input
            for FAN_INPUT in "${FAN_INPUTS[@]}"; do
                # Extract fan number
                FAN_NUM=$(echo "$FAN_INPUT" | grep -oE 'fan([0-9]+)_input' | sed 's/fan\([0-9]*\)_input/\1/')
                
                # Get fan speed
                FAN_SPEED=$(cat "$FAN_INPUT" 2>/dev/null || echo "0")
                
                # Get min and max if available
                FAN_MIN_FILE="${FAN_INPUT%_input}_min"
                FAN_MAX_FILE="${FAN_INPUT%_input}_max"
                FAN_LABEL_FILE="${FAN_INPUT%_input}_label"
                
                FAN_MIN=$(cat "$FAN_MIN_FILE" 2>/dev/null || echo "N/A")
                FAN_MAX=$(cat "$FAN_MAX_FILE" 2>/dev/null || echo "N/A")
                
                # Get fan label if available, otherwise use fan number
                if [ -f "$FAN_LABEL_FILE" ]; then
                    FAN_LABEL=$(cat "$FAN_LABEL_FILE" 2>/dev/null)
                else
                    FAN_LABEL="Fan $FAN_NUM"
                fi
                
                # Display fan info
                echo -n "  ▶ $FAN_LABEL: $FAN_SPEED RPM"
                
                # Add min/max if available
                if [ "$FAN_MIN" != "N/A" ] || [ "$FAN_MAX" != "N/A" ]; then
                    echo -n " (Min: $FAN_MIN, Max: $FAN_MAX)"
                fi
                
                # Calculate percentage if max is available
                if [ "$FAN_MAX" != "N/A" ] && [ "$FAN_MAX" -gt 0 ]; then
                    PERCENT=$((FAN_SPEED * 100 / FAN_MAX))
                    echo -n " - Usage: "
                    
                    if [ "$PERCENT" -gt "85" ]; then
                        echo -e "${RED}${PERCENT}%${NC} [HIGH]"
                    elif [ "$PERCENT" -gt "65" ]; then
                        echo -e "${YELLOW}${PERCENT}%${NC}"
                    else
                        echo -e "${GREEN}${PERCENT}%${NC}"
                    fi
                else
                    echo ""
                fi
            done
        done
    fi
    
    # Report if no fans were found after all attempts
    if [ "$FOUND_FANS" = false ]; then
        warning "No fan sensors found in the system"
        if [ "$DEBUG" = true ]; then
            echo "  Available hwmon devices:"
            find "$SYS_HWMON" -type d -name "hwmon*" -exec echo "    {}" \;
            echo "  Available Apple SMC devices:"
            find "$SYS_DEVICES"/platform -name "applesmc*" -exec echo "    {}" \;
            echo "  Available fan files:"
            find "$SYS_DEVICES" -name "fan*_input" -exec echo "    {}" \;
        fi
    fi
    
    echo
}

# Function to display CPU and GPU temperatures reading directly from sysfs
show_temperature_info() {
    echo -e "${BOLD}${RED}Temperature Information:${NC}"
    
    FOUND_TEMPS=false
    
    # List all hwmon devices if in debug mode
    if [ "$DEBUG" = true ]; then
        echo "  Detected temperature sensors:"
        for dir in "$SYS_HWMON"/*; do
            if [ -d "$dir" ]; then
                name=$(cat "$dir/name" 2>/dev/null || echo "unknown")
                temp_files=$(find "$dir" -name "temp*_input" | wc -l)
                echo "    - $(basename "$dir"): $name ($temp_files temperature sensors)"
            fi
        done
        echo ""
    fi
    
    # ===== CPU Temperature Monitoring =====
    echo "  CPU Temperature:"
    
    # Look for CPU temperature sensors in hwmon
    for HWMON_DIR in "$SYS_HWMON"/*; do
        if [ ! -d "$HWMON_DIR" ]; then
            continue
        fi
        
        # Check if this is a CPU temperature sensor
        HWMON_NAME=$(cat "$HWMON_DIR/name" 2>/dev/null || echo "unknown")
        
        # Skip non-CPU sensors
        if [[ "$HWMON_NAME" != *"coretemp"* ]] && [[ "$HWMON_NAME" != *"k10temp"* ]]; then
            continue
        fi
        
        # Found CPU temperature sensor
        FOUND_TEMPS=true
        
        # Look for package and core temperature inputs
        PACKAGE_TEMP=""
        PACKAGE_HIGH=""
        PACKAGE_CRIT=""
        
        # Find CPU package temperature (usually temp1)
        for TEMP_INPUT in "$HWMON_DIR"/temp*_input; do
            if [ ! -f "$TEMP_INPUT" ]; then
                continue
            fi
            
            # Extract temperature number
            TEMP_NUM=$(echo "$TEMP_INPUT" | grep -oE 'temp([0-9]+)_input' | sed 's/temp\([0-9]*\)_input/\1/')
            
            # Check if this is package temperature (typically temp1 or has "package" in label)
            TEMP_LABEL_FILE="${TEMP_INPUT%_input}_label"
            if [ -f "$TEMP_LABEL_FILE" ]; then
                TEMP_LABEL=$(cat "$TEMP_LABEL_FILE" 2>/dev/null)
                if [[ "$TEMP_LABEL" == *"Package"* ]] || [[ "$TEMP_NUM" -eq 1 ]]; then
                    # Found package temperature
                    PACKAGE_TEMP=$(cat "$TEMP_INPUT" 2>/dev/null || echo "0")
                    PACKAGE_TEMP=$(echo "scale=1; $PACKAGE_TEMP / 1000" | bc)
                    
                    # Get high and critical thresholds if available
                    TEMP_HIGH_FILE="${TEMP_INPUT%_input}_max"
                    TEMP_CRIT_FILE="${TEMP_INPUT%_input}_crit"
                    
                    if [ -f "$TEMP_HIGH_FILE" ]; then
                        PACKAGE_HIGH=$(cat "$TEMP_HIGH_FILE" 2>/dev/null || echo "80000")
                        PACKAGE_HIGH=$(echo "scale=1; $PACKAGE_HIGH / 1000" | bc)
                    else
                        PACKAGE_HIGH=80.0
                    fi
                    
                    if [ -f "$TEMP_CRIT_FILE" ]; then
                        PACKAGE_CRIT=$(cat "$TEMP_CRIT_FILE" 2>/dev/null || echo "100000")
                        PACKAGE_CRIT=$(echo "scale=1; $PACKAGE_CRIT / 1000" | bc)
                    else
                        PACKAGE_CRIT=100.0
                    fi
                    
                    # Display package temperature
                    echo -n "  ▶ Package    : ${PACKAGE_TEMP}°C (High: ${PACKAGE_HIGH}°C, Critical: ${PACKAGE_CRIT}°C)"
                    
                    if (( $(echo "$PACKAGE_TEMP >= $PACKAGE_CRIT" | bc -l) )); then
                        echo -e " ${RED}[CRITICAL]${NC}"
                    elif (( $(echo "$PACKAGE_TEMP >= $PACKAGE_HIGH" | bc -l) )); then
                        echo -e " ${YELLOW}[HIGH]${NC}"
                    else
                        echo ""
                    fi
                    
                    continue
                fi
            fi
            
            # Check if this is a core temperature
            if [ -f "$TEMP_LABEL_FILE" ]; then
                TEMP_LABEL=$(cat "$TEMP_LABEL_FILE" 2>/dev/null)
                if [[ "$TEMP_LABEL" == *"Core"* ]]; then
                    # Found core temperature
                    TEMP_VALUE=$(cat "$TEMP_INPUT" 2>/dev/null || echo "0")
                    TEMP_VALUE=$(echo "scale=1; $TEMP_VALUE / 1000" | bc)
                    
                    # Get high threshold if available
                    TEMP_HIGH_FILE="${TEMP_INPUT%_input}_max"
                    TEMP_CRIT_FILE="${TEMP_INPUT%_input}_crit"
                    
                    if [ -f "$TEMP_HIGH_FILE" ]; then
                        TEMP_HIGH=$(cat "$TEMP_HIGH_FILE" 2>/dev/null || echo "80000")
                        TEMP_HIGH=$(echo "scale=1; $TEMP_HIGH / 1000" | bc)
                    else
                        TEMP_HIGH=80.0
                    fi
                    
                    if [ -f "$TEMP_CRIT_FILE" ]; then
                        TEMP_CRIT=$(cat "$TEMP_CRIT_FILE" 2>/dev/null || echo "100000")
                        TEMP_CRIT=$(echo "scale=1; $TEMP_CRIT / 1000" | bc)
                    else
                        TEMP_CRIT=100.0
                    fi
                    
                    # Display core temperature in a compact format
                    echo -n "    $TEMP_LABEL: ${TEMP_VALUE}°C "
                    
                    if (( $(echo "$TEMP_VALUE >= $TEMP_CRIT" | bc -l) )); then
                        echo -e "${RED}[CRIT]${NC}"
                    elif (( $(echo "$TEMP_VALUE >= $TEMP_HIGH" | bc -l) )); then
                        echo -e "${YELLOW}[HIGH]${NC}"
                    else
                        echo ""
                    fi
                fi
            fi
        done
    done
    
    # ===== GPU Temperature Monitoring =====
    echo ""
    echo "  GPU Temperature:"
    GPU_FOUND=false
    
    # First check AMD GPU temperature in /sys/class/drm/card*/device/hwmon/
    for CARD_DIR in "$SYS_DRM"/card*/device; do
        if [ ! -d "$CARD_DIR" ]; then
            continue
        fi
        
        # Look for hwmon directory in the GPU device path
        for GPU_HWMON in "$CARD_DIR"/hwmon/*; do
            if [ ! -d "$GPU_HWMON" ]; then
                continue
            fi
            
            # Look for temperature sensors in this hwmon device
            for TEMP_INPUT in "$GPU_HWMON"/temp*_input; do
                if [ ! -f "$TEMP_INPUT" ]; then
                    continue
                fi
                
                # Found a GPU temperature sensor
                GPU_FOUND=true
                FOUND_TEMPS=true
                
                # Get temperature value
                TEMP_VALUE=$(cat "$TEMP_INPUT" 2>/dev/null || echo "0")
                TEMP_VALUE=$(echo "scale=1; $TEMP_VALUE / 1000" | bc)
                
                # Get label if available
                TEMP_LABEL_FILE="${TEMP_INPUT%_input}_label"
                if [ -f "$TEMP_LABEL_FILE" ]; then
                    TEMP_LABEL=$(cat "$TEMP_LABEL_FILE" 2>/dev/null)
                else
                    # Extract temperature number for a generic label
                    TEMP_NUM=$(echo "$TEMP_INPUT" | grep -oE 'temp([0-9]+)_input' | sed 's/temp\([0-9]*\)_input/\1/')
                    if [ "$TEMP_NUM" = "1" ]; then
                        TEMP_LABEL="Edge"
                    elif [ "$TEMP_NUM" = "2" ]; then
                        TEMP_LABEL="Junction"
                    elif [ "$TEMP_NUM" = "3" ]; then
                        TEMP_LABEL="Memory"
                    else
                        TEMP_LABEL="Sensor $TEMP_NUM"
                    fi
                fi
                
                # Get critical threshold if available
                TEMP_CRIT_FILE="${TEMP_INPUT%_input}_crit"
                if [ -f "$TEMP_CRIT_FILE" ]; then
                    TEMP_CRIT=$(cat "$TEMP_CRIT_FILE" 2>/dev/null || echo "110000")
                    TEMP_CRIT=$(echo "scale=1; $TEMP_CRIT / 1000" | bc)
                else
                    TEMP_CRIT=110.0
                fi
                
                # Display GPU temperature
                echo -n "  ▶ AMD GPU ($TEMP_LABEL): ${TEMP_VALUE}°C (Critical: ${TEMP_CRIT}°C)"
                
                # Use 80% of critical as high threshold
                TEMP_HIGH=$(echo "scale=1; $TEMP_CRIT * 0.8" | bc)
                
                if (( $(echo "$TEMP_VALUE >= $TEMP_CRIT" | bc -l) )); then
                    echo -e " ${RED}[CRITICAL]${NC}"
                elif (( $(echo "$TEMP_VALUE >= $TEMP_HIGH" | bc -l) )); then
                    echo -e " ${YELLOW}[HIGH]${NC}"
                else
                    echo ""
                fi
            done
        done
    done
    
    # Check if we found any GPU temperatures
    if [ "$GPU_FOUND" = false ]; then
        # Try looking in other hwmon devices for GPU temperatures
        for HWMON_DIR in "$SYS_HWMON"/*; do
            if [ ! -d "$HWMON_DIR" ]; then
                continue
            fi
            
            # Check if this might be a GPU device
            HWMON_NAME=$(cat "$HWMON_DIR/name" 2>/dev/null || echo "unknown")
            
            # Skip CPU and fan devices we've already checked
            if [[ "$HWMON_NAME" == *"coretemp"* ]] || [[ "$HWMON_NAME" == *"k10temp"* ]] || [[ "$HWMON_NAME" == *"applesmc"* ]]; then
                continue
            fi
            
            # If this is an NVIDIA or AMD device
            if [[ "$HWMON_NAME" == *"nvidia"* ]] || [[ "$HWMON_NAME" == *"amdgpu"* ]] || [[ "$HWMON_NAME" == *"radeon"* ]]; then
                # Look for temperature sensors
                for TEMP_INPUT in "$HWMON_DIR"/temp*_input; do
                    if [ ! -f "$TEMP_INPUT" ]; then
                        continue
                    fi
                    
                    # Found a GPU temperature sensor
                    GPU_FOUND=true
                    FOUND_TEMPS=true
                    
                    # Get temperature value
                    TEMP_VALUE=$(cat "$TEMP_INPUT" 2>/dev/null || echo "0")
                    TEMP_VALUE=$(echo "scale=1; $TEMP_VALUE / 1000" | bc)
                    
                    # Display GPU temperature
                    echo -n "  ▶ GPU ($HWMON_NAME): ${TEMP_VALUE}°C"
                    
                    # Check for high temperature
                    if (( $(echo "$TEMP_VALUE >= 90" | bc -l) )); then
                        echo -e " ${RED}[CRITICAL]${NC}"
                    elif (( $(echo "$TEMP_VALUE >= 75" | bc -l) )); then
                        echo -e " ${YELLOW}[HIGH]${NC}"
                    else
                        echo ""
                    fi
                done
            fi
        done
        
        # If we still didn't find a GPU
        if [ "$GPU_FOUND" = false ]; then
            echo "  No GPU temperature sensors found"
        fi
    fi
    
    # Check if no temperature sensors were found at all
    if [ "$FOUND_TEMPS" = false ]; then
        warning "No temperature sensors found in the system"
    fi
    
    echo
}

# ====== Main Program ======

# Enable debug mode with -d or --debug
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -d|--debug)
            DEBUG=true
            shift
            ;;
        -i|--interval)
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                INTERVAL="$2"
                shift 2
            else
                error "Interval must be a positive number"
                exit 1
            fi
            ;;
        *)
            usage
            ;;
    esac
done

# Check for required commands
for cmd in free ps df uptime; do
    if ! command_exists "$cmd"; then
        error "Required command '$cmd' not found. Please install it and try again."
        exit 1
    fi
done

# Handle clean script termination
trap 'echo -e "\n${CYAN}Script terminated by user${NC}"; exit 0' INT

# Display initial header
clear
echo -e "${BOLD}${CYAN}===== System Monitor =====${NC}"
echo -e "${CYAN}Press Ctrl+C to exit${NC}\n"

# Main monitoring loop
while true; do
    # Get and display timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${BOLD}Last Updated: ${TIMESTAMP}${NC}\n"
    
    # Display system information
    show_uptime_info
    show_memory_info
    show_cpu_info
    show_disk_info
    show_fan_info
    show_temperature_info
    
    # Wait for the specified interval
    sleep "$INTERVAL"
    
    # Clear screen for next update
    clear
    echo -e "${BOLD}${CYAN}===== System Monitor =====${NC}"
    echo -e "${CYAN}Press Ctrl+C to exit${NC}\n"
done
