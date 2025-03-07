#!/bin/bash

# Production deployment script for Traefik multi-project setup

# Set up environment
echo "Setting up environment for production deployment..."

# Create traefik-public network if it doesn't exist
if ! docker network ls | grep -q traefik-public; then
  echo "Creating traefik-public network..."
  docker network create traefik-public
fi

# Ask if user wants to generate a new password
read -p "Do you want to generate a new password for Traefik dashboard? (y/n): " generate_password
if [[ $generate_password == "y" || $generate_password == "Y" ]]; then
  read -s -p "Enter new password: " new_password
  echo ""
  hashed_password=$(openssl passwd -apr1 "$new_password")
  echo "Generated hashed password. Updating .env.production file..."
  # Use sed to replace the HASHED_PASSWORD line in .env.production
  sed -i "s|HASHED_PASSWORD=.*|HASHED_PASSWORD=$hashed_password|" traefik/.env.production
fi

# Copy production environment files
echo "Copying production environment files..."
cp traefik/.env.production traefik/.env
cp portfolio/.env.production portfolio/.env

# Authenticate with Google Artifact Registry
echo "Authenticating with Google Artifact Registry..."
echo "Note: You need to have gcloud CLI installed and be logged in"
gcloud auth configure-docker asia-southeast2-docker.pkg.dev

# Start Traefik
echo "Starting Traefik..."
cd traefik
docker-compose down
docker-compose up -d
cd ..

# Wait for Traefik to start
echo "Waiting for Traefik to initialize..."
sleep 10

# Start Portfolio
echo "Starting Portfolio service..."
cd portfolio
docker-compose down
docker-compose up -d
cd ..

echo "Deployment completed successfully!"
echo "Please ensure your DNS records are properly configured in Cloudflare:"
echo "- A record for yourdomain.com pointing to your server IP"
echo "- A record for traefik.yourdomain.com pointing to your server IP"
echo ""
echo "Your services should be available at:"
echo "- Portfolio: https://yourdomain.com"
echo "- Traefik Dashboard: https://traefik.yourdomain.com"
