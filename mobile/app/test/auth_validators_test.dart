import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/core/validation/auth_validators.dart';

void main() {
  group('validateLoginIdentity', () {
    test('rejects an empty or whitespace-only identifier', () {
      expect(validateLoginIdentity(''), 'Enter your email or phone number.');
      expect(validateLoginIdentity('   '), 'Enter your email or phone number.');
    });

    test('accepts a non-empty identifier', () {
      expect(validateLoginIdentity('customer@josi.test'), isNull);
      expect(validateLoginIdentity('+2348012345678'), isNull);
    });
  });

  group('validateLoginPassword', () {
    test('rejects an empty password', () {
      expect(validateLoginPassword(''), 'Enter your password.');
    });

    test('rejects a password shorter than the minimum length', () {
      expect(
        validateLoginPassword('short'),
        'Password must be at least $kMinPasswordLength characters.',
      );
      // One character below the boundary is still rejected.
      expect(
        validateLoginPassword('a' * (kMinPasswordLength - 1)),
        'Password must be at least $kMinPasswordLength characters.',
      );
    });

    test('accepts a password at or above the minimum length', () {
      expect(validateLoginPassword('a' * kMinPasswordLength), isNull);
      expect(validateLoginPassword('Password123!'), isNull);
    });

    test('mirrors the backend Password::min(8) rule', () {
      expect(kMinPasswordLength, 8);
    });
  });

  group('validatePhoneNumber', () {
    test('rejects an empty phone number', () {
      expect(validatePhoneNumber(''), 'Phone number is required.');
    });

    test('rejects a 10-digit number missing the leading 0', () {
      // This is the exact bug: a 10-digit number was previously accepted.
      expect(
        validatePhoneNumber('8012345678'),
        'Enter an 11-digit phone number (e.g. 08012345678).',
      );
    });

    test('rejects a 9-digit or 12-digit local-looking number', () {
      expect(
        validatePhoneNumber('080123456'),
        'Enter an 11-digit phone number (e.g. 08012345678).',
      );
      expect(
        validatePhoneNumber('080123456789'),
        'Enter an 11-digit phone number (e.g. 08012345678).',
      );
    });

    test('accepts a well-formed 11-digit local number', () {
      expect(validatePhoneNumber('08012345678'), isNull);
    });

    test('accepts formatted local numbers with spaces or dashes', () {
      expect(validatePhoneNumber('0801 234 5678'), isNull);
      expect(validatePhoneNumber('0801-234-5678'), isNull);
    });

    test('accepts the +234 international equivalent', () {
      expect(validatePhoneNumber('+2348012345678'), isNull);
      expect(validatePhoneNumber('2348012345678'), isNull);
      expect(validatePhoneNumber('+234 801 234 5678'), isNull);
    });

    test('rejects other country codes and garbage input', () {
      expect(
        validatePhoneNumber('+15551234567'),
        'Enter an 11-digit phone number (e.g. 08012345678).',
      );
      expect(
        validatePhoneNumber('not a phone number'),
        'Enter an 11-digit phone number (e.g. 08012345678).',
      );
    });
  });
}
