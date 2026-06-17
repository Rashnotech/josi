import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/core/auth/token_storage.dart';
import 'package:josi_ride/core/mock/josi_models.dart';
import 'package:josi_ride/core/repositories/repositories.dart';
import 'package:josi_ride/core/services/api_client.dart';

void main() {
  test('rider onboarding repository uses backend driver endpoints', () async {
    final List<Map<String, Object?>> requests = <Map<String, Object?>>[];
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    await storage.saveToken('rider-token', userRole: 'rider');

    final RiderRepository repository = RiderRepository(
      tokenStorage: storage,
      apiClient: ApiClient(
        baseUrl: 'https://api.josi.test/api/v1',
        httpRequest: (
          Uri uri, {
          required String method,
          required Map<String, String> headers,
          Object? body,
        }) async {
          requests.add(<String, Object?>{
            'method': method,
            'path': uri.path,
            'authorization': headers['Authorization'],
            'body': body == null ? null : jsonDecode(body as String),
          });

          return ApiHttpResponse(
            statusCode: 200,
            body: _onboardingBody(
              profilePhoto:
                  uri.path.endsWith('/profile-picture') ? 'selfie.jpg' : null,
              bankName: uri.path.endsWith('/bank-account')
                  ? 'Josi Microfinance'
                  : null,
              vehicleType: uri.path.endsWith('/riding-details') ? 'car' : null,
              submitted: uri.path.endsWith('/submit'),
            ),
          );
        },
      ),
    );

    final RiderOnboarding initial = await repository.onboarding();
    final RiderOnboarding profile = await repository.saveProfilePicture(
      profilePhoto: 'selfie.jpg',
    );
    final RiderOnboarding bank = await repository.saveBankAccount(
      accountNumber: '0123456789',
      bankName: 'Josi Microfinance',
      accountName: 'Amina Yusuf',
    );
    final RiderOnboarding riding = await repository.saveRidingDetails(
      vehicleType: 'car',
      brand: 'Toyota',
      model: 'Corolla',
      color: 'White',
      plateNumber: 'ABC 482 JK',
      registrationNumber: 'REG-2408-JR',
      city: 'Abuja',
      state: 'FCT',
    );
    final RiderOnboarding submitted = await repository.submitOnboarding();

    expect(initial.profile?.fullName, 'Amina Yusuf');
    expect(initial.profilePictureComplete, isFalse);
    expect(profile.profilePictureComplete, isTrue);
    expect(bank.bankAccount?.bankName, 'Josi Microfinance');
    expect(riding.ridingDetails?.type, 'Car');
    expect(submitted.isSubmitted, isTrue);
    expect(
      requests.map((Map<String, Object?> request) => request['path']),
      <String>[
        '/api/v1/driver/onboarding',
        '/api/v1/driver/onboarding/profile-picture',
        '/api/v1/driver/onboarding/bank-account',
        '/api/v1/driver/onboarding/riding-details',
        '/api/v1/driver/onboarding/submit',
      ],
    );
    expect(requests.every((Map<String, Object?> request) {
      return request['authorization'] == 'Bearer rider-token';
    }), isTrue);
    expect(
      (requests[1]['body']! as Map<String, Object?>)['profile_photo'],
      'selfie.jpg',
    );
    expect(
      (requests[2]['body']! as Map<String, Object?>)['account_number'],
      '0123456789',
    );
    expect(
      (requests[3]['body']! as Map<String, Object?>)['vehicle_type'],
      'car',
    );
  });
}

String _onboardingBody({
  String? profilePhoto,
  String? bankName,
  String? vehicleType,
  bool submitted = false,
}) {
  final bool profileComplete = profilePhoto != null;
  final bool bankComplete = bankName != null;
  final bool ridingComplete = vehicleType != null;

  return jsonEncode(<String, Object?>{
    'status': true,
    'message': 'OK',
    'data': <String, Object?>{
      'profile': <String, Object?>{
        'first_name': 'Amina',
        'last_name': 'Yusuf',
        'phone': '+2348023456789',
        'city': 'Abuja',
        'state': 'FCT',
        'profile_photo': profilePhoto,
        'application_status': submitted ? 'under_review' : 'pending',
      },
      'bank_account': <String, Object?>{
        'bank_name': bankName,
        'account_name': bankName == null ? null : 'Amina Yusuf',
        'account_number': bankName == null ? null : '0123456789',
      },
      'riding_details': vehicleType == null
          ? null
          : <String, Object?>{
              'vehicle_type': vehicleType,
              'brand': 'Toyota',
              'model': 'Corolla',
              'color': 'White',
              'plate_number': 'ABC 482 JK',
              'registration_number': 'REG-2408-JR',
            },
      'onboarding': <String, Object?>{
        'profile_picture_complete': profileComplete,
        'bank_account_complete': bankComplete,
        'riding_details_complete': ridingComplete,
        'is_complete': profileComplete && bankComplete && ridingComplete,
        'is_submitted': submitted,
        'submitted_at': submitted ? '2026-06-17T00:00:00Z' : null,
        'missing_steps': <String>[
          if (!profileComplete) 'profile_picture',
          if (!bankComplete) 'bank_account_details',
          if (!ridingComplete) 'riding_details',
        ],
      },
    },
  });
}

class _MemoryTokenStorage implements TokenStorage {
  String? _token;
  String? _tokenType;
  String? _userRole;

  @override
  Future<void> clearToken() async {
    _token = null;
    _tokenType = null;
    _userRole = null;
  }

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<String?> readTokenType() async => _tokenType;

  @override
  Future<String?> readUserRole() async => _userRole;

  @override
  Future<void> saveToken(
    String token, {
    String tokenType = 'bearer',
    String? userRole,
  }) async {
    _token = token;
    _tokenType = tokenType;
    _userRole = userRole;
  }
}
