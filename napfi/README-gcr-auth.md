# Google Artifact Registry Authentication for Watchtower

This guide explains how to set up authentication for Watchtower to access private images in Google Artifact Registry.

## Step 1: Create a Service Account Key

1. Go to the Google Cloud Console: https://console.cloud.google.com/
2. Navigate to IAM & Admin > Service Accounts
3. Click "Create Service Account"
4. Name your service account (e.g., "watchtower-artifact-registry")
5. Grant the service account the "Artifact Registry Reader" role
6. Click "Done"
7. Find your new service account in the list
8. Click on the service account name
9. Go to the "Keys" tab
10. Click "Add Key" > "Create new key"
11. Choose JSON format
12. Click "Create" to download the key file

## Step 2: Upload the Key to Your Server

The service account key file should be placed in your portfolio directory and named `service-account-key.json`. If you already have this file in your portfolio folder, you can skip this step.

If you need to upload a new key file:
1. Copy the downloaded JSON key file to your server:
   ```bash
   scp service-account-key.json user@your-server:/path/to/portfolio/
   ```
2. Set proper permissions:
   ```bash
   chmod 600 /path/to/portfolio/service-account-key.json
   ```

## Step 3: Set Up Environment Variables

Run the provided setup script to create the necessary environment variables:

```bash
chmod +x setup-credentials.sh
./setup-credentials.sh
```

This script will:
1. Check if the service account key file exists
2. Set proper permissions for the key file
3. Read the content of the key file
4. Create or update the `.env` file with the necessary environment variables

## Step 4: Update Your Docker Compose Configuration

Make sure your docker-compose.yaml contains the following configuration for Watchtower:

```yaml
watchtower:
  image: containrrr/watchtower
  command:
    - "--label-enable"
    - "--interval"
    - "60"
    - "--rolling-restart"
  environment:
    # Google Artifact Registry authentication
    - REPO_USER=_json_key
    - REPO_PASS=${GOOGLE_APPLICATION_CREDENTIALS}
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
```

## Step 5: Restart Your Services

1. Restart the portfolio service:
   ```bash
   cd /path/to/portfolio
   docker-compose down
   docker-compose up -d
   ```

## Verification

Check the Watchtower logs to verify authentication is working:
```bash
docker logs portfolio-watchtower-1
```

You should see messages like:
```
time="2025-03-07T16:42:08Z" level=info msg="Found new asia-southeast2-docker.pkg.dev/mamenesia/images/portfolio:release image (c989e527b0d0)"
```

## How It Works

This configuration uses the `_json_key` authentication method with Google Artifact Registry, which is the recommended approach for service accounts. The service account key content is passed as an environment variable.

The key settings in the docker-compose.yaml file are:

```yaml
environment:
  - REPO_USER=_json_key
  - REPO_PASS=${GOOGLE_APPLICATION_CREDENTIALS}
```

This tells Watchtower to use the `_json_key` authentication method and read the key from the environment variable.
