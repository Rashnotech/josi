# Josi Ride Mobile Design Eval

Outcome: a rider should see the Josi brand first, complete phone-based sign in, and land on a ride request surface without needing any external service.

Gate rubric:

1. Brand: splash renders the Josi logo, red `0xFFE50914`, black `0xFF080808`, and no unrelated dominant palette.
2. Logo placement: the actual Josi image logo only appears on the splash screen.
3. Typography: the Flutter theme declares Inter and the bundled font files cover regular, medium, semibold, bold, and extrabold weights.
4. Auth flow: app starts on splash, transitions to sign in, validates terms acceptance, and can navigate to the ride home shell.
5. Ride context: post-auth screen shows a map-like Abuja ride surface with destination search and later scheduling affordance.
6. Portability: no API keys, map SDKs, runtime font downloads, or network calls are required for the current UI.

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
