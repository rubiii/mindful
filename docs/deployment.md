# Deployment Guide

This template is configured for deployment using [Kamal](https://kamal-deploy.org). The default configuration assumes a single-server setup on Hetzner Cloud, but it can be adapted for any VPS provider (DigitalOcean, AWS EC2, etc.).

## Prerequisites

To deploy your application, you will need:

1. A Virtual Private Server (VPS):
  * Provider: Hetzner Cloud (recommended for cost/performance), DigitalOcean, etc.
  * Specs: 4GB RAM is recommended for Rails + PostgreSQL + Good Job.
  * OS: Ubuntu 24.04 LTS (or any Docker-compatible Linux).
  * Access: You must have SSH root access.

2. A Domain Name:
  * Pointed to your server's IP address (A Record).

3. Container Registry:
  * GitHub Container Registry (GHCR) or Docker Hub.
  * You need a Personal Access Token with `read:packages` and `write:packages` scopes.

4. Object Storage (S3):
  * Hetzner Storage Box, AWS S3, DigitalOcean Spaces, etc.
  * Required for Active Storage uploads.

## Configuration Steps

### 1. Configure the Server

Create your server and note the public IP address. Add your SSH public key to the server for passwordless access.

Firewall Rules:
Configure your cloud provider's firewall to allow:
* Inbound TCP 22 (SSH)
* Inbound TCP 80 (HTTP)
* Inbound TCP 443 (HTTPS)

### 2. Configure Kamal

Open `config/deploy.yml` and make the following updates:

1. Image: Change `service` and `image` to match your repository.
  ```yaml
  service: my-app-name
  image: ghcr.io/my-username/my-app-name
  ```

2. Server IP: Replace the placeholder IP addresses with your actual server IP.
  ```yaml
  servers:
    web:
      - <YOUR_SERVER_IP>
    job:
      hosts:
        - <YOUR_SERVER_IP>
  ```

3. Domain: Update the proxy host for SSL.
  ```yaml
  proxy:
    ssl: true
    host: your-domain.com
  ```

4. Registry: Update the registry username to match your GitHub/Docker Hub username.

### 3. Set Up Secrets

This template uses a local `.kamal/secrets` file to manage sensitive environment variables. This file is gitignored and automatically loaded by the `bin/kamal` wrapper script.

1. Create the file: `touch .kamal/secrets`
2. Add your secrets in `KEY=VALUE` format:

```bash
# .kamal/secrets

# Rails Master Key (copy from config/master.key)
RAILS_MASTER_KEY=...

# Generate a strong password for the production database
# Run: openssl rand -hex 32
POSTGRES_PASSWORD=...

# Your Registry Password (e.g., GitHub PAT)
KAMAL_REGISTRY_PASSWORD=...

# Database Connection Strings
# Replace <POSTGRES_PASSWORD> with the value generated above.
# The host 'my-app-name-postgres' matches the accessory name defined in config/deploy.yml + service name.
# Default service name is 'mindful', so host is 'mindful-postgres'.
DATABASE_URL=postgresql://mindful:<POSTGRES_PASSWORD>@mindful-postgres:5432/mindful_production
CACHE_DATABASE_URL=postgresql://mindful:<POSTGRES_PASSWORD>@mindful-postgres:5432/mindful_production_cache
CABLE_DATABASE_URL=postgresql://mindful:<POSTGRES_PASSWORD>@mindful-postgres:5432/mindful_production_cable

# Object Storage Credentials (S3)
HETZNER_ACCESS_KEY_ID=...
HETZNER_SECRET_ACCESS_KEY=...
HETZNER_BUCKET=...
HETZNER_REGION=fsn1
HETZNER_ENDPOINT=https://fsn1.your-object-storage.com
```

### 4. Initial Deployment

Run the setup command to provision the server, start the database, and deploy the app:

```bash
bin/kamal setup
```

### 5. Create Additional Databases

The primary database is created automatically, but you must manually create the `cache` and `cable` databases.

```bash
# Create Cache DB
bin/kamal accessory exec postgres -i --reuse "psql -U mindful -d postgres -c 'CREATE DATABASE mindful_production_cache;'"

# Create Cable DB
bin/kamal accessory exec postgres -i --reuse "psql -U mindful -d postgres -c 'CREATE DATABASE mindful_production_cable;'"
```

Note: Replace `mindful` with your configured database username if you changed it.

## Routine Operations

### Deploying Changes

To build and deploy the latest version of your code:

```bash
bin/kamal deploy
```

### Viewing Logs

To tail the application logs in real-time:

```bash
bin/kamal logs -f
```

To view logs for the background job processor:

```bash
bin/kamal logs -f job
```

### Rails Console

To open a Rails console on the production server:

```bash
bin/kamal app exec -i 'bin/rails console'
```

### Database Console

To connect to the production database via psql:

```bash
bin/kamal accessory exec postgres -i --reuse "psql -U mindful -d mindful_production"
```

## Troubleshooting

### "Database does not exist"

If you see errors about `mindful_production_cache` or `mindful_production_cable` missing, ensure you ran the creation commands in Step 5.

### SSL Certificate Issues

Traefik handles SSL automatically via Let's Encrypt. If HTTPS is not working:
1. Verify your DNS settings are correct and propagated.
2. Check Traefik logs: `bin/kamal traefik logs`.

## Production Best Practices

* Database Backups: The default setup runs PostgreSQL on the server's local disk. You must configure automated backups (e.g., a cron job that runs `pg_dump` and uploads to S3) to prevent data loss.
* System Updates: Kamal manages containers, not the host OS. Periodically SSH into your server and run `apt update && apt upgrade`.