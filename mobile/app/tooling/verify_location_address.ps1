$ErrorActionPreference = "Stop"

function Assert-Contains {
  param(
    [string]$Path,
    [string]$Pattern,
    [string]$Message
  )

  $Content = Get-Content -Raw -Path $Path
  if ($Content -notmatch $Pattern) {
    throw $Message
  }
}

function Assert-NotContains {
  param(
    [string]$Path,
    [string]$Pattern,
    [string]$Message
  )

  $Content = Get-Content -Raw -Path $Path
  if ($Content -match $Pattern) {
    throw $Message
  }
}

Assert-Contains "pubspec.yaml" "geocoding:" "geocoding must be installed."
Assert-Contains "lib/core/location/reverse_geocoding_service.dart" "placemarkFromCoordinates" "ReverseGeocodingService must use placemarkFromCoordinates."
Assert-Contains "lib/core/location/reverse_geocoding_service.dart" "street" "Address formatter must include street."
Assert-Contains "lib/core/location/reverse_geocoding_service.dart" "subLocality" "Address formatter must include subLocality."
Assert-Contains "lib/core/location/reverse_geocoding_service.dart" "locality" "Address formatter must include locality."
Assert-Contains "lib/core/location/reverse_geocoding_service.dart" "administrativeArea" "Address formatter must include administrativeArea."
Assert-Contains "lib/core/location/reverse_geocoding_service.dart" "country" "Address formatter must include country."
Assert-Contains "lib/core/location/location_providers.dart" "currentLocationAddressProvider" "Current location address provider must exist."
Assert-Contains "lib/core/location/location_providers.dart" "selectedPickupAddressProvider" "Pickup address provider must exist."
Assert-Contains "lib/core/location/location_providers.dart" "selectedDestinationAddressProvider" "Destination address provider must exist."
Assert-Contains "lib/core/location/location_providers.dart" "tripLocationPayloadProvider" "Backend-ready location payload provider must exist."
Assert-Contains "lib/core/location/location_providers.dart" "pickup_latitude" "Payload must keep pickup latitude."
Assert-Contains "lib/core/location/location_providers.dart" "pickup_address" "Payload must keep pickup address."
Assert-Contains "lib/core/location/location_providers.dart" "destination_longitude" "Payload must keep destination longitude."
Assert-Contains "lib/features/customer/customer_screens.dart" "Fetching location address" "Customer UI must show address loading copy."
Assert-Contains "lib/features/customer/customer_screens.dart" "Unable to get address\. Please adjust the pin\." "Customer UI must show a friendly address fallback."
Assert-NotContains "lib/features/customer/customer_screens.dart" "_mockAddress" "Customer UI must not format raw coordinates for users."
Assert-NotContains "lib/features/customer/customer_screens.dart" "toStringAsFixed\(5\)" "Customer UI must not render rounded coordinates for users."
Assert-Contains "lib/features/customer/customer_screens.dart" "ride-search-map" "Searching ride map must use the reusable map surface."
Assert-Contains "lib/features/customer/customer_screens.dart" "ride-found-google-map" "Ride found map must use the reusable map surface."
Assert-Contains "lib/features/customer/customer_screens.dart" "Rider Arrived" "Active trip copy must say Rider Arrived."
Assert-Contains "lib/features/customer/customer_screens.dart" "Rate Rider" "Completed trip copy must say Rate Rider."
Assert-Contains "lib/features/customer/customer_screens.dart" "Rider pending" "Bookings must use Rider wording for unassigned trips."
Assert-Contains "lib/core/constants/app_assets.dart" "material-symbols--sms\.svg" "SMS asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "material-symbols--call\.svg" "Call asset must be registered."
Assert-Contains "lib/features/customer/customer_screens.dart" "booking-sms-button" "Bookings must expose SMS action."
Assert-Contains "lib/features/customer/customer_screens.dart" "booking-call-button" "Bookings must expose call action."

Write-Host "OK: location addresses, rider wording, real map surfaces, and contact assets are covered."
