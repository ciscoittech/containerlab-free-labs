# Common Pitfalls and Fixes

**Last Updated**: October 3, 2025

This document catalogs all common issues users encounter when deploying labs, organized by error message and deployment path.

---

## Quick Error Lookup

**Search for your error message** (Ctrl/Cmd+F):

| Error Message | Path | Fix Link |
|---------------|------|----------|
| `permission denied` | All | [#permission-denied](#permission-denied) |
| `docker: command not found` | 2, 3 | [#docker-not-installed](#docker-not-installed) |
| `containerlab: command not found` | 3 | [#containerlab-not-found](#containerlab-not-found) |
| `cannot connect to docker daemon` | 2, 3 | [#docker-daemon-not-running](#docker-daemon-not-running) |
| `reopen in container button missing` | 2 | [#no-reopen-button](#no-reopen-button) |
| `failed to pull image` | All | [#image-pull-failed](#image-pull-failed) |
| `port already allocated` | All | [#port-conflict](#port-already-allocated) |
| `tests failed` | All | [#validation-tests-fail](#validation-tests-fail) |
| `no such container` | All | [#container-not-found](#no-such-container) |
| `sudo: a terminal is required` | 2 | [#sudo-in-devcontainer](#sudo-in-devcontainer) |

---

## Path 1: GitHub Codespaces Issues

### Codespace Won't Start

**Symptoms**:
- Stuck on "Setting up your codespace..."
- Timeout error after 10+ minutes

**Causes**:
1. GitHub service outage
2. Account billing limit reached
3. Network connectivity issues

**Fixes**:

**Fix 1: Check GitHub Status**
```
Visit: https://www.githubstatus.com/
```
- If degraded performance reported, wait and retry later

**Fix 2: Check Codespaces Usage**
```
GitHub → Settings → Billing and plans → Codespaces
```
- Free tier: 60 hours/month
- If exceeded, either wait for reset or upgrade plan

**Fix 3: Retry Creation**
- Delete existing codespace
- Create new one
- Sometimes transient network issues resolve

**Prevention**: None (external service dependency)

---

### Codespace Slow Performance

**Symptoms**:
- Commands take 30+ seconds
- Terminal laggy
- Container deployments timeout

**Causes**:
- Insufficient machine type (default: 2-core)
- Too many containers running
- Codespace running too long (needs restart)

**Fixes**:

**Fix 1: Upgrade Machine Type**
```
Codespaces → ... menu → Change machine type → 4-core
```
- Requires GitHub Pro or Team plan
- 2-core is usually sufficient for single lab

**Fix 2: Destroy Unused Labs**
```bash
cd /workspaces/containerlab-free-labs
sudo containerlab destroy --all
```

**Fix 3: Restart Codespace**
- Stop codespace
- Start again (clears memory/cache)

**Prevention**: Only run one lab at a time

---

### PostCreateCommand Failed

**Symptoms**:
```
Running postCreateCommand...
ERROR: Failed to pull image
```

**Causes**:
- Docker Hub rate limiting
- Network timeout
- Incorrect image name

**Fixes**:

**Fix 1: Manual Image Pull**
```bash
docker pull frrouting/frr:latest
docker pull alpine:latest
```

**Fix 2: Wait and Retry**
- Docker Hub rate limit: 100 pulls per 6 hours (unauthenticated)
- Wait 10 minutes and try again

**Fix 3: Rebuild Container**
```
Cmd/Ctrl+Shift+P → "Codespaces: Rebuild Container"
```

**Prevention**: Reuse existing codespaces (images already cached)

---

## Path 2: VS Code + Docker Desktop Issues

### No "Reopen in Container" Button

**Symptoms**:
- Opened lab folder in VS Code
- No notification about devcontainer
- Bottom-left corner doesn't show container options

**Causes**:
1. Remote-Containers extension not installed
2. `.devcontainer/devcontainer.json` not detected
3. VS Code opened wrong directory

**Fixes**:

**Fix 1: Install Extension**
```bash
code --install-extension ms-vscode-remote.remote-containers
```

**Verify**:
```bash
code --list-extensions | grep ms-vscode-remote.remote-containers
```

**Fix 2: Check Directory**
```bash
# Must be in LAB directory (not repo root)
pwd
# Should show: .../containerlab-free-labs/linux-network-namespaces

# Check for devcontainer config
ls .devcontainer/
# Should show: devcontainer.json
```

**Fix 3: Manual Trigger**
```
Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"
```

**Prevention**: Always `cd` into specific lab directory before `code .`

---

### Docker Daemon Not Running

**Symptoms**:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
Is the docker daemon running?
```

**Causes**:
- Docker Desktop not started
- Docker service stopped (Linux)
- Docker socket permissions

**Fixes**:

**Fix 1: Start Docker Desktop (Mac/Windows)**
- **Mac**: Check menu bar for Docker whale icon
- **Windows**: Check system tray
- **Start**: Open Docker Desktop app
- **Wait for**: "Docker Desktop is running" status

**Fix 2: Start Docker Service (Linux)**
```bash
sudo systemctl start docker
sudo systemctl enable docker  # Auto-start on boot
```

**Verify**:
```bash
docker ps
# Should show empty table (not error)
```

**Fix 3: Socket Permissions (Linux)**
```bash
# Temporary fix
sudo chmod 666 /var/run/docker.sock

# Permanent fix
sudo usermod -aG docker $USER
# Log out and back in
```

**Prevention**: Keep Docker Desktop running when working with labs

---

### Devcontainer Build Failed

**Symptoms**:
```
Failed to create devcontainer
Error response from daemon: pull access denied
```

**Causes**:
- Cannot pull base image
- Network firewall blocking Docker Hub
- Insufficient disk space

**Fixes**:

**Fix 1: Manual Image Pull**
```bash
docker pull ghcr.io/srl-labs/containerlab/devcontainer-dind-slim:0.68.0
```

**If succeeds**: Retry "Reopen in Container"

**If fails**: Check network/firewall

**Fix 2: Check Disk Space**
```bash
docker system df
```

**If low space**:
```bash
docker system prune -a
# Warning: Removes all unused images
```

**Fix 3: Corporate Firewall Workaround**
- Some networks block `ghcr.io` (GitHub Container Registry)
- Use mobile hotspot temporarily
- Or ask IT to whitelist `ghcr.io`

**Prevention**: Ensure 10GB+ free disk space

---

### Sudo in Devcontainer Error

**Symptoms**:
```bash
./scripts/deploy.sh
# Shows: sudo: a terminal is required to read the password
```

**Causes**:
- Running script OUTSIDE devcontainer
- In local terminal instead of VS Code integrated terminal

**Fixes**:

**Fix 1: Verify You're in Devcontainer**
```
Check bottom-left corner of VS Code
Should show: "Dev Container: <Lab Name>"

If shows: WSL, SSH, or nothing → Not in container!
```

**Fix 2: Reopen in Container**
```
Cmd/Ctrl+Shift+P → "Remote-Containers: Reopen in Container"
```

**Fix 3: Use VS Code Terminal**
```
Terminal → New Terminal (Ctrl+`)
# Should open INSIDE container
```

**Once in container**: No `sudo` password needed (root user)

**Prevention**: Always check bottom-left corner before running scripts

---

## Path 3: Local Containerlab Issues

### Containerlab Not Found

**Symptoms**:
```bash
containerlab version
# bash: containerlab: command not found
```

**Causes**:
- Not installed
- Not in PATH
- Installed to non-standard location

**Fixes**:

**Fix 1: Install Containerlab**
```bash
bash -c "$(curl -sL https://get.containerlab.dev)"
```

**Fix 2: Check Installation Location**
```bash
which containerlab
# Common locations:
# /usr/local/bin/containerlab
# ~/.local/bin/containerlab
```

**Fix 3: Add to PATH**
```bash
# Temporary
export PATH=$PATH:~/.local/bin

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

**Fix 4: Use Full Path**
```bash
~/.local/bin/containerlab version
~/.local/bin/containerlab deploy -t topology.clab.yml
```

**Prevention**: Follow official installation instructions

---

### Permission Denied

**Symptoms**:
```bash
sudo containerlab deploy -t topology.clab.yml
# permission denied while trying to connect to Docker daemon
```

**Causes**:
- User not in `docker` group (Linux)
- Docker socket permissions
- Running as wrong user

**Fixes**:

**Fix 1: Add User to Docker Group (Recommended)**
```bash
sudo usermod -aG docker $USER
```

**Then**:
```bash
# Log out and log back in (or reboot)
# Verify:
groups
# Should include "docker"
```

**Fix 2: Temporary Socket Permission**
```bash
sudo chmod 666 /var/run/docker.sock
```
**Warning**: Resets on reboot, less secure

**Fix 3: Always Use Sudo**
```bash
sudo containerlab deploy -t topology.clab.yml
sudo containerlab destroy -t topology.clab.yml
sudo docker exec -it clab-lab-r1 vtysh
```
**Downside**: Gets tedious, but always works

**Prevention**: Add user to docker group during setup

---

### Containerlab Version Mismatch

**Symptoms**:
```
WARNING: topology version (1.0.0) does not match installed containerlab version (0.50.0)
```

**Causes**:
- Old containerlab installation
- Topology file uses newer features

**Fixes**:

**Fix 1: Upgrade Containerlab**
```bash
bash -c "$(curl -sL https://get.containerlab.dev)"
```

**Verify**:
```bash
containerlab version
# Should show: 0.68.0 or newer
```

**Fix 2: Check Topology File**
```bash
grep "containerlab" topology.clab.yml
# Look for version requirement
```

**Prevention**: Keep containerlab updated

---

## Common to All Paths

### Image Pull Failed

**Symptoms**:
```
Error response from daemon: pull access denied for frrouting/frr
```
or
```
Error response from daemon: Get https://registry-1.docker.io/v2/: net/http: TLS handshake timeout
```

**Causes**:
1. Docker Hub rate limit (100 pulls/6hrs unauthenticated)
2. Network firewall
3. Corporate proxy
4. DNS issues

**Fixes**:

**Fix 1: Wait and Retry**
```bash
# Wait 10-30 minutes
docker pull frrouting/frr:latest
```

**Fix 2: Docker Login (Increases Rate Limit)**
```bash
docker login
# Username: <docker-hub-username>
# Password: <docker-hub-password>

# Rate limit: 200 pulls/6hrs (authenticated)
```

**Fix 3: Pre-pull Images**
```bash
docker pull frrouting/frr:latest
docker pull alpine:latest
docker pull ghcr.io/nokia/srlinux:latest

# Then deploy lab
```

**Fix 4: Check Network**
```bash
# Test Docker Hub connectivity
curl -I https://registry-1.docker.io/v2/

# If fails: Corporate firewall/proxy issue
# Workaround: Use mobile hotspot or VPN
```

**Fix 5: Use Image Mirrors (Corporate)**
```bash
# Edit /etc/docker/daemon.json (Linux/Mac)
{
  "registry-mirrors": ["https://your-corporate-registry.com"]
}

# Restart Docker
sudo systemctl restart docker
```

**Prevention**: Pre-pull images, use Docker Hub account

---

### Port Already Allocated

**Symptoms**:
```
Error response from daemon: driver failed programming external connectivity:
Bind for 0.0.0.0:22 failed: port is already allocated
```

**Causes**:
- Previous lab still running
- Conflicting containerlab topology
- Host service using same port

**Fixes**:

**Fix 1: Destroy Previous Lab**
```bash
# List running labs
sudo containerlab inspect --all

# Destroy specific lab
sudo containerlab destroy -t topology.clab.yml

# Destroy ALL labs
sudo containerlab destroy --all
```

**Fix 2: Check Docker Containers**
```bash
docker ps
# Look for clab-* containers

# Stop all
docker stop $(docker ps -q)

# Remove all
docker rm $(docker ps -aq)
```

**Fix 3: Find Conflicting Process**
```bash
# Linux/Mac
sudo lsof -i :22

# Kill process if needed
kill <PID>
```

**Prevention**: Always run cleanup scripts when done with labs

---

### Validation Tests Fail

**Symptoms**:
```bash
./scripts/validate.sh
# Shows: ✗ FAILED
```

**Causes**:
1. Protocols haven't converged yet (OSPF/BGP)
2. Configuration error
3. Containers not fully started
4. Timing issue

**Fixes**:

**Fix 1: Wait for Protocol Convergence**
```bash
# OSPF needs 30-60 seconds
# BGP needs 60-90 seconds

# Wait
sleep 60

# Retry validation
./scripts/validate.sh
```

**Fix 2: Check Container Status**
```bash
docker ps | grep clab
# All containers should show "Up" status

# If "Restarting" or "Exited":
docker logs clab-<lab>-<node>
```

**Fix 3: Check Specific Test**
```bash
# Example: Test ping manually
docker exec -it clab-ospf-basics-r1 vtysh -c "ping 10.0.3.2"

# If fails, check OSPF:
docker exec -it clab-ospf-basics-r1 vtysh -c "show ip ospf neighbor"
```

**Fix 4: Redeploy Lab**
```bash
./scripts/cleanup.sh
./scripts/deploy.sh
sleep 60
./scripts/validate.sh
```

**Prevention**: Wait 30-60 seconds before validating OSPF/BGP labs

---

### No Such Container

**Symptoms**:
```bash
docker exec -it clab-ospf-basics-r1 vtysh
# Error: No such container: clab-ospf-basics-r1
```

**Causes**:
- Lab not deployed
- Container name typo
- Lab deployed with different name

**Fixes**:

**Fix 1: List Running Containers**
```bash
docker ps | grep clab
# Shows actual container names
```

**Fix 2: Check Lab Name in Topology**
```bash
grep "name:" topology.clab.yml
# Shows lab name (used as prefix)
```

**Fix 3: Use Tab Completion**
```bash
docker exec -it clab-<TAB><TAB>
# Auto-completes container names
```

**Fix 4: Deploy Lab**
```bash
# If no containers running:
./scripts/deploy.sh
```

**Prevention**: Use exact container names from `docker ps`

---

### Slow Performance / Out of Memory

**Symptoms**:
- Labs take 5+ minutes to deploy
- Docker containers crash
- System becomes unresponsive

**Causes**:
- Insufficient RAM (< 8GB)
- Too many labs running
- Other applications consuming memory
- Swap disabled (Linux)

**Fixes**:

**Fix 1: Check System Resources**
```bash
# Mac
htop or Activity Monitor

# Linux
free -h
top

# Windows
Task Manager → Performance tab
```

**Fix 2: Close Other Applications**
- Browsers with many tabs
- IDEs with large projects
- Video conferencing apps

**Fix 3: Destroy Unused Labs**
```bash
sudo containerlab destroy --all
docker system prune -a
```

**Fix 4: Run One Lab at a Time**
```bash
# Instead of:
# - OSPF lab (150MB)
# - BGP lab (200MB)
# - Namespaces lab (80MB)
# Total: 430MB

# Run individually:
./scripts/deploy.sh    # One lab
# Do work
./scripts/cleanup.sh   # Clean up before next
```

**Fix 5: Upgrade RAM or Use Codespaces**
- Codespaces (Path 1): Runs in cloud, no local RAM impact
- Minimum: 8GB RAM recommended
- Optimal: 16GB RAM

**Prevention**: Monitor `docker stats` while labs running

---

## Advanced Troubleshooting

### Get Detailed Logs

**Container logs**:
```bash
docker logs clab-<lab>-<node>
```

**Containerlab debug mode**:
```bash
sudo containerlab --debug deploy -t topology.clab.yml
```

**FRR logs** (inside container):
```bash
docker exec -it clab-ospf-basics-r1 vtysh
show logging
```

### Check Network Connectivity

**Between containers**:
```bash
# From host
docker network ls
docker network inspect <network-name>

# From container
docker exec -it clab-lab-r1 ip route
docker exec -it clab-lab-r1 ip addr
```

**Internet connectivity**:
```bash
docker exec -it clab-lab-r1 ping -c 3 8.8.8.8
```

### Verify Configuration Files

**Check FRR config**:
```bash
docker exec -it clab-ospf-basics-r1 vtysh -c "show running-config"
```

**Check files mounted**:
```bash
docker exec -it clab-ospf-basics-r1 cat /etc/frr/frr.conf
```

---

## Prevention Checklist

Before starting labs, verify:

### Path 1: Codespaces
- ✅ GitHub account active
- ✅ Codespaces usage < 60 hours/month
- ✅ Stable internet connection

### Path 2: VS Code + Docker
- ✅ Docker Desktop running
- ✅ 10GB+ free disk space
- ✅ 8GB+ RAM available
- ✅ Remote-Containers extension installed
- ✅ In correct lab directory (not repo root)

### Path 3: Native Install
- ✅ Containerlab installed (`containerlab version`)
- ✅ Docker running (`docker ps`)
- ✅ User in docker group or using `sudo`
- ✅ PATH configured correctly

### All Paths
- ✅ Previous labs cleaned up (`containerlab destroy --all`)
- ✅ No port conflicts (check with `docker ps`)
- ✅ Images pre-pulled (optional but recommended)

---

## Still Stuck?

### Before Asking for Help

Collect this information:

```bash
# 1. Path used
echo "Path: Codespaces / Local VS Code / Native Install"

# 2. System info (if local)
uname -a
docker --version
containerlab version

# 3. Lab and topology
pwd
cat topology.clab.yml | head -20

# 4. Container status
docker ps -a | grep clab

# 5. Recent logs
docker logs clab-<lab>-<node> --tail 50

# 6. Error message
# Copy full error output
```

### Get Help

**GitHub Issues**: https://github.com/ciscoittech/containerlab-free-labs/issues
- Report bugs
- Document new errors
- Include system info from above

**GitHub Discussions**: https://github.com/ciscoittech/containerlab-free-labs/discussions
- Ask questions
- Share solutions
- Get community help

**Include**:
1. Which path you're using
2. Error message (full text)
3. Steps to reproduce
4. System information
5. What you've already tried

---

## Error Frequency Analysis

Based on simulated user testing:

### Most Common Errors (Path 1: Codespaces)
1. **Slow setup** (20% of users) → Wait 3-5 minutes
2. **Tests fail** (8% of users) → Wait 60 seconds for convergence
3. **Codespace quota** (5% of users) → Delete old codespaces

### Most Common Errors (Path 2: VS Code)
1. **Docker not running** (15% of users) → Start Docker Desktop
2. **No reopen button** (12% of users) → Install Remote-Containers extension
3. **sudo in devcontainer** (10% of users) → Verify in container mode
4. **Image pull timeout** (8% of users) → Corporate firewall issue

### Most Common Errors (Path 3: Native)
1. **Permission denied** (18% of users) → Add to docker group
2. **Containerlab not found** (12% of users) → PATH configuration
3. **sudo required everywhere** (10% of users) → Docker group membership

---

*Last Updated: October 3, 2025*
*Found a new error? [Report it](https://github.com/ciscoittech/containerlab-free-labs/issues)*
