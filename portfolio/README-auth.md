# Google Artifact Registry Authentication for Watchtower

This guide explains how to set up authentication for Watchtower to access private images in Google Artifact Registry.

## Step 1: Create a Service Account

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Navigate to IAM & Admin > Service Accounts
3. Click "Create Service Account"
4. Name your service account (e.g., "watchtower-artifact-registry")
5. Grant the service account the "Artifact Registry Reader" role
6. Click "Done"

## Step 2: Create and Download a Service Account Key

1. Find your new service account in the list
2. Click on the service account name
3. Go to the "Keys" tab
4. Click "Add Key" > "Create new key"
5. Choose JSON format
6. Click "Create" to download the key file

## Step 3: Upload the Key to Your Server

1. Copy the key file to your server:
   ```bash
   scp service-account-key.json user@your-server:/tmp/
   ```

## Step 4: Base64 Encode the Key

1. SSH into your server
2. Base64 encode the key file:
   ```bash
   cat /tmp/service-account-key.json | base64 -w 0 > /tmp/key.base64
   ```
3. Copy the encoded content:
   ```bash
   cat /tmp/key.base64
   ```

## Step 5: Update Your .env.production File

1. Add the base64-encoded key to your .env.production file:
   ```
   GOOGLE_APPLICATION_CREDENTIALS_BASE64=<paste-the-base64-encoded-key-here>
   ```

## Step 6: Restart Your Services

1. Restart the portfolio service:
   ```bash
   cd /path/to/portfolio
   docker-compose --env-file .env.production down
   docker-compose --env-file .env.production up -d
   ```

## Verification

Check the Watchtower logs to verify authentication is working:
```bash
docker logs portfolio-watchtower-1
```

You should no longer see the "Unauthenticated request" error.
