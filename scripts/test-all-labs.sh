#!/bin/bash
# test-all-labs.sh - Master test runner for containerlab-free-labs
#
# Usage:
#   ./scripts/test-all-labs.sh              # Run all 6 labs
#   ./scripts/test-all-labs.sh --quick      # Skip enterprise-vpn (resource-heavy)
#   ./scripts/test-all-labs.sh --lab NAME   # Run specific lab
#   ./scripts/test-all-labs.sh --json FILE  # Custom JSON output path

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Lab definitions: name:type:wait_seconds
declare -A LAB_CONFIG=(
    ["ospf-basics"]="containerlab:60"
    ["bgp-ebgp-basics"]="containerlab:60"
    ["linux-network-namespaces"]="containerlab:30"
    ["vyos-firewall-basics"]="containerlab:60"
    ["enterprise-vpn-migration"]="containerlab:90"
    ["zero-trust-fundamentals"]="docker-compose:30"
)

# Default lab order (all labs)
LAB_ORDER=(
    "ospf-basics"
    "bgp-ebgp-basics"
    "linux-network-namespaces"
    "vyos-firewall-basics"
    "enterprise-vpn-migration"
    "zero-trust-fundamentals"
)

# Quick mode labs (skip heavy ones)
QUICK_LABS=(
    "ospf-basics"
    "bgp-ebgp-basics"
    "linux-network-namespaces"
    "vyos-firewall-basics"
    "zero-trust-fundamentals"
)

# Results tracking
declare -A LAB_RESULTS
declare -A LAB_DURATION
declare -A LAB_TESTS_PASSED
declare -A LAB_TESTS_FAILED
declare -A LAB_ERROR
TOTAL_PASSED=0
TOTAL_FAILED=0
START_TIME=$(date +%s)
JSON_OUTPUT="$REPO_ROOT/test-results.json"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments
SELECTED_LABS=()
SINGLE_LAB=""
QUICK_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --lab)
            SINGLE_LAB="$2"
            shift 2
            ;;
        --json)
            JSON_OUTPUT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --quick       Skip enterprise-vpn lab (resource-heavy)"
            echo "  --lab NAME    Run specific lab only"
            echo "  --json FILE   Output JSON report to FILE (default: test-results.json)"
            echo "  --help        Show this help"
            echo ""
            echo "Available labs:"
            for lab in "${LAB_ORDER[@]}"; do
                echo "  - $lab"
            done
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Determine which labs to run
if [[ -n "$SINGLE_LAB" ]]; then
    if [[ -z "${LAB_CONFIG[$SINGLE_LAB]:-}" ]]; then
        echo -e "${RED}Error: Unknown lab '$SINGLE_LAB'${NC}"
        exit 1
    fi
    SELECTED_LABS=("$SINGLE_LAB")
elif [[ "$QUICK_MODE" == true ]]; then
    SELECTED_LABS=("${QUICK_LABS[@]}")
else
    SELECTED_LABS=("${LAB_ORDER[@]}")
fi

print_header() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

print_subheader() {
    echo -e "${CYAN}--- $1 ---${NC}"
}

cleanup_containerlab() {
    local lab_name=$1
    local lab_dir="$REPO_ROOT/$lab_name"

    if [[ -f "$lab_dir/topology.clab.yml" ]]; then
        echo -e "${YELLOW}Cleaning up $lab_name...${NC}"
        cd "$lab_dir"
        sudo containerlab destroy -t topology.clab.yml --cleanup 2>/dev/null || true
    fi
    cd "$REPO_ROOT"
}

cleanup_docker_compose() {
    local lab_name=$1
    local lab_dir="$REPO_ROOT/$lab_name"

    if [[ -f "$lab_dir/docker-compose.yml" ]]; then
        echo -e "${YELLOW}Cleaning up $lab_name...${NC}"
        cd "$lab_dir"
        docker-compose down -v 2>/dev/null || true
    fi
    cd "$REPO_ROOT"
}

