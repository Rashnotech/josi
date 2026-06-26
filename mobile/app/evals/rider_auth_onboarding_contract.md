# Rider Auth And Onboarding Contract

Gate checks for rider auth and account setup:

- Rider create account posts to `/auth/register`.
- The mobile UI field `fullName` is never sent as `full_name`.
- `fullName` is split into `first_name` and optional `last_name`; mobile also sends `name` because the Laravel public register contract accepts it.
- Rider registration stores the returned bearer token through `TokenStorage` and restores the rider through `/auth/me`.
- Rider login, forgot password, verify reset code, and reset password use the shared auth backend endpoints with `identifier`.
- Routes under `/rider/*` require an authenticated rider.
- `/rider/application-status` greets the authenticated rider as `Welcome, name`.
- Required account setup sections are shown only while missing: Profile Picture, Bank Account Details, Riding Details.
- Complete Your Profile onboarding only asks for address, gender, and city you drive in.
- Profile Picture opens device photo selection from the upload icon and supports taking a camera selfie or choosing from gallery.
- Profile Picture back navigation returns to `/rider/application-status`.
- Profile Picture posts `profile_photo` to `/driver/onboarding/profile-picture`.
- Bank Account Details posts `account_number`, `bank_name`, and `account_name` to `/driver/onboarding/bank-account`.
- Riding Details posts backend enum `vehicle_type`, vehicle fields, city, and state to `/driver/onboarding/riding-details`.
- Riding Details normalizes unsupported profile city/state values to `Other` so Flutter dropdowns do not assert.
- Riding Details back navigation returns to `/rider/application-status`.
- Rider home metrics derive Pre-Booked and Today Earned from `/driver/trips`, not mock values.
- Rider home shows the Finding jobs progress only after tapping the floating search action.
- Rider home shows No ride found when `/driver/trips` has no assigned trip and opens the Ride Request panel automatically when one exists.
- Ride Request uses real trip customer, pickup, destination, fare, and a 30 second countdown.
- Ride Request Accept posts `/driver/trips/{trip}/accept`; Decline posts `/driver/trips/{trip}/decline`.
- Rider Bookings filters actual `/driver/trips` data into Active, Completed, and Cancelled tabs.
- Approved/onboarded rider login and session restore open `/rider/location-access`, not the application-status welcome screen; allowing location opens `/rider/home`.
- Rider home account/profile icon opens `/rider/profile`.
- Rider Wallet summary and transactions read `/driver/wallet`, not `JosiMockData.riderWallet` or static mock transactions.
- The application-status Continue action posts to `/driver/onboarding/submit` and shows success or backend validation errors.
- Rider profile/account setup uses backend data from `/driver/onboarding`, not mock rider profile data.
- Rider Profile shows backend rider name, phone, and location when available.
- `Your profile` saves name, phone, gender, address, city/state, and profile photo through `/driver/profile`.
- Settings Password Manager posts `current_password`, `password`, and `password_confirmation` to `/auth/change-password`.

Run:

```powershell
cd mobile/app
flutter test test/auth_repository_test.dart
flutter test test/rider_repository_test.dart
flutter test test/josi_ride_app_test.dart
```
