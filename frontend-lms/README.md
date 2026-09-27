# Tafakkur LMS — Flutter app

Flutter client for the Tafakkur LMS Rails API with the same dashboard as the web app (`../frontend`):
a role-based sidebar (collapsible on desktop/tablet, a drawer on phones), and dashboards for
administrators, teachers, students and parents.

HeroUI is a React library, so it can't be used from Flutter directly. Instead
`lib/app/theme/` recreates HeroUI v3's default theme with Flutter widgets: the colour tokens are
converted from `@heroui/styles` (light and dark), with the same radii (pill buttons, 12px fields,
24px cards), Inter type, and soft chips and icon tiles.

## Run

```bash
flutter pub get
flutter run                                   # API at http://localhost:3001/api/v1
flutter run --dart-define=API_URL=http://10.0.2.2:3001/api/v1   # Android emulator
```

No backend? On the sign-in screen pick a role under "explore with sample data".

When running as a Flutter **web** app, the Rails CORS config (`FRONTEND_URL`) must allow the
Flutter dev server's origin.

## Layout

| Path | What |
|------|------|
| `lib/app/theme/` | HeroUI tokens (`HeroColors`) and `ThemeData` |
| `lib/app/router.dart` | go_router routes and role-based redirects |
| `lib/core/api/api_client.dart` | JSON client: bearer token, refresh cookie, one retry on 401 |
| `lib/core/auth/auth_controller.dart` | Sign-in, demo sign-in, sign-out |
| `lib/core/navigation/nav_items.dart` | Sidebar items per role (mirrors the web app) |
| `lib/shell/` | Sidebar, top bar, responsive shell |
| `lib/features/` | Login, role dashboards, students/teachers lists |

Headcounts and the students/teachers lists come from the API. Widgets marked **Sample** use
`lib/features/dashboard/mock_data.dart` until the API has those endpoints.

## Checks

```bash
flutter analyze
flutter test
```
