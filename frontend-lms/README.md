# Tafakkur LMS — Flutter app

Mobile (Android and iOS) client for the Tafakkur LMS Rails API with the same dashboards as the web app
(`../frontend`): a role-based sidebar in a drawer, and dashboards for administrators, teachers, students
and parents. The app also signs the user in on the web by scanning a QR code, like Telegram.

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

On a real phone, point `API_URL` at your machine's LAN address.

## QR sign-in for the web

1. Open the web sign-in page; the **QR code** tab shows a code that refreshes every 2 minutes.
2. In the app (signed in with a real account, not sample data) tap the QR icon in the top bar.
3. Scan the code, check the browser and IP on the confirmation sheet, and tap **Sign in**.

The QR code holds `tafakkur://qr-login?token=…`. The app needs camera permission
(`CAMERA` in `AndroidManifest.xml`, `NSCameraUsageDescription` in `Info.plist`).

## Layout

| Path | What |
|------|------|
| `lib/app/theme/` | HeroUI tokens (`HeroColors`) and `ThemeData` |
| `lib/app/router.dart` | go_router routes and role-based redirects |
| `lib/core/api/api_client.dart` | JSON client: bearer token, refresh cookie, one retry on 401 |
| `lib/core/auth/auth_controller.dart` | Sign-in, demo sign-in, sign-out |
| `lib/core/navigation/nav_items.dart` | Sidebar items per role (mirrors the web app) |
| `lib/shell/` | Drawer sidebar, top bar (QR scanner button, account menu) |
| `lib/features/qr_login/` | QR scanner and sign-in confirmation |
| `lib/core/services/qr_login_service.dart` | `/auth/qr/scan`, `/approve`, `/decline` |
| `lib/features/` | Login, role dashboards, students/teachers lists |

Headcounts and the students/teachers lists come from the API. Widgets marked **Sample** use
`lib/features/dashboard/mock_data.dart` until the API has those endpoints.

## Checks

```bash
flutter analyze
flutter test
```
