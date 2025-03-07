# Google Artifact Registry Authentication for Watchtower

This guide explains how to set up authentication for Watchtower to access private images in Google Artifact Registry.

## Step 1: Set Up Google Cloud SDK on Your Server

1. Install the Google Cloud SDK on your server:
   ```bash
   # Add the Cloud SDK distribution URI as a package source
   echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
   
   # Import the Google Cloud public key
   curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
   
   # Update and install the SDK
   sudo apt-get update && sudo apt-get install google-cloud-sdk
   ```

2. Authenticate with Google Cloud:
   ```bash
   gcloud auth login
   ```

3. Configure application default credentials:
   ```bash
   gcloud auth application-default login
   ```

## Step 2: Update Your Docker Compose Configuration

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
    - WATCHTOWER_GOOGLE_ARTIFACT_REGISTRY=true
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /home/ubuntu/.config/gcloud:/config/gcloud:ro
```

**Note**: Adjust the path `/home/ubuntu/.config/gcloud` to match your server's user home directory where the gcloud credentials are stored.

## Step 3: Restart Your Services

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

You should no longer see the "Unauthenticated request" error.

## How It Works

This configuration uses the Google Cloud SDK's application default credentials to authenticate with Google Artifact Registry. The key settings are:

1. `WATCHTOWER_GOOGLE_ARTIFACT_REGISTRY=true` - Enables Google Artifact Registry authentication
2. Mounting the gcloud credentials directory into the container

This approach leverages your existing Google Cloud authentication on the server, making it more straightforward than managing separate service account keys.
