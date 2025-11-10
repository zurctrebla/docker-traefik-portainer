# 🐳 Docker + Traefik + Portainer Setup

A simple and fully automated setup for **Docker**, **Traefik**, and **Portainer**, with automatic HTTPS (Let's Encrypt) and Basic Authentication.

---

## 🥇 Step 1 — Clone the Project

Clone the repository and enter the core directory:

```bash
git clone https://github.com/zurctrebla/docker-traefik-portainer ./src
cd src/core
```

---

## 🥈 Step 2 — Install Docker

Run the Docker installation script:

```bash
sudo bash install-docker.sh
```

This script will:

* Update the system;
* Install **Docker Engine** and **Docker Compose Plugin**;
* Enable and start the Docker service;
* Add your user to the `docker` group;
* Test the installation.

After this step, Docker will be ready to use **without sudo**.

---

## 🥉 Step 3 — Run the Configuration Script

Execute the setup script to configure **Traefik** and **Portainer**:

```bash
sudo bash interactive-setup.sh
```

You will be asked for:

* Traefik domain (example: `traefik.yourdomain.com`)
* Portainer domain (example: `portainer.yourdomain.com`)
* Email for Let's Encrypt (example: `admin@yourdomain.com`)
* BasicAuth username and password
* Timezone (example: `America/Sao_Paulo`)
* HTTP/HTTPS ports (80/443)

After completion, access your services:

| Service               | URL                                                                  | Credentials                                       |
| --------------------- | -------------------------------------------------------------------- | ------------------------------------------------- |
| **Traefik Dashboard** | [https://traefik.yourdomain.com](https://traefik.yourdomain.com)     | `admin / admin123` *(or your custom credentials)* |
| **Portainer**         | [https://portainer.yourdomain.com](https://portainer.yourdomain.com) | *(create user on first login)*                    |

---

🛠️ **Done!**
Your environment — **Docker + Traefik + Portainer** — is installed, configured, and ready to use.
