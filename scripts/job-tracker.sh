#!/bin/bash
################################################################################
# Job Hunting Tracker - Interactive Job Management Script
# Secure bash implementation with Excel integration
################################################################################

# Security hardening (set -euo pipefail is mandatory)
set -euo pipefail

# Set secure umask (user only)
umask 0077

# Error handling trap
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DATA_DIR="${SCRIPT_DIR}/data"
readonly JOBS_FILE="${DATA_DIR}/jobs.csv"
readonly EXCEL_SCRIPT="${SCRIPT_DIR}/scripts/generate-excel.vbs"
readonly LOG_FILE="${DATA_DIR}/tracker.log"

################################################################################
# Logging Function
################################################################################
log_action() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

################################################################################
# Data Directory Initialization
################################################################################
init_data_directory() {
    # Create data directory with secure permissions
    if [[ ! -d "$DATA_DIR" ]]; then
        mkdir -p "$DATA_DIR"
        chmod 700 "$DATA_DIR"
        log_action "Created data directory: $DATA_DIR"
    fi

    # Initialize CSV file with headers if it doesn't exist
    if [[ ! -f "$JOBS_FILE" ]]; then
        echo "ID,Job Name,Title,Company,Status,Date Added,Last Updated,Notes" > "$JOBS_FILE"
        chmod 600 "$JOBS_FILE"
        log_action "Created jobs database: $JOBS_FILE"
    fi

    # Initialize log file
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
        chmod 600 "$LOG_FILE"
    fi
}

################################################################################
# Input Validation Functions
################################################################################

# Validate non-empty string
validate_required_input() {
    local input="$1"
    local field_name="$2"

    if [[ -z "$input" ]]; then
        echo "Error: $field_name cannot be empty" >&2
        return 1
    fi
    return 0
}

# Validate against allowed values
validate_status() {
    local status="$1"

    case "$status" in
        1|Pending)
            echo "Pending"
            return 0
            ;;
        2|Rejected)
            echo "Rejected"
            return 0
            ;;
        3|Approved)
            echo "Approved"
            return 0
            ;;
        *)
            echo "Error: Invalid status. Choose: 1=Pending, 2=Rejected, 3=Approved" >&2
            return 1
            ;;
    esac
}

