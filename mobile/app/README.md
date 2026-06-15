# Josi Mobile App

Flutter source for the Josi customer and rider MVP.

Included:

- Material 3 app shell with Inter typography and a centralized red-based Josi design system.
- Normal mobile text sizing shared across the app, with compact back controls.
- `mobile/DESIGN.md` light redline applied to the first-run splash, role selection, and login screens.
- GoRouter route map for splash, onboarding, auth/reset, customer flows, rider flows, and shared profile/support/settings surfaces.
- `flutter_svg` support for SVG icons in `assets/images`.
- Riverpod providers for auth, users, rider application data, trips, rider wallet, cash ledger, and notifications.
- Laravel-ready auth repository for login, rider/courier registration, forgot password, reset code verification, password reset, logout, and `/me` session restore.
- Mock fallback remains active only when no auth API base URL is configured, so widget tests stay deterministic.
- Reusable UI components for forms, cards, status badges, bottom navigation, map placeholders, trip cards, rider wallet cards, vehicle cards, document upload cards, and empty/loading/error states.
- Customer screens for destination entry, payment methods, driver-arrived active trip, rate-driver completed trip, trip history/detail, notifications, support, settings, and profile.
- Rider screens for onboarding approval, KYC documents, vehicle setup, available requests, active trip actions, earnings, cash ledger, notifications, support, settings, and profile.
- Route drawing through `RouteService`, with Google Routes API support, a Laravel-ready route endpoint option, and a local fallback polyline when no route API is configured.
- Widget tests and deterministic source eval.

Run locally:

```powershell
cd mobile/app
flutter pub get
flutter analyze
flutter test
flutter run
```

Route configuration:

```powershell
flutter run --dart-define=JOSI_GOOGLE_ROUTES_API_KEY=<google-routes-api-key>
```

Laravel auth API configuration:

```powershell
flutter run --dart-define=JOSI_API_BASE_URL=https://your-api.test/api/v1
```

Auth tokens are stored with `flutter_secure_storage`. The app sends:

- `POST /auth/login`
- `POST /auth/register` for rider and courier accounts
- `POST /auth/forgot-password`
- `POST /auth/verify-reset-code`
- `POST /auth/reset-password`
- `POST /auth/logout`
- `GET /auth/me`

For production, prefer routing through Laravel instead of exposing a Google
Routes key in the mobile client:

```powershell
flutter run --dart-define=JOSI_BACKEND_ROUTE_ENDPOINT=https://your-api.test/api/v1/maps/route
```

Deterministic source check:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_mobile_app.ps1
```

Notes:

- No payment processor, Google Maps SDK, WebSocket tracking, or backend keys are required for this UI pass.
- Splash uses `assets/images/josi_log.png`; role/login use `assets/images/josi-logo.jpeg` plus local SVG icons.
- The bundled Josi image and Inter font assets are used locally.
