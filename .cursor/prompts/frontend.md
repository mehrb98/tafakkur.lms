# Frontend Development Prompt — Tafakkur LMS

## Role

Act as Principal Frontend Architect, Senior React Engineer, and UX Architect.

Build a production-ready, multi-tenant SaaS LMS frontend. The Rails REST API is the source of truth — do not redesign the backend.

**Planning schema (source of truth for routes/folders):** `.cursor/docs/architecture/frontend-schema.md`

---

## Tech Stack (mandatory)

| Layer | Technology |
|-------|------------|
| Framework | Next.js 16+ App Router, React 19, TypeScript (strict) |
| UI | HeroUI v3.2.2, Tailwind CSS v4 |
| Forms | React Hook Form, Zod, `@hookform/resolvers` |
| API | Wretch (`lib/api/`) |
| Auth | Better Auth + Rails JWT bridge (`lib/auth/`) |
| Server state | TanStack React Query |
| Tables | TanStack React Table (via `components/data-table/`) |
| Charts | Recharts |
| i18n | next-intl (en, de) |
| Theme | next-themes |
| Toasts | Sonner |
| Utils | clsx, class-variance-authority, date-fns |
| Upload | react-dropzone (when file API exists) |
| Testing | Vitest, RTL, Playwright |

**Formatting:** 4 spaces, Prettier, no `any`, functional components only.

---

## Architecture Principles

- Feature-based modules — each feature is independent
- Server Components by default; Client Components only when needed
- No `AppShell`, `AuthLayout`, `DashboardLayout`, or `<Feature>Page` wrappers
- Routes compose feature components directly in `page.tsx`
- Shared composites in `components/<domain>/` only when reused 3+ features
- Feature UI in `features/<name>/components/<domain>/`
- Auth at `app/auth/*` → `/auth/login`; root `/` redirect in `proxy.ts` only
- Tenant context from session only — never `school_id` in forms

---

## Project Structure

```
frontend/src/
├── proxy.ts                    # Auth, role guards, / redirect
├── app/
│   ├── layout.tsx
│   ├── auth/                   # Public auth → /auth/*
│   ├── (dashboard)/            # Authenticated routes
│   └── api/auth/[...all]/      # Better Auth handlers
├── components/                 # Shared composites (data-table, page-header, charts, stat-card)
├── config/                     # App config, env validation
├── constants/                  # App-wide constants
├── features/<name>/            # Domain modules
│   ├── components/<domain>/
│   ├── hooks/
│   ├── schemas/
│   ├── services/
│   ├── types/
│   └── utils/
├── hooks/                      # Cross-feature hooks
├── layout/                     # sidebar/, top-bar/
├── lib/
│   ├── api/                    # client, errors, pagination, endpoints
│   ├── auth/                   # Better Auth, session, permissions, role-home
│   ├── form/                   # RHF helpers
│   ├── navigation/             # Role nav configs
│   └── utils/                  # cn(), formatters
├── messages/                   # next-intl JSON (en/, de/)
├── providers/                  # Theme, Query, Auth, I18n, Toaster
├── schemas/                    # Shared Zod schemas
├── styles/                     # globals.css, tokens, focus
└── types/                      # Shared TS types
```

---

## User Roles & Routes

| Role | Home | Key areas |
|------|------|-----------|
| Admin | `/admin` | School, teachers, students, parents, classes, subjects, departments, academic-years, reports, settings |
| Teacher | `/teacher` | Classes, attendance, grades, homework*, exams* |
| Student | `/student` | Timetable*, grades, attendance, announcements* |
| Parent | `/parent` | Children, grades, attendance, notifications* |

\* Backend API pending — scaffold route only when blocked.

---

## API Layer

```
lib/api/client.ts       # Wretch + credentials + Bearer + 401 refresh
lib/api/errors.ts       # ApiClientError parser
lib/api/pagination.ts   # buildQuery, PaginatedResponse
lib/api/endpoints.ts    # Route constants
```

Each feature owns `features/<name>/services/*.service.ts` calling `api`.

**Token flow:** Rails issues JWT + refresh cookie; Better Auth manages session; access token in memory via `token-store`; Wretch attaches Bearer; 401 triggers silent refresh.

---

## State Management

