#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Instala Docker Engine + Compose Plugin (Ubuntu)
# -------------------------------------------------------------------

echo "===> Atualizando sistema..."
sudo apt update -y
sudo apt upgrade -y

echo "===> Removendo versões antigas (se existirem)..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

echo "===> Instalando dependências..."
sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

echo "===> Adicionando chave GPG oficial do Docker..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "===> Adicionando repositório Docker ao APT..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "===> Atualizando índices de pacotes..."
sudo apt update -y

echo "===> Instalando Docker Engine, CLI, containerd e Compose plugin..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "===> Habilitando e iniciando serviço Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "===> Verificando status do serviço..."
sudo systemctl --no-pager status docker | grep Active

CURRENT_USER=$(logname 2>/dev/null || echo "$USER")

echo "===> Adicionando usuário '$CURRENT_USER' ao grupo 'docker'..."
sudo usermod -aG docker "$CURRENT_USER"

if command -v newgrp >/dev/null 2>&1; then
  echo "===> Aplicando grupo docker na sessão atual..."
  newgrp docker <<EONG
echo "===> Testando Docker sem sudo..."
docker run --rm hello-world
EONG
else
  echo "===> newgrp não encontrado — faça logout/login para aplicar grupo docker."
fi

echo "===> Testando versões..."
docker version
docker compose version

echo
echo "=========================================================="
echo "Docker instalado e configurado com sucesso!"
echo
echo "Usuário '$CURRENT_USER' já faz parte do grupo docker."
echo "Você pode usar Docker e Docker Compose sem sudo."
echo
echo "Agora pode rodar o script setup.sh para Traefik + Portainer."
echo "=========================================================="