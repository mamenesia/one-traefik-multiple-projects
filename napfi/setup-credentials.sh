#!/bin/bash

# Script to set up Google Artifact Registry credentials for Watchtower

# Check if service account key file exists
if [ ! -f "service-account-key.json" ]; then
  echo "Error: service-account-key.json not found in the current directory"
  exit 1
fi

# Set proper permissions for the key file
chmod 600 service-account-key.json

# Read the content of the service account key file
KEY_CONTENT=$(cat service-account-key.json)

# Create or update .env file with the credentials
echo "DOMAIN=mamenesia.com" > .env
echo "GOOGLE_APPLICATION_CREDENTIALS='$KEY_CONTENT'" >> .env

echo "Credentials have been set up successfully in .env file"
echo "Now restart your services with: docker-compose down && docker-compose up -d"
