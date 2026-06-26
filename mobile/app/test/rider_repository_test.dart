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
    await repository.updateProfile(
      fullName: 'Amina Yusuf',
      phone: '+2348023000000',
      gender: 'Female',
      city: 'Abuja',
      state: 'FCT',
      address: '22 Adetokunbo Ademola Crescent',
      profilePhoto: 'profile.jpg',
    );
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
        '/api/v1/driver/profile',
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
      (requests[3]['body']! as Map<String, Object?>)['profile_photo'],
      'selfie.jpg',
    );
    expect(
      (requests[1]['body']! as Map<String, Object?>)['first_name'],
      'Amina',
    );
    expect(
      (requests[1]['body']! as Map<String, Object?>)['phone'],
      '+2348023000000',
    );
    expect(
      (requests[4]['body']! as Map<String, Object?>)['account_number'],
      '0123456789',
    );
    expect(
      (requests[5]['body']! as Map<String, Object?>)['vehicle_type'],
      'car',
    );
  });

  test('rider trip repository reads history and declines assigned trips',
      () async {
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
            body: uri.path.endsWith('/decline')
                ? _tripEnvelope(status: 'requested')
                : _tripsEnvelope(),
          );
        },
      ),
    );

    final List<Trip> trips = await repository.availableTrips();
    final Trip declined = await repository.declineTrip('TRP-2408');

    expect(trips, hasLength(3));
    expect(trips.first.customerName, 'Esther Howard');
    expect(trips.first.status, TripStatus.searching);
    expect(trips.first.amount, 3500);
    expect(trips.first.requestedAt, DateTime.parse('2026-06-26T09:00:00Z'));
    expect(trips[1].status, TripStatus.completed);
    expect(trips[1].completedAt, DateTime.parse('2026-06-26T10:30:00Z'));
    expect(trips[2].status, TripStatus.cancelled);
    expect(declined.status, TripStatus.searching);
    expect(
      requests.map((Map<String, Object?> request) => request['path']),
      <String>[
        '/api/v1/driver/trips',
        '/api/v1/driver/trips/TRP-2408/decline',
      ],
    );
    expect(requests.every((Map<String, Object?> request) {
      return request['authorization'] == 'Bearer rider-token';
    }), isTrue);
  });

  test('rider wallet repository reads backend driver wallet data', () async {
    final List<Map<String, Object?>> requests = <Map<String, Object?>>[];
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    await storage.saveToken('rider-token', userRole: 'rider');

    final WalletRepository repository = WalletRepository(
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
          });

          return ApiHttpResponse(
            statusCode: 200,
            body: _walletEnvelope(),
          );
        },
      ),
    );

    final WalletSummary summary = await repository.summary(AppRole.rider);
    final List<WalletTransaction> transactions =
        await repository.transactions(AppRole.rider);

    expect(summary.availableBalance, 'NGN 7,700');
    expect(summary.totalEarnings, 'NGN 11,000');
    expect(summary.pendingRemittance, 'NGN 900');
    expect(summary.todayEarnings, 'NGN 4,200');
    expect(transactions, hasLength(2));
    expect(transactions.first.title, 'Trip earning');
    expect(transactions.first.subtitle, 'CRN : #TRP-2409');
    expect(transactions.first.amount, 'NGN 4,200');
    expect(transactions.first.isCredit, isTrue);
    expect(
      requests.map((Map<String, Object?> request) => request['path']),
      <String>[
        '/api/v1/driver/wallet',
        '/api/v1/driver/wallet',
      ],
    );
    expect(requests.every((Map<String, Object?> request) {
      return request['authorization'] == 'Bearer rider-token';
    }), isTrue);
  });
}

String _tripsEnvelope() {
  return jsonEncode(<String, Object?>{
    'status': true,
    'message': 'OK',
    'data': <String, Object?>{
      'trips': <Object?>[
        _tripPayload(id: 'TRP-2408', status: 'assigned'),
        _tripPayload(
          id: 'TRP-2409',
          customerName: 'Musa Danjuma',
          status: 'completed',
          amount: 4200,
          completedAt: '2026-06-26T10:30:00Z',
        ),
        _tripPayload(
          id: 'TRP-2410',
          customerName: 'Ada Okoro',
          status: 'cancelled',
          amount: 2100,
          cancelledAt: '2026-06-25T15:20:00Z',
        ),
      ],
    },
  });
}

String _tripEnvelope({required String status}) {
  return jsonEncode(<String, Object?>{
    'status': true,
    'message': 'OK',
    'data': <String, Object?>{
      'trip': _tripPayload(status: status),
    },
  });
}

String _walletEnvelope() {
  return jsonEncode(<String, Object?>{
    'status': true,
    'message': 'Driver wallet fetched successfully',
    'data': <String, Object?>{
      'summary': <String, Object?>{
        'balance': 7700,
        'available_balance': 7700,
        'total_earnings': 11000,
        'pending_remittance': 900,
        'today_earnings': 4200,
      },
      'transactions': <Object?>[
        <String, Object?>{
          'title': 'Trip earning',
          'subtitle': 'CRN : #TRP-2409',
          'amount': 4200,
          'is_credit': true,
          'status': 'Completed',
        },
        <String, Object?>{
          'title': 'Trip earning',
          'subtitle': 'CRN : #TRP-2411',
          'amount': 6800,
          'is_credit': true,
          'status': 'Completed',
        },
      ],
    },
  });
}

Map<String, Object?> _tripPayload({
  String id = 'TRP-2408',
  String customerName = 'Esther Howard',
  String status = 'assigned',
  int amount = 3500,
  String? completedAt,
  String? cancelledAt,
}) {
  return <String, Object?>{
    'id': id,
    'pickup_address': 'Wuse Market',
    'destination_address': 'Jabi Lake Mall',
    'amount': amount,
    'payment_method': 'cash',
    'trip_status': status,
    'customer_name': customerName,
    'distance': '7.6 km',
    'duration': '18 mins',
    'requested_at': '2026-06-26T09:00:00Z',
    'completed_at': completedAt,
    'cancelled_at': cancelledAt,
    'vehicle_label': 'Red Bajaj Boxer',
    'plate_number': 'JOS-123AB',
  };
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
