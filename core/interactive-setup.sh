#!/usr/bin/env bash
set -euo pipefail

# --- helpers --------------------------------------------------------------
command_exists() { command -v "$1" >/dev/null 2>&1; }
abort() { echo "ERRO: $*" >&2; exit 1; }
info()  { echo ">> $*"; }

# --- pré-checagens --------------------------------------------------------
[[ $EUID -ne 0 ]] && abort "rode como root: sudo bash setup.sh"

command_exists docker || abort "docker não encontrado."
command_exists htpasswd || abort "htpasswd não encontrado (instale: sudo apt-get install -y apache2-utils)."

if ! docker compose version >/dev/null 2>&1; then
  abort "docker compose V2 não encontrado (use 'docker compose', não 'docker-compose')."
fi

cd "$(dirname "$0")"

# --- perguntas ------------------------------------------------------------
read -r -p "Domínio do Traefik [traefik.seu-dominio.com]: " TRAEFIK_DOMAIN
TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN:-traefik.seu-dominio.com}

read -r -p "Domínio do Portainer [portainer.seu-dominio.com]: " PORTAINER_DOMAIN
PORTAINER_DOMAIN=${PORTAINER_DOMAIN:-portainer.seu-dominio.com}

read -r -p "E-mail para Let's Encrypt (obrigatório): " LETSENCRYPT_EMAIL
[[ -z "${LETSENCRYPT_EMAIL}" ]] && abort "e-mail é obrigatório."
# validação simples de e-mail
[[ "${LETSENCRYPT_EMAIL}" =~ ^[^@]+@[^@]+\.[^@]+$ ]] || abort "e-mail inválido."

read -r -p "Usuário BasicAuth [.admin]: " AUTH_USER
AUTH_USER=${AUTH_USER:-.admin} && AUTH_USER=${AUTH_USER#.}  # remove ponto inicial se sobrou

# senha sem echo
read -r -s -p "Senha BasicAuth: " AUTH_PASS_1; echo
read -r -s -p "Confirme a senha: " AUTH_PASS_2; echo
[[ "${AUTH_PASS_1}" != "${AUTH_PASS_2}" ]] && abort "senhas não conferem."
AUTH_PASS="${AUTH_PASS_1}"

read -r -p "Timezone [America/Sao_Paulo]: " TZ
TZ=${TZ:-America/Sao_Paulo}

read -r -p "Rede docker (externa) [proxy]: " DOCKER_NETWORK
DOCKER_NETWORK=${DOCKER_NETWORK:-proxy}

read -r -p "Porta HTTP pública [80]: " HTTP_PORT
HTTP_PORT=${HTTP_PORT:-80}

read -r -p "Porta HTTPS pública [443]: " HTTPS_PORT
HTTPS_PORT=${HTTPS_PORT:-443}

read -r -p "Porta interna Portainer [9000]: " PORTAINER_PORT
PORTAINER_PORT=${PORTAINER_PORT:-9000}

# --- gerar .env -----------------------------------------------------------
info "gerando .env ..."
[[ -f .env ]] && cp -f .env ".env.bak.$(date +%Y%m%d%H%M%S)"

cat > .env <<EOF
DOCKER_NETWORK=${DOCKER_NETWORK}

TRAEFIK_CONTAINER_NAME=traefik
PORTAINER_CONTAINER_NAME=portainer

HTTP_PORT=${HTTP_PORT}
HTTPS_PORT=${HTTPS_PORT}
PORTAINER_PORT=${PORTAINER_PORT}

TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN}
PORTAINER_DOMAIN=${PORTAINER_DOMAIN}

LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}

# htpasswd via usersFile
BASIC_AUTH_FILE=/configurations/.htpasswd

TZ=${TZ}
EOF
info ".env criado em $(pwd)/.env"

# --- preparar pastas/arquivos --------------------------------------------
info "preparando pastas ..."
mkdir -p traefik-data/configurations

info "criando/ajustando acme.json ..."
touch traefik-data/acme.json
chmod 600 traefik-data/acme.json
chown root:root traefik-data/acme.json || true

# --- criar rede docker ----------------------------------------------------
info "criando rede '${DOCKER_NETWORK}' (se não existir) ..."
docker network create "${DOCKER_NETWORK}" >/dev/null 2>&1 || true

# --- gerar .htpasswd ------------------------------------------------------
info "gerando traefik-data/configurations/.htpasswd ..."
htpasswd -nbB "${AUTH_USER}" "${AUTH_PASS}" > traefik-data/configurations/.htpasswd

# --- subir stack ----------------------------------------------------------
info "subindo containers ..."
docker compose down -v --remove-orphans >/dev/null 2>&1 || true
docker compose up -d

echo
echo "=============================================================="
echo "Setup concluído!"
echo
echo "  Traefik Dashboard:  https://${TRAEFIK_DOMAIN}"
echo "  Portainer:          https://${PORTAINER_DOMAIN}"
echo "  BasicAuth:          ${AUTH_USER} / (senha que você definiu)"
echo
echo "Dica: garanta DNS -> IP do servidor e portas ${HTTP_PORT}/${HTTPS_PORT} liberadas."
echo "Logs do Traefik (Ctrl+C para sair):"
echo "=============================================================="
docker compose logs -f traefik