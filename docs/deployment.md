# Deployment Guide

This template is configured for deployment using [Kamal 2](https://kamal-deploy.org). The default configuration assumes a single-server setup on Hetzner Cloud, but it can be adapted for any VPS provider (DigitalOcean, AWS EC2, etc.).

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

### 3. Set Up Secrets (Kamal 2)

Kamal 2 requires secrets to be imported from environment variables, password managers, or files. The `.kamal/secrets` file defines *where* to find secrets, but doesn't contain the actual values.

The `.kamal/secrets` file is **safe to commit** to git because it only contains import statements like:

```bash
# Import from environment variable
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY=$RAILS_MASTER_KEY
```

#### Setting Up Secrets Locally

For local deployments, use the `.env` file to manage your secrets:

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and fill in your actual values:**
   
   Open `.env` in your editor and scroll to the "Kamal Deployment Secrets" section. Fill in:
   
   - `RAILS_MASTER_KEY` - Copy from your `config/master.key` file
   - `KAMAL_REGISTRY_PASSWORD` - Your GitHub Personal Access Token
   - `POSTGRES_PASSWORD` - Generate with: `openssl rand -hex 32`
   - `DATABASE_URL` - Use the format shown, replacing the password
   - `CACHE_DATABASE_URL` - Use the format shown, replacing the password
   - `CABLE_DATABASE_URL` - Use the format shown, replacing the password
   - `HETZNER_*` - Your Hetzner Object Storage credentials

3. **Deploy:**
   ```bash
   bin/kamal deploy
   ```

The `bin/kamal` wrapper automatically loads variables from your `.env` file using dotenv-rails.

**Note:** The `.env` file is already gitignored, so your secrets are safe.

#### Setting Up Secrets in CI/CD

For GitHub Actions or other CI/CD platforms, you need to set environment variables as repository secrets since the `.env` file won't be available:

1. Add secrets to your repository settings (e.g., GitHub Settings → Secrets and variables → Actions)

2. Set these secrets (copy the values from your local `.env` file):
   - `RAILS_MASTER_KEY`
   - `KAMAL_REGISTRY_PASSWORD`
   - `POSTGRES_PASSWORD`
   - `DATABASE_URL`
   - `CACHE_DATABASE_URL`
   - `CABLE_DATABASE_URL`
   - `HETZNER_ACCESS_KEY_ID`
   - `HETZNER_SECRET_ACCESS_KEY`
   - `HETZNER_BUCKET`
   - `HETZNER_REGION`
   - `HETZNER_ENDPOINT`

3. Configure your CI workflow to export these as environment variables before running kamal commands.

#### Using a Password Manager (Advanced)

Kamal 2 supports 1Password, LastPass, and other password managers. You can configure `.kamal/secrets` to fetch secrets directly:

```bash
# .kamal/secrets
SECRETS=$(kamal secrets fetch --adapter 1password --account your-account --from Vault/Item KAMAL_REGISTRY_PASSWORD POSTGRES_PASSWORD)
KAMAL_REGISTRY_PASSWORD=$(kamal secrets extract KAMAL_REGISTRY_PASSWORD ${SECRETS})
POSTGRES_PASSWORD=$(kamal secrets extract POSTGRES_PASSWORD ${SECRETS})
```

See the [Kamal secrets documentation](https://kamal-deploy.org/docs/upgrading/secrets-changes/) for more details.

### 4. Generate Secret Values

When filling in your `.env` file, you'll need to generate these values:

**Rails Master Key:**
```bash
cat config/master.key
```
Copy this value to `RAILS_MASTER_KEY` in your `.env` file.

**GitHub Personal Access Token:**
1. Visit https://github.com/settings/tokens
2. Create a new "Classic" token
3. Select scopes: `read:packages` and `write:packages`
4. Copy the token (starts with `ghp_`) to `KAMAL_REGISTRY_PASSWORD` in your `.env` file

**PostgreSQL Password:**
```bash
openssl rand -hex 32
```
Copy this to `POSTGRES_PASSWORD` in your `.env` file, then use it in the database URLs.

**Database URLs:**
Format: `postgresql://username:password@host:port/database`
- Username: `mindful` (or your configured username)
- Password: Use the postgres password you generated above
- Host: `mindful-postgres` (this is the Docker container name: service name + `-postgres`)
- Port: `5432`
- Databases: `mindful_production`, `mindful_production_cache`, `mindful_production_cable`

Example:
```
DATABASE_URL=postgresql://mindful:abc123def456@mindful-postgres:5432/mindful_production
```

**Hetzner Object Storage:**
1. Go to Hetzner Cloud Console → Object Storage
2. Create a new bucket
3. Copy the access key, secret key, bucket name, region, and endpoint to your `.env` file

### 5. Initial Deployment

Once your `.env` file is configured with all secrets, run the setup command to provision the server, start the database, and deploy the app:

```bash
bin/kamal setup
```

The `bin/kamal` wrapper will automatically load your secrets from the `.env` file.

### 6. Create Additional Databases

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

### "Secret 'RAILS_MASTER_KEY' not found"

This error means Kamal can't find the required environment variables. Make sure:
1. You've created a `.env` file: `cp .env.example .env`
2. You've filled in all the Kamal deployment secrets in your `.env` file
3. Your `.env` file is in the project root directory
4. For `RAILS_MASTER_KEY`, copy the value from `config/master.key`
5. In CI/CD, all secrets are properly configured in your repository settings as environment variables

### "Database does not exist"

If you see errors about `mindful_production_cache` or `mindful_production_cable` missing, ensure you ran the database creation commands in Step 6.

### SSL Certificate Issues

Traefik handles SSL automatically via Let's Encrypt. If HTTPS is not working:
1. Verify your DNS settings are correct and propagated.
2. Check Traefik logs: `bin/kamal traefik logs`.
3. Ensure ports 80 and 443 are open in your firewall.

### "Permission denied" or SSH Issues

Make sure your SSH key is added to the server and you can connect:
```bash
ssh root@your-server-ip
```

If this fails, check your cloud provider's SSH key configuration.

## Production Best Practices

* **Database Backups:** The default setup runs PostgreSQL on the server's local disk. You must configure automated backups (e.g., a cron job that runs `pg_dump` and uploads to S3) to prevent data loss.

* **System Updates:** Kamal manages containers, not the host OS. Periodically SSH into your server and run `apt update && apt upgrade`.

* **Monitoring:** Consider setting up monitoring and alerting (e.g., AppSignal, New Relic, or simple uptime monitoring).

* **Secrets Management:** For production deployments with teams, consider using a password manager integration (1Password, etc.) instead of `.env` files.

* **Environment Separation:** Use different servers or at least different database names for staging vs. production environments.

## Alternative Database Options

The default configuration uses a Kamal-managed PostgreSQL accessory running on your server. This is suitable for small to medium applications, but you may want to consider:

### External Managed Database (Recommended for Production)

For production applications with high availability requirements:

1. Create a managed PostgreSQL instance with your provider:
   - AWS RDS
   - DigitalOcean Managed Database
   - Railway
   - Neon
   - Supabase

2. Create four databases: `mindful_production`, `mindful_production_cache`, `mindful_production_cable`

3. Update your environment variables to point to the external database:
   ```bash
   DATABASE_URL=postgresql://user:password@external-host:5432/mindful_production
   CACHE_DATABASE_URL=postgresql://user:password@external-host:5432/mindful_production_cache
   CABLE_DATABASE_URL=postgresql://user:password@external-host:5432/mindful_production_cable
   ```

4. Comment out or remove the `postgres` accessory from `config/deploy.yml`

Benefits: Automatic backups, high availability, easy scaling, monitoring, and managed updates.