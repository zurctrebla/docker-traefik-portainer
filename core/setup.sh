#!/usr/bin/env bash
set -e

# === CONFIGURAÇÕES INICIAIS ===
# Edite estas variáveis antes de rodar o script
DOMAIN="seu-dominio.com"
LETSENCRYPT_EMAIL="seu.email@dominio.com"
AUTH_USER="admin"
AUTH_PASS="admin123"
TZ="America/Sao_Paulo"

# Subdomínios gerados automaticamente
TRAEFIK_DOMAIN="traefik.${DOMAIN}"
PORTAINER_DOMAIN="portainer.${DOMAIN}"

echo ">> Configurando domínios..."
echo "   Domínio base: ${DOMAIN}"
echo "   Traefik: ${TRAEFIK_DOMAIN}"
echo "   Portainer: ${PORTAINER_DOMAIN}"
echo

# === GERAR BASIC_AUTH_USERS ===
echo ">> Gerando hash de autenticação..."
BASIC_AUTH_HASH=$(htpasswd -nbB "${AUTH_USER}" "${AUTH_PASS}" | sed 's/\$/\$\$/g')
echo "[OK] Usuário: ${AUTH_USER} | Senha: ${AUTH_PASS}"

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

TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN}
PORTAINER_DOMAIN=${PORTAINER_DOMAIN}

LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}

BASIC_AUTH_USERS=${BASIC_AUTH_HASH}

TZ=${TZ}
EOF

echo "[OK] .env criado em $(pwd)/.env"

# === CRIAR ARQUIVOS ESSENCIAIS ===
echo ">> Criando acme.json e setando permissões..."
mkdir -p traefik-data
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json
chown $USER:$USER traefik-data/acme.json 2>/dev/null || true

# === CRIAR REDE DOCKER ===
echo ">> Criando rede 'proxy' (se não existir)..."
docker network create proxy >/dev/null 2>&1 || echo "Rede proxy já existe."

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
