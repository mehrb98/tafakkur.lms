# Operations Guide — Tafakkur LMS v2.0

> **Master document:** [SAD.md §16-19](./SAD.md#16-docker-setup)

**Scope:** Docker, CI/CD, production infrastructure, monitoring, disaster recovery.

---

## Table of Contents

1. [Docker — Backend Dockerfile](#1-docker--backend-dockerfile)
2. [Docker — Frontend Dockerfile](#2-docker--frontend-dockerfile)
3. [Docker Compose — Development](#3-docker-compose--development)
4. [Docker Compose — Production](#4-docker-compose--production)
5. [CI/CD — GitHub Actions](#5-cicd--github-actions)
6. [Production Infrastructure](#6-production-infrastructure)
7. [Monitoring & Alerting](#7-monitoring--alerting)
8. [Disaster Recovery Runbook](#8-disaster-recovery-runbook)
9. [Environment Variables](#9-environment-variables)

---

## 1. Docker — Backend Dockerfile

```dockerfile
# backend/Dockerfile

# --- Build stage ---
FROM ruby:3.3-slim AS builder

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential libpq-dev git curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4

COPY . .

# --- Development stage ---
FROM builder AS development

RUN bundle config set --local without '' && \
    bundle install --jobs 4

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends postgresql-client && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# --- Production stage ---
FROM ruby:3.3-slim AS production

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 1001 rails && \
    useradd --system --uid 1001 --gid rails rails

WORKDIR /app

COPY --from=builder --chown=rails:rails /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

---

## 2. Docker — Frontend Dockerfile

```dockerfile
# frontend/Dockerfile

# --- Dependencies stage ---
FROM node:22-alpine AS deps

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# --- Build stage ---
FROM node:22-alpine AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

# --- Development stage ---
FROM node:22-alpine AS development

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

EXPOSE 3000
CMD ["npm", "run", "dev"]

# --- Production stage ---
FROM node:22-alpine AS production

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
```

---

## 3. Docker Compose — Development

```yaml
# docker-compose.yml

services:
    db:
        image: postgres:16-alpine
        environment:
            POSTGRES_USER: lms
            POSTGRES_PASSWORD: lms_dev_password
            POSTGRES_DB: lms_development
        ports:
            - "5432:5432"
        volumes:
            - pgdata:/var/lib/postgresql/data
        healthcheck:
            test: ["CMD-SHELL", "pg_isready -U lms -d lms_development"]
            interval: 5s
            timeout: 5s
            retries: 5
        networks:
            - lms-network

    redis:
        image: redis:7-alpine
        ports:
            - "6379:6379"
        healthcheck:
            test: ["CMD", "redis-cli", "ping"]
            interval: 5s
            timeout: 5s
            retries: 5
        networks:
            - lms-network

    api:
        build:
            context: ./backend
            target: development
        command: bundle exec rails server -b 0.0.0.0
        volumes:
            - ./backend:/app
            - bundle_cache:/usr/local/bundle
        ports:
            - "3001:3000"
        depends_on:
            db:
                condition: service_healthy
            redis:
                condition: service_healthy
        environment:
            RAILS_ENV: development
            DATABASE_URL: postgres://lms:lms_dev_password@db:5432/lms_development
            REDIS_URL: redis://redis:6379/0
            JWT_SECRET: dev_jwt_secret_change_in_production
            FRONTEND_URL: http://localhost:3000
            RAILS_LOG_TO_STDOUT: "true"
        networks:
            - lms-network

    sidekiq:
        build:
            context: ./backend
            target: development
        command: bundle exec sidekiq -C config/sidekiq.yml
        volumes:
            - ./backend:/app
            - bundle_cache:/usr/local/bundle
        depends_on:
            api:
                condition: service_started
            redis:
                condition: service_healthy
        environment:
            RAILS_ENV: development
            DATABASE_URL: postgres://lms:lms_dev_password@db:5432/lms_development
            REDIS_URL: redis://redis:6379/0
            JWT_SECRET: dev_jwt_secret_change_in_production
        networks:
            - lms-network

    frontend:
        build:
            context: ./frontend
            target: development
        command: npm run dev
        volumes:
            - ./frontend:/app
            - node_modules:/app/node_modules
        ports:
            - "3000:3000"
        environment:
            NEXT_PUBLIC_API_URL: http://localhost:3001/api/v1
            BETTER_AUTH_SECRET: dev_auth_secret_change_in_production
            BETTER_AUTH_URL: http://localhost:3000
        depends_on:
            - api
        networks:
            - lms-network

volumes:
    pgdata:
    bundle_cache:
    node_modules:

networks:
    lms-network:
        driver: bridge
```

### Development Commands

```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# Run migrations
docker-compose exec api bundle exec rails db:migrate

# Seed database
docker-compose exec api bundle exec rails db:seed

# Run backend tests
docker-compose exec api bundle exec rspec

# Run frontend tests
docker-compose exec frontend npm run test

# View logs
docker-compose logs -f api sidekiq

# Stop all
docker-compose down
```

---

## 4. Docker Compose — Production

```yaml
# docker-compose.prod.yml

services:
    api:
        build:
            context: ./backend
            target: production
        restart: unless-stopped
        ports:
            - "3001:3000"
        environment:
            RAILS_ENV: production
            DATABASE_URL: ${DATABASE_URL}
            REDIS_URL: ${REDIS_URL}
            JWT_SECRET: ${JWT_SECRET}
            FRONTEND_URL: ${FRONTEND_URL}
            RAILS_LOG_TO_STDOUT: "true"
            RAILS_SERVE_STATIC_FILES: "true"
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
            AWS_BUCKET: ${AWS_BUCKET}
            AWS_REGION: ${AWS_REGION}
            RESEND_API_KEY: ${RESEND_API_KEY}
            SENTRY_DSN: ${SENTRY_DSN}
        healthcheck:
            test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
            interval: 30s
            timeout: 5s
            retries: 3
        deploy:
            resources:
                limits:
                    memory: 1G
                    cpus: "1.0"
        networks:
            - lms-network

    sidekiq:
        build:
            context: ./backend
            target: production
        command: bundle exec sidekiq -C config/sidekiq.yml
        restart: unless-stopped
        environment:
            RAILS_ENV: production
            DATABASE_URL: ${DATABASE_URL}
            REDIS_URL: ${REDIS_URL}
            JWT_SECRET: ${JWT_SECRET}
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
            AWS_BUCKET: ${AWS_BUCKET}
            RESEND_API_KEY: ${RESEND_API_KEY}
            SENTRY_DSN: ${SENTRY_DSN}
        deploy:
            resources:
                limits:
                    memory: 1G
                    cpus: "1.0"
        depends_on:
            api:
                condition: service_healthy
        networks:
            - lms-network

    frontend:
        build:
            context: ./frontend
            target: production
        restart: unless-stopped
        ports:
            - "3000:3000"
        environment:
            NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL}
            BETTER_AUTH_SECRET: ${BETTER_AUTH_SECRET}
            BETTER_AUTH_URL: ${BETTER_AUTH_URL}
            SENTRY_DSN: ${SENTRY_DSN_FRONTEND}
        healthcheck:
            test: ["CMD", "wget", "-qO-", "http://localhost:3000/api/health"]
            interval: 30s
            timeout: 5s
            retries: 3
        deploy:
            resources:
                limits:
                    memory: 512M
                    cpus: "0.5"
        networks:
            - lms-network

networks:
    lms-network:
        driver: bridge
```

**Note:** In production AWS deployment, PostgreSQL (RDS) and Redis (ElastiCache) are managed services — not Docker containers. The production compose file above is for VPS/self-hosted deployments. AWS ECS uses the same Docker images without compose.

---

## 5. CI/CD — GitHub Actions

```yaml
# .github/workflows/ci.yml

name: CI/CD Pipeline

on:
    push:
        branches: [main, develop]
    pull_request:
        branches: [main]

env:
    REGISTRY: ghcr.io
    API_IMAGE: ghcr.io/${{ github.repository }}/api
    FRONTEND_IMAGE: ghcr.io/${{ github.repository }}/frontend

jobs:
    # ─── Backend Lint & Security ───
    backend-lint:
        runs-on: ubuntu-latest
        defaults:
            run:
                working-directory: backend
        steps:
            - uses: actions/checkout@v4
            - uses: ruby/setup-ruby@v1
              with:
                  ruby-version: "3.3"
                  bundler-cache: true
            - run: bundle exec rubocop
            - run: bundle exec brakeman --no-pager -q
            - run: bundle exec bundler-audit check --update

    # ─── Backend Tests ───
    backend-test:
        runs-on: ubuntu-latest
        needs: backend-lint
        services:
            postgres:
                image: postgres:16-alpine
                env:
                    POSTGRES_USER: lms
                    POSTGRES_PASSWORD: lms_test
                    POSTGRES_DB: lms_test
                ports: ["5432:5432"]
                options: >-
                    --health-cmd pg_isready
                    --health-interval 10s
                    --health-timeout 5s
                    --health-retries 5
            redis:
                image: redis:7-alpine
                ports: ["6379:6379"]
                options: >-
                    --health-cmd "redis-cli ping"
                    --health-interval 10s
                    --health-timeout 5s
                    --health-retries 5
        defaults:
            run:
                working-directory: backend
        env:
            RAILS_ENV: test
            DATABASE_URL: postgres://lms:lms_test@localhost:5432/lms_test
            REDIS_URL: redis://localhost:6379/1
            JWT_SECRET: test_secret
        steps:
            - uses: actions/checkout@v4
            - uses: ruby/setup-ruby@v1
              with:
                  ruby-version: "3.3"
                  bundler-cache: true
            - run: bundle exec rails db:create db:migrate
            - run: bundle exec rspec --format progress

    # ─── Frontend Lint & Type Check ───
    frontend-lint:
        runs-on: ubuntu-latest
        defaults:
            run:
                working-directory: frontend
        steps:
            - uses: actions/checkout@v4
            - uses: actions/setup-node@v4
              with:
                  node-version: "22"
                  cache: npm
                  cache-dependency-path: frontend/package-lock.json
            - run: npm ci
            - run: npm run lint
            - run: npx tsc --noEmit

    # ─── Frontend Tests ───
    frontend-test:
        runs-on: ubuntu-latest
        needs: frontend-lint
        defaults:
            run:
                working-directory: frontend
        steps:
            - uses: actions/checkout@v4
            - uses: actions/setup-node@v4
              with:
                  node-version: "22"
                  cache: npm
                  cache-dependency-path: frontend/package-lock.json
            - run: npm ci
            - run: npm run test -- --coverage

    # ─── Security Audit ───
    security-audit:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4
            - uses: actions/setup-node@v4
              with:
                  node-version: "22"
            - run: cd frontend && npm ci && npm audit --audit-level=high

    # ─── Build Docker Images ───
    build:
        runs-on: ubuntu-latest
        needs: [backend-test, frontend-test, security-audit]
        if: github.ref == 'refs/heads/main'
        steps:
            - uses: actions/checkout@v4

            - uses: docker/login-action@v3
              with:
                  registry: ${{ env.REGISTRY }}
                  username: ${{ github.actor }}
                  password: ${{ secrets.GITHUB_TOKEN }}

            - uses: docker/build-push-action@v5
              with:
                  context: ./backend
                  target: production
                  push: true
                  tags: |
                      ${{ env.API_IMAGE }}:${{ github.sha }}
                      ${{ env.API_IMAGE }}:latest

            - uses: docker/build-push-action@v5
              with:
                  context: ./frontend
                  target: production
                  push: true
                  tags: |
                      ${{ env.FRONTEND_IMAGE }}:${{ github.sha }}
                      ${{ env.FRONTEND_IMAGE }}:latest

    # ─── Deploy Staging ───
    deploy-staging:
        runs-on: ubuntu-latest
        needs: build
        if: github.ref == 'refs/heads/main'
        environment: staging
        steps:
            - uses: actions/checkout@v4

            - name: Run database migrations
              run: |
                  # ECS run-task for migration
                  aws ecs run-task \
                      --cluster tafakkur-staging \
                      --task-definition tafakkur-migrate \
                      --launch-type FARGATE \
                      --network-configuration "awsvpcConfiguration={subnets=[${{ secrets.STAGING_SUBNET }}],securityGroups=[${{ secrets.STAGING_SG }}]}"

            - name: Deploy API to ECS
              run: |
                  aws ecs update-service \
                      --cluster tafakkur-staging \
                      --service tafakkur-api \
                      --force-new-deployment

            - name: Deploy Sidekiq to ECS
              run: |
                  aws ecs update-service \
                      --cluster tafakkur-staging \
                      --service tafakkur-sidekiq \
                      --force-new-deployment

            - name: Smoke test
              run: |
                  sleep 30
                  curl -f https://staging-api.tafakkur.com/health

    # ─── E2E Tests (Staging) ───
    e2e:
        runs-on: ubuntu-latest
        needs: deploy-staging
        steps:
            - uses: actions/checkout@v4
            - uses: actions/setup-node@v4
              with:
                  node-version: "22"
            - run: cd frontend && npm ci && npx playwright install --with-deps
            - run: cd frontend && npx playwright test
              env:
                  BASE_URL: https://staging.tafakkur.com
                  API_URL: https://staging-api.tafakkur.com/api/v1

    # ─── Deploy Production ───
    deploy-production:
        runs-on: ubuntu-latest
        needs: e2e
        if: github.ref == 'refs/heads/main'
        environment: production
        steps:
            - name: Run database migrations
              run: |
                  aws ecs run-task \
                      --cluster tafakkur-production \
                      --task-definition tafakkur-migrate \
                      --launch-type FARGATE \
                      --network-configuration "awsvpcConfiguration={subnets=[${{ secrets.PROD_SUBNET }}],securityGroups=[${{ secrets.PROD_SG }}]}"

            - name: Deploy API to ECS
              run: |
                  aws ecs update-service \
                      --cluster tafakkur-production \
                      --service tafakkur-api \
                      --force-new-deployment

            - name: Deploy Sidekiq to ECS
              run: |
                  aws ecs update-service \
                      --cluster tafakkur-production \
                      --service tafakkur-sidekiq \
                      --force-new-deployment

            - name: Deploy Frontend to Vercel
              run: |
                  npx vercel deploy --prod --token=${{ secrets.VERCEL_TOKEN }}

            - name: Production smoke test
              run: |
                  sleep 30
                  curl -f https://api.tafakkur.com/health
                  curl -f https://tafakkur.com
```

### Rollback Procedure

```bash
# 1. Revert ECS to previous task definition
aws ecs update-service \
    --cluster tafakkur-production \
    --service tafakkur-api \
    --task-definition tafakkur-api:PREVIOUS_REVISION

# 2. Revert Vercel deployment
npx vercel rollback --token=$VERCEL_TOKEN

# 3. Rollback database (only if migration is reversible)
aws ecs run-task \
    --cluster tafakkur-production \
    --task-definition tafakkur-migrate \
    --overrides '{"containerOverrides":[{"name":"migrate","command":["bundle","exec","rails","db:rollback","STEP=1"]}]}'
```

---

## 6. Production Infrastructure

### 6.1 Architecture Diagram

```mermaid
flowchart LR
    Users --> CF[Cloudflare CDN/WAF]
    CF --> Vercel[Vercel - Next.js]
    CF --> ALB[AWS ALB]
    ALB --> ECS[ECS Fargate - Rails API]
    ECS --> RDS[(RDS PostgreSQL Multi-AZ)]
    ECS --> ElastiCache[(ElastiCache Redis)]
    ECS --> R2[Cloudflare R2]
    ECS --> SidekiqECS[ECS Sidekiq Workers]
    SidekiqECS --> RDS
    SidekiqECS --> ElastiCache
    SidekiqECS --> R2
```

### 6.2 AWS Resource Configuration

| Resource | Service | Configuration |
|----------|---------|---------------|
| VPC | AWS VPC | 2 AZs, public + private subnets |
| ALB | Application Load Balancer | HTTPS (ACM cert), health check `/health` |
| ECS Cluster | Fargate | 2 API tasks (min), 2 Sidekiq tasks (min) |
| ECS Auto Scaling | Target tracking | CPU > 70% → scale out (max 10 tasks) |
| RDS | PostgreSQL 16 | db.r6g.large, Multi-AZ, 100 GB gp3, 35-day backups |
| ElastiCache | Redis 7 | cache.r6g.large, cluster mode, 2 shards |
| R2 | Cloudflare R2 | Standard storage, CDN via Cloudflare |
| Secrets | AWS Secrets Manager | Auto-rotation for DB credentials |
| DNS | Cloudflare | Proxied (WAF + CDN) |
| WAF | Cloudflare WAF | OWASP ruleset, rate limiting |

### 6.3 ECS Task Definitions

**API Task:**

| Setting | Value |
|---------|-------|
| CPU | 1024 (1 vCPU) |
| Memory | 2048 MB |
| Port | 3000 |
| Health check | `curl -f http://localhost:3000/health` |
| Log driver | awslogs → CloudWatch |
| Min tasks | 2 |
| Max tasks | 10 |

**Sidekiq Task:**

| Setting | Value |
|---------|-------|
| CPU | 1024 (1 vCPU) |
| Memory | 2048 MB |
| Health check | Sidekiq process check |
| Min tasks | 2 |
| Max tasks | 5 |

**Migration Task:**

| Setting | Value |
|---------|-------|
| CPU | 512 |
| Memory | 1024 MB |
| Command | `bundle exec rails db:migrate` |
| Run | On-demand before each deploy |

### 6.4 Vercel Configuration

| Setting | Value |
|---------|-------|
| Framework | Next.js |
| Node version | 22 |
| Build command | `npm run build` |
| Output | Standalone |
| Regions | `iad1` (primary), `fra1` (EU) |
| Environment | Production secrets via Vercel dashboard |

### 6.5 SSL/TLS

| Component | Certificate |
|-----------|-------------|
| ALB | AWS ACM (auto-renewal) |
| Vercel | Automatic (Let's Encrypt) |
| Cloudflare | Full (strict) SSL mode |
| RDS | TLS enforced for connections |
| Redis | TLS in-transit enabled |

### 6.6 Backup Strategy

| Resource | Method | Frequency | Retention |
|----------|--------|-----------|-----------|
| RDS | Automated snapshots | Daily | 35 days |
| RDS | Manual snapshot before migrations | Per deploy | 7 days |
| R2 | Cross-region replication | Continuous | Indefinite |
| Redis | AOF persistence | Continuous | 7 days |
| Secrets | Secrets Manager versioning | Per rotation | 30 versions |

---

## 7. Monitoring & Alerting

### 7.1 Sentry Configuration

**Backend (`config/initializers/sentry.rb`):**

```ruby
Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 0.1
    config.profiles_sample_rate = 0.1
    config.environment = Rails.env
    config.enabled_environments = %w[production staging]
    config.excluded_exceptions += ["ActionController::RoutingError"]
end
```

**Frontend (`sentry.client.config.ts`):**

```typescript
Sentry.init({
    dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
    tracesSampleRate: 0.1,
    environment: process.env.NODE_ENV,
});
```

### 7.2 OpenTelemetry

**Backend (`config/initializers/opentelemetry.rb`):**

```ruby
OpenTelemetry::SDK.configure do |c|
    c.service_name = "tafakkur-api"
    c.use "OpenTelemetry::Instrumentation::Rails"
    c.use "OpenTelemetry::Instrumentation::PG"
    c.use "OpenTelemetry::Instrumentation::Redis"
    c.use "OpenTelemetry::Instrumentation::Sidekiq"
end
```

Collector exports to Jaeger/Tempo via OTLP gRPC.

### 7.3 Prometheus Metrics (Yabeda)

| Metric | Type | Labels |
|--------|------|--------|
| `rails_requests_total` | Counter | method, path, status |
| `rails_request_duration_seconds` | Histogram | method, path |
| `sidekiq_jobs_total` | Counter | queue, status |
| `sidekiq_queue_latency_seconds` | Gauge | queue |
| `db_connection_pool_size` | Gauge | — |
| `db_connection_pool_busy` | Gauge | — |

### 7.4 Grafana Dashboards

| Dashboard | Panels |
|-----------|--------|
| API Overview | Request rate, p50/p95/p99 latency, error rate, status code distribution |
| Sidekiq | Queue depths, job throughput, failure rate, dead queue size |
| Database | Connection pool, query duration, slow queries, disk usage |
| Infrastructure | ECS CPU/memory, RDS CPU/connections, Redis memory/hit rate |
| Business | Active schools, daily logins, grades created, emails sent |

### 7.5 Structured Logging

**Backend (lograge):**

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new
    config.lograge.custom_payload do |controller|
        {
            user_id: controller.current_user&.id,
            school_id: controller.current_user&.school_id,
            request_id: controller.request.request_id
        }
    end
end
```

**Log output:**

```json
{
    "method": "GET",
    "path": "/api/v1/students",
    "status": 200,
    "duration": 45.2,
    "user_id": "018f3a2b-...",
    "school_id": "018f3a2b-...",
    "request_id": "abc-123"
}
```

### 7.6 Alert Rules

| Alert | Condition | Severity | Channel |
|-------|-----------|----------|---------|
| API Down | `/health` fails 3 consecutive checks | P1 | PagerDuty |
| High Error Rate | Error rate > 1% for 5 min | P1 | PagerDuty |
| High Latency | API p95 > 500ms for 5 min | P2 | Slack |
| Sidekiq Backlog | Queue latency > 60s | P2 | Slack |
| DB Connections | Pool > 80% for 10 min | P2 | Slack |
| DB Disk | Storage > 85% | P1 | PagerDuty |
| Redis Memory | Memory > 80% | P2 | Slack |
| Dead Queue | Dead jobs > 50 | P3 | Slack |
| Failed Deploy | Smoke test fails post-deploy | P1 | PagerDuty |

---

## 8. Disaster Recovery Runbook

### 8.1 Targets

| Metric | Target |
|--------|--------|
| RTO (Recovery Time Objective) | 4 hours |
| RPO (Recovery Point Objective) | 1 hour |

### 8.2 Scenario: Database Failure

1. **Detect:** RDS CloudWatch alarm → PagerDuty P1
2. **Assess:** Check RDS console for instance status
3. **Recover:**
   - Multi-AZ failover is automatic (~60 seconds)
   - If failover fails: restore from latest automated snapshot
   ```bash
   aws rds restore-db-instance-from-db-snapshot \
       --db-instance-identifier tafakkur-db-restored \
       --db-snapshot-identifier rds:tafakkur-db-2026-07-09
   ```
4. **Update:** Point `DATABASE_URL` in Secrets Manager to restored instance
5. **Redeploy:** Force new ECS deployment to pick up new connection string
6. **Verify:** Run smoke tests, check data integrity
7. **Communicate:** Status page update, notify affected schools if downtime > 15 min

### 8.3 Scenario: Application Failure

1. **Detect:** ALB health check failures → ECS service unhealthy
2. **Recover:**
   - ECS auto-replaces unhealthy tasks
   - If persistent: rollback to previous task definition (see Rollback Procedure)
3. **Verify:** Smoke tests pass

### 8.4 Scenario: Region Failure

1. **Detect:** All health checks fail across AZs
2. **Recover:**
   - Restore RDS snapshot to secondary region
   - Deploy ECS cluster in secondary region from latest images
   - Update Cloudflare DNS to point to secondary region ALB
   - Promote R2 cross-region replica
3. **RTO:** ~4 hours (manual process)

---

## 9. Environment Variables

### 9.1 Backend (Rails API)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `RAILS_ENV` | Yes | Environment | `production` |
| `DATABASE_URL` | Yes | PostgreSQL connection string | `postgres://user:pass@host:5432/db` |
| `REDIS_URL` | Yes | Redis connection string | `redis://host:6379/0` |
| `JWT_SECRET` | Yes | JWT signing secret (256-bit) | Random string |
| `FRONTEND_URL` | Yes | CORS allowed origin | `https://tafakkur.com` |
| `AWS_ACCESS_KEY_ID` | Yes | R2/S3 access key | — |
| `AWS_SECRET_ACCESS_KEY` | Yes | R2/S3 secret key | — |
| `AWS_BUCKET` | Yes | Storage bucket name | `tafakkur-files` |
| `AWS_REGION` | Yes | Storage region | `auto` (R2) |
| `AWS_ENDPOINT` | No | R2 endpoint URL | `https://xxx.r2.cloudflarestorage.com` |
| `RESEND_API_KEY` | Yes | Resend email API key | `re_xxx` |
| `SENTRY_DSN` | Yes | Sentry error tracking DSN | `https://xxx@sentry.io/xxx` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | No | OpenTelemetry collector URL | `http://collector:4317` |
| `RAILS_LOG_TO_STDOUT` | Yes | Log to stdout for CloudWatch | `true` |
| `WEB_CONCURRENCY` | No | Puma workers (default: CPU count) | `4` |
| `RAILS_MAX_THREADS` | No | Puma threads per worker | `5` |

### 9.2 Frontend (Next.js)

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | Yes | Rails API base URL | `https://api.tafakkur.com/api/v1` |
| `BETTER_AUTH_SECRET` | Yes | Better Auth encryption secret | Random string |
| `BETTER_AUTH_URL` | Yes | Frontend base URL | `https://tafakkur.com` |
| `NEXT_PUBLIC_SENTRY_DSN` | Yes | Sentry frontend DSN | `https://xxx@sentry.io/xxx` |

### 9.3 Secrets Management

| Environment | Method |
|-------------|--------|
| Development | `.env` files (gitignored) |
| CI | GitHub Secrets |
| Staging/Production | AWS Secrets Manager → injected as ECS task env vars |
| Vercel | Vercel Environment Variables (encrypted) |

**Rules:**

- Never commit secrets to git
- Rotate `JWT_SECRET` and `BETTER_AUTH_SECRET` quarterly
- DB credentials auto-rotated by Secrets Manager
- Audit secret access via CloudTrail

---

**See also:** [SAD.md](./SAD.md) · [database-schema.md](./database-schema.md) · [api-reference.md](./api-reference.md)
