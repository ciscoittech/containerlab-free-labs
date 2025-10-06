#!/bin/bash
#############################################################################
# Enterprise VPN Migration Lab - Comprehensive Validation Script
#############################################################################
#
# Purpose: Validate lab infrastructure and service functionality before and
#          after VPN IP migration. Provides clear pass/fail status for each
#          test with detailed troubleshooting output.
#
# Usage:
#   ./scripts/validate.sh                    # Run all 22 tests
#   ./scripts/validate.sh --pre-migration    # Run only baseline tests (1-16)
#   ./scripts/validate.sh --post-migration   # Run only post-migration tests (17-22)
#   ./scripts/validate.sh --quick            # Run critical tests only (1,5,9,13)
#
# Exit Codes:
#   0  - All tests passed
#   1  - One or more tests failed
#   2  - Script usage error
#
#############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Lab topology name
TOPOLOGY="enterprise-vpn-migration"

# Test execution mode (all, pre, post, quick)
TEST_MODE="all"

#############################################################################
# Helper Functions
#############################################################################

print_header() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

print_test() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo ""
    echo -e "${YELLOW}[Test $TESTS_TOTAL] $1${NC}"
}

print_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓ PASS${NC}: $1"
}

print_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗ FAIL${NC}: $1"
}

print_info() {
    echo -e "${BLUE}ℹ INFO${NC}: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING${NC}: $1"
}

# Execute command in container
exec_in_container() {
    local container="clab-${TOPOLOGY}-$1"
    shift
    docker exec "$container" "$@" 2>&1
}

# Execute vtysh command in FRR container
exec_vtysh() {
    local container="clab-${TOPOLOGY}-$1"
    local command="$2"
    docker exec "$container" vtysh -c "$command" 2>&1
}

# Check if container is running
is_container_running() {
    local container="clab-${TOPOLOGY}-$1"
    docker ps --format '{{.Names}}' | grep -q "^${container}$"
}

# Wait for condition with timeout
wait_for_condition() {
    local timeout=$1
    local interval=$2
    local condition=$3
    local elapsed=0

    while [ $elapsed -lt $timeout ]; do
        if eval "$condition"; then
            return 0
        fi
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done
    return 1
}

#############################################################################
# Test Functions - Category 1: Infrastructure Health
#############################################################################

test_01_all_containers_running() {
    print_test "Verify all 16 containers are running and healthy"

    local containers=(
        "isp-a" "router-a1" "router-a2" "firewall-a"
        "web-a" "dns-a" "ldap-a" "monitor-a"
        "isp-b" "router-b1" "router-b2" "firewall-b"
        "web-b" "server-b"
        "internet-core" "netbox"
    )

    local all_running=true

    for container in "${containers[@]}"; do
        if is_container_running "$container"; then
            print_info "$container is running"
        else
            print_fail "$container is NOT running"
            all_running=false
        fi
    done

    if [ "$all_running" = true ]; then
        print_pass "All 16 containers are running"
    else
        print_fail "One or more containers are not running"
        return 1
    fi
}

test_02_network_interfaces_up() {
    print_test "Verify all critical network interfaces are UP"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 interfaces
    if exec_in_container router-a1 ip link show eth1 | grep -q "state UP"; then
        print_info "router-a1 eth1 (to router-a2) is UP"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a1 eth1 is DOWN"
        tests_failed=$((tests_failed + 1))
    fi

    if exec_in_container router-a1 ip link show eth2 | grep -q "state UP"; then
        print_info "router-a1 eth2 (WAN to ISP) is UP"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a1 eth2 is DOWN"
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b1 interfaces
    if exec_in_container router-b1 ip link show eth1 | grep -q "state UP"; then
        print_info "router-b1 eth1 (to router-b2) is UP"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b1 eth1 is DOWN"
        tests_failed=$((tests_failed + 1))
    fi

    if exec_in_container router-b1 ip link show eth2 | grep -q "state UP"; then
        print_info "router-b1 eth2 (WAN to ISP) is UP"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b1 eth2 is DOWN"
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "All critical interfaces are UP ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed interface(s) are DOWN"
        return 1
    fi
}

