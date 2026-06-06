# Josi Ride Mobile Design Eval

Outcome: a rider should see the Josi brand first, complete the dark email login experience, and land on a ride request surface without needing any external service.

Gate rubric:

1. Brand: splash is only red `0xFFE50914`, keeps the Josi logo centered, and remains visible for 4.2 seconds before routing.
2. Logo placement: the actual Josi image logo only appears on the splash screen, not on login or home.
3. Typography: the Flutter theme declares Inter and the bundled font files cover regular, medium, semibold, bold, and extrabold weights.
4. Auth flow: app starts on splash, transitions to a black email/password login screen, uses red Google/Apple buttons, and can navigate to the ride home shell.
5. Booking drawer: the home drawer is draggable, accepts pickup and drop-off locations, shows nearby riders with proximity instead of Popular Rides, and keeps the bottom menu fixed outside the drawer scroll.
6. Payment flow: selecting a rider opens a payment section with "How would you like to pay?", Cash, and Add debit/credit card.
7. Driver flow: selecting a payment method opens the driver-on-the-way page with arrival time, driver, vehicle, fare, route facts, cancel, and share actions.
8. Account flow: tapping Account opens a smooth slide/fade account page with customer name, rating, right-side profile-picture upload action, and only Profile, Payment, Support, Safety, Saved places, and Settings.
9. Removed account sections: Promotions, Family Profile, and Work Profile must not render in the account list.
10. Portability: no API keys, map SDKs, runtime font downloads, or network calls are required for the current UI.

Run the deterministic local eval:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_mobile_app.ps1
```

Run the Flutter widget tests when the Flutter SDK is installed:

```powershell
cd mobile/app
flutter test
```
