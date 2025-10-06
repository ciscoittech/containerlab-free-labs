#!/bin/bash
# Build frr-ssh image in GitHub Codespaces

echo "Creating temporary build directory..."
mkdir -p /tmp/frr-ssh-build
cd /tmp/frr-ssh-build

echo "Creating Dockerfile..."
cat > Dockerfile << 'DOCKERFILE'
# Custom FRR Image with SSH Support
# Base image: FRRouting latest stable
FROM frrouting/frr:latest

# Install OpenSSH server and utilities (Alpine Linux uses apk)
RUN apk add --no-cache \
    openssh \
    openssh-server \
    iproute2 \
    iputils \
    tcpdump \
    vim \
    nano \
    sudo \
    bash

# Create SSH directory
RUN mkdir -p /var/run/sshd

# Create cisco user with password and bash shell
RUN adduser -D -s /bin/bash cisco && \
    echo 'cisco:cisco' | chpasswd && \
    addgroup cisco frrvty

# Allow cisco user to access vtysh without password
RUN echo 'cisco ALL=(ALL) NOPASSWD: /usr/bin/vtysh' >> /etc/sudoers

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# Create vtysh wrapper for cisco user
RUN echo '#!/bin/bash' > /usr/local/bin/vtysh-cisco && \
    echo 'sudo /usr/bin/vtysh "$@"' >> /usr/local/bin/vtysh-cisco && \
    chmod +x /usr/local/bin/vtysh-cisco

# Ensure FRR config directory exists and has proper permissions
RUN mkdir -p /etc/frr && \
    touch /etc/frr/frr.conf && \
    touch /etc/frr/daemons && \
    chown -R frr:frr /etc/frr && \
    chmod 640 /etc/frr/frr.conf && \
    chmod 640 /etc/frr/daemons

# Add vtysh to cisco's PATH and auto-start vtysh on SSH login
# Use .bash_profile for login shells (SSH) instead of .bashrc
RUN echo 'alias vtysh="sudo /usr/bin/vtysh"' >> /home/cisco/.bash_profile && \
    echo 'export PATH=$PATH:/usr/local/bin' >> /home/cisco/.bash_profile && \
    echo '# Auto-start vtysh on SSH login (like real routers)' >> /home/cisco/.bash_profile && \
    echo 'exec sudo /usr/bin/vtysh' >> /home/cisco/.bash_profile

# Expose SSH port
EXPOSE 22

# Copy custom entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
DOCKERFILE

echo "Creating entrypoint.sh..."
cat > entrypoint.sh << 'ENTRYPOINT'
#!/bin/bash
set -e

# Start SSH daemon
echo "Starting SSH daemon..."
/usr/sbin/sshd

# Wait a moment for SSH to initialize
sleep 1

# Start FRR daemons (preserve original FRR behavior)
echo "Starting FRR daemons..."
exec /usr/lib/frr/docker-start
ENTRYPOINT

chmod +x entrypoint.sh

echo "Building frr-ssh:latest image..."
docker buildx build --platform linux/amd64 --load -t frr-ssh:latest .

echo ""
echo "✅ frr-ssh:latest image built successfully!"
echo ""
echo "Cleanup..."
cd /
rm -rf /tmp/frr-ssh-build

echo "✅ Ready to deploy labs!"
