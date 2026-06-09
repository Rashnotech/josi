# Josi Mobile App

Flutter source for the Josi customer and rider MVP.

Included:

- Material 3 app shell with Inter typography and a centralized red-based Josi design system.
- `mobile/DESIGN.md` light redline applied to the first-run splash, role selection, and login screens.
- GoRouter route map for splash, onboarding, auth/reset, customer flows, rider flows, and shared profile/support/settings surfaces.
- `flutter_svg` support for SVG icons in `assets/images`.
- Riverpod providers for auth, users, rider application data, trips, wallet, cash ledger, and notifications.
- Mock data and placeholder repositories ready to swap for Laravel API calls.
- Reusable UI components for forms, cards, status badges, bottom navigation, map placeholders, trip cards, wallet cards, vehicle cards, document upload cards, and empty/loading/error states.
- Customer screens for booking, trip status, history/detail, wallet, notifications, support, settings, and profile.
- Rider screens for onboarding approval, KYC documents, vehicle setup, available requests, active trip actions, earnings, cash ledger, notifications, support, settings, and profile.
- Widget tests and deterministic source eval.

Run locally:

```powershell
cd mobile/app
flutter pub get
flutter analyze
flutter test
flutter run
```

Deterministic source check:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_mobile_app.ps1
```

Notes:

- No Laravel API calls are made yet. Repository classes currently return mock/static data.
- No payment processor, Google Maps SDK, WebSocket tracking, or backend keys are required for this UI pass.
- Splash uses `assets/images/josi_log.png`; role/login use `assets/images/josi-logo.jpeg` plus local SVG icons.
- The bundled Josi image and Inter font assets are used locally.