run_containerlab_test() {
    local lab_name=$1
    local wait_time=$2
    local lab_dir="$REPO_ROOT/$lab_name"

    cd "$lab_dir"

    # Deploy
    print_subheader "Deploying topology"
    if ! sudo containerlab deploy -t topology.clab.yml; then
        LAB_ERROR[$lab_name]="Failed to deploy topology"
        return 1
    fi

    # Wait for convergence
    print_subheader "Waiting ${wait_time}s for convergence"
    sleep "$wait_time"

    # Validate
    print_subheader "Running validation tests"
    local output
    local result=0

    if [[ -x "$lab_dir/scripts/validate.sh" ]]; then
        output=$(sudo bash "$lab_dir/scripts/validate.sh" 2>&1) || result=1
        echo "$output"

        # Parse test results from output
        local passed=$(echo "$output" | grep -oP 'Tests Passed: \K\d+' || echo "0")
        local failed=$(echo "$output" | grep -oP 'Tests Failed: \K\d+' || echo "0")
        LAB_TESTS_PASSED[$lab_name]="${passed:-0}"
        LAB_TESTS_FAILED[$lab_name]="${failed:-0}"
    else
        LAB_ERROR[$lab_name]="validate.sh not found or not executable"
        result=1
    fi

    cd "$REPO_ROOT"
    return $result
}

run_docker_compose_test() {
    local lab_name=$1
    local wait_time=$2
    local lab_dir="$REPO_ROOT/$lab_name"

    cd "$lab_dir"

    # Deploy
    print_subheader "Starting services with docker-compose"
    if ! docker-compose up -d --build; then
        LAB_ERROR[$lab_name]="Failed to start docker-compose services"
        return 1
    fi

    # Wait for services
    print_subheader "Waiting ${wait_time}s for services"
    sleep "$wait_time"

    # Validate
    print_subheader "Running validation tests"
    local output
    local result=0

    if [[ -x "$lab_dir/scripts/validate.sh" ]]; then
        output=$(bash "$lab_dir/scripts/validate.sh" 2>&1) || result=1
        echo "$output"

        # Parse test results from output
        local passed=$(echo "$output" | grep -oP 'Tests Passed: \K\d+' || echo "0")
        local failed=$(echo "$output" | grep -oP 'Tests Failed: \K\d+' || echo "0")
        LAB_TESTS_PASSED[$lab_name]="${passed:-0}"
        LAB_TESTS_FAILED[$lab_name]="${failed:-0}"
    else
        LAB_ERROR[$lab_name]="validate.sh not found or not executable"
        result=1
    fi

    cd "$REPO_ROOT"
    return $result
}

generate_json_report() {
    local output_file=$1
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))
    local run_id=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local environment="${CODESPACES:-local}"

    # Start JSON
    cat > "$output_file" << EOF
{
  "run_id": "$run_id",
  "environment": "$environment",
  "total_labs": ${#SELECTED_LABS[@]},
  "passed_labs": $TOTAL_PASSED,
  "failed_labs": $TOTAL_FAILED,
  "total_duration_seconds": $total_duration,
  "labs": [
EOF

    local first=true
    for lab in "${SELECTED_LABS[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            echo "," >> "$output_file"
        fi

        local status="${LAB_RESULTS[$lab]:-skipped}"
        local duration="${LAB_DURATION[$lab]:-0}"
        local tests_passed="${LAB_TESTS_PASSED[$lab]:-0}"
        local tests_failed="${LAB_TESTS_FAILED[$lab]:-0}"
        local error="${LAB_ERROR[$lab]:-}"
        local lab_type
        IFS=':' read -r lab_type _ <<< "${LAB_CONFIG[$lab]}"

        # Escape error message for JSON
        error=$(echo "$error" | sed 's/"/\\"/g' | tr '\n' ' ')

        cat >> "$output_file" << EOF
    {
      "name": "$lab",
      "type": "$lab_type",
      "status": "$status",
      "tests_passed": $tests_passed,
      "tests_failed": $tests_failed,
      "duration_seconds": $duration,
      "error": $(if [[ -n "$error" ]]; then echo "\"$error\""; else echo "null"; fi)
    }
EOF
    done

    cat >> "$output_file" << EOF

  ]
}
EOF
}

# Main execution
main() {
    print_header "Containerlab Labs Test Suite"
    echo ""
    echo -e "Labs to test: ${#SELECTED_LABS[@]}"
    echo -e "JSON output:  $JSON_OUTPUT"
    if [[ "$QUICK_MODE" == true ]]; then
        echo -e "Mode:         ${YELLOW}Quick (skipping enterprise-vpn)${NC}"
    fi
    echo ""

    # Pre-flight: Build frr-ssh image if needed
    local needs_frr=false
    for lab in "${SELECTED_LABS[@]}"; do
        if [[ "$lab" == "ospf-basics" || "$lab" == "bgp-ebgp-basics" || "$lab" == "enterprise-vpn-migration" ]]; then
            needs_frr=true
            break
        fi
    done

    if [[ "$needs_frr" == true ]]; then
        print_subheader "Building frr-ssh image"
        bash "$REPO_ROOT/build-frr-ssh.sh"
    fi

    # Run each lab
    for lab in "${SELECTED_LABS[@]}"; do
        print_header "Testing: $lab"

        local lab_type wait_time
        IFS=':' read -r lab_type wait_time <<< "${LAB_CONFIG[$lab]}"

        local lab_start=$(date +%s)

        # Cleanup any existing state
        if [[ "$lab_type" == "containerlab" ]]; then
            cleanup_containerlab "$lab"
        else
            cleanup_docker_compose "$lab"
        fi

        # Run test
        local result=0
        if [[ "$lab_type" == "containerlab" ]]; then
            run_containerlab_test "$lab" "$wait_time" || result=1
        else
            run_docker_compose_test "$lab" "$wait_time" || result=1
        fi

        local lab_end=$(date +%s)
        LAB_DURATION[$lab]=$((lab_end - lab_start))

        # Record result
        if [[ $result -eq 0 ]]; then
            LAB_RESULTS[$lab]="passed"
            ((TOTAL_PASSED++))
            echo ""
            echo -e "${GREEN}>>> $lab PASSED (${LAB_DURATION[$lab]}s)${NC}"
        else
            LAB_RESULTS[$lab]="failed"
            ((TOTAL_FAILED++))
            echo ""
            echo -e "${RED}>>> $lab FAILED (${LAB_DURATION[$lab]}s)${NC}"
        fi

        # Cleanup
        if [[ "$lab_type" == "containerlab" ]]; then
            cleanup_containerlab "$lab"
        else
            cleanup_docker_compose "$lab"
        fi
    done

    # Generate JSON report
    generate_json_report "$JSON_OUTPUT"

    # Summary
    print_header "Test Summary"
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))

    echo ""
    printf "%-30s %s\n" "Lab" "Status"
    printf "%-30s %s\n" "---" "------"
    for lab in "${SELECTED_LABS[@]}"; do
        local status="${LAB_RESULTS[$lab]:-skipped}"
        local duration="${LAB_DURATION[$lab]:-0}"
        if [[ "$status" == "passed" ]]; then
            printf "%-30s ${GREEN}%s${NC} (%ss)\n" "$lab" "PASSED" "$duration"
        else
            printf "%-30s ${RED}%s${NC} (%ss)\n" "$lab" "FAILED" "$duration"
        fi
    done

    echo ""
    echo "----------------------------------------"
    echo -e "Total:   ${#SELECTED_LABS[@]} labs"
    echo -e "Passed:  ${GREEN}$TOTAL_PASSED${NC}"
    echo -e "Failed:  ${RED}$TOTAL_FAILED${NC}"
    echo -e "Time:    ${total_duration}s"
    echo -e "Report:  $JSON_OUTPUT"
    echo ""

    if [[ $TOTAL_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All labs passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some labs failed.${NC}"
        exit 1
    fi
}

main "$@"
