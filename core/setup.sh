#!/usr/bin/env bash
set -e

# === CONFIGURAÇÕES INICIAIS ===
TRAEFIK_DOMAIN="traefik.seu-dominio.com"
PORTAINER_DOMAIN="portainer.seu-dominio.com"
LETSENCRYPT_EMAIL="seu.email@dominio.com"
AUTH_USER="admin"
AUTH_PASS="admin123"
TZ="America/Sao_Paulo"

# === CRIAR .env ===
echo ">> Criando arquivo .env..."
cat > .env <<EOF
# ---------------------------------------------------------------------
# Docker Traefik Portainer - Environment configuration
# ---------------------------------------------------------------------

TRAEFIK_CONTAINER_NAME=traefik
PORTAINER_CONTAINER_NAME=portainer

HTTP_PORT=80
HTTPS_PORT=443
PORTAINER_PORT=9000

TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN}
PORTAINER_DOMAIN=${PORTAINER_DOMAIN}

LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}

BASIC_AUTH_FILE=/configurations/.htpasswd

TZ=${TZ}
EOF

echo "[OK] .env criado em $(pwd)/.env"

# === CRIAR ARQUIVOS ESSENCIAIS ===
echo ">> Criando acme.json e setando permissões..."
mkdir -p traefik-data/configurations
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json
chown root:root traefik-data/acme.json 2>/dev/null || true

# === CRIAR REDE DOCKER ===
echo ">> Criando rede 'proxy' (se não existir)..."
docker network create proxy >/dev/null 2>&1 || echo "Rede proxy já existe."

# === GERAR .htpasswd ===
echo ">> Gerando arquivo .htpasswd..."
htpasswd -nbB "${AUTH_USER}" "${AUTH_PASS}" > traefik-data/configurations/.htpasswd
echo "[OK] Usuário: ${AUTH_USER} | Senha: ${AUTH_PASS}"

# === SUBIR CONTAINERS ===
echo ">> Subindo containers..."
docker compose down -v --remove-orphans >/dev/null 2>&1 || true
docker compose up -d

echo
echo "=============================================================="
echo "Setup concluído!"
echo
echo "  Traefik Dashboard:  https://${TRAEFIK_DOMAIN}"
echo "  Portainer:          https://${PORTAINER_DOMAIN}"
echo "  Login BasicAuth:    ${AUTH_USER} / ${AUTH_PASS}"
echo
echo "Logs do Traefik:"
docker compose logs -f traefik
