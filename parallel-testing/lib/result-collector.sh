#!/bin/bash

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Global variables for result collection
RESULTS_DIR=""
CURRENT_LAB=""
CURRENT_LAB_RESULTS=""
LAB_START_TIME=""
EXERCISE_RESULTS=()

# Initialize results directory
# Usage: init_results [output_dir]
init_results() {
    local output_dir="${1:-results}"
    local timestamp=$(get_file_timestamp)

    RESULTS_DIR="${output_dir}/run-${timestamp}"

    mkdir -p "$RESULTS_DIR"

    if [ ! -d "$RESULTS_DIR" ]; then
        log_error "Failed to create results directory: $RESULTS_DIR"
        return 1
    fi

    log_success "Results directory initialized: $RESULTS_DIR"

    # Create metadata file
    cat > "${RESULTS_DIR}/metadata.json" <<EOF
{
  "test_run_id": "run-${timestamp}",
  "start_time": "$(get_timestamp)",
  "runner": "$(whoami)@$(hostname)",
  "working_dir": "$(pwd)"
}
EOF

    return 0
}

# Start lab result collection
# Usage: start_lab_results <lab_name>
start_lab_results() {
    local lab_name="$1"

    if [ -z "$lab_name" ]; then
        log_error "Lab name required for start_lab_results"
        return 1
    fi

    CURRENT_LAB="$lab_name"
    LAB_START_TIME=$(get_timestamp)
    EXERCISE_RESULTS=()

    log_info "Started result collection for lab: $lab_name"
    return 0
}

# Add exercise result
# Usage: add_exercise_result <exercise_name> <status> <message> [details]
# status: "passed", "failed", "skipped"
add_exercise_result() {
    local exercise_name="$1"
    local status="$2"
    local message="$3"
    local details="${4:-}"

    if [ -z "$exercise_name" ] || [ -z "$status" ]; then
        log_error "Exercise name and status required for add_exercise_result"
        return 1
    fi

    # Escape quotes in message and details for JSON
    message=$(echo "$message" | sed 's/"/\\"/g' | sed "s/'/\\'/g")
    details=$(echo "$details" | sed 's/"/\\"/g' | sed "s/'/\\'/g")

    # Create exercise result JSON object
    local exercise_json=$(cat <<EOF
{
  "exercise": "$exercise_name",
  "status": "$status",
  "message": "$message",
  "details": "$details",
  "timestamp": "$(get_timestamp)"
}
EOF
)

    EXERCISE_RESULTS+=("$exercise_json")

    case "$status" in
        passed)
            log_success "Exercise '$exercise_name': PASSED"
            ;;
        failed)
            log_error "Exercise '$exercise_name': FAILED - $message"
            ;;
        skipped)
            log_warn "Exercise '$exercise_name': SKIPPED - $message"
            ;;
        *)
            log_warn "Exercise '$exercise_name': $status - $message"
            ;;
    esac

    return 0
}

