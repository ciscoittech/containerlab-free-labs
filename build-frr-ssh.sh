#!/bin/bash
# Build the frr-ssh image used by the OSPF, BGP and enterprise-VPN labs.
#
# The image gives each FRR router an `admin` account that lands straight in the
# router CLI over SSH, the way a real Cisco/Juniper box does.
set -euo pipefail

# Pinned, multi-arch (amd64 + arm64). docker.io/frrouting/frr is amd64-only,
# which is why the labs could not run natively on Apple Silicon.
FRR_BASE="${FRR_BASE:-quay.io/frrouting/frr:10.4.4}"
IMAGE="${IMAGE:-frr-ssh:latest}"

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

echo "Building $IMAGE from $FRR_BASE ..."

cat > "$BUILD_DIR/Dockerfile" <<DOCKERFILE
FROM ${FRR_BASE}

RUN apk add --no-cache \
    openssh openssh-server iproute2 iputils tcpdump vim nano sudo bash

RUN mkdir -p /var/run/sshd

# Router CLI as a login shell.
#
# sshd runs the user's login shell as \`\$SHELL -c "<command>"\` for a remote
# command, and bare for an interactive session. Handling both here is what makes
#   ssh admin@r1                          -> lands at "r1#"
#   ssh admin@r1 "show ip ospf neighbor"  -> returns parseable output
# work. The old approach put \`exec vtysh\` in ~/.bash_profile, which sshd never
# sources for a remote command, so every scripted SSH call hit bash instead.
RUN printf '%s\n' \
      '#!/bin/sh' \
      '[ "\$1" = "-c" ] && { shift; exec sudo /usr/bin/vtysh -c "\$*"; }' \
      'exec sudo /usr/bin/vtysh' \
    > /usr/local/bin/vtysh-shell \
 && chmod +x /usr/local/bin/vtysh-shell \
 && echo /usr/local/bin/vtysh-shell >> /etc/shells

RUN adduser -D -s /usr/local/bin/vtysh-shell admin \
 && echo 'admin:cisco' | chpasswd \
 && addgroup admin frrvty \
 && echo 'admin ALL=(ALL) NOPASSWD: /usr/bin/vtysh' >> /etc/sudoers

# \`admin\` has no shell, so scp/sftp and VS Code Remote-SSH cannot use it.
# \`labshell\` keeps that capability without weakening the router-CLI experience.
RUN adduser -D -s /bin/bash labshell \
 && echo 'labshell:cisco' | chpasswd \
 && echo 'labshell ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
 && ssh-keygen -A

RUN mkdir -p /etc/frr \
 && touch /etc/frr/frr.conf /etc/frr/daemons /etc/frr/vtysh.conf \
 && chown -R frr:frr /etc/frr \
 && chmod 640 /etc/frr/frr.conf /etc/frr/daemons \
 && chmod 644 /etc/frr/vtysh.conf

EXPOSE 22

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
DOCKERFILE

cat > "$BUILD_DIR/entrypoint.sh" <<'ENTRYPOINT'
#!/bin/bash
set -e
/usr/sbin/sshd
exec /usr/lib/frr/docker-start
ENTRYPOINT
chmod +x "$BUILD_DIR/entrypoint.sh"

# No --platform: build for the host arch so the labs run natively on both
# x86_64 CI runners and Apple Silicon.
docker build -t "$IMAGE" "$BUILD_DIR"

echo
echo "Built $IMAGE — ready to deploy labs."
