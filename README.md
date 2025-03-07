![Screenshot (11)](https://github.com/user-attachments/assets/4ea5c69b-9d50-4bfb-a08c-dc5523d2a7a1)

# one-traefik-multiple-projects

This repo demonstrates how to use a single Traefik Docker container as a reverse proxy for multiple projects, each with different domains. Instead of manually installing and configuring a reverse proxy for a server, you can deploy this pre-configured Traefik container and easily add as many projects with as many domains as you need.

```
root/
├── traefik/
│ ├── docker-compose.yml
├── project-1/
│ ├── docker-compose.yml
├── project-2/
│ ├── docker-compose.yml
├── README.md
└── ... (additional projects)
```

## Prerequisites

Before getting started, ensure you have the following installed on your system:

- Docker - [How to install Docker](https://docs.docker.com/get-docker/) (version 20.10.0 or higher)
- Docker Compose - [How to install Docker Compose](https://docs.docker.com/compose/install/) (version 1.27.0 or higher)
- Git - [How to Install Git on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu)
- A registered domain name pointed to your server's IP address - [What are DNS Records?](https://www.cloudflare.com/learning/dns/dns-records/) - [What is a DNS A Record?](https://www.cloudflare.com/learning/dns/dns-records/dns-a-record/)
- Open ports `80` and `443` on your server - [How to Open a Port on a Linux Server Using UFW?](https://www.digitalocean.com/community/tutorials/opening-a-port-on-linux)

## Getting Started

Follow these steps to set up the Traefik reverse proxy and deploy multiple projects.

### 1. Clone the Repository

```bash
git clone https://github.com/sesto-dev/one-traefik-multiple-projects.git
```

### 2. Create Docker Network

Traefik and the projects need to communicate over a shared Docker network.

```bash
docker network create traefik-public
```

### 3. Traefik Docker Container

Set up the necessary environment variables for Traefik and each project.

```bash
cd one-traefik-multiple-projects/traefik
```

Create a `.env` file inside the `traefik` directory:

```bash
cp .env.example .env
nano .env
```

Edit the `.env` file to set your domain and other necessary variables.

```bash
USERNAME=your_admin_username
PASSWORD=your_admin_password
DOMAIN=yourdomain.com
ACME_EMAIL=youremail@domain.com
```

**Note:** To generate and set the hashed password in one command for Traefik's HTTP Basic Auth, you can use the following command:

```bash
export HASHED_PASSWORD=$(openssl passwd -apr1 $PASSWORD)
```

Then spin up your Traefik container:

```bash
docker compose up -d
```

### 4. Project Docker Containers

For each project, create a `.env` file based on the provided examples and enter the DOMAIN for that project.

```bash
cd ../project-1
cp .env.example .env
nano .env`
```

```bash
DOMAIN=project1.yourdomain.com
```

Then spin up the project container:

```bash
docker compose up -d
```

Repeat for project-2.

### 5. Verify the Setup

Open your browser and navigate to the domains you've configured. You should see the projects running correctly. You can also visit Traefik's dashboard at `https://traefik.yourdomain.com`.

## Production Deployment Guide

This section provides a comprehensive guide for deploying your Traefik setup with Cloudflare DNS in a production environment.

### 1. Production Configuration Files

The repository includes production-ready configuration files:

- `traefik/.env.production`: Contains production domain and Cloudflare credentials
- `portfolio/.env.production`: Contains production domain
- `deploy-production.sh`: Automates the deployment process
- `generate-password.sh`: Helper script to generate secure passwords

### 2. Pre-Deployment Checklist

Before deploying to production, make sure to:

#### Update Domain Names

Replace `yourdomain.com` in both `.env.production` files with your actual domain:

```bash
# In traefik/.env.production and portfolio/.env.production
DOMAIN=yourdomain.com
```

#### Generate a Secure Password

Generate a new hashed password for the Traefik dashboard:

```bash
# Using the provided script
./generate-password.sh

# Or directly with OpenSSL
openssl passwd -apr1 your_secure_password
```

Update the `HASHED_PASSWORD` in `traefik/.env.production` with the generated hash.

#### Verify Cloudflare Credentials

Ensure your Cloudflare API key or DNS API token is correct in `traefik/.env.production`:

```bash
CLOUDFLARE_EMAIL=your-cloudflare-email@example.com
CLOUDFLARE_API_KEY=your-global-api-key
# OR
# CLOUDFLARE_DNS_API_TOKEN=your-dns-api-token
```

### 3. DNS Configuration in Cloudflare

#### Add DNS Records

1. Create an A record for your root domain (e.g., `yourdomain.com`) pointing to your server's IP
2. Create an A record for the Traefik subdomain (e.g., `traefik.yourdomain.com`) pointing to the same IP
3. Set the proxy status to "DNS only" (gray cloud) initially until certificates are issued

#### SSL/TLS Settings

1. Set SSL/TLS mode to "Full (Strict)" for maximum security
2. Enable "Always Use HTTPS" in the SSL/TLS section
3. Set minimum TLS version to TLS 1.2 or 1.3

### 4. Server Preparation

#### Install Docker and Docker Compose

Ensure Docker and Docker Compose are installed on your production server.

#### Install Google Cloud SDK (if using Google Artifact Registry)

If you're using Google Artifact Registry for your container images:

```bash
curl https://sdk.cloud.google.com | bash
gcloud init
```

#### Copy Files to Server

Copy the entire `multi-project-setup` directory to your production server.

### 5. Deployment

#### Make the Deployment Script Executable

```bash
chmod +x deploy-production.sh
```

#### Run the Deployment Script

```bash
./deploy-production.sh
```

The script will:
- Create the traefik-public network if it doesn't exist
- Optionally generate a new password
- Copy production environment files
- Authenticate with Google Artifact Registry
- Start Traefik and your services

#### Verify Deployment

- Check if containers are running: `docker ps`
- Check Traefik logs: `docker logs traefik-traefik-1`
- Verify certificate issuance in the logs

### 6. Post-Deployment

#### Update Cloudflare Proxy Status

Once certificates are issued, you can change the proxy status to "Proxied" (orange cloud) for additional protection.

#### Monitor Logs

Regularly check Traefik logs for any errors or issues:

```bash
docker logs traefik-traefik-1
```

#### Backup Certificates

Periodically backup the `traefik/certificates` directory which contains your Let's Encrypt certificates.

### 7. Troubleshooting

#### Certificate Issuance

If you encounter issues with certificate issuance:
- Check Traefik logs for any DNS challenge errors
- Verify Cloudflare API credentials
- Ensure DNS records are properly configured

#### ACME Permissions Error

If you see an error like:
```
ERR The ACME resolve is skipped from the resolvers list error="unable to get ACME account: permissions 644 for /certificates/acme.json are too open, please use 600"
```

This is because Let's Encrypt requires strict permissions on the certificate storage file. The configuration has been updated to automatically set the correct permissions, but if you still encounter this issue:

1. Stop the Traefik container:
   ```bash
   cd traefik
   docker-compose down
   ```

2. Create or fix permissions on the acme.json file:
   ```bash
   touch ./certificates/acme.json
   chmod 600 ./certificates/acme.json
   ```

3. Restart Traefik:
   ```bash
   docker-compose up -d
   ```

#### Google Artifact Registry Authentication

If you have issues pulling your private image:

```bash
gcloud auth login
gcloud auth configure-docker asia-southeast2-docker.pkg.dev
```

#### Network Issues

- Ensure ports 80 and 443 are open on your server's firewall
- Check that the traefik-public network exists: `docker network ls`

### 8. Local Development

For local development:
1. Use the `.env` files (not `.env.production`)
2. Set `DOMAIN=localhost` in both `.env` files
3. The configuration will automatically use HTTP only for local development

This setup allows you to develop locally without needing to obtain SSL certificates for localhost domains.
