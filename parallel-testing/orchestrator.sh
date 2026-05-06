#!/bin/bash
#############################################################################
# Parallel Testing Orchestrator
#############################################################################
#
# Purpose: Deploy all labs in parallel, run student exercise tests, and
#          collect results.
#
# Usage: ./orchestrator.sh [options]
#   --labs <list|all>     Labs to test (comma-separated or 'all')
#   --parallel-limit <n>  Max concurrent labs (default: 3)
#   --skip-deploy         Skip deployment, run tests on existing labs
#   --skip-cleanup        Skip cleanup after tests
#
#############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common libraries
source "$SCRIPT_DIR/lib/common.sh"

# Configuration
ALL_LABS=(
    "ospf-basics"
    "bgp-ebgp-basics"
    "linux-network-namespaces"
    "vyos-firewall-basics"
    "enterprise-vpn-migration"
    "zero-trust-fundamentals"
)

# Wait times for protocol convergence (seconds)
declare -A WAIT_TIMES=(
    ["ospf-basics"]=60
    ["bgp-ebgp-basics"]=60
    ["linux-network-namespaces"]=30
    ["vyos-firewall-basics"]=60
    ["enterprise-vpn-migration"]=90
    ["zero-trust-fundamentals"]=30
)

# Parse arguments
LABS_TO_TEST=("${ALL_LABS[@]}")
PARALLEL_LIMIT=3
SKIP_DEPLOY=false
SKIP_CLEANUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --labs)
            if [[ "$2" == "all" ]]; then
                LABS_TO_TEST=("${ALL_LABS[@]}")
            else
                IFS=',' read -ra LABS_TO_TEST <<< "$2"
            fi
            shift 2
            ;;
        --parallel-limit)
            PARALLEL_LIMIT="$2"
            shift 2
            ;;
        --skip-deploy)
            SKIP_DEPLOY=true
            shift
            ;;
        --skip-cleanup)
            SKIP_CLEANUP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Results directory
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
RESULTS_DIR="$SCRIPT_DIR/results/run-$TIMESTAMP"
mkdir -p "$RESULTS_DIR"

#############################################################################
# Pre-flight Checks
#############################################################################

preflight_checks() {
    log_info "Running pre-flight checks..."

    # Check Docker
    if ! command -v docker &>/dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    if ! docker info &>/dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    log_success "Docker is available"

    # Check containerlab
    if ! command -v containerlab &>/dev/null; then
        log_error "containerlab is not installed"
        exit 1
    fi
    log_success "containerlab is available"

    # Check available memory
    local total_mem=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "4096")
    if [[ "$total_mem" -lt 3500 ]]; then
        log_warn "Low memory detected: ${total_mem}MB (recommend 4GB+)"
    else
        log_success "Memory check: ${total_mem}MB available"
    fi

    echo ""
}

#############################################################################
# Build FRR-SSH Image
#############################################################################

build_frr_image() {
    log_info "Checking frr-ssh Docker image..."

    if docker images | grep -q "frr-ssh"; then
        log_success "frr-ssh image already exists"
    else
        log_info "Building frr-ssh image..."
        cd "$REPO_ROOT"
        if [[ -f "build-frr-ssh.sh" ]]; then
            ./build-frr-ssh.sh
            log_success "frr-ssh image built successfully"
        else
            log_warn "build-frr-ssh.sh not found, some labs may fail"
        fi
    fi
    echo ""
}

#############################################################################
# Deploy Single Lab
#############################################################################

deploy_lab() {
    local lab="$1"
    local lab_dir="$REPO_ROOT/$lab"
    local log_file="$RESULTS_DIR/${lab}-deploy.log"

    if [[ ! -d "$lab_dir" ]]; then
        log_error "Lab directory not found: $lab_dir"
        return 1
    fi

    log_info "Deploying $lab..."

    cd "$lab_dir"

    # Find topology file
    local topo_file=""
    if [[ -f "topology.clab.yml" ]]; then
        topo_file="topology.clab.yml"
    elif [[ -f "docker-compose.yml" ]]; then
        # Zero-trust uses docker-compose
        docker-compose up -d &>"$log_file"
        log_success "$lab deployed (docker-compose)"
        return 0
    else
        log_error "No topology file found for $lab"
        return 1
    fi

    # Deploy with containerlab
    sudo containerlab deploy -t "$topo_file" --reconfigure &>"$log_file" 2>&1 || {
        log_error "$lab deployment failed (see $log_file)"
        return 1
    }

    log_success "$lab deployed successfully"
    return 0
}

