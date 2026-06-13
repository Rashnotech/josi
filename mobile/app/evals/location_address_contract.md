# Josi Location Address Eval

Outcome: customer map and trip screens show readable rider/location copy while keeping coordinates available for backend payloads.

Gate rubric:

1. `geocoding` is installed and `ReverseGeocodingService` uses `placemarkFromCoordinates`.
2. Reverse geocoding formats street, sub-locality, locality, administrative area, and country into one readable address.
3. Current, pickup, and destination address providers exist alongside coordinate providers.
4. Backend trip location payloads keep latitude, longitude, and address values.
5. Customer home and destination selection show address text or `Fetching location address...`, not raw latitude/longitude.
6. Searching ride and ride-found screens render `JosiGoogleMap`.
7. Customer-facing trip copy uses Rider wording.
8. Driver-arrived, booking, and rider-contact actions use the provided SMS and call SVG assets.

Run the deterministic source eval:

```powershell
cd mobile/app
powershell -ExecutionPolicy Bypass -File tooling/verify_location_address.ps1
```
