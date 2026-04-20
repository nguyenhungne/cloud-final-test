#!/bin/bash

# MyMiniCloud - Docker and Docker Compose Installation Script for Ubuntu
# This script installs Docker Engine and Docker Compose on Ubuntu 20.04/22.04

set -e

echo "=========================================="
echo "MyMiniCloud Docker Installation Script"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Please do not run this script as root or with sudo"
    echo "The script will prompt for sudo password when needed"
    exit 1
fi

# Check Ubuntu version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    echo "Detected OS: $OS $VER"
else
    echo "Cannot detect OS version"
    exit 1
fi

if [[ "$OS" != *"Ubuntu"* ]]; then
    echo "This script is designed for Ubuntu only"
    exit 1
fi

echo ""
echo "Step 1: Updating package index..."
sudo apt-get update

echo ""
echo "Step 2: Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo ""
echo "Step 3: Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo ""
echo "Step 4: Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ""
echo "Step 5: Installing Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ""
echo "Step 6: Adding current user to docker group..."
sudo usermod -aG docker $USER

echo ""
echo "Step 7: Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "Step 8: Verifying installation..."
DOCKER_VERSION=$(docker --version)
COMPOSE_VERSION=$(docker compose version)

echo "✓ $DOCKER_VERSION"
echo "✓ $COMPOSE_VERSION"

echo ""
echo "=========================================="
echo "Installation completed successfully!"
echo "=========================================="
echo ""
echo "IMPORTANT: You need to log out and log back in for group changes to take effect"
echo "Or run: newgrp docker"
echo ""
echo "After logging back in, verify with:"
echo "  docker run hello-world"
echo ""
echo "Next steps:"
echo "  1. Clone the repository: git clone <repo-url>"
echo "  2. Navigate to project: cd hotenSVminicloud"
echo "  3. Build images: docker compose build"
echo "  4. Start services: docker compose up -d"
echo ""
