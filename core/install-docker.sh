#!/bin/bash
set -e

echo "🚀 Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "🔑 Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "📦 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔁 Updating package list..."
sudo apt update -y

echo "🐋 Installing Docker Engine and Compose plugin..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🧰 Installing apache2-utils (for htpasswd)..."
sudo apt-get install -y apache2-utils

echo "✅ Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "🔄 Applying docker group without reboot..."
newgrp docker <<EONG
echo "⚙️ Docker version:"
docker version

echo "⚙️ Docker Compose version:"
docker compose version
EONG

echo "🎉 Docker installation complete!"
echo "You can now run Docker and Docker Compose without sudo."