#############################################################################
# Deploy Labs in Batches
#############################################################################

deploy_labs_parallel() {
    log_info "Deploying ${#LABS_TO_TEST[@]} labs (parallel limit: $PARALLEL_LIMIT)..."
    echo ""

    local batch=()
    local batch_num=1

    for lab in "${LABS_TO_TEST[@]}"; do
        batch+=("$lab")

        if [[ ${#batch[@]} -ge $PARALLEL_LIMIT ]]; then
            log_info "Batch $batch_num: ${batch[*]}"

            # Deploy batch in parallel
            local pids=()
            for b_lab in "${batch[@]}"; do
                deploy_lab "$b_lab" &
                pids+=($!)
            done

            # Wait for batch to complete
            for pid in "${pids[@]}"; do
                wait $pid || true
            done

            batch=()
            ((batch_num++))
        fi
    done

    # Deploy remaining labs
    if [[ ${#batch[@]} -gt 0 ]]; then
        log_info "Batch $batch_num: ${batch[*]}"

        local pids=()
        for b_lab in "${batch[@]}"; do
            deploy_lab "$b_lab" &
            pids+=($!)
        done

        for pid in "${pids[@]}"; do
            wait $pid || true
        done
    fi

    echo ""
    log_success "All labs deployed"
    echo ""
}

#############################################################################
# Wait for Convergence
#############################################################################

wait_for_convergence() {
    # Find max wait time
    local max_wait=0
    for lab in "${LABS_TO_TEST[@]}"; do
        local wait_time=${WAIT_TIMES[$lab]:-60}
        if [[ $wait_time -gt $max_wait ]]; then
            max_wait=$wait_time
        fi
    done

    log_info "Waiting ${max_wait}s for protocol convergence..."

    local elapsed=0
    while [[ $elapsed -lt $max_wait ]]; do
        sleep 10
        elapsed=$((elapsed + 10))
        echo -ne "\r  Progress: ${elapsed}/${max_wait}s   "
    done
    echo ""

    log_success "Convergence wait complete"
    echo ""
}

#############################################################################
# Run Student Exercise Tests
#############################################################################

run_exercise_tests() {
    log_info "Running student exercise tests..."
    echo ""

    local test_pids=()

    for lab in "${LABS_TO_TEST[@]}"; do
        # Map lab name to test script
        local test_script=""
        case "$lab" in
            "ospf-basics")
                test_script="$SCRIPT_DIR/student-tests/ospf-basics-exercises.sh"
                ;;
            "bgp-ebgp-basics")
                test_script="$SCRIPT_DIR/student-tests/bgp-ebgp-basics-exercises.sh"
                ;;
            "linux-network-namespaces")
                test_script="$SCRIPT_DIR/student-tests/linux-namespaces-exercises.sh"
                ;;
            "vyos-firewall-basics")
                test_script="$SCRIPT_DIR/student-tests/vyos-firewall-exercises.sh"
                ;;
            "enterprise-vpn-migration")
                test_script="$SCRIPT_DIR/student-tests/enterprise-vpn-exercises.sh"
                ;;
            "zero-trust-fundamentals")
                test_script="$SCRIPT_DIR/student-tests/zero-trust-exercises.sh"
                ;;
        esac

        if [[ -x "$test_script" ]]; then
            log_info "Testing $lab..."
            (
                "$test_script" > "$RESULTS_DIR/${lab}-results.json" 2>"$RESULTS_DIR/${lab}-test.log"
            ) &
            test_pids+=($!)
        else
            log_warn "No test script for $lab"
        fi
    done

    # Wait for all tests
    log_info "Waiting for tests to complete..."
    for pid in "${test_pids[@]}"; do
        wait $pid || true
    done

    echo ""
    log_success "All tests completed"
    echo ""
}

#############################################################################
# Generate Summary Report
#############################################################################