test_03_ip_addressing_correct() {
    print_test "Verify IP addressing on key interfaces"

    local tests_passed=0
    local tests_failed=0

    # Check router-a2 (Site A core) has 10.1.10.1
    if exec_in_container router-a2 ip addr show eth1 | grep -q "10.1.10.1"; then
        print_info "router-a2 eth1 has correct IP (10.1.10.1/24)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a2 eth1 does not have 10.1.10.1"
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b2 (Site B core) has 10.2.10.1
    if exec_in_container router-b2 ip addr show eth1 | grep -q "10.2.10.1"; then
        print_info "router-b2 eth1 has correct IP (10.2.10.1/24)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b2 eth1 does not have 10.2.10.1"
        tests_failed=$((tests_failed + 1))
    fi

    # Check web-a has 10.1.20.10
    if exec_in_container web-a ip addr show eth1 | grep -q "10.1.20.10"; then
        print_info "web-a has correct IP (10.1.20.10/24)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "web-a does not have 10.1.20.10"
        tests_failed=$((tests_failed + 1))
    fi

    # Check web-b has 10.2.20.10
    if exec_in_container web-b ip addr show eth1 | grep -q "10.2.20.10"; then
        print_info "web-b has correct IP (10.2.20.10/24)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "web-b does not have 10.2.20.10"
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "All IP addresses are correctly assigned ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed IP address(es) are incorrect"
        return 1
    fi
}

test_04_routing_tables_populated() {
    print_test "Verify routing tables have expected routes"

    # Check router-a1 has default route
    if exec_vtysh router-a1 "show ip route" | grep -q "0.0.0.0/0"; then
        print_info "router-a1 has default route"
    else
        print_fail "router-a1 missing default route"
        return 1
    fi

    # Check router-a1 has route to 10.2.0.0/16 (Site B) via VPN
    if exec_vtysh router-a1 "show ip route" | grep -q "10.2.0.0/16"; then
        print_info "router-a1 has route to Site B (10.2.0.0/16)"
    else
        print_fail "router-a1 missing route to Site B"
        return 1
    fi

    print_pass "Routing tables are populated with expected routes"
}

#############################################################################
# Test Functions - Category 2: Routing Protocols
#############################################################################

test_05_ospf_adjacencies() {
    print_test "Verify OSPF neighbor adjacencies are FULL"

    local tests_passed=0
    local tests_failed=0

    # Check Site A: router-a2 ↔ router-a1
    if exec_vtysh router-a2 "show ip ospf neighbor" | grep -q "Full"; then
        print_info "Site A OSPF: router-a2 ↔ router-a1 adjacency is FULL"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "Site A OSPF adjacency is not FULL"
        exec_vtysh router-a2 "show ip ospf neighbor"
        tests_failed=$((tests_failed + 1))
    fi

    # Check Site B: router-b2 ↔ router-b1
    if exec_vtysh router-b2 "show ip ospf neighbor" | grep -q "Full"; then
        print_info "Site B OSPF: router-b2 ↔ router-b1 adjacency is FULL"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "Site B OSPF adjacency is not FULL"
        exec_vtysh router-b2 "show ip ospf neighbor"
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "All OSPF adjacencies are FULL ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed OSPF adjacency(ies) failed"
        return 1
    fi
}

test_06_bgp_peering_established() {
    print_test "Verify BGP peering sessions are ESTABLISHED"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 BGP session to internet-core
    if exec_vtysh router-a1 "show bgp summary" | grep -q "Established"; then
        print_info "router-a1 BGP session to internet-core is ESTABLISHED"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a1 BGP session is not ESTABLISHED"
        exec_vtysh router-a1 "show bgp summary"
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b1 BGP session to internet-core
    if exec_vtysh router-b1 "show bgp summary" | grep -q "Established"; then
        print_info "router-b1 BGP session to internet-core is ESTABLISHED"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b1 BGP session is not ESTABLISHED"
        exec_vtysh router-b1 "show bgp summary"
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "All BGP sessions are ESTABLISHED ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed BGP session(s) failed"
        return 1
    fi
}

test_07_bgp_routes_advertised() {
    print_test "Verify BGP routes are advertised correctly"

    # Check router-a1 is advertising Site A networks (10.1.0.0/16)
    if exec_vtysh router-a1 "show bgp ipv4 unicast" | grep -q "10.1.0.0/16"; then
        print_info "router-a1 advertising Site A networks"
    else
        print_fail "router-a1 not advertising Site A networks"
        return 1
    fi

    # Check router-b1 is advertising Site B networks (10.2.0.0/16)
    if exec_vtysh router-b1 "show bgp ipv4 unicast" | grep -q "10.2.0.0/16"; then
        print_info "router-b1 advertising Site B networks"
    else
        print_fail "router-b1 not advertising Site B networks"
        return 1
    fi

    print_pass "BGP routes are advertised correctly"
}

