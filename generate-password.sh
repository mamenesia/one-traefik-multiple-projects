#!/bin/bash

# Script to generate a hashed password for Traefik basic authentication

# Check if password was provided as argument
if [ $# -eq 1 ]; then
  password="$1"
else
  # Prompt for password if not provided
  read -s -p "Enter password to hash: " password
  echo ""
fi

# Generate hashed password using OpenSSL
hashed_password=$(openssl passwd -apr1 "$password")

echo "Your hashed password is:"
echo "$hashed_password"
echo ""
echo "You can use this in your .env file as:"
echo "HASHED_PASSWORD=$hashed_password"