# Sanitize input (alphanumeric, spaces, common punctuation)
sanitize_input() {
    local input="$1"
    # Remove leading/trailing whitespace
    input="${input#"${input%%[![:space:]]*}"}"
    input="${input%"${input##*[![:space:]]}"}"
    echo "$input"
}

# Get next available ID
get_next_id() {
    local max_id=0
    local line_count
    line_count=$(wc -l < "$JOBS_FILE")
    
    if (( line_count > 1 )); then
        # Skip header, find max ID
        max_id=$(tail -n +2 "$JOBS_FILE" | cut -d',' -f1 | sort -n | tail -1)
    fi
    
    echo $((max_id + 1))
}

################################################################################
# Menu Functions
################################################################################

# Display main menu
show_main_menu() {
    clear
    echo "================================"
    echo "  Job Hunting Tracker"
    echo "================================"
    echo "1. Add new job"
    echo "2. View all jobs"
    echo "3. Update job status"
    echo "4. Delete job"
    echo "5. Generate Excel report"
    echo "6. Exit"
    echo "================================"
}

# Display status menu
show_status_menu() {
    echo ""
    echo "Select Status:"
    echo "  1. Pending"
    echo "  2. Rejected"
    echo "  3. Approved"
    echo ""
}

################################################################################
# Add Job Function
################################################################################
add_job() {
    echo ""
    echo "--- Add New Job ---"
    
    # Get and validate job name
    read -rp "Enter job name: " job_name
    job_name=$(sanitize_input "$job_name")
    validate_required_input "$job_name" "Job name" || return 1
    
    # Get and validate job title
    read -rp "Enter job title: " job_title
    job_title=$(sanitize_input "$job_title")
    validate_required_input "$job_title" "Job title" || return 1
    
    # Get company name
    read -rp "Enter company name (optional): " company
    company=$(sanitize_input "$company")
    
    # Get and validate status
    show_status_menu
    read -rp "Enter status (1-3): " status_choice
    local status
    status=$(validate_status "$status_choice") || return 1
    
    # Get notes
    read -rp "Enter notes (optional): " notes
    notes=$(sanitize_input "$notes")
    
    # Generate new ID and timestamps
    local id
    id=$(get_next_id)
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Append to CSV file
    echo "$id,\"$job_name\",\"$job_title\",\"$company\",$status,$timestamp,$timestamp,\"$notes\"" >> "$JOBS_FILE"
    
    log_action "Added job: ID=$id, Name=$job_name, Title=$job_title, Status=$status"
    echo "✓ Job added successfully (ID: $id)"
    
    # Auto-update Excel report
    echo ""
    auto_update_excel
}

################################################################################
# View Jobs Function
################################################################################
view_jobs() {
    echo ""
    echo "--- All Jobs ---"
    
    local line_count
    line_count=$(wc -l < "$JOBS_FILE")
    
    if (( line_count <= 1 )); then
        echo "No jobs found."
        return 0
    fi
    
    # Display header
    printf "%-4s %-20s %-25s %-20s %-10s\n" "ID" "Job Name" "Title" "Company" "Status"
    printf "%s\n" "$(printf '%.0s-' {1..79})"
    
    # Display jobs (skip header)
    tail -n +2 "$JOBS_FILE" | while IFS=',' read -r id job_name job_title company status rest; do
        # Remove quotes from fields
        job_name="${job_name%\"}"
        job_name="${job_name#\"}"
        job_title="${job_title%\"}"
        job_title="${job_title#\"}"
        company="${company%\"}"
        company="${company#\"}"
        
        printf "%-4s %-20s %-25s %-20s %-10s\n" "$id" "$job_name" "$job_title" "$company" "$status"
    done
}

################################################################################
# Update Job Status Function
################################################################################
update_job_status() {
    echo ""
    echo "--- Update Job Status ---"
    
    local line_count
    line_count=$(wc -l < "$JOBS_FILE")
    
    if (( line_count <= 1 )); then
        echo "No jobs found."
        return 0
    fi
    
    # Show current jobs
    view_jobs
    
    # Get job ID to update
    echo ""
    read -rp "Enter Job ID to update: " job_id
    job_id=$(sanitize_input "$job_id")
    validate_required_input "$job_id" "Job ID" || return 1
    
    # Validate job ID exists
    if ! grep -q "^${job_id}," "$JOBS_FILE"; then
        echo "Error: Job ID $job_id not found" >&2
        return 1
    fi
    
    # Get new status
    show_status_menu
    read -rp "Enter new status (1-3): " status_choice
    local new_status
    new_status=$(validate_status "$status_choice") || return 1
    
    # Update timestamp
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create temporary file for update
    local tmpfile
    tmpfile=$(mktemp)
    trap "rm -f '$tmpfile'" EXIT
    
    # Update the job record
    while IFS=',' read -r id rest; do
        if [[ "$id" == "$job_id" ]]; then
            # Parse the existing record
            IFS=',' read -r id job_name job_title company old_status date_added rest <<< "$id,$rest"
            echo "$id,$job_name,$job_title,$company,$new_status,$date_added,$timestamp,$rest" >> "$tmpfile"
        else
            echo "$id,$rest" >> "$tmpfile"
        fi
    done < "$JOBS_FILE"
    
    # Replace original file
    mv "$tmpfile" "$JOBS_FILE"
    log_action "Updated Job ID=$job_id to Status=$new_status"
    echo "✓ Job status updated successfully"
    
    # Auto-update Excel report
    echo ""
    auto_update_excel
}

################################################################################
# Delete Job Function
################################################################################
delete_job() {
    echo ""
    echo "--- Delete Job ---"
    
    local line_count
    line_count=$(wc -l < "$JOBS_FILE")
    
    if (( line_count <= 1 )); then
        echo "No jobs found."
        return 0
    fi
    
    # Show current jobs
    view_jobs
    
    # Get job ID to delete
    echo ""
    read -rp "Enter Job ID to delete: " job_id
    job_id=$(sanitize_input "$job_id")
    validate_required_input "$job_id" "Job ID" || return 1
    
    # Confirm deletion
    read -rp "Are you sure you want to delete Job ID $job_id? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Deletion cancelled."
        return 0
    fi
    
    # Validate job ID exists
    if ! grep -q "^${job_id}," "$JOBS_FILE"; then
        echo "Error: Job ID $job_id not found" >&2
        return 1
    fi
    
    # Delete the job (keep header, remove matching line)
    local tmpfile
    tmpfile=$(mktemp)
    trap "rm -f '$tmpfile'" EXIT
    
    head -1 "$JOBS_FILE" > "$tmpfile"
    grep -v "^${job_id}," "$JOBS_FILE" >> "$tmpfile" || true
    
    mv "$tmpfile" "$JOBS_FILE"
    log_action "Deleted Job ID=$job_id"
    echo "✓ Job deleted successfully"
    
    # Auto-update Excel report
    echo ""
    auto_update_excel
}

################################################################################
# Auto-Update Excel Report Function (Silent)
################################################################################
auto_update_excel() {
    # Check if VBS script exists
    if [[ ! -f "$EXCEL_SCRIPT" ]]; then
        log_action "WARNING: Excel generation script not found"
        return 1
    fi
    
    # Check if there are any jobs
    local line_count
    line_count=$(wc -l < "$JOBS_FILE")
    
    if (( line_count <= 1 )); then
        return 0
    fi
    
    # Generate the Excel file using VBS (silent mode, no prompts)
    local excel_output="${DATA_DIR}/Job_Tracker.xlsx"
    
    if cscript.exe "$EXCEL_SCRIPT" "$JOBS_FILE" "$excel_output" 2>/dev/null; then
        log_action "Auto-updated Excel report: $excel_output"
        echo "✓ Excel report updated automatically"
    else
        log_action "WARNING: Failed to auto-update Excel report"
        return 1
    fi
}

################################################################################
# Generate Excel Report Function (Manual with options)
################################################################################
generate_excel_report() {
    echo ""
    echo "--- Generate Excel Report ---"
    
    # Check if VBS script exists
    if [[ ! -f "$EXCEL_SCRIPT" ]]; then
        echo "Error: Excel generation script not found at $EXCEL_SCRIPT" >&2
        log_action "ERROR: Excel script not found"
        return 1
    fi
    
    # Check if there are any jobs
    local line_count
    line_count=$(wc -l < "$JOBS_FILE")
    
    if (( line_count <= 1 )); then
        echo "No jobs found. Cannot generate report."
        return 0
    fi
    
    # Generate the Excel file using VBS
    local excel_output="${DATA_DIR}/Job_Tracker_$(date +%Y%m%d_%H%M%S).xlsx"
    
    echo "Generating Excel report: $excel_output"
    
    # Call VBS script with CSV file path
    if cscript.exe "$EXCEL_SCRIPT" "$JOBS_FILE" "$excel_output" 2>/dev/null; then
        log_action "Generated Excel report: $excel_output"
        echo "✓ Excel report generated successfully"
        echo "Report saved to: $excel_output"
        
        # Optionally open the Excel file
        read -rp "Open report in Excel? (y/n): " open_excel
        if [[ "$open_excel" == "y" || "$open_excel" == "Y" ]]; then
            start "" "$excel_output" || true
        fi
    else
        echo "Error: Failed to generate Excel report" >&2
        log_action "ERROR: Failed to generate Excel report"
        return 1
    fi
}

################################################################################
# Main Loop
################################################################################
main() {
    init_data_directory
    log_action "Script started"
    
    while true; do
        show_main_menu
        
        read -rp "Enter your choice (1-6): " choice
        choice=$(sanitize_input "$choice")
        
        case "$choice" in
            1)
                add_job
                ;;
            2)
                view_jobs
                ;;
            3)
                update_job_status
                ;;
            4)
                delete_job
                ;;
            5)
                generate_excel_report
                ;;
            6)
                log_action "Script ended normally"
                echo "Thank you for using Job Hunting Tracker!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
        
        read -rp "Press Enter to continue..."
    done
}

# Execute main function
main "$@"
