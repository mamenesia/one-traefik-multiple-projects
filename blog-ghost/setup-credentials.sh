#!/bin/bash

# Ghost CMS Environment Setup Script
# This script sets up the necessary environment variables for Ghost CMS deployment

echo "Setting up Ghost CMS environment variables..."

# Generate secure passwords
GHOST_DB_PASSWORD=$(openssl rand -base64 32)
GHOST_DB_ROOT_PASSWORD=$(openssl rand -base64 32)

# Create .env file
cat > .env << EOF
# Ghost CMS Database Configuration
GHOST_DB_PASSWORD=${GHOST_DB_PASSWORD}
GHOST_DB_ROOT_PASSWORD=${GHOST_DB_ROOT_PASSWORD}

# Ghost CMS Mail Configuration (Gmail SMTP)
# Replace with your actual Gmail credentials
GHOST_MAIL_USER=your-email@gmail.com
GHOST_MAIL_PASSWORD=your-app-password
GHOST_MAIL_FROM=your-email@gmail.com

# Google Artifact Registry (if using private images)
# This should be the JSON key content as a single line
GOOGLE_APPLICATION_CREDENTIALS=your-google-credentials-json-key
EOF

echo "Environment file created: .env"
echo ""
echo "IMPORTANT: Please update the following in your .env file:"
echo "1. GHOST_MAIL_USER - Your Gmail address"
echo "2. GHOST_MAIL_PASSWORD - Your Gmail app password (not regular password)"
echo "3. GHOST_MAIL_FROM - The 'from' email address for Ghost notifications"
echo "4. GOOGLE_APPLICATION_CREDENTIALS - Your Google service account JSON key (if needed)"
echo ""
echo "Generated database passwords:"
echo "- Ghost DB Password: ${GHOST_DB_PASSWORD}"
echo "- Ghost DB Root Password: ${GHOST_DB_ROOT_PASSWORD}"
echo ""
echo "To set up Gmail app password:"
echo "1. Enable 2-factor authentication on your Google account"
echo "2. Go to Google Account settings > Security > App passwords"
echo "3. Generate an app password for 'Mail'"
echo "4. Use this app password in GHOST_MAIL_PASSWORD"
echo ""
echo "Setup complete! Remember to:"
echo "1. Update the domain 'blog.mamenesia.com' in docker-compose.yaml if needed"
echo "2. Ensure your DNS points to this server"
echo "3. Run 'docker-compose up -d' to start Ghost CMS"
