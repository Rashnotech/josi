import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/core/auth/token_storage.dart';
import 'package:josi_ride/core/mock/josi_models.dart';
import 'package:josi_ride/core/repositories/repositories.dart';
import 'package:josi_ride/core/services/api_client.dart';

void main() {
  test('customer registration splits full name and never sends full_name',
      () async {
    final List<Map<String, Object?>> requests = <Map<String, Object?>>[];
    final _MemoryTokenStorage storage = _MemoryTokenStorage();
    final AuthRepository repository = AuthRepository(
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

          if (uri.path.endsWith('/auth/register/customer')) {
            return const ApiHttpResponse(
              statusCode: 201,
              body: '''
{
  "status": true,
  "message": "Customer registration successful",
  "data": {
    "token": "token-123",
    "token_type": "bearer",
    "role": "customer",
    "user": {
      "id": 10,
      "name": "Abdulrasheed Aliyu",
      "email": "abdul@example.com",
      "phone": "+2348012345678",
      "role": "customer"
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
  "message": "Authenticated user fetched successfully",
  "data": {
    "user": {
      "id": 10,
      "name": "Abdulrasheed Aliyu",
      "email": "abdul@example.com",
      "phone": "+2348012345678",
      "role": "customer"
    }
  }
}
''',
          );
        },
      ),
    );

    final AuthResult result = await repository.registerCustomer(
      fullName: 'Abdulrasheed Aliyu',
      email: 'abdul@example.com',
      phone: '+2348012345678',
      password: 'Password123!',
      passwordConfirmation: 'Password123!',
    );

    final Map<String, Object?> body =
        requests.first['body']! as Map<String, Object?>;
    expect(requests.first['path'], '/api/v1/auth/register/customer');
    expect(body['name'], 'Abdulrasheed Aliyu');
    expect(body['first_name'], 'Abdulrasheed');
    expect(body['last_name'], 'Aliyu');
    expect(body.containsKey('full_name'), isFalse);
    expect(body['password_confirmation'], 'Password123!');
    expect(await storage.readToken(), 'token-123');
    expect(await storage.readTokenType(), 'bearer');
    expect(await storage.readUserRole(), 'customer');
    expect(result.isAuthenticated, isTrue);
    expect(result.user?.role, AppRole.customer);
  });

  test('single-word customer names omit last_name from register payload',
      () async {
    late Map<String, Object?> capturedBody;
    final AuthRepository repository = AuthRepository(
      tokenStorage: _MemoryTokenStorage(),
      apiClient: ApiClient(
        baseUrl: 'https://api.josi.test/api/v1',
        httpRequest: (
          Uri uri, {
          required String method,
          required Map<String, String> headers,
          Object? body,
        }) async {
          capturedBody = jsonDecode(body as String) as Map<String, Object?>;
          return const ApiHttpResponse(
            statusCode: 201,
            body: '''
{
  "status": true,
  "message": "Customer registration successful",
  "data": {
    "user": {
      "id": 11,
      "name": "Abdulrasheed",
      "email": "abdul@example.com",
      "phone": "+2348012345678",
      "role": "customer"
    }
  }
}
''',
          );
        },
      ),
    );

    await repository.registerCustomer(
      fullName: 'Abdulrasheed',
      email: 'abdul@example.com',
      phone: '+2348012345678',
      password: 'Password123!',
      passwordConfirmation: 'Password123!',
    );

    expect(capturedBody['first_name'], 'Abdulrasheed');
    expect(capturedBody.containsKey('last_name'), isFalse);
    expect(capturedBody.containsKey('full_name'), isFalse);
  });

  test('login and password reset use backend identifier field', () async {
    final List<Map<String, Object?>> bodies = <Map<String, Object?>>[];
    final AuthRepository repository = AuthRepository(
      tokenStorage: _MemoryTokenStorage(),
      apiClient: ApiClient(
        baseUrl: 'https://api.josi.test/api/v1',
        httpRequest: (
          Uri uri, {
          required String method,
          required Map<String, String> headers,
          Object? body,
        }) async {
          if (body != null) {
            bodies.add(jsonDecode(body as String) as Map<String, Object?>);
          }

          if (uri.path.endsWith('/auth/login')) {
            return const ApiHttpResponse(
              statusCode: 200,
              body: '''
{
  "status": true,
  "message": "Login successful",
  "data": {
    "token": "token-123",
    "token_type": "bearer",
    "role": "customer",
    "user": {
      "id": 10,
      "name": "Abdulrasheed Aliyu",
      "email": "abdul@example.com",
      "phone": "+2348012345678",
      "role": "customer"
    }
  }
}
''',
            );
          }

          if (uri.path.endsWith('/auth/me')) {
            return const ApiHttpResponse(
              statusCode: 200,
              body: '''
{
  "status": true,
  "message": "Authenticated user fetched successfully",
  "data": {
    "user": {
      "id": 10,
      "name": "Abdulrasheed Aliyu",
      "email": "abdul@example.com",
      "phone": "+2348012345678",
      "role": "customer"
    }
  }
}
''',
            );
          }

          return const ApiHttpResponse(
            statusCode: 200,
            body: '{"status": true, "message": "OK", "data": {}}',
          );
        },
      ),
    );

    await repository.signIn(
      identity: '+2348012345678',
      password: 'Password123!',
    );
    await repository.requestPasswordReset('+2348012345678');
    await repository.verifyResetCode(
      emailOrPhone: '+2348012345678',
      code: '123456',
    );
    await repository.resetPassword(
      emailOrPhone: '+2348012345678',
      code: '123456',
      password: 'Password123!',
      passwordConfirmation: 'Password123!',
    );

    expect(bodies[0]['identifier'], '+2348012345678');
    expect(bodies[0].containsKey('email_or_phone'), isFalse);
    expect(bodies[1]['identifier'], '+2348012345678');
    expect(bodies[2]['identifier'], '+2348012345678');
    expect(bodies[3]['identifier'], '+2348012345678');
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