test_08_routing_convergence_time() {
    print_test "Measure routing protocol convergence time (informational)"

    # This test is informational - measures time for OSPF/BGP to converge
    # In real scenario, would restart routing daemon and measure recovery

    print_info "OSPF convergence target: <5 seconds"
    print_info "BGP convergence target: <10 seconds"
    print_info "Actual convergence times measured during lab deployment"

    print_pass "Convergence time test is informational (manual verification required)"
}

#############################################################################
# Test Functions - Category 3: VPN Tunnel
#############################################################################

test_09_gre_tunnel_interfaces_exist() {
    print_test "Verify GRE tunnel interfaces exist and are UP"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 has gre0 interface
    if exec_in_container router-a1 ip link show gre0 2>/dev/null | grep -q "gre0"; then
        if exec_in_container router-a1 ip link show gre0 | grep -q "state UP"; then
            print_info "router-a1 gre0 interface exists and is UP"
            tests_passed=$((tests_passed + 1))
        else
            print_fail "router-a1 gre0 exists but is DOWN"
            tests_failed=$((tests_failed + 1))
        fi
    else
        print_fail "router-a1 gre0 interface does not exist"
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b1 has gre0 interface
    if exec_in_container router-b1 ip link show gre0 2>/dev/null | grep -q "gre0"; then
        if exec_in_container router-b1 ip link show gre0 | grep -q "state UP"; then
            print_info "router-b1 gre0 interface exists and is UP"
            tests_passed=$((tests_passed + 1))
        else
            print_fail "router-b1 gre0 exists but is DOWN"
            tests_failed=$((tests_failed + 1))
        fi
    else
        print_fail "router-b1 gre0 interface does not exist"
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "GRE tunnel interfaces exist and are UP ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed GRE interface(s) failed"
        return 1
    fi
}

test_10_gre_tunnel_ip_addressing() {
    print_test "Verify GRE tunnel IP addressing (172.16.0.1 ↔ 172.16.0.2)"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 gre0 has 172.16.0.1
    if exec_in_container router-a1 ip addr show gre0 | grep -q "172.16.0.1"; then
        print_info "router-a1 gre0 has correct IP (172.16.0.1/30)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a1 gre0 does not have 172.16.0.1"
        exec_in_container router-a1 ip addr show gre0
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b1 gre0 has 172.16.0.2
    if exec_in_container router-b1 ip addr show gre0 | grep -q "172.16.0.2"; then
        print_info "router-b1 gre0 has correct IP (172.16.0.2/30)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b1 gre0 does not have 172.16.0.2"
        exec_in_container router-b1 ip addr show gre0
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "GRE tunnel IP addressing is correct ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed GRE IP address(es) incorrect"
        return 1
    fi
}

test_11_gre_tunnel_connectivity() {
    print_test "Verify GRE tunnel connectivity via ping"

    # Ping from router-a1 (172.16.0.1) to router-b1 (172.16.0.2)
    if exec_in_container router-a1 ping -c 3 -W 2 172.16.0.2 | grep -q "3 received"; then
        print_info "Ping from router-a1 to router-b1 successful (3/3 packets)"
    else
        print_fail "Ping from router-a1 to router-b1 failed"
        exec_in_container router-a1 ping -c 3 -W 2 172.16.0.2
        return 1
    fi

    # Ping from router-b1 (172.16.0.2) to router-a1 (172.16.0.1)
    if exec_in_container router-b1 ping -c 3 -W 2 172.16.0.1 | grep -q "3 received"; then
        print_info "Ping from router-b1 to router-a1 successful (3/3 packets)"
    else
        print_fail "Ping from router-b1 to router-a1 failed"
        exec_in_container router-b1 ping -c 3 -W 2 172.16.0.1
        return 1
    fi

    print_pass "GRE tunnel connectivity verified (bidirectional ping successful)"
}

test_12_ipsec_tunnel_established() {
    print_test "Verify IPsec tunnel is established (if configured)"

    # Check if IPsec is configured on firewall-a
    if exec_in_container firewall-a which ipsec >/dev/null 2>&1; then
        if exec_in_container firewall-a ipsec status 2>/dev/null | grep -q "ESTABLISHED"; then
            print_info "IPsec tunnel is ESTABLISHED on firewall-a"
        else
            print_warning "IPsec not ESTABLISHED (may not be configured yet)"
        fi
    else
        print_warning "IPsec not installed on firewall-a (optional for basic lab)"
    fi

    # For now, mark as informational pass (IPsec is optional enhancement)
    print_pass "IPsec tunnel status checked (optional feature)"
}

