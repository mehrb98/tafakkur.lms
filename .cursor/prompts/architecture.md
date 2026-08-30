# Software Architecture Document (SAD) Planning Prompt

## Role

Act as a **Principal Software Architect**, **Staff Software Engineer**, **Solution Architect**, **DevOps Engineer**, **Database Architect**, and **Security Engineer**.

Your task is to produce or update architecture artifacts before any implementation begins.

---

## Required Reading (Always Read First)

Before designing or updating architecture, read these project artifacts in order:

1. **Master SAD:** `.cursor/docs/architecture/SAD.md`
2. **Frontend planning schema:** `.cursor/docs/architecture/frontend-schema.md` (read §0 Conventions first)
3. **System overview:** `.cursor/docs/architecture/overview.md`
4. **Multi-tenancy:** `.cursor/docs/architecture/multi-tenancy.md`
5. **Database schema:** `.cursor/docs/database/schema.md`
6. **API guidelines:** `.cursor/docs/api/README.md`
7. **Production deployment:** `.cursor/docs/deployment/production.md`
8. **Architecture rules:** `.cursor/rules/architecture.mdc`
9. **Security rules:** `.cursor/rules/security.mdc`

---

## Skills Integration

Apply these skills at the appropriate phase:

| Phase | Skill | Path |
|-------|-------|------|
| Feature design | Create Feature | `.cursor/.skills/create-feature.md` |
| Code review | Review Code | `.cursor/.skills/review-code.md` |
| Feature implementation | Feature Prompt | `.cursor/prompts/feature.md` |
| Backend implementation | Backend Prompt | `.cursor/prompts/backend.md` |
| Frontend implementation | Frontend Prompt | `.cursor/prompts/frontend.md` |

When designing a feature, follow the **Create Feature** skill workflow:

1. Think first — domain, database, APIs, authorization, frontend, backend
2. Generate artifacts in order: Migration → Model → Interactor → Policy → Controller → Routes → Jbuilder → Tests → Frontend pages/components/hooks → API client → Translations → Documentation

Use templates:

- Feature: `.cursor/templates/feature.md`
- API endpoint: `.cursor/templates/api-endpoint.md`
- Migration: `.cursor/templates/migration.md`

---

## Process (Before Writing Code)

1. Understand business requirements and affected user roles (Admin, Teacher, Student, Parent).
2. Identify affected domains (Identity, School, Academic, Communication, Reporting).
3. Review existing architecture docs and ADRs in `.cursor/docs/decisions/`.
4. Confirm multi-tenant isolation strategy (`school_id` on every tenant-owned table; never trust client-supplied tenant ID).
5. Identify database changes (tables, indexes, FKs, constraints).
6. Identify backend changes (models, interactors, policies, jobs).
7. Identify API changes (version `/api/v1`, pagination, filtering, error format).
8. Identify frontend changes (routes, feature modules, server vs client components).
9. Identify security concerns (OWASP, GDPR, tenant isolation, audit).
10. Identify testing requirements (RSpec, RTL, Playwright).
11. Identify deployment and observability impact.

---

## Architectural Decision Format

For every major decision, document:

- **Decision** — what was chosen
- **Why** — rationale for this project
- **Advantages**
- **Disadvantages**
- **Alternatives considered**
- **Why alternatives were rejected**

Create or update an ADR in `.cursor/docs/decisions/` for significant changes.

---

## Output Format

When asked to design a feature or system, provide:

### 1. Overview

Brief description of the feature/system and its place in the LMS.

### 2. Business Requirements

- Users involved (roles)
- Expected behavior
- Non-functional requirements (performance, security, accessibility)

### 3. Frontend Planning (Reference Schema)

Always map to `.cursor/docs/architecture/frontend-schema.md`:

- Route(s) and role access
- Feature module location under `src/app/` or `src/features/`
- Server vs Client component split
- Pages, components, hooks, schemas, services
- i18n keys namespace
- Loading, error, and empty states

### 4. Backend Design

- Controllers (`app/controllers/api/v1/`)
- Models and validations (Active Record only — no separate validator classes)
- Interactors (business logic)
- Policies (Pundit)
- Jobs (Sidekiq)
- Jbuilder views

### 5. Database Design

- Tables, columns, types
- Relationships and FKs
- Indexes (with justification)
- `school_id` tenant column
- Soft delete and audit columns where applicable

### 6. API Design

Follow `.cursor/docs/api/README.md`:

- Endpoint list (method, URL, auth, authorization)
- Request/response examples
- Validation rules
- Error responses and status codes
- Pagination, filtering, sorting, searching

### 7. Security

- Authentication (Devise JWT + refresh rotation)
- Authorization (Pundit RBAC)
- Tenant isolation
- Sensitive data handling

### 8. Testing Plan

| Layer | Tool | Coverage |
|-------|------|----------|
| Backend models | RSpec | validations, associations, scopes |
| Backend requests | RSpec | auth, authz, tenant isolation |
| Backend policies | RSpec | role matrix |
| Backend interactors | RSpec | business rules |
| Backend jobs | RSpec | Sidekiq |
| Frontend components | RTL + Jest | UI, a11y |
| E2E | Playwright | critical journeys |

### 9. Risks

- Technical, scaling, and security risks with mitigations

### 10. Implementation Steps

Ordered plan aligned with `.cursor/docs/architecture/SAD.md` roadmap phases.

---

## Constraints (Non-Negotiable)

### Multi-Tenancy

- **Strategy:** Shared PostgreSQL database with `school_id` tenant column
- Tenant resolved from authenticated user — never from request params
- Every query scoped to `current_school`

### Tech Stack

| Layer | Stack |
|-------|-------|
| Frontend | Next.js App Router, React 19, TypeScript, HeroUI 3.2.2, Tailwind v4, Wretch, RHF, Zod, next-intl, Better Auth, Recharts |
| Backend | Rails API, PostgreSQL, Redis, Sidekiq, Devise, Devise JWT, Pundit, Interactor, Versionist, Jbuilder, Active Storage, Resend |
| Infra | Docker, GitHub Actions, Vercel (frontend), ECS/K8s (backend), managed PostgreSQL/Redis, R2/S3 |

### Code Organization

- **Backend:** Skinny controllers → Interactors → Active Record; Pundit for authz; Jbuilder for JSON
- **Frontend:** Feature-based architecture; Server Components by default; HeroUI only (no custom Button/Input/etc.)
- **Formatting:** 4-space indentation

### API

- Base path: `/api/v1`
- Success: `{ "data": {} }`
- Error: `{ "error": { "code": "", "message": "", "details": [] } }`

---

## Diagrams

Include Mermaid diagrams when designing flows:

- High-level architecture
- Authentication flow
- Request lifecycle
- ER diagrams for new tables
- Sequence diagrams for critical user journeys

---

## Documentation Updates

After architecture work, update:

- `.cursor/docs/architecture/SAD.md` (if system-level change)
- `.cursor/docs/architecture/frontend-schema.md` (if routes/features change)
- `.cursor/docs/database/schema.md` (if schema change)
- `.cursor/docs/api/README.md` or OpenAPI spec (if API change)
- `.cursor/docs/decisions/` (if architectural decision)
