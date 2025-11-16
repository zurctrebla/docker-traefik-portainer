# Traefik + Portainer com Docker Compose

Stack completa de gerenciamento Docker com reverse proxy Traefik e Portainer.

## Características

✅ Configuração 100% via Docker Compose (sem arquivos externos)
✅ SSL automático via Let's Encrypt
✅ HTTP/2 e TLS 1.3
✅ BasicAuth em todos os serviços
✅ Security Headers (HSTS, XSS Protection, etc)
✅ Subdomínios automáticos

## Requisitos

- Docker Engine
- Docker Compose v2
- apache2-utils (para htpasswd)
- Portas 80 e 443 abertas
- DNS configurado apontando para o servidor

## Instalação Rápida

### 1. Instalar Docker (se necessário)
```bash
sudo bash install-docker.sh
```

### 2. Setup Interativo (Recomendado)
```bash
sudo bash interactive-setup.sh
```

### 3. Ou Setup Rápido
Edite o arquivo `setup.sh` (linhas 6-10):
```bash
DOMAIN="seu-dominio.com"
LETSENCRYPT_EMAIL="seu.email@dominio.com"
AUTH_USER="admin"
AUTH_PASS="sua-senha-segura"
```

Execute:
```bash
sudo bash setup.sh
```

## Acessos

Após o setup, acesse:

- **Traefik Dashboard:** https://traefik.seu-dominio.com
- **Portainer:** https://portainer.seu-dominio.com

**Credenciais:** As que você definiu no setup

## Estrutura de Arquivos

```
core/
├── docker-compose.yml       # Configuração principal
├── setup.sh                 # Setup rápido
├── interactive-setup.sh     # Setup interativo
├── install-docker.sh        # Instalador Docker
├── .env.example            # Exemplo de configuração
└── traefik-data/
    └── acme.json           # Certificados SSL
```

## Comandos Úteis

```bash
# Ver logs
docker compose logs -f

# Reiniciar
docker compose restart

# Parar
docker compose down

# Atualizar
docker compose pull
docker compose up -d
```

## DNS

Configure os registros DNS:

```
traefik.seu-dominio.com    A    SEU_IP_SERVIDOR
portainer.seu-dominio.com  A    SEU_IP_SERVIDOR
```

## Troubleshooting

### Certificados não geram
- Verifique se o DNS está propagado: `nslookup traefik.seu-dominio.com`
- Verifique se as portas 80/443 estão abertas
- Veja os logs: `docker logs traefik`

### Dashboard não abre
- Limpe o cache do navegador (Ctrl+Shift+Del)
- Tente em modo anônimo
- Verifique as credenciais BasicAuth

### Erro de permissão
- Rode com sudo: `sudo bash setup.sh`
- Ou adicione seu usuário ao grupo docker: `sudo usermod -aG docker $USER`

## Segurança

- ✅ HTTPS forçado
- ✅ BasicAuth em todos os endpoints
- ✅ Security headers habilitados
- ✅ Certificados renovados automaticamente
- ✅ no-new-privileges habilitado