generate_summary() {
    log_info "Generating summary report..."

    local total_labs=0
    local passed_labs=0
    local failed_labs=0
    local total_exercises=0
    local passed_exercises=0
    local failed_exercises=0

    local labs_json=""

    for lab in "${LABS_TO_TEST[@]}"; do
        local result_file="$RESULTS_DIR/${lab}-results.json"

        if [[ -f "$result_file" ]]; then
            ((total_labs++))

            # Parse results (handle different JSON formats from different scripts)
            local lab_passed=$(grep -o '"passed"[[:space:]]*:[[:space:]]*[0-9]*' "$result_file" | head -1 | grep -o '[0-9]*' || echo "0")
            local lab_failed=$(grep -o '"failed"[[:space:]]*:[[:space:]]*[0-9]*' "$result_file" | head -1 | grep -o '[0-9]*' || echo "0")
            local lab_total=$((lab_passed + lab_failed))

            total_exercises=$((total_exercises + lab_total))
            passed_exercises=$((passed_exercises + lab_passed))
            failed_exercises=$((failed_exercises + lab_failed))

            local lab_status="passed"
            if [[ $lab_failed -gt 0 ]]; then
                lab_status="failed"
                ((failed_labs++))
            else
                ((passed_labs++))
            fi

            if [[ -n "$labs_json" ]]; then
                labs_json="$labs_json,"
            fi
            labs_json="$labs_json
    {\"lab\": \"$lab\", \"status\": \"$lab_status\", \"passed\": $lab_passed, \"failed\": $lab_failed}"
        fi
    done

    # Write summary
    cat > "$RESULTS_DIR/summary.json" << EOF
{
  "test_run": "run-$TIMESTAMP",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "summary": {
    "total_labs": $total_labs,
    "passed_labs": $passed_labs,
    "failed_labs": $failed_labs,
    "total_exercises": $total_exercises,
    "passed_exercises": $passed_exercises,
    "failed_exercises": $failed_exercises
  },
  "labs": [$labs_json
  ]
}
EOF

    log_success "Summary written to: $RESULTS_DIR/summary.json"
    echo ""

    # Print summary
    echo "==========================================="
    echo "        STUDENT EXERCISE TEST SUMMARY"
    echo "==========================================="
    echo ""
    echo "Labs:      $passed_labs/$total_labs passed"
    echo "Exercises: $passed_exercises/$total_exercises passed"
    echo ""

    if [[ $failed_labs -gt 0 ]] || [[ $failed_exercises -gt 0 ]]; then
        log_error "Some tests failed"
        echo ""
        echo "Failed labs:"
        for lab in "${LABS_TO_TEST[@]}"; do
            local result_file="$RESULTS_DIR/${lab}-results.json"
            if [[ -f "$result_file" ]]; then
                local lab_failed=$(grep -o '"failed"[[:space:]]*:[[:space:]]*[0-9]*' "$result_file" | head -1 | grep -o '[0-9]*' || echo "0")
                if [[ $lab_failed -gt 0 ]]; then
                    echo "  - $lab ($lab_failed failed)"
                fi
            fi
        done
    else
        log_success "All tests passed!"
    fi

    echo ""
    echo "Results directory: $RESULTS_DIR"
    echo "==========================================="
}

#############################################################################
# Cleanup Labs
#############################################################################

cleanup_labs() {
    log_info "Cleaning up labs..."

    for lab in "${LABS_TO_TEST[@]}"; do
        local lab_dir="$REPO_ROOT/$lab"

        if [[ ! -d "$lab_dir" ]]; then
            continue
        fi

        cd "$lab_dir"

        if [[ -f "topology.clab.yml" ]]; then
            sudo containerlab destroy -t topology.clab.yml --cleanup &>/dev/null || true
            log_info "Cleaned up $lab"
        elif [[ -f "docker-compose.yml" ]]; then
            docker-compose down &>/dev/null || true
            log_info "Cleaned up $lab (docker-compose)"
        fi
    done

    echo ""
    log_success "Cleanup complete"
}

#############################################################################
# Main Execution
#############################################################################

main() {
    echo "==========================================="
    echo "   PARALLEL STUDENT EXERCISE TESTING"
    echo "==========================================="
    echo ""
    echo "Labs to test: ${LABS_TO_TEST[*]}"
    echo "Parallel limit: $PARALLEL_LIMIT"
    echo "Results: $RESULTS_DIR"
    echo ""

    # Pre-flight checks
    preflight_checks

    # Build FRR image if needed
    build_frr_image

    # Deploy labs
    if [[ "$SKIP_DEPLOY" == "false" ]]; then
        deploy_labs_parallel
        wait_for_convergence
    else
        log_info "Skipping deployment (--skip-deploy)"
        echo ""
    fi

    # Run tests
    run_exercise_tests

    # Generate summary
    generate_summary

    # Cleanup
    if [[ "$SKIP_CLEANUP" == "false" ]]; then
        cleanup_labs
    else
        log_info "Skipping cleanup (--skip-cleanup)"
    fi

    echo ""
    log_success "Test run complete!"
}

main "$@"
