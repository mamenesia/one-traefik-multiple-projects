# Define the domain to use for local development
$LOCAL_DOMAIN = "localhost"
$TRAEFIK_SUBDOMAIN = "traefik.localhost"
$HOSTS_FILE = "C:\Windows\System32\drivers\etc\hosts"

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script must be run as administrator to modify the hosts file" -ForegroundColor Yellow
    Write-Host "Please run it again with administrator privileges" -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting up local development environment..." -ForegroundColor Green

# Check if entries already exist in hosts file
$hostsContent = Get-Content $HOSTS_FILE
$localDomainExists = $hostsContent | Where-Object { $_ -match "127.0.0.1\s+$LOCAL_DOMAIN" }
$traefikSubdomainExists = $hostsContent | Where-Object { $_ -match "127.0.0.1\s+$TRAEFIK_SUBDOMAIN" }

if ($localDomainExists -and $traefikSubdomainExists) {
    Write-Host "Hosts file entries already exist" -ForegroundColor Green
} else {
    # Add entries to hosts file
    Write-Host "Adding entries to hosts file..." -ForegroundColor Green
    
    if (-not $localDomainExists) {
        Add-Content -Path $HOSTS_FILE -Value "127.0.0.1 $LOCAL_DOMAIN"
    }
    
    if (-not $traefikSubdomainExists) {
        Add-Content -Path $HOSTS_FILE -Value "127.0.0.1 $TRAEFIK_SUBDOMAIN"
    }
    
    Write-Host "Hosts file updated successfully" -ForegroundColor Green
}

# Create .env files for local development if they don't exist
$traefikEnvPath = ".\traefik\.env"
if (-not (Test-Path $traefikEnvPath)) {
    Write-Host "Creating traefik/.env file..." -ForegroundColor Green
    @"
USERNAME=admin
DOMAIN=localhost
ACME_EMAIL=your-email@example.com
HASHED_PASSWORD=`$apr1`$ruca84Hq`$mbjdMZBAG.KWn7vfN/SNK/

# Local development doesn't need Cloudflare credentials
# CLOUDFLARE_EMAIL=your-cloudflare-email@example.com
# CLOUDFLARE_API_KEY=your-global-api-key
"@ | Out-File -FilePath $traefikEnvPath -Encoding utf8
    Write-Host "Created traefik/.env file" -ForegroundColor Green
}

$portfolioEnvPath = ".\portfolio\.env"
if (-not (Test-Path $portfolioEnvPath)) {
    Write-Host "Creating portfolio/.env file..." -ForegroundColor Green
    @"
DOMAIN=localhost
"@ | Out-File -FilePath $portfolioEnvPath -Encoding utf8
    Write-Host "Created portfolio/.env file" -ForegroundColor Green
}

# Create traefik-public network if it doesn't exist
$networkExists = docker network ls | Select-String -Pattern "traefik-public"
if (-not $networkExists) {
    Write-Host "Creating traefik-public network..." -ForegroundColor Green
    docker network create traefik-public
    Write-Host "Created traefik-public network" -ForegroundColor Green
} else {
    Write-Host "traefik-public network already exists" -ForegroundColor Green
}

Write-Host "Local development environment setup complete!" -ForegroundColor Green
Write-Host "You can now start your services:" -ForegroundColor Green
Write-Host "cd traefik && docker-compose up -d" -ForegroundColor Yellow
Write-Host "cd portfolio && docker-compose up -d" -ForegroundColor Yellow
Write-Host "Then access your services at:" -ForegroundColor Green
Write-Host "http://localhost - Portfolio" -ForegroundColor Yellow
Write-Host "http://traefik.localhost - Traefik Dashboard" -ForegroundColor Yellow
