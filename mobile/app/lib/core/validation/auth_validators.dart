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

/// Strips spaces, dashes, and parentheses so phone numbers can be compared
/// regardless of how the user separated the digits.
String _normalizePhone(String value) =>
    value.trim().replaceAll(RegExp(r'[\s\-()]'), '');

/// Nigerian local mobile format: a leading 0 followed by 10 digits (11 total),
/// e.g. 08012345678.
final RegExp _localNigerianPhone = RegExp(r'^0\d{10}$');

/// Nigerian international format: +234 (country code, plus optional) followed
/// by the 10 digits that remain once the leading 0 is dropped, e.g.
/// +2348012345678.
final RegExp _internationalNigerianPhone = RegExp(r'^\+?234\d{10}$');

/// Returns an error message for a registration phone number, or `null` when
/// it matches the required 11-digit Nigerian format.
///
/// Rejects anything that isn't exactly an 11-digit local number (0XXXXXXXXXX)
/// or its +234 international equivalent, so a 10-digit number missing the
/// leading 0 is never accepted.
String? validatePhoneNumber(String value) {
  if (value.trim().isEmpty) {
    return 'Phone number is required.';
  }
  final String normalized = _normalizePhone(value);
  final bool isValid = _localNigerianPhone.hasMatch(normalized) ||
      _internationalNigerianPhone.hasMatch(normalized);
  if (!isValid) {
    return 'Enter an 11-digit phone number (e.g. 08012345678).';
  }
  return null;
}
