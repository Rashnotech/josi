# Josi Ride Mobile Design Eval

Outcome: a rider should see the Josi brand first, complete phone-based sign in, and land on a ride request surface without needing any external service.

Gate rubric:

1. Brand: splash and sign-in both render the Josi logo, red `0xFFE50914`, black `0xFF080808`, and no unrelated dominant palette.
2. Typography: the Flutter theme declares Urbanist and the bundled font files cover regular, medium, semibold, bold, and extrabold weights.
3. Auth flow: app starts on splash, transitions to sign in, validates terms acceptance, and can navigate to the ride home shell.
4. Ride context: post-auth screen shows a map-like Abuja ride surface with destination search and later scheduling affordance.
5. Portability: no API keys, map SDKs, runtime font downloads, or network calls are required for the current UI.

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
