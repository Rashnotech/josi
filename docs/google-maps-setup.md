# Google Maps Setup

## Android

The app reads the Android Maps key through the `googleMapsApiKey` manifest
placeholder in `mobile/app/android/app/build.gradle.kts`.

Use one of these local-only options:

```properties
# mobile/app/android/local.properties
JOSI_ANDROID_MAPS_API_KEY=<android-maps-api-key>
```

or:

```powershell
$env:JOSI_ANDROID_MAPS_API_KEY="<android-maps-api-key>"
flutter run
```

`mobile/app/android/local.properties` is ignored by git. Do not commit
production API keys.

Before production release, restrict the Android key in Google Cloud Console:

- Application restriction: Android apps
- Package name: `com.example.josi_ride` until the production package id changes
- Add the SHA-1 certificate fingerprint for each signing key
- API restriction: Maps SDK for Android

Create separate debug, staging, and production keys.

## iOS Later

This Flutter project currently does not include `mobile/app/ios/Runner`. When iOS
is generated, update:

`ios/Runner/AppDelegate.swift`

```swift
import GoogleMaps
```

Inside `didFinishLaunchingWithOptions`, before
`GeneratedPluginRegistrant.register`:

```swift
GMSServices.provideAPIKey("<ios-maps-api-key>")
```

Update `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Josi needs your location to show pickup points, nearby riders, and active trips.</string>
```

For production, store the iOS key in an `.xcconfig` file that is not committed,
and restrict it to the iOS bundle id in Google Cloud Console.
