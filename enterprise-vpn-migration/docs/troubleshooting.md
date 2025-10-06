# Enterprise VPN Migration Lab - Troubleshooting Guide

This guide provides detailed troubleshooting procedures for common issues encountered in the Enterprise VPN Migration Lab.

---

## Table of Contents

1. [Container and Infrastructure Issues](#container-and-infrastructure-issues)
2. [OSPF Routing Issues](#ospf-routing-issues)
3. [BGP Peering Issues](#bgp-peering-issues)
4. [GRE Tunnel Issues](#gre-tunnel-issues)
5. [Service Connectivity Issues](#service-connectivity-issues)
6. [Migration-Specific Issues](#migration-specific-issues)
7. [Performance and Resource Issues](#performance-and-resource-issues)

---

## Container and Infrastructure Issues

### Issue 1.1: Containers Won't Start During Deployment

**Symptoms**:
- `containerlab deploy` fails with error messages
- Some containers start but others fail
- Docker errors about resource constraints

**Possible Causes**:
1. Insufficient system resources (RAM, disk space)
2. Port conflicts with existing services
3. Docker daemon not running or misconfigured
4. Old lab containers still running

**Diagnosis**:
```bash
# Check Docker status
docker info

# Check available memory
free -h

# Check disk space
df -h

# Check for existing lab containers
docker ps -a | grep clab-enterprise-vpn-migration

# Check for port conflicts (Grafana, Netbox)
sudo netstat -tulpn | grep -E ':(3000|8000)'
```

**Solutions**:

**Solution 1.1a: Insufficient Memory**
```bash
# Free up memory by stopping other containers
docker stop $(docker ps -q)

# Or increase Docker memory limit (Docker Desktop)
# Go to Settings → Resources → Memory → Increase to 4GB+
```

**Solution 1.1b: Clean Up Old Lab**
```bash
# Destroy existing lab
cd /path/to/lab
containerlab destroy -t topology.clab.yml --cleanup

# Remove orphaned containers
docker container prune -f

# Remove orphaned networks
docker network prune -f
```

**Solution 1.1c: Port Conflicts**
```bash
# Identify process using conflicting port
sudo lsof -i :3000
sudo lsof -i :8000

# Stop conflicting process or change lab ports
```

---

### Issue 1.2: Container Crashed After Deployment

**Symptoms**:
- Container appears in `docker ps` initially but then exits
- Container status shows "Exited (1)" or "Exited (137)"
- Services not responding

**Diagnosis**:
```bash
# Check container status
docker ps -a | grep clab-enterprise-vpn-migration

# View container logs
docker logs clab-enterprise-vpn-migration-router-a1

# Check for OOM (Out of Memory) kills
dmesg | grep -i oom
```

**Solutions**:

**Solution 1.2a: FRR Container Crashed**
```bash
# Restart the container
docker restart clab-enterprise-vpn-migration-router-a1

# Check FRR daemon status inside container
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show daemons"

# Manually start FRR if needed
docker exec clab-enterprise-vpn-migration-router-a1 /usr/lib/frr/frrinit.sh start
```

**Solution 1.2b: Service Container Crashed**
```bash
# For nginx (web-a, web-b)
docker exec clab-enterprise-vpn-migration-web-a nginx

# For dnsmasq (dns-a)
docker exec clab-enterprise-vpn-migration-dns-a dnsmasq --no-daemon &

# For Grafana
docker restart clab-enterprise-vpn-migration-monitor-a
```

---

## OSPF Routing Issues

### Issue 2.1: OSPF Adjacencies Not Forming (Stuck in INIT or 2WAY)

**Symptoms**:
- `show ip ospf neighbor` shows neighbors in INIT or 2WAY state
- Neighbors never reach FULL state
- Validation test 5 fails

**Possible Causes**:
1. Network type mismatch (broadcast vs. point-to-point)
2. OSPF area mismatch
3. Interface down or IP not configured
4. MTU mismatch on GRE tunnel
5. OSPF hello/dead interval mismatch

**Diagnosis**:
```bash
# Check OSPF interface configuration
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface"

# Check neighbor state
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor"

# Check interface status
docker exec clab-enterprise-vpn-migration-router-a1 ip link show

# Check OSPF configuration
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run | section ospf"

# Enable OSPF debugging
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug ospf event"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug ospf packet hello"
```

**Solutions**:

**Solution 2.1a: Network Type Mismatch**
```bash
# Set interface to point-to-point (correct for GRE and physical links)
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface eth1" \
  -c "ip ospf network point-to-point" \
  -c "end"

# Repeat on router-a2 and all OSPF interfaces
```

**Solution 2.1b: OSPF Area Mismatch**
```bash
# Verify both routers are in area 0
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface eth1" | grep Area
docker exec clab-enterprise-vpn-migration-router-a2 vtysh -c "show ip ospf interface eth1" | grep Area

# Fix area mismatch
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface eth1" \
  -c "ip ospf area 0" \
  -c "end"
```

**Solution 2.1c: MTU Mismatch on GRE Tunnel**
```bash
# Check MTU on both sides
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre0 | grep mtu
docker exec clab-enterprise-vpn-migration-router-b1 ip link show gre0 | grep mtu

# Set MTU to 1400 on both sides (standard for GRE)
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 mtu 1400
docker exec clab-enterprise-vpn-migration-router-b1 ip link set gre0 mtu 1400
```

---

### Issue 2.2: OSPF Routes Not Being Learned

**Symptoms**:
- OSPF adjacency is FULL
- But routes from remote site not appearing in routing table
- Validation test 4 fails

**Possible Causes**:
1. Routes not being advertised
2. Route filtering blocking routes
3. Passive interface incorrectly configured
4. Redistribute configuration missing

**Diagnosis**:
```bash
# Check OSPF database
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf database"

# Check routing table
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route"

# Check what's being advertised
docker exec clab-enterprise-vpn-migration-router-a2 vtysh -c "show ip ospf route"

# Check for route filters
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run | section route-map"
```

**Solutions**:

**Solution 2.2a: Missing Network Statements**
```bash
# Add network statements to OSPF
docker exec clab-enterprise-vpn-migration-router-a2 vtysh -c "conf t" \
  -c "router ospf" \
  -c "network 10.1.20.0/24 area 0" \
  -c "end"
```

**Solution 2.2b: Passive Interface Blocking**
```bash
# Check passive interfaces
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf interface" | grep -i passive

# Remove passive from OSPF link (if incorrectly set)
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "router ospf" \
  -c "no passive-interface eth1" \
  -c "end"
```

**Solution 2.2c: Redistribute Static Routes**
```bash
# Enable redistribution of static routes
docker exec clab-enterprise-vpn-migration-router-a2 vtysh -c "conf t" \
  -c "router ospf" \
  -c "redistribute static" \
  -c "end"
```

---

## BGP Peering Issues

### Issue 3.1: BGP Session Not Establishing (Active/Connect State)

**Symptoms**:
- `show bgp summary` shows neighbor in Active or Connect state
- BGP session never reaches Established state
- Validation test 6 fails

**Possible Causes**:
1. TCP connectivity issue (cannot reach neighbor IP)
2. Incorrect neighbor IP address
3. AS number mismatch
4. BGP not activated for IPv4 address-family
5. Firewall blocking TCP port 179

**Diagnosis**:
```bash
# Check BGP summary
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show bgp summary"

# Check TCP connectivity to BGP peer
docker exec clab-enterprise-vpn-migration-router-a1 ping 100.64.0.100

# Check BGP configuration
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run | section bgp"

# Check BGP neighbors
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show bgp neighbors"

# Enable BGP debugging
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug bgp keepalives"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug bgp updates"
```

**Solutions**:

**Solution 3.1a: TCP Connectivity Issue**
```bash
# Verify IP addressing on BGP peering interface
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show eth3

# Add missing IP if needed
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 100.64.0.10/24 dev eth3

# Test ping to peer
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 100.64.0.100
```

**Solution 3.1b: Incorrect Neighbor Configuration**
```bash
# Fix neighbor IP address
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "router bgp 64512" \
  -c "neighbor 100.64.0.100 remote-as 65000" \
  -c "end"
```

**Solution 3.1c: IPv4 Address-Family Not Activated**
```bash
# Activate neighbor in IPv4 address-family
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "router bgp 64512" \
  -c "address-family ipv4 unicast" \
  -c "neighbor 100.64.0.100 activate" \
  -c "end"
```

---

### Issue 3.2: BGP Routes Not Being Advertised

**Symptoms**:
- BGP session is Established
- But routes not appearing on remote peer
- Validation test 7 fails

**Possible Causes**:
1. Network statement missing in BGP
2. Route-map filtering outbound routes
3. Next-hop unreachable
4. Prefix not in routing table

**Diagnosis**:
```bash
# Check BGP table
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show bgp ipv4 unicast"

# Check what's being advertised to neighbor
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show bgp ipv4 unicast neighbors 100.64.0.100 advertised-routes"

# Check route-maps
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show route-map"

# Check routing table for network to be advertised
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip route 10.1.0.0/16"
```

**Solutions**:

**Solution 3.2a: Add Network Statement**
```bash
# Advertise Site A networks (10.1.0.0/16)
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "router bgp 64512" \
  -c "address-family ipv4 unicast" \
  -c "network 10.1.0.0/16" \
  -c "end"
```

**Solution 3.2b: Fix Route-Map Filtering**
```bash
# Check route-map for outbound neighbor
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run | section route-map"

# Remove restrictive route-map temporarily
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "router bgp 64512" \
  -c "address-family ipv4 unicast" \
  -c "no neighbor 100.64.0.100 route-map SITE-A-OUT out" \
  -c "end"

# Clear BGP session to apply
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "clear bgp *"
```

---

## GRE Tunnel Issues

### Issue 4.1: GRE Tunnel Interface Not Coming Up

**Symptoms**:
- GRE tunnel interface shows as DOWN
- Cannot ping across tunnel
- Validation test 9 fails

**Possible Causes**:
1. Tunnel not configured correctly
2. Source/destination IPs incorrect
3. Underlying WAN connectivity broken
4. Tunnel not explicitly brought up

**Diagnosis**:
```bash
# Check tunnel configuration
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show gre0

# Check tunnel interface status
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre0

# Check if tunnel IP is configured
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show gre0

# Test underlying WAN connectivity
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 198.51.100.10
```

**Solutions**:

**Solution 4.1a: Bring Tunnel Interface Up**
```bash
# Explicitly bring up tunnel
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 up

# Verify status
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre0
```

**Solution 4.1b: Recreate Tunnel with Correct Parameters**
```bash
# Delete existing tunnel
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel del gre0

# Create tunnel with correct source/dest
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel add gre0 mode gre \
  remote 198.51.100.10 local 203.0.113.10 ttl 255

# Add IP address
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 172.16.0.1/30 dev gre0

# Bring up
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 up

# Set MTU
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 mtu 1400
```

**Solution 4.1c: Fix WAN Connectivity**
```bash
# Verify WAN IP is configured
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show eth2

# Add WAN IP if missing
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 203.0.113.10/30 dev eth2

# Test WAN connectivity
docker exec clab-enterprise-vpn-migration-router-a1 ping 203.0.113.9
```

---

### Issue 4.2: GRE Tunnel Up But No Connectivity

**Symptoms**:
- GRE tunnel interface is UP
- Tunnel IPs are configured
- But cannot ping across tunnel
- Validation test 11 fails

**Possible Causes**:
1. IP addressing mismatch (different subnets)
2. Routing issue (no route to tunnel subnet)
3. Firewall blocking GRE (protocol 47)
4. MTU issues causing packet drops

**Diagnosis**:
```bash
# Check tunnel IPs on both sides
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show gre0
docker exec clab-enterprise-vpn-migration-router-b1 ip addr show gre0

# Check if packets are being sent/received
docker exec clab-enterprise-vpn-migration-router-a1 ip -s link show gre0

# Ping with verbose output
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 5 -v 172.16.0.2

# Traceroute across tunnel
docker exec clab-enterprise-vpn-migration-router-a1 traceroute 172.16.0.2

# Check for GRE packets with tcpdump
docker exec clab-enterprise-vpn-migration-router-a1 tcpdump -i eth2 proto gre -n
```

**Solutions**:

**Solution 4.2a: Fix IP Addressing Mismatch**
```bash
# Ensure both ends are in same subnet (172.16.0.0/30)
# Router-A1 should be 172.16.0.1
# Router-B1 should be 172.16.0.2

# Fix router-a1 if needed
docker exec clab-enterprise-vpn-migration-router-a1 ip addr del <wrong-ip>/30 dev gre0
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 172.16.0.1/30 dev gre0
```

**Solution 4.2b: Check MTU and Fragmentation**
```bash
# Test with different packet sizes
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 -s 1200 172.16.0.2  # Small
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 -s 1400 172.16.0.2  # Medium
docker exec clab-enterprise-vpn-migration-router-a1 ping -c 3 -s 1500 172.16.0.2  # Large

# If large packets fail, set MTU to 1400
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre0 mtu 1400
docker exec clab-enterprise-vpn-migration-router-b1 ip link set gre0 mtu 1400
```

---

## Service Connectivity Issues

### Issue 5.1: Cannot Access Web Services Across Sites

**Symptoms**:
- Cannot curl web-b from web-a (or vice versa)
- Validation tests 14-15 fail
- DNS works but HTTP fails

**Possible Causes**:
1. Routing issue (no route to remote site)
2. Firewall blocking HTTP traffic
3. Nginx not running on target
4. Incorrect IP address or hostname

**Diagnosis**:
```bash
# Test basic connectivity (ping)
docker exec clab-enterprise-vpn-migration-web-a ping -c 3 10.2.20.10

# Check routing table on web-a
docker exec clab-enterprise-vpn-migration-web-a ip route

# Test if nginx is listening
docker exec clab-enterprise-vpn-migration-web-b netstat -tuln | grep :80

# Try curl with verbose output
docker exec clab-enterprise-vpn-migration-web-a curl -v http://10.2.20.10

# Trace route
docker exec clab-enterprise-vpn-migration-web-a traceroute 10.2.20.10
```

**Solutions**:

**Solution 5.1a: Fix Routing on Web Hosts**
```bash
# Add default route on web-a (via firewall-a)
docker exec clab-enterprise-vpn-migration-web-a ip route add default via 10.1.20.3

# Add default route on web-b (via firewall-b)
docker exec clab-enterprise-vpn-migration-web-b ip route add default via 10.2.20.3
```

**Solution 5.1b: Restart Nginx**
```bash
# Check if nginx is running
docker exec clab-enterprise-vpn-migration-web-b ps aux | grep nginx

# Start nginx if not running
docker exec clab-enterprise-vpn-migration-web-b nginx

# Verify it's listening
docker exec clab-enterprise-vpn-migration-web-b netstat -tuln | grep :80
```

**Solution 5.1c: Test with Specific IP**
```bash
# Use IP instead of hostname to rule out DNS
docker exec clab-enterprise-vpn-migration-web-a curl http://10.2.20.10

# If IP works but hostname doesn't, it's a DNS issue
```

---

### Issue 5.2: DNS Resolution Failing Across Sites

**Symptoms**:
- Cannot resolve hostnames from Site B to Site A DNS
- Validation test 13 fails
- `nslookup` or `dig` queries timeout

**Possible Causes**:
1. dnsmasq not running on dns-a
2. Routing issue to DNS server
3. Firewall blocking UDP 53
4. DNS configuration incorrect

**Diagnosis**:
```bash
# Check if dnsmasq is running
docker exec clab-enterprise-vpn-migration-dns-a ps aux | grep dnsmasq

# Test DNS connectivity (UDP 53)
docker exec clab-enterprise-vpn-migration-web-b nc -zvu 10.1.20.11 53

# Try DNS query with verbose output
docker exec clab-enterprise-vpn-migration-web-b nslookup -debug web-a.site-a.local 10.1.20.11

# Check dnsmasq configuration
docker exec clab-enterprise-vpn-migration-dns-a cat /etc/dnsmasq.conf

# Check routing to DNS server
docker exec clab-enterprise-vpn-migration-web-b traceroute 10.1.20.11
```

**Solutions**:

**Solution 5.2a: Restart dnsmasq**
```bash
# Kill existing dnsmasq processes
docker exec clab-enterprise-vpn-migration-dns-a pkill dnsmasq

# Start dnsmasq
docker exec clab-enterprise-vpn-migration-dns-a dnsmasq --no-daemon --log-queries &

# Verify it's listening on port 53
docker exec clab-enterprise-vpn-migration-dns-a netstat -uln | grep :53
```

**Solution 5.2b: Add DNS Records**
```bash
# Add records to dnsmasq configuration
docker exec clab-enterprise-vpn-migration-dns-a sh -c 'echo "address=/web-a.site-a.local/10.1.20.10" >> /etc/dnsmasq.conf'
docker exec clab-enterprise-vpn-migration-dns-a sh -c 'echo "address=/web-b.site-b.local/10.2.20.10" >> /etc/dnsmasq.conf'

# Restart dnsmasq
docker exec clab-enterprise-vpn-migration-dns-a pkill -HUP dnsmasq
```

---

## Migration-Specific Issues

### Issue 6.1: New GRE Tunnel Won't Establish During Migration

**Symptoms**:
- Created gre1 tunnel with new IPs
- But cannot ping across new tunnel
- Migration step 3.3 fails

**Possible Causes**:
1. New WAN IPs not actually configured
2. Incorrect tunnel source/dest IPs
3. ISP not routing new IP block yet
4. Typo in tunnel configuration

**Diagnosis**:
```bash
# Verify new WAN IPs are present (dual-stack)
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show eth2 | grep 192.0.2

# Check new tunnel configuration
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show gre1

# Test underlying connectivity on new IPs
docker exec clab-enterprise-vpn-migration-router-a1 ping -I 192.0.2.10 192.0.2.20

# Check tunnel interface status
docker exec clab-enterprise-vpn-migration-router-a1 ip link show gre1
```

**Solutions**:

**Solution 6.1a: Add New WAN IPs (Dual-Stack)**
```bash
# Ensure new IPs are added alongside old IPs
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 192.0.2.10/30 dev eth2
docker exec clab-enterprise-vpn-migration-router-b1 ip addr add 192.0.2.20/30 dev eth2

# Verify both IPs present
docker exec clab-enterprise-vpn-migration-router-a1 ip addr show eth2
```

**Solution 6.1b: Recreate New Tunnel with Correct Parameters**
```bash
# Delete incorrect tunnel
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel del gre1

# Create with correct source/dest (NEW IPs)
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel add gre1 mode gre \
  remote 192.0.2.20 local 192.0.2.10 ttl 255
docker exec clab-enterprise-vpn-migration-router-a1 ip addr add 172.16.1.1/30 dev gre1
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre1 up
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre1 mtu 1400

# Verify
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel show gre1
```

---

### Issue 6.2: Migration Downtime Exceeds 5 Minutes

**Symptoms**:
- Migration completes successfully
- But total downtime is >5 minutes, violating SLA
- Services were unavailable longer than planned

**Possible Causes**:
1. Sequential execution when parallel possible
2. Waiting too long between steps
3. Manual typing of commands too slow
4. OSPF convergence delays
5. Not using optimal migration strategy

**Diagnosis**:
```bash
# Review migration log timestamps
# Calculate time between:
# - When old tunnel removed from OSPF (downtime start)
# - When new tunnel fully operational (downtime end)

# Check OSPF convergence time
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show ip ospf neighbor" | grep "Dead time"
```

**Solutions**:

**Solution 6.2a: Use Automated Migration Script**
```bash
# Use the optimized automation
./scripts/migrate-vpn.sh --auto

# This script:
# - Executes steps without manual delays
# - Uses optimal OSPF cost manipulation
# - Minimizes convergence time
```

**Solution 6.2b: Improve Strategy (Dual-Stack with Cost Manipulation)**
```bash
# Instead of removing old tunnel immediately, use OSPF cost:

# 1. Create new tunnel (gre1)
# 2. Add gre1 to OSPF with LOWER cost (50)
# 3. Keep gre0 in OSPF with HIGHER cost (100)
# 4. Traffic shifts to gre1 immediately (no downtime)
# 5. Verify all traffic on gre1
# 6. THEN remove gre0 (still no downtime)

docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre1" \
  -c "ip ospf cost 50" \
  -c "end"

docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre0" \
  -c "ip ospf cost 100" \
  -c "end"
```

**Solution 6.2c: Reduce OSPF Timers (Faster Convergence)**
```bash
# Reduce hello interval for faster convergence during migration
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre1" \
  -c "ip ospf hello-interval 1" \
  -c "ip ospf dead-interval 3" \
  -c "end"

# Note: This gives ~3 second convergence vs. default 15 seconds
```

---

### Issue 6.3: Need to Rollback But Services Already Down

**Symptoms**:
- Migration failed at critical step
- Services are currently down
- Need to execute rollback quickly

**Actions**:

**Step 1: Execute Automated Rollback**
```bash
cd /path/to/lab
./scripts/rollback.sh
```

**Step 2: If Automated Rollback Unavailable, Manual Steps**
```bash
# 1. Remove new tunnel from OSPF immediately
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre1" -c "no ip ospf area 0" -c "end"
docker exec clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" \
  -c "interface gre1" -c "no ip ospf area 0" -c "end"

# 2. Add old tunnel back to OSPF
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "conf t" \
  -c "interface gre0" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "end"
docker exec clab-enterprise-vpn-migration-router-b1 vtysh -c "conf t" \
  -c "interface gre0" -c "ip ospf area 0" -c "ip ospf network point-to-point" -c "end"

# 3. Wait for OSPF convergence (10 seconds)
sleep 10

# 4. Verify services restored
docker exec clab-enterprise-vpn-migration-web-a curl -s http://10.2.20.10

# 5. Clean up new tunnel (after services restored)
docker exec clab-enterprise-vpn-migration-router-a1 ip link set gre1 down
docker exec clab-enterprise-vpn-migration-router-a1 ip tunnel del gre1
```

---

## Performance and Resource Issues

### Issue 7.1: Lab Running Slowly or Unresponsive

**Symptoms**:
- Commands take long time to execute
- Containers freezing or slow to respond
- Docker commands hang

**Diagnosis**:
```bash
# Check system resource usage
free -h
df -h
top

# Check Docker resource usage
docker stats

# Check for CPU throttling
dmesg | grep -i throttle
```

**Solutions**:

**Solution 7.1a: Reduce Lab Load**
```bash
# Stop non-essential containers
docker stop clab-enterprise-vpn-migration-netbox
docker stop clab-enterprise-vpn-migration-monitor-a

# Restart after freeing resources
docker start clab-enterprise-vpn-migration-netbox
```

**Solution 7.1b: Increase Docker Resources**
```
# Docker Desktop: Settings → Resources
# - Memory: Increase to 4GB minimum (6GB recommended)
# - CPU: Increase to 2+ cores
# - Disk: Ensure 10GB+ available
```

---

## General Troubleshooting Tips

### Tip 1: Always Check the Basics First
1. Is the container running? (`docker ps`)
2. Are interfaces UP? (`ip link show`)
3. Are IPs configured? (`ip addr show`)
4. Can I ping? (`ping`)
5. What does routing table show? (`ip route` or `show ip route`)

### Tip 2: Use Validation Script for Quick Diagnosis
```bash
# Run validation to identify exactly which tests are failing
./scripts/validate.sh

# Focus troubleshooting on failed tests
```

### Tip 3: Enable Debugging for Protocols
```bash
# FRR debugging commands
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug ospf event"
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "debug bgp updates"

# Disable debugging when done
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "no debug all"
```

### Tip 4: Packet Capture for Deep Troubleshooting
```bash
# Capture GRE packets on WAN interface
docker exec clab-enterprise-vpn-migration-router-a1 tcpdump -i eth2 proto gre -n -v

# Capture OSPF hellos
docker exec clab-enterprise-vpn-migration-router-a1 tcpdump -i eth1 proto ospf -n -v

# Capture BGP traffic
docker exec clab-enterprise-vpn-migration-router-a1 tcpdump -i eth3 port 179 -n -v
```

### Tip 5: Compare Working vs. Non-Working Configuration
```bash
# Save working config
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run" > working.conf

# After making changes, compare
docker exec clab-enterprise-vpn-migration-router-a1 vtysh -c "show run" > current.conf
diff working.conf current.conf
```

---

## Getting Help

If you're still stuck after trying these troubleshooting steps:

1. **Run full validation**: `./scripts/validate.sh` and note which specific tests fail
2. **Capture output**: Save command outputs and error messages
3. **Check logs**: Review containerlab deployment logs and Docker logs
4. **Review documentation**: Reread `docs/objectives.md`, `docs/scenario.md`
5. **Start fresh**: Sometimes it's faster to `./scripts/cleanup.sh` and `./scripts/deploy.sh` again

---

**Document Version**: 1.0
**Last Updated**: 2025-10-05
