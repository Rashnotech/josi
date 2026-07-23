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
}
