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

## iOS

`ios/Runner/AppDelegate.swift` reads the Maps key from the `GMSApiKey` entry in
`ios/Runner/Info.plist`, which in turn resolves the `GOOGLE_MAPS_IOS_API_KEY`
xcconfig build setting (mirrors the Android `local.properties` pattern above).
`ios/Runner/Info.plist` already declares `NSLocationWhenInUseUsageDescription`.

To supply a real key locally:

```powershell
cp mobile/app/ios/Flutter/Local.xcconfig.example mobile/app/ios/Flutter/Local.xcconfig
```

Then edit `mobile/app/ios/Flutter/Local.xcconfig` and set:

```
GOOGLE_MAPS_IOS_API_KEY = <ios-maps-api-key>
```

`ios/Flutter/Local.xcconfig` is ignored by git. Do not commit production API
keys. If the key is left blank, `AppDelegate.swift` skips calling
`GMSServices.provideAPIKey` rather than crashing — the map will just render
unauthenticated (blank/grey) until a real key is set.

Restrict the iOS key in Google Cloud Console to the iOS bundle id and the
Maps SDK for iOS before shipping to TestFlight/App Store.

Building on Windows cannot run `pod install`/verify this compiles — confirm on
a Mac (or CI) before shipping. `google_maps_flutter_ios`'s podspec pulls in the
native `GoogleMaps` CocoaPod automatically; no manual Podfile change is needed.
