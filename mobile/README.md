# Josi Mobile

The Flutter rider app lives in `app/`.

Quick checks:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_mobile_app.ps1
flutter test
```

If the Flutter platform folders have not been generated yet:

```powershell
cd mobile/app
flutter create --platforms=android,ios .
```
