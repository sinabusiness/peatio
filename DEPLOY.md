# Deploying exchange.صراف.com

## Prerequisites

- Docker 24+
- Docker Compose v2+
- Linux server (Ubuntu 22.04+ recommended) with 8GB+ RAM
- Domain: exchange.صراف.com pointing to your server
- SSL certificate (via Let's Encrypt / Caddy)

## Quick Start (Production)

```bash
# 1. Clone the repo on your server
git clone https://github.com/sinabusiness/peatio.git
cd peatio

# 2. Generate secrets
openssl rand -hex 64 > /tmp/secret_key_base
# Run the setup script to generate keys:
bash bin/generate-keys

# 3. Edit .env with your values
cp .env.example .env
# Edit .env and fill in generated keys

# 4. Set up blockchain nodes (if not using external providers)
# You'll need Bitcoin, Ethereum, or BSC nodes accessible

# 5. Deploy
docker compose build
docker compose up -d mysql redis rabbitmq
sleep 20
docker compose run --rm peatio bundle exec rake db:create db:migrate db:seed
docker compose up -d peatio peatio-daemons barong

# 6. Set up reverse proxy (Caddy/Nginx)
# Example with Caddy:
# exchange.صراف.com {
#     reverse_proxy /api/* localhost:3000
#     reverse_proxy /auth/* localhost:3001
#     reverse_proxy /* localhost:3000
# }
```

## Architecture

```
User Browser
    |
    | HTTPS
    |
Reverse Proxy (Caddy/Nginx)
    |
    +---> Peatio (:3000)  - Trading engine, accounting, API
    |
    +---> Barong (:3001)  - Authentication, KYC, user management
    |
    +---> Frontend (Custom React/Angular/Next.js)

Infrastructure:
    MySQL 8.0     - Database
    Redis 7       - Cache, sessions
    RabbitMQ 3.13 - Message broker for events
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Peatio API | 3000 | Core exchange engine |
| Barong Auth | 3001 | User auth & KYC |
| MySQL | 3306 | Database |
| Redis | 6379 | Cache |
| RabbitMQ | 5672 | Message broker |
| RabbitMQ UI | 15672 | Admin dashboard |

## Seed Data

Edit files in `config/seed/` to configure:
- `currencies.yml` - Supported cryptocurrencies
- `markets.yml` - Trading pairs
- `wallets.yml` - Blockchain wallet connections

## Security Notes

1. Change all default passwords in .env
2. Use strong random keys (run `bash bin/generate-keys`)
3. Configure firewall - only expose ports 80/443
4. Set up monitoring (Sentry, Grafana)
5. Regular database backups
6. Keep OS and Docker updated
7. Use hardware security modules for cold wallets

## Maintenance

```bash
# View logs
docker compose logs -f peatio

# Backup database
docker compose exec mysql mysqldump -u root -p peatio_production > backup.sql

# Update Peatio
git pull
docker compose build peatio
docker compose up -d peatio

# Restart services
docker compose restart
```

## Frontend

Peatio exposes REST API v2. Common frontend options:
- OpenDAX (React) - Official Openware frontend
- Custom React/Vue.js app using Peatio API
- Mobile apps via Peatio's WebSocket API

## Monitoring

Configure alerts for:
- Deposit/withdrawal failures
- Server resource usage
- Failed login attempts
- Database connection drops
- RabbitMQ queue backups
