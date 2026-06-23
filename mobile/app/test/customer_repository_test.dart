import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/core/auth/token_storage.dart';
import 'package:josi_ride/core/mock/josi_models.dart';
import 'package:josi_ride/core/repositories/repositories.dart';
import 'package:josi_ride/core/services/api_client.dart';

void main() {
  test('customer profile update uses backend profile endpoint and bearer token',
      () async {
    final List<Map<String, Object?>> requests = <Map<String, Object?>>[];
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    await storage.saveToken('token-123', userRole: 'customer');

    final CustomerRepository repository = CustomerRepository(
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
            'headers': headers,
            'body': jsonDecode(body as String),
          });

          return const ApiHttpResponse(
            statusCode: 200,
            body: '''
{
  "status": true,
  "message": "Profile updated successfully",
  "data": {
    "user": {
      "id": 10,
      "name": "Ada Johnson",
      "email": "ada@example.com",
      "phone": "+2348099990000",
      "role": "customer",
      "gender": "Female"
    }
  }
}
''',
          );
        },
      ),
    );

    final JosiUser user = await repository.updateProfile(
      name: 'Ada Johnson',
      phone: '+2348099990000',
      email: 'ada@example.com',
      gender: 'Female',
    );

    final Map<String, Object?> request = requests.single;
    final Map<String, Object?> body = request['body']! as Map<String, Object?>;
    final Map<String, String> headers =
        request['headers']! as Map<String, String>;
    expect(request['method'], 'PUT');
    expect(request['path'], '/api/v1/customer/profile');
    expect(headers['Authorization'], 'Bearer token-123');
    expect(body['name'], 'Ada Johnson');
    expect(body['phone'], '+2348099990000');
    expect(body['email'], 'ada@example.com');
    expect(body['gender'], 'Female');
    expect(body.containsKey('full_name'), isFalse);
    expect(user.displayName, 'Ada Johnson');
    expect(user.gender, 'Female');
  });

  test('customer saved addresses are created and fetched from backend',
      () async {
    final List<Map<String, Object?>> requests = <Map<String, Object?>>[];
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    await storage.saveToken('token-123', userRole: 'customer');

    final CustomerRepository repository = CustomerRepository(
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
            'body': body == null ? null : jsonDecode(body as String),
          });

          if (method == 'POST') {
            return const ApiHttpResponse(
              statusCode: 201,
              body: '''
{
  "status": true,
  "message": "Address saved successfully",
  "data": {
    "address": {
      "id": 7,
      "label": "Home",
      "address": "12 Jabi Lake Road, Abuja",
      "floor": "2",
      "landmark": "Beside the mall"
    }
  }
}
''',
            );
          }

          return const ApiHttpResponse(
            statusCode: 200,
            body: '''
{
  "status": true,
  "data": {
    "addresses": [
      {
        "id": 7,
        "label": "Home",
        "address": "12 Jabi Lake Road, Abuja",
        "floor": "2",
        "landmark": "Beside the mall"
      }
    ]
  }
}
''',
          );
        },
      ),
    );

    final CustomerSavedAddress created = await repository.createSavedAddress(
      label: 'Home',
      address: '12 Jabi Lake Road, Abuja',
      floor: '2',
      landmark: 'Beside the mall',
    );
    final List<CustomerSavedAddress> addresses =
        await repository.savedAddresses();

    final Map<String, Object?> createBody =
        requests.first['body']! as Map<String, Object?>;
    expect(requests.first['method'], 'POST');
    expect(requests.first['path'], '/api/v1/customer/addresses');
    expect(createBody['label'], 'Home');
    expect(createBody['address'], '12 Jabi Lake Road, Abuja');
    expect(createBody['floor'], '2');
    expect(createBody['landmark'], 'Beside the mall');
    expect(requests.last['method'], 'GET');
    expect(requests.last['path'], '/api/v1/customer/addresses');
    expect(created.id, '7');
    expect(addresses.single.address, '12 Jabi Lake Road, Abuja');
  });

  test('customer trip request posts pickup, destination, and service type',
      () async {
    late Map<String, Object?> request;
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    await storage.saveToken('token-123', userRole: 'customer');

    final CustomerRepository repository = CustomerRepository(
      tokenStorage: storage,
      apiClient: ApiClient(
        baseUrl: 'https://api.josi.test/api/v1',
        httpRequest: (
          Uri uri, {
          required String method,
          required Map<String, String> headers,
          Object? body,
        }) async {
          request = <String, Object?>{
            'method': method,
            'path': uri.path,
            'body': jsonDecode(body as String),
          };

          return const ApiHttpResponse(
            statusCode: 201,
            body: '''
{
  "status": true,
  "message": "Trip requested successfully",
  "data": {
    "trip": {
      "id": 99,
      "pickup_address": "Wuse 2, Abuja",
      "destination_address": "Jabi Lake Mall",
      "amount": 3500,
      "trip_status": "requested",
      "payment_method": "cash",
      "requested_at": "2026-06-18T08:30:00Z"
    }
  }
}
''',
          );
        },
      ),
    );

    final Trip trip = await repository.requestTrip(
      pickupAddress: 'Wuse 2, Abuja',
      pickupLatitude: 9.0765,
      pickupLongitude: 7.3986,
      destinationAddress: 'Jabi Lake Mall',
      destinationLatitude: 9.0643,
      destinationLongitude: 7.4231,
      serviceType: 'courier',
    );

    final Map<String, Object?> body = request['body']! as Map<String, Object?>;
    expect(request['method'], 'POST');
    expect(request['path'], '/api/v1/customer/trips');
    expect(body['pickup_address'], 'Wuse 2, Abuja');
    expect(body['destination_address'], 'Jabi Lake Mall');
    expect(body['pickup_latitude'], 9.0765);
    expect(body['destination_longitude'], 7.4231);
    expect(body['payment_method'], 'cash');
    expect(body['service_type'], 'courier');
    expect(trip.status, TripStatus.searching);
    expect(trip.fare, 'NGN 3500');
    expect(trip.dateLabel, contains('Jun 18, 2026'));
    expect(trip.dateLabel, isNot(contains('T08:30:00Z')));
  });

  test('customer rider matching, assignment, arrival, and review use backend',
      () async {
    final List<Map<String, Object?>> requests = <Map<String, Object?>>[];
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    await storage.saveToken('token-123', userRole: 'customer');

    final CustomerRepository repository = CustomerRepository(
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
            'headers': headers,
            'body': body == null ? null : jsonDecode(body as String),
          });

          if (uri.path.endsWith('/available-riders')) {
            return const ApiHttpResponse(
              statusCode: 200,
              body: '''
{
  "status": true,
  "data": {
    "riders": [
      {
        "id": 44,
        "name": "Ayo Balogun",
        "phone": "+2348000000004",
        "city": "Abuja",
        "state": "FCT",
        "vehicle": {
          "label": "Red Bajaj Boxer",
          "plate_number": "JOS-123AB"
        }
      }
    ]
  }
}
''',
            );
          }

          if (uri.path.endsWith('/request-rider')) {
            return const ApiHttpResponse(
              statusCode: 200,
              body: '''
{
  "status": true,
  "message": "Rider requested and notified successfully",
  "data": {
    "rider_notified": true,
    "trip": {
      "id": 99,
      "pickup_address": "Wuse 2, Abuja",
      "destination_address": "Jabi Lake Mall",
      "amount": 3500,
      "trip_status": "assigned",
      "payment_method": "cash",
      "rider_name": "Ayo Balogun",
      "rider_phone": "+2348000000004",
      "vehicle_label": "Red Bajaj Boxer",
      "plate_number": "JOS-123AB",
      "is_arrived_at_pickup": false
    }
  }
}
''',
            );
          }

          if (uri.path.endsWith('/review')) {
            return const ApiHttpResponse(
              statusCode: 200,
              body: '''
{
  "status": true,
  "message": "Rider review submitted successfully",
  "data": {
    "review": {
      "id": 7,
      "rating": 5,
      "review": "Fast pickup."
    }
  }
}
''',
            );
          }

          if (uri.path.endsWith('/cancel')) {
            return const ApiHttpResponse(
              statusCode: 200,
              body: '''
{
  "status": true,
  "message": "Trip cancelled successfully",
  "data": {
    "trip": {
      "id": 99,
      "pickup_address": "Wuse 2, Abuja",
      "destination_address": "Jabi Lake Mall",
      "amount": 3500,
      "trip_status": "cancelled",
      "payment_method": "cash",
      "rider_name": "Ayo Balogun",
      "rider_phone": "+2348000000004",
      "vehicle_label": "Red Bajaj Boxer",
      "plate_number": "JOS-123AB"
    }
  }
}
''',
            );
          }

          return const ApiHttpResponse(
            statusCode: 200,
            body: '''
{
  "status": true,
  "data": {
    "trip": {
      "id": 99,
      "pickup_address": "Wuse 2, Abuja",
      "destination_address": "Jabi Lake Mall",
      "amount": 3500,
      "trip_status": "ongoing",
      "payment_method": "cash",
      "rider_name": "Ayo Balogun",
      "rider_phone": "+2348000000004",
      "vehicle_label": "Red Bajaj Boxer",
      "plate_number": "JOS-123AB",
      "is_arrived_at_pickup": true,
      "review": {
        "rating": 4,
        "review": "Smooth ride."
      }
    }
  }
}
''',
          );
        },
      ),
    );

    final List<AvailableRider> riders = await repository.availableRiders('99');
    final Trip assigned = await repository.requestRider(
      tripId: '99',
      riderProfileId: '44',
    );
    final Trip arrived = await repository.trip('99');
    final String reviewMessage = await repository.submitRiderReview(
      tripId: '99',
      rating: 5,
      review: 'Fast pickup.',
    );
    final Trip cancelled = await repository.cancelTrip(
      tripId: '99',
      reason: 'Changed my plans',
    );

    expect(requests[0]['method'], 'GET');
    expect(requests[0]['path'], '/api/v1/customer/trips/99/available-riders');
    expect(riders.single.name, 'Ayo Balogun');
    expect(riders.single.vehicleLabel, 'Red Bajaj Boxer');
    expect(riders.single.plateNumber, 'JOS-123AB');

    expect(requests[1]['method'], 'POST');
    expect(requests[1]['path'], '/api/v1/customer/trips/99/request-rider');
    expect((requests[1]['body']! as Map<String, Object?>)['rider_profile_id'],
        '44');
    expect(assigned.riderName, 'Ayo Balogun');
    expect(assigned.riderPhone, '+2348000000004');
    expect(assigned.plateNumber, 'JOS-123AB');
    expect(assigned.isArrivedAtPickup, isFalse);

    expect(requests[2]['method'], 'GET');
    expect(requests[2]['path'], '/api/v1/customer/trips/99');
    expect(arrived.isArrivedAtPickup, isTrue);
    expect(arrived.reviewRating, 4);

    expect(requests[3]['method'], 'POST');
    expect(requests[3]['path'], '/api/v1/customer/trips/99/review');
    expect((requests[3]['body']! as Map<String, Object?>)['rating'], 5);
    expect((requests[3]['body']! as Map<String, Object?>)['review'],
        'Fast pickup.');
    expect(reviewMessage, 'Rider review submitted successfully');

    expect(requests[4]['method'], 'POST');
    expect(requests[4]['path'], '/api/v1/customer/trips/99/cancel');
    expect((requests[4]['body']! as Map<String, Object?>)['reason'],
        'Changed my plans');
    expect(cancelled.status, TripStatus.cancelled);
    expect(cancelled.riderName, 'Ayo Balogun');
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
