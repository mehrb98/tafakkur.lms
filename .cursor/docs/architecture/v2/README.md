# Tafakkur LMS — Architecture Documentation v2.0

Enterprise-grade Software Architecture Document suite for the multi-tenant SaaS Learning Management System.

**Status:** Approved for implementation  
**Date:** July 2026

---

## Document Suite

| Document | Description |
|----------|-------------|
| **[SAD.md](./SAD.md)** | Master Software Architecture Document — all 24 sections with decisions, rationale, and diagrams |
| **[database-schema.md](./database-schema.md)** | Complete PostgreSQL schema — every table, column, index, and FK with rationale |
| **[api-reference.md](./api-reference.md)** | Exhaustive REST API specification — every endpoint with request/response examples |
| **[operations.md](./operations.md)** | Docker, CI/CD, production infrastructure, monitoring, and disaster recovery |

## Related Documents

| Document | Location |
|----------|----------|
| Frontend planning schema | [../frontend-schema.md](../frontend-schema.md) |
| SAD v1.0 (unchanged) | [../SAD.md](../SAD.md) |
| Multi-tenancy deep dive | [../multi-tenancy.md](../multi-tenancy.md) |
| System overview | [../overview.md](../overview.md) |

## Quick Navigation by Topic

| Topic | Section |
|-------|---------|
| Technology decisions & ADRs | [SAD §2](./SAD.md#2-technology-decisions) |
| Multi-tenant strategy | [SAD §4](./SAD.md#4-multi-tenant-strategy) |
| Database design | [SAD §5](./SAD.md#5-database-design) → [database-schema.md](./database-schema.md) |
| Frontend architecture | [SAD §6](./SAD.md#6-frontend-architecture) |
| Backend architecture | [SAD §7](./SAD.md#7-backend-architecture) |
| Authentication | [SAD §8](./SAD.md#8-authentication) |
| Authorization (Pundit RBAC) | [SAD §9](./SAD.md#9-authorization) |
| REST API | [SAD §10](./SAD.md#10-rest-api-design) → [api-reference.md](./api-reference.md) |
| Background jobs (Sidekiq) | [SAD §11](./SAD.md#11-background-jobs) |
| Security (OWASP) | [SAD §14](./SAD.md#14-security) |
| Docker & CI/CD | [SAD §16-17](./SAD.md#16-docker-setup) → [operations.md](./operations.md) |
| Production infrastructure | [SAD §18](./SAD.md#18-production-infrastructure) → [operations.md §6](./operations.md#6-production-infrastructure) |
| Monitoring | [SAD §19](./SAD.md#19-monitoring) → [operations.md §7](./operations.md#7-monitoring--alerting) |
| Development roadmap | [SAD §22](./SAD.md#22-development-roadmap) |
| MVP roadmap | [SAD §23](./SAD.md#23-mvp-roadmap) |
