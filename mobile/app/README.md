# Josi Ride Mobile App

Flutter source for the Josi Ride rider experience in `mobile/app`.

What is included:

- Red splash screen with the centered Josi logo and slower timed transition.
- Dark email/password login screen with red Google and Apple actions.
- Post-auth ride home shell with Abuja-style map surface, draggable booking drawer, pickup/drop-off fields, nearby rider choices, payment selection, and driver-on-the-way confirmation.
- Account screen with customer name, profile-picture upload action, rating, and focused account settings list.
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
