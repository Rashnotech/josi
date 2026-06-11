# Josi Mobile MVP Design Eval

Outcome: a customer or rider can launch Josi, understand the role split, authenticate through the shared login, and reach a polished mock MVP experience that is ready for Laravel API integration.

Gate rubric:

1. Architecture: app source lives in `lib/core` and `lib/features`, with the old `lib/src` prototype removed from active use.
2. Navigation: `GoRouter` owns every required general, customer, rider, and dynamic trip route.
3. State: Riverpod provides auth, current user, rider profile, trips, wallet, cash ledger, documents, and notifications.
4. Backend readiness: placeholder repositories exist for auth, customer, rider, trip, wallet, and notifications.
5. Theme: Material 3, Inter, Josi red `0xFFE31837`, `#F7F9FB` light surface, off-black text, low-contrast outlines, normal mobile text sizing, and 4-8px shape rules follow `mobile/DESIGN.md`.
6. Components: shared widgets cover buttons, fields, dropdowns, search, cards, status badges, empty/loading/error states, section headers, trip/vehicle/wallet/profile/document/map UI, scaffold, and role-aware bottom nav.
7. First-run flow: splash uses a red background with `josi_log.png`, then routes directly to the uploaded role-selection design.
8. SVG assets: `flutter_svg` is installed and the auth flow uses SVG icons from `assets/images`.
9. Login flow: selecting customer or rider opens the uploaded role-specific login design and uses `josi-logo.jpeg`.
10. Signup flow: customer signup uses the uploaded `Create Account` layout; rider signup uses the uploaded `Drive with Josi Ride` layout with vehicle type selection.
11. Customer flow: home, select location, payment methods, searching rider, active trip, completed trip, trips, trip detail, profile, notifications, support, and settings are routed. The standalone customer wallet screen and customer wallet route are not present. Customer home is map-first, fills the body from the top edge, uses a draggable where-to bottom sheet for destination entry, uses the history SVG for Activity navigation, uses the office SVG for the Office tile, and lets current-location controls trigger phone GPS. The customer Activity screen opens a `Bookings` page with a three-item tab menu for Active, Completed, and Cancelled bookings, compact normal-size text, reference-style driver cards, date/time, route, rating, car number, active map preview actions, and cancelled status labels. The shared Settings screen matches the uploaded three-row layout for Notification Settings, Password Manager, and Delete Account. The shared Help Center screen matches the uploaded search layout and uses a two-item tab menu for FAQ and Contact Us, with FAQ category chips and contact cards.
12. Destination flow: the destination title sits at normal header size with compact top spacing, current location can fill from device GPS, the destination field remains editable before confirmation, saved address text and the confirm action use normal mobile sizing, confirmation opens the uploaded payment methods step before rider search, and the Rides tab stays visibly selected on the destination screen. The obsolete Book a trip screen and `/customer/book-trip` route are not present.
13. Payment methods flow: the customer payment screen keeps Cash, Wallet, and Add Card only; More Payment Options, Paypal, Apple Pay, and Google Pay are not present. Payment labels and the Confirm Payment action use normal medium mobile sizing.
14. Ride search flow: searching and found states render a full-screen street map, use the humbleicons bike SVG instead of car/taxi imagery, and show the request ride details in a shorter draggable bottom sheet with normal-size fitting text and no empty bottom space.
15. Active trip flow: the customer active trip screen matches the uploaded Driver Arrived map layout, uses compact back controls, shows Jenny Wilson, Sedan, pickup/drop-off, OTP, rate, car number, seats, and uses a `Trip preview` action instead of `Cancel Ride`.
16. Completed trip flow: the customer completed trip screen matches the uploaded Rate Driver layout, shows Jenny Wilson, vehicle details, star rating, detailed review input, submit action, and keeps the `{amount} cash payment recorded for this trip` message visible.
17. Rider flow: home, application status, profile setup, documents, vehicle setup, available trips, trip request, active trip, completed trip, trips, wallet, cash ledger, notifications, profile, support, and settings are routed.
18. MVP constraints: no backend, payment processor, map SDK, WebSockets, API keys, or network runtime dependency is required for the UI.

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
