# Tafakkur LMS — Web

Next.js 16 (App Router) + HeroUI v3 dashboard for the Tafakkur LMS Rails API.

## Run

```bash
cp .env.example .env.local   # points at the Rails API on :3001
npm install
npm run dev                  # http://localhost:3000
```

Or from the repo root: `docker compose up frontend`.

No backend running? On the sign-in page pick **Administrator**, **Teacher**, **Student** or **Parent** under
"explore with sample data" to open that role's dashboard with in-browser demo data.

## What's here

| Area | Notes |
|------|-------|
| `src/app/auth/login` | Sign-in against `POST /auth/login`; demo sign-in per role |
| `src/app/(dashboard)/layout.tsx` | Sidebar + top bar shell (collapsible sidebar on desktop, drawer on mobile) |
| `src/app/(dashboard)/{admin,teacher,student,parent}` | Role dashboards |
| `src/app/(dashboard)/admin/{students,teachers}` | Paginated, searchable tables wired to `/students` and `/teachers` |
| `src/proxy.ts` | Redirects `/` to the user's role dashboard and guards dashboard routes |
| `src/lib/api/client.ts` | Wretch client: bearer token, one refresh-and-retry on 401 |
| `src/lib/navigation/nav.ts` | Sidebar items per role |

Headcounts on the admin dashboard and the student/teacher tables come from the real API. Widgets marked
**Sample** (attendance trends, grade distribution, timetable, homework, announcements) use
`src/features/dashboard/data/mock.ts` until the API exposes those endpoints. Sidebar items without a
screen yet render a "not built yet" placeholder.

## Checks

```bash
npm run lint
npm run build
```
