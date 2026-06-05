# Josi Ride Mobile App

Flutter source for the Josi Ride rider experience in `mobile/app`.

What is included:

- Splash screen with the Josi logo, red and black brand system, and timed transition.
- Phone-first sign-in screen with Nigeria country code, terms gate, and social sign-in actions.
- Post-auth ride home shell with Abuja-style map surface, destination search, scheduling action, and navigation shortcuts.
- Bundled Inter font weights and bundled Josi logo asset.
- Flutter widget tests plus a deterministic local design eval.

Run locally:

```powershell
cd mobile/app
flutter pub get
flutter test
flutter run
```

If platform folders are not generated yet:

```powershell
cd mobile/app
flutter create --platforms=android,ios .
```

Deterministic source check without Flutter:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_mobile_app.ps1
```

Notes:

- The current UI uses no map SDK or backend keys. The home screen paints a lightweight map-like surface for the first product pass.
- Inter is bundled from Google Fonts under the SIL Open Font License in `assets/fonts/Inter-OFL.txt`.
- The Josi logo asset comes from `mobile/josi-logo.png`.