# Finalize lab results and write JSON file
# Usage: finalize_lab_results
finalize_lab_results() {
    if [ -z "$CURRENT_LAB" ]; then
        log_error "No active lab for finalize_lab_results"
        return 1
    fi

    if [ -z "$RESULTS_DIR" ]; then
        log_error "Results directory not initialized"
        return 1
    fi

    local lab_end_time=$(get_timestamp)
    local lab_file="${RESULTS_DIR}/${CURRENT_LAB}.json"

    # Count passed, failed, skipped
    local passed_count=0
    local failed_count=0
    local skipped_count=0
    local total_count=${#EXERCISE_RESULTS[@]}

    for result in "${EXERCISE_RESULTS[@]}"; do
        if echo "$result" | grep -q '"status": "passed"'; then
            passed_count=$((passed_count + 1))
        elif echo "$result" | grep -q '"status": "failed"'; then
            failed_count=$((failed_count + 1))
        elif echo "$result" | grep -q '"status": "skipped"'; then
            skipped_count=$((skipped_count + 1))
        fi
    done

    # Calculate duration
    local duration=$(calculate_duration "$LAB_START_TIME" "$lab_end_time")

    # Determine overall status
    local overall_status="passed"
    if [ $failed_count -gt 0 ]; then
        overall_status="failed"
    elif [ $total_count -eq 0 ]; then
        overall_status="no_tests"
    elif [ $passed_count -eq 0 ] && [ $skipped_count -gt 0 ]; then
        overall_status="all_skipped"
    fi

    # Build exercises JSON array
    local exercises_json=""
    if [ ${#EXERCISE_RESULTS[@]} -gt 0 ]; then
        exercises_json=$(printf ",\n    %s" "${EXERCISE_RESULTS[@]}")
        exercises_json="${exercises_json:1}" # Remove leading comma
    fi

    # Write lab results file
    cat > "$lab_file" <<EOF
{
  "lab_name": "$CURRENT_LAB",
  "start_time": "$LAB_START_TIME",
  "end_time": "$lab_end_time",
  "duration_seconds": $duration,
  "overall_status": "$overall_status",
  "summary": {
    "total": $total_count,
    "passed": $passed_count,
    "failed": $failed_count,
    "skipped": $skipped_count
  },
  "exercises": [
    $exercises_json
  ]
}
EOF

    log_success "Lab results written to: $lab_file"
    log_info "Summary: $passed_count passed, $failed_count failed, $skipped_count skipped (${duration}s)"

    # Reset for next lab
    CURRENT_LAB=""
    EXERCISE_RESULTS=()
    LAB_START_TIME=""

    return 0
}

# Generate summary report aggregating all lab results
# Usage: generate_summary
generate_summary() {
    if [ -z "$RESULTS_DIR" ]; then
        log_error "Results directory not initialized"
        return 1
    fi

    local summary_file="${RESULTS_DIR}/summary.json"
    local end_time=$(get_timestamp)

    # Read metadata
    local start_time=$(grep '"start_time"' "${RESULTS_DIR}/metadata.json" | cut -d'"' -f4)
    local total_duration=$(calculate_duration "$start_time" "$end_time")

    # Aggregate stats from all lab result files
    local total_labs=0
    local passed_labs=0
    local failed_labs=0
    local total_exercises=0
    local passed_exercises=0
    local failed_exercises=0
    local skipped_exercises=0

    local lab_summaries=""

    for lab_file in "${RESULTS_DIR}"/*.json; do
        # Skip metadata and summary files
        if [[ "$lab_file" == *"metadata.json"* ]] || [[ "$lab_file" == *"summary.json"* ]]; then
            continue
        fi

        if [ -f "$lab_file" ]; then
            total_labs=$((total_labs + 1))

            # Extract stats using grep and cut (simple JSON parsing)
            local lab_status=$(grep '"overall_status"' "$lab_file" | cut -d'"' -f4)
            local lab_total=$(grep '"total"' "$lab_file" | head -1 | grep -o '[0-9]\+')
            local lab_passed=$(grep '"passed"' "$lab_file" | head -1 | grep -o '[0-9]\+')
            local lab_failed=$(grep '"failed"' "$lab_file" | head -1 | grep -o '[0-9]\+')
            local lab_skipped=$(grep '"skipped"' "$lab_file" | head -1 | grep -o '[0-9]\+')
            local lab_name=$(basename "$lab_file" .json)

            if [ "$lab_status" = "passed" ]; then
                passed_labs=$((passed_labs + 1))
            else
                failed_labs=$((failed_labs + 1))
            fi

            total_exercises=$((total_exercises + lab_total))
            passed_exercises=$((passed_exercises + lab_passed))
            failed_exercises=$((failed_exercises + lab_failed))
            skipped_exercises=$((skipped_exercises + lab_skipped))

            # Add to lab summaries
            local lab_summary=$(cat <<EOF
    {
      "lab_name": "$lab_name",
      "status": "$lab_status",
      "total": $lab_total,
      "passed": $lab_passed,
      "failed": $lab_failed,
      "skipped": $lab_skipped
    }
EOF
)

            if [ -n "$lab_summaries" ]; then
                lab_summaries="${lab_summaries},\n${lab_summary}"
            else
                lab_summaries="$lab_summary"
            fi
        fi
    done

    # Determine overall test run status
    local overall_status="passed"
    if [ $failed_labs -gt 0 ] || [ $failed_exercises -gt 0 ]; then
        overall_status="failed"
    elif [ $total_labs -eq 0 ]; then
        overall_status="no_labs"
    fi

    # Write summary file
    cat > "$summary_file" <<EOF
{
  "test_run_summary": {
    "start_time": "$start_time",
    "end_time": "$end_time",
    "duration_seconds": $total_duration,
    "overall_status": "$overall_status"
  },
  "lab_summary": {
    "total_labs": $total_labs,
    "passed_labs": $passed_labs,
    "failed_labs": $failed_labs
  },
  "exercise_summary": {
    "total_exercises": $total_exercises,
    "passed_exercises": $passed_exercises,
    "failed_exercises": $failed_exercises,
    "skipped_exercises": $skipped_exercises
  },
  "labs": [
$(echo -e "$lab_summaries")
  ]
}
EOF

    log_success "Summary report written to: $summary_file"
    echo ""
    log_info "========================================="
    log_info "TEST RUN SUMMARY"
    log_info "========================================="
    log_info "Labs: $passed_labs/$total_labs passed"
    log_info "Exercises: $passed_exercises/$total_exercises passed"
    if [ $failed_exercises -gt 0 ]; then
        log_error "Failed exercises: $failed_exercises"
    fi
    if [ $skipped_exercises -gt 0 ]; then
        log_warn "Skipped exercises: $skipped_exercises"
    fi
    log_info "Duration: ${total_duration}s"
    log_info "Status: $overall_status"
    log_info "========================================="

    return 0
}

# Quick test result helpers
pass_test() {
    local test_name="$1"
    local message="${2:-Test passed}"
    add_exercise_result "$test_name" "passed" "$message"
}

fail_test() {
    local test_name="$1"
    local message="${2:-Test failed}"
    local details="${3:-}"
    add_exercise_result "$test_name" "failed" "$message" "$details"
}

skip_test() {
    local test_name="$1"
    local message="${2:-Test skipped}"
    add_exercise_result "$test_name" "skipped" "$message"
}
