# Ghost CMS Deployment

This folder contains the configuration for deploying Ghost CMS using Docker and Traefik reverse proxy.

## Overview

Ghost CMS will be deployed with:
- **Ghost CMS**: Latest Ghost 5.x Alpine image
- **MySQL Database**: For content storage
- **Traefik Integration**: SSL/TLS certificates and reverse proxy
- **Watchtower**: Automatic updates
- **Email Support**: Gmail SMTP configuration

## Quick Start

### 1. Set up environment variables

```bash
chmod +x setup-credentials.sh
./setup-credentials.sh
```

### 2. Update configuration

Edit the `.env` file created by the setup script:
- Update `GHOST_MAIL_USER` with your Gmail address
- Update `GHOST_MAIL_PASSWORD` with your Gmail app password
- Update `GHOST_MAIL_FROM` with your desired sender email
- Update domain in `docker-compose.yaml` if not using `blog.mamenesia.com`

### 3. Deploy Ghost CMS

```bash
docker-compose up -d
```

### 4. Access Ghost Admin

Once deployed, access your Ghost admin panel at:
- **Frontend**: https://blog.mamenesia.com
- **Admin Panel**: https://blog.mamenesia.com/ghost

## Configuration Details

### Domain Configuration

The default domain is set to `blog.mamenesia.com`. To change this:

1. Update the `url` environment variable in `docker-compose.yaml`
2. Update the Traefik labels `Host()` rules in `docker-compose.yaml`
3. Ensure your DNS points to your server

### Email Configuration

Ghost uses Gmail SMTP for sending emails. You need:
1. A Gmail account with 2-factor authentication enabled
2. An app password (not your regular Gmail password)
3. Update the mail environment variables in `.env`

### Database

- **Engine**: MySQL 8.0
- **Database Name**: ghost
- **User**: ghost
- **Password**: Auto-generated (stored in `.env`)

### Volumes

- `ghost_content`: Ghost content files (themes, images, etc.)
- `ghost_db`: MySQL database files

## Troubleshooting

### Ghost not starting
1. Check logs: `docker-compose logs ghost`
2. Verify database is running: `docker-compose logs ghost-db`
3. Check environment variables in `.env`

### SSL Certificate issues
1. Ensure DNS points to your server
2. Check Traefik logs: `docker logs traefik`
3. Verify ports 80 and 443 are open

### Email not working
1. Verify Gmail app password is correct
2. Check Ghost logs for SMTP errors
3. Test with a different SMTP provider if needed

## Backup

To backup your Ghost installation:

```bash
# Backup content
docker run --rm -v blog-ghost_ghost_content:/data -v $(pwd):/backup alpine tar czf /backup/ghost-content-backup.tar.gz -C /data .

# Backup database
docker exec blog-ghost-db mysqldump -u ghost -p ghost > ghost-database-backup.sql
```

## Updates

Watchtower automatically updates the Ghost container. To manually update:

```bash
docker-compose pull
docker-compose up -d
```

## Security Notes

- Database passwords are auto-generated and stored in `.env`
- Keep your `.env` file secure and never commit it to version control
- Use strong Gmail app passwords
- Regularly update Ghost and MySQL images