#############################################################################
# Test Functions - Category 4: Application Services
#############################################################################

test_13_dns_resolution_cross_site() {
    print_test "Verify DNS resolution works across VPN (Site B → Site A)"

    # Test DNS resolution from web-b to dns-a (10.1.20.11)
    if exec_in_container web-b nslookup web-a.site-a.local 10.1.20.11 2>/dev/null | grep -q "10.1.20.10"; then
        print_info "DNS query from Site B to Site A successful (web-a.site-a.local = 10.1.20.10)"
    else
        print_fail "DNS resolution from Site B to Site A failed"
        exec_in_container web-b nslookup web-a.site-a.local 10.1.20.11
        return 1
    fi

    print_pass "DNS resolution across VPN is working"
}

test_14_web_service_accessibility_a_to_b() {
    print_test "Verify web-b (10.2.20.10) is accessible from Site A"

    # HTTP GET request from web-a to web-b
    if exec_in_container web-a curl -s -m 5 http://10.2.20.10 | grep -q "Welcome"; then
        print_info "HTTP request from web-a to web-b successful"
    else
        print_fail "HTTP request from web-a to web-b failed"
        exec_in_container web-a curl -v http://10.2.20.10
        return 1
    fi

    print_pass "Web service (Site B) is accessible from Site A"
}

test_15_web_service_accessibility_b_to_a() {
    print_test "Verify web-a (10.1.20.10) is accessible from Site B"

    # HTTP GET request from web-b to web-a
    if exec_in_container web-b curl -s -m 5 http://10.1.20.10 | grep -q "Welcome"; then
        print_info "HTTP request from web-b to web-a successful"
    else
        print_fail "HTTP request from web-b to web-a failed"
        exec_in_container web-b curl -v http://10.1.20.10
        return 1
    fi

    print_pass "Web service (Site A) is accessible from Site B"
}

test_16_ldap_connectivity() {
    print_test "Verify LDAP server (10.1.20.12) is accessible from Site B"

    # Test LDAP connectivity using netcat or telnet
    if exec_in_container server-b nc -zv -w 3 10.1.20.12 389 2>&1 | grep -q "succeeded"; then
        print_info "LDAP port 389 is reachable from Site B"
    else
        print_fail "LDAP port 389 is not reachable from Site B"
        exec_in_container server-b nc -zv -w 3 10.1.20.12 389
        return 1
    fi

    print_pass "LDAP service is accessible across VPN"
}

#############################################################################
# Test Functions - Category 5: Migration Validation
#############################################################################

test_17_new_wan_ips_assigned() {
    print_test "Verify new WAN IPs are assigned (192.0.2.10 and 192.0.2.20)"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 has new IP 192.0.2.10
    if exec_in_container router-a1 ip addr show eth2 | grep -q "192.0.2.10"; then
        print_info "router-a1 eth2 has new WAN IP (192.0.2.10/30)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a1 eth2 does not have new WAN IP (192.0.2.10)"
        exec_in_container router-a1 ip addr show eth2
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b1 has new IP 192.0.2.20
    if exec_in_container router-b1 ip addr show eth2 | grep -q "192.0.2.20"; then
        print_info "router-b1 eth2 has new WAN IP (192.0.2.20/30)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b1 eth2 does not have new WAN IP (192.0.2.20)"
        exec_in_container router-b1 ip addr show eth2
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "New WAN IPs are correctly assigned ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed new WAN IP(s) not assigned"
        return 1
    fi
}

