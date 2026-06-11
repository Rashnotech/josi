# Josi Mobile MVP Design Eval

Outcome: a customer or rider can launch Josi, understand the role split, authenticate through the shared login, and reach a polished mock MVP experience that is ready for Laravel API integration.

Gate rubric:

1. Architecture: app source lives in `lib/core` and `lib/features`, with the old `lib/src` prototype removed from active use.
2. Navigation: `GoRouter` owns every required general, customer, rider, and dynamic trip route.
3. State: Riverpod provides auth, current user, rider profile, trips, wallet, cash ledger, documents, and notifications.
4. Backend readiness: placeholder repositories exist for auth, customer, rider, trip, wallet, and notifications.
5. Theme: Material 3, Inter, Josi red `0xFFE31837`, `#F7F9FB` light surface, off-black text, low-contrast outlines, and 4-8px shape rules follow `mobile/DESIGN.md`.
6. Components: shared widgets cover buttons, fields, dropdowns, search, cards, status badges, empty/loading/error states, section headers, trip/vehicle/wallet/profile/document/map UI, scaffold, and role-aware bottom nav.
7. First-run flow: splash uses a red background with `josi_log.png`, then routes directly to the uploaded role-selection design.
8. SVG assets: `flutter_svg` is installed and the auth flow uses SVG icons from `assets/images`.
9. Login flow: selecting customer or rider opens the uploaded role-specific login design and uses `josi-logo.jpeg`.
10. Signup flow: customer signup uses the uploaded `Create Account` layout; rider signup uses the uploaded `Drive with Josi Ride` layout with vehicle type selection.
11. Customer flow: home, select location, payment methods, searching rider, active trip, completed trip, trips, trip detail, wallet, profile, notifications, support, and settings are routed. Customer home is map-first, fills the body from the top edge, uses a draggable where-to bottom sheet for destination entry, uses the history SVG for Activity navigation, uses the office SVG for the Office tile, and lets current-location controls trigger phone GPS.
12. Destination flow: the destination title sits at normal header size with compact top spacing, current location can fill from device GPS, the destination field remains editable before confirmation, and confirmation opens the payment methods step before rider search. The obsolete Book a trip screen and `/customer/book-trip` route are not present.
13. Rider flow: home, application status, profile setup, documents, vehicle setup, available trips, trip request, active trip, completed trip, trips, wallet, cash ledger, notifications, profile, support, and settings are routed.
14. MVP constraints: no backend, payment processor, map SDK, WebSockets, API keys, or network runtime dependency is required for the UI.

Run the deterministic source eval:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_mobile_app.ps1
```

Run Flutter checks:

```powershell
cd mobile/app
flutter analyze
flutter test
```
