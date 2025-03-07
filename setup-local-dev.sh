#!/bin/bash

# Define the domain to use for local development
LOCAL_DOMAIN="localhost"
TRAEFIK_SUBDOMAIN="traefik.localhost"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up local development environment...${NC}"

# Check if running with administrator privileges
if [ "$(id -u)" != "0" ]; then
   echo -e "${YELLOW}This script must be run as administrator to modify the hosts file${NC}"
   echo -e "${YELLOW}Please run it again with administrator privileges${NC}"
   exit 1
fi

# Check if entries already exist in hosts file
if grep -q "$LOCAL_DOMAIN" /etc/hosts && grep -q "$TRAEFIK_SUBDOMAIN" /etc/hosts; then
    echo -e "${GREEN}Hosts file entries already exist${NC}"
else
    # Add entries to hosts file
    echo -e "${GREEN}Adding entries to hosts file...${NC}"
    echo "127.0.0.1 $LOCAL_DOMAIN" >> /etc/hosts
    echo "127.0.0.1 $TRAEFIK_SUBDOMAIN" >> /etc/hosts
    echo -e "${GREEN}Hosts file updated successfully${NC}"
fi

# Create .env files for local development if they don't exist
if [ ! -f "traefik/.env" ]; then
    echo -e "${GREEN}Creating traefik/.env file...${NC}"
    cat > traefik/.env << EOL
USERNAME=admin
DOMAIN=localhost
ACME_EMAIL=your-email@example.com
HASHED_PASSWORD=\$apr1\$ruca84Hq\$mbjdMZBAG.KWn7vfN/SNK/

# Local development doesn't need Cloudflare credentials
# CLOUDFLARE_EMAIL=your-cloudflare-email@example.com
# CLOUDFLARE_API_KEY=your-global-api-key
EOL
    echo -e "${GREEN}Created traefik/.env file${NC}"
fi

if [ ! -f "portfolio/.env" ]; then
    echo -e "${GREEN}Creating portfolio/.env file...${NC}"
    cat > portfolio/.env << EOL
DOMAIN=localhost
EOL
    echo -e "${GREEN}Created portfolio/.env file${NC}"
fi

# Create traefik-public network if it doesn't exist
if ! docker network ls | grep -q traefik-public; then
    echo -e "${GREEN}Creating traefik-public network...${NC}"
    docker network create traefik-public
    echo -e "${GREEN}Created traefik-public network${NC}"
else
    echo -e "${GREEN}traefik-public network already exists${NC}"
fi

echo -e "${GREEN}Local development environment setup complete!${NC}"
echo -e "${GREEN}You can now start your services:${NC}"
echo -e "${YELLOW}cd traefik && docker-compose up -d${NC}"
echo -e "${YELLOW}cd portfolio && docker-compose up -d${NC}"
echo -e "${GREEN}Then access your services at:${NC}"
echo -e "${YELLOW}http://localhost${NC} - Portfolio"
echo -e "${YELLOW}http://traefik.localhost${NC} - Traefik Dashboard"