| State | Tool |
|-------|------|
| Server/async | TanStack React Query (queries, mutations, cache, invalidation) |
| Auth session | Better Auth + `AuthProvider` |
| Theme | next-themes via `ThemeProvider` |
| UI ephemeral | Component state |
| Forms | React Hook Form |

Do not use Redux.

---

## Authorization (RBAC)

```
lib/auth/permissions.ts     # canAccessPath(role, pathname)
hooks/useRole.ts          # useRole(), usePermission()
components/auth/          # RoleGuard, Can (when needed)
proxy.ts                  # Route-level guards
```

Frontend checks are UX only — backend Pundit is authoritative.

---

## Data Fetching Patterns

- **RSC:** `getSession()`, initial server fetches where appropriate
- **CSR:** React Query hooks in client feature components
- **Mutations:** `useMutation` + Sonner toast + `queryClient.invalidateQueries`
- **Pagination:** `page`, `limit` query params; `DataTable` contract
- **Optimistic updates:** Grades, attendance mutations

---

## UI System

### HeroUI v3 only

Use primitives directly. Never create custom Button/Input/Modal replacements.

### Shared composites (build when 3+ features need them)

- `components/data-table/DataTable.tsx` — pagination, sort, filter, empty, loading
- `components/page-header/PageHeader.tsx`
- `components/charts/ChartCard.tsx`
- `components/stat-card/StatCard.tsx`

### Design tokens

All colors via CSS variables in `styles/globals.css`. No hardcoded hex in components.

### Layout chrome

- `layout/sidebar/Sidebar.tsx` — role nav, icons, collapsible on mobile
- `layout/top-bar/TopBar.tsx` — search, notifications, theme, user menu

---

## Forms

```
features/<name>/schemas/*.schema.ts   # Zod
features/<name>/components/           # RHF + HeroUI TextField/Input
```

Map API `{ error: { details: [{ field, message }] } }` to field errors.

---

## Internationalization

```
messages/en/*.json
messages/de/*.json
providers/I18nProvider.tsx
```

Start with `common`, `auth`, per-feature namespaces.

---

## Error Handling

- Route `error.tsx` boundaries
- `ApiClientError` → Sonner toast or inline field errors
- Global `Toaster` in providers
- 404/403 via `not-found.tsx` and proxy redirects

---

## Testing

| Layer | Tool | Priority |
|-------|------|----------|
| Unit | Vitest + RTL | forms, hooks, DataTable |
| E2E | Playwright | login, admin CRUD, tenant isolation |
| a11y | RTL + manual | forms, sidebar keyboard nav |

---

## Performance

- Lazy-load heavy client features (charts, dropzone)
- React Query staleTime/cacheTime per resource
- Skeleton loading on all list routes
- `loading.tsx` per route segment

---

## Security Checklist

- Access token in memory only (never localStorage)
- Refresh via httpOnly cookie on Rails origin
- `credentials: "include"` on Wretch
- RBAC in proxy + layout server checks
- No secrets in client bundles
- CSP-compatible theme script in layout `<head>`

---

## Feature Deliverables (per module)

1. `types/*.types.ts` — mirror Jbuilder shapes
2. `schemas/*.schema.ts` — Zod for forms
3. `services/*.service.ts` — API calls
4. `hooks/use*.ts` — React Query hooks
5. `components/<domain>/` — List, Form, Filters
6. `app/(dashboard)/.../page.tsx` — compose directly
7. `loading.tsx`, `error.tsx` where applicable
8. `messages/en/<feature>.json` + `de/` mirror

---

## Current Implementation Status

| Area | Status |
|------|--------|
| Auth (Better Auth + Rails) | Done |
| API client + refresh | Done |
| Dashboard shell | Basic — modernizing |
| Admin list pages | Read-only lists |
| CRUD forms | Not started |
| React Query | Integrating |
| Sonner | Integrating |
| next-intl | Dep only |
| Charts/dashboards | Placeholder |
| Messaging, announcements, files | Blocked on backend |

---

## Deliverable Checklist (every task)

1. Architecture fit (schema §0 conventions)
2. Types + service + schema
3. React Query hooks (not raw useEffect fetch)
4. HeroUI components, design tokens
5. Loading, empty, error states
6. Sonner feedback on mutations
7. ESLint + TypeScript pass
8. No placeholder/demo copy in production paths

---

## Final Rule

Build like a commercial SaaS team: explicit types, feature isolation, accessible HeroUI, scalable patterns. Never ship placeholder UIs in completed phases.