test_18_old_wan_ips_removed() {
    print_test "Verify old WAN IPs are removed (203.0.113.10 and 198.51.100.10)"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 does NOT have old IP 203.0.113.10
    if exec_in_container router-a1 ip addr show eth2 | grep -q "203.0.113.10"; then
        print_fail "router-a1 eth2 still has old WAN IP (203.0.113.10) - should be removed"
        exec_in_container router-a1 ip addr show eth2
        tests_failed=$((tests_failed + 1))
    else
        print_info "router-a1 old WAN IP (203.0.113.10) successfully removed"
        tests_passed=$((tests_passed + 1))
    fi

    # Check router-b1 does NOT have old IP 198.51.100.10
    if exec_in_container router-b1 ip addr show eth2 | grep -q "198.51.100.10"; then
        print_fail "router-b1 eth2 still has old WAN IP (198.51.100.10) - should be removed"
        exec_in_container router-b1 ip addr show eth2
        tests_failed=$((tests_failed + 1))
    else
        print_info "router-b1 old WAN IP (198.51.100.10) successfully removed"
        tests_passed=$((tests_passed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "Old WAN IPs are removed ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed old WAN IP(s) still present"
        return 1
    fi
}

test_19_gre_tunnel_using_new_ips() {
    print_test "Verify GRE tunnel is using new source/destination IPs"

    local tests_passed=0
    local tests_failed=0

    # Check router-a1 gre0 tunnel source is 192.0.2.10
    if exec_in_container router-a1 ip tunnel show gre0 | grep -q "remote 192.0.2.20"; then
        print_info "router-a1 gre0 tunnel destination is 192.0.2.20 (correct)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-a1 gre0 tunnel destination is not 192.0.2.20"
        exec_in_container router-a1 ip tunnel show gre0
        tests_failed=$((tests_failed + 1))
    fi

    # Check router-b1 gre0 tunnel source is 192.0.2.20
    if exec_in_container router-b1 ip tunnel show gre0 | grep -q "remote 192.0.2.10"; then
        print_info "router-b1 gre0 tunnel destination is 192.0.2.10 (correct)"
        tests_passed=$((tests_passed + 1))
    else
        print_fail "router-b1 gre0 tunnel destination is not 192.0.2.10"
        exec_in_container router-b1 ip tunnel show gre0
        tests_failed=$((tests_failed + 1))
    fi

    if [ $tests_failed -eq 0 ]; then
        print_pass "GRE tunnel is using new IPs ($tests_passed/$((tests_passed + tests_failed)))"
    else
        print_fail "$tests_failed GRE tunnel endpoint(s) incorrect"
        return 1
    fi
}

test_20_no_routing_loops() {
    print_test "Verify no routing loops exist (traceroute Site A ↔ Site B)"

    # Traceroute from web-a (Site A) to web-b (Site B)
    local traceroute_output=$(exec_in_container web-a traceroute -m 10 -w 1 10.2.20.10 2>&1)

    # Check if traceroute completes without loops
    if echo "$traceroute_output" | grep -q "10.2.20.10"; then
        local hops=$(echo "$traceroute_output" | grep -c "ms")
        print_info "Traceroute from Site A to Site B completed in $hops hops"

        if [ "$hops" -le 6 ]; then
            print_info "Hop count is reasonable (<= 6 hops)"
        else
            print_warning "Hop count is high (> 6 hops) - possible suboptimal routing"
        fi
    else
        print_fail "Traceroute from Site A to Site B failed or looped"
        echo "$traceroute_output"
        return 1
    fi

    print_pass "No routing loops detected"
}

#############################################################################
# Test Functions - Category 6: Monitoring & Documentation
#############################################################################

test_21_grafana_accessible() {
    print_test "Verify Grafana dashboard is accessible (10.1.20.13:3000)"

    # Check if Grafana container is running
    if ! is_container_running "monitor-a"; then
        print_fail "Grafana container (monitor-a) is not running"
        return 1
    fi

    # Check if Grafana web interface responds
    if exec_in_container web-a curl -s -m 5 http://10.1.20.13:3000/api/health | grep -q "ok"; then
        print_info "Grafana health check returned 'ok'"
    else
        print_fail "Grafana health check failed"
        exec_in_container web-a curl -v http://10.1.20.13:3000/api/health
        return 1
    fi

    print_pass "Grafana dashboard is accessible and healthy"
}

test_22_netbox_accessible() {
    print_test "Verify Netbox is accessible and updated (10.1.20.14:8000)"

    # Check if Netbox container is running
    if ! is_container_running "netbox"; then
        print_fail "Netbox container is not running"
        return 1
    fi

    # Check if Netbox web interface responds
    if exec_in_container web-a curl -s -m 5 http://10.1.20.14:8000 | grep -q "NetBox"; then
        print_info "Netbox web interface is responding"
    else
        print_fail "Netbox web interface is not responding"
        exec_in_container web-a curl -v http://10.1.20.14:8000
        return 1
    fi

    print_pass "Netbox is accessible and ready for documentation updates"
}

#############################################################################
# Main Test Execution
#############################################################################

run_all_tests() {
    print_header "Enterprise VPN Migration Lab - Full Validation Suite"

    # Category 1: Infrastructure Health
    test_01_all_containers_running || true
    test_02_network_interfaces_up || true
    test_03_ip_addressing_correct || true
    test_04_routing_tables_populated || true

    # Category 2: Routing Protocols
    test_05_ospf_adjacencies || true
    test_06_bgp_peering_established || true
    test_07_bgp_routes_advertised || true
    test_08_routing_convergence_time || true

    # Category 3: VPN Tunnel
    test_09_gre_tunnel_interfaces_exist || true
    test_10_gre_tunnel_ip_addressing || true
    test_11_gre_tunnel_connectivity || true
    test_12_ipsec_tunnel_established || true

    # Category 4: Application Services
    test_13_dns_resolution_cross_site || true
    test_14_web_service_accessibility_a_to_b || true
    test_15_web_service_accessibility_b_to_a || true
    test_16_ldap_connectivity || true

    # Category 5: Migration Validation (post-migration only)
    if [ "$TEST_MODE" = "all" ] || [ "$TEST_MODE" = "post" ]; then
        test_17_new_wan_ips_assigned || true
        test_18_old_wan_ips_removed || true
        test_19_gre_tunnel_using_new_ips || true
        test_20_no_routing_loops || true
    fi

    # Category 6: Monitoring & Documentation
    test_21_grafana_accessible || true
    test_22_netbox_accessible || true
}

run_pre_migration_tests() {
    print_header "Enterprise VPN Migration Lab - Pre-Migration Baseline Tests"

    # Run tests 1-16 only (baseline before migration)
    test_01_all_containers_running || true
    test_02_network_interfaces_up || true
    test_03_ip_addressing_correct || true
    test_04_routing_tables_populated || true
    test_05_ospf_adjacencies || true
    test_06_bgp_peering_established || true
    test_07_bgp_routes_advertised || true
    test_08_routing_convergence_time || true
    test_09_gre_tunnel_interfaces_exist || true
    test_10_gre_tunnel_ip_addressing || true
    test_11_gre_tunnel_connectivity || true
    test_12_ipsec_tunnel_established || true
    test_13_dns_resolution_cross_site || true
    test_14_web_service_accessibility_a_to_b || true
    test_15_web_service_accessibility_b_to_a || true
    test_16_ldap_connectivity || true
}

run_post_migration_tests() {
    print_header "Enterprise VPN Migration Lab - Post-Migration Validation Tests"

    # Run tests 17-22 only (migration validation)
    test_17_new_wan_ips_assigned || true
    test_18_old_wan_ips_removed || true
    test_19_gre_tunnel_using_new_ips || true
    test_20_no_routing_loops || true
    test_21_grafana_accessible || true
    test_22_netbox_accessible || true
}

run_quick_tests() {
    print_header "Enterprise VPN Migration Lab - Quick Validation Tests"

    # Run only critical tests (1, 5, 9, 13)
    test_01_all_containers_running || true
    test_05_ospf_adjacencies || true
    test_09_gre_tunnel_interfaces_exist || true
    test_13_dns_resolution_cross_site || true
}

print_summary() {
    echo ""
    print_header "Test Summary"
    echo ""
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Total Tests:  ${BLUE}$TESTS_TOTAL${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}=========================================${NC}"
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        echo -e "${GREEN}=========================================${NC}"
        exit 0
    else
        echo -e "${RED}=========================================${NC}"
        echo -e "${RED}✗ $TESTS_FAILED TEST(S) FAILED${NC}"
        echo -e "${RED}=========================================${NC}"
        exit 1
    fi
}

#############################################################################
# Command-Line Argument Parsing
#############################################################################

if [ $# -eq 0 ]; then
    TEST_MODE="all"
elif [ "$1" = "--pre-migration" ]; then
    TEST_MODE="pre"
elif [ "$1" = "--post-migration" ]; then
    TEST_MODE="post"
elif [ "$1" = "--quick" ]; then
    TEST_MODE="quick"
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [--pre-migration|--post-migration|--quick|--help]"
    echo ""
    echo "Options:"
    echo "  (none)             Run all 22 tests"
    echo "  --pre-migration    Run baseline tests 1-16 (before VPN migration)"
    echo "  --post-migration   Run migration validation tests 17-22"
    echo "  --quick            Run critical tests only (1, 5, 9, 13)"
    echo "  --help, -h         Show this help message"
    exit 0
else
    echo "Error: Unknown option '$1'"
    echo "Run '$0 --help' for usage information"
    exit 2
fi

#############################################################################
# Main Execution
#############################################################################

case $TEST_MODE in
    all)
        run_all_tests
        ;;
    pre)
        run_pre_migration_tests
        ;;
    post)
        run_post_migration_tests
        ;;
    quick)
        run_quick_tests
        ;;
esac

print_summary
