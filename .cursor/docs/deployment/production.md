# Production Deployment

> **Full operations guide (v2.0):** [architecture/v2/operations.md](../architecture/v2/operations.md)


## Infrastructure


Frontend:

Next.js


Backend:

Rails API


Database:

Managed PostgreSQL


Cache:

Redis


Storage:

AWS S3 or Cloudflare R2



# Docker


Required containers:


frontend

backend

postgres

redis

sidekiq



# CI/CD


GitHub Actions


Pipeline:


1. Install dependencies

2. Run lint

3. Run tests

4. Security scan

5. Build images

6. Deploy


# Environment Variables


Never commit secrets.


Use:

Secret Manager

Environment variables



# Monitoring


Use:


Sentry

OpenTelemetry

Prometheus

Grafana



# Backup


Database:

Daily backups


Storage:

Versioning enabled


# Recovery


Define:

RPO

RTO


Document disaster recovery.