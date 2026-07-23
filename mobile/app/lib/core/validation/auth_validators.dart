/// Client-side auth field validation.
///
/// These run before any loading state or network request so the user gets
/// immediate feedback. The password rule mirrors the backend
/// `Password::min(8)` requirement enforced on register/reset
/// (see backend `app/Http/Requests/Api/V1/Auth/*`).
library;

/// Minimum password length accepted anywhere in the app. Matches the backend
/// `Password::min(8)` rule.
const int kMinPasswordLength = 8;

/// Returns an error message for the login identifier (email or phone), or
/// `null` when it is acceptable.
String? validateLoginIdentity(String value) {
  if (value.trim().isEmpty) {
    return 'Enter your email or phone number.';
  }
  return null;
}

/// Returns an error message for a login password, or `null` when it satisfies
/// the client-side requirements.
///
/// A blank field and a too-short password are reported before the request is
/// sent, so the sign-in screen never shows a loading spinner for input that can
/// never succeed.
String? validateLoginPassword(String value) {
  if (value.isEmpty) {
    return 'Enter your password.';
  }
  if (value.length < kMinPasswordLength) {
    return 'Password must be at least $kMinPasswordLength characters.';
  }
  return null;
}
