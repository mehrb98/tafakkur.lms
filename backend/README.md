# Tafakkur LMS — Backend API

Rails 8 API-only backend for the Tafakkur LMS MVP.

## Prerequisites

- Ruby 3.4+
- Bundler
- Docker (for Postgres + Redis)

## Quick start

```bash
cd backend
bundle install
rails setup              # Docker db/redis + gems + db:prepare
rails db:seed            # demo data
rails dev                # API + Sidekiq (foreman)
```

## Rails commands

All workflows use standard `rails` / `rake` tasks:

### Setup

| Command | Description |
|---------|-------------|
| `rails setup` | Full setup: Docker, bundle, `setup:db`, clear tmp |
| `rails setup:env` | Copy `.env.example` → `.env` |
| `rails setup:db` | Prepare database (create + migrate) |
| `rails setup:db:reset` | Drop, create, migrate, seed |
| `rails db:seed` | Load demo data (built-in Rails task) |
| `rails db:prepare` | Create DB + migrate (built-in) |
| `rails db:reset` | Reset DB (built-in) |

Skip Docker during setup: `SKIP_DOCKER=1 rails setup`

### Docker

| Command | Description |
|---------|-------------|
| `rails docker:up` | Start **only** Postgres + Redis (~5s, **no image build**) |
| `rails docker:down` | Stop containers |
| `rails docker:ps` | Container status |
| `rails docker:logs` | Tail logs (`SERVICE=db rails docker:logs`) |
| `rails docker:build` | Build API image (optional — only if running API in Docker) |
| `rails docker:start` | Full stack in Docker (db + redis + api + sidekiq) |

### Docker-only (no host Ruby / bundle install)

Everything is built and runs **inside Docker**:

```bash
cd backend
rails docker:start          # build image + start db, redis, api, sidekiq
rails docker:exec db:seed   # seed inside container
rails docker:logs           # watch API logs
rails docker:shell          # bash in API container
```

API: http://localhost:3001/api/v1  
Swagger: http://localhost:3001/api

Rebuild after Gemfile changes: `rails docker:build` then `docker compose --profile app up -d api sidekiq`

### Hybrid (Docker infra + local Rails)

```bash
rails docker:up      # db + redis only (~5s)
bundle install       # on your Mac
rails setup:db
rails dev
```

API: http://localhost:3000/api/v1

### Development

| Command | Description |
|---------|-------------|
| `rails dev` | Start API + Sidekiq via `Procfile.dev` (foreman) |
| `rails server` | API only (built-in) |
| `rails spec` | Run RSpec |
| `rails check` | RuboCop + Brakeman + bundler-audit + RSpec |

List all custom tasks: `rails -T`

## Procfile.dev

```
web:    bundle exec rails server -b 0.0.0.0 -p 3000
worker: bundle exec sidekiq -C config/sidekiq.yml
```

Started by `rails dev`.

## URLs

| Service | URL |
|---------|-----|
| API | http://localhost:3000/api/v1 |
| Swagger UI | http://localhost:3000/api |
| Health | http://localhost:3000/health |
| Docker API | http://localhost:3001/api/v1 (`rails docker:start`) |
| Docker Swagger | http://localhost:3001/api |

## Demo credentials (after `rails db:seed`)

- **Email:** `admin@demo.tafakkur.local`
- **Password:** `DemoPassword123!`

## Environment

`.env` is created from `.env.example` on first `rails setup`.

Postgres runs on **port 5433** (Docker maps `5433:5432`).

## API documentation

- **Swagger UI:** http://localhost:3000/api (Docker: http://localhost:3001/api)
- **OpenAPI spec:** `/api/openapi/v1/swagger.yaml`
- **Markdown reference:** [api-reference.md](../.cursor/docs/architecture/v2/api-reference.md)

Regenerate from request specs (optional): `RAILS_ENV=test rails rswag:specs:swaggerize`
