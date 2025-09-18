# Deployment Guide

## Environment Variables Required

Before deploying, set these environment variables:

```bash
export KAMAL_SERVER_IP=your.server.ip.address
export DOCKER_HUB_USERNAME=your_docker_hub_username
```

## Kamal Secrets Required

Set these secrets using Kamal:

```bash
# Docker Hub token (not password)
kamal secrets set KAMAL_REGISTRY_PASSWORD your_docker_hub_token

# Rails master key
kamal secrets set RAILS_MASTER_KEY $(cat config/master.key)
```

## Deployment Steps

1. Set environment variables (see above)
2. Set Kamal secrets (see above)
3. Deploy: `bin/kamal setup`

## Server Setup (One-time)

On your DigitalOcean server:

```bash
# Copy nginx config
sudo cp domain.com.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/domain.com.conf /etc/nginx/sites-enabled/

# Get SSL certificate
sudo certbot --nginx -d domain.com

# Reload nginx
sudo nginx -t && sudo systemctl reload nginx
```
