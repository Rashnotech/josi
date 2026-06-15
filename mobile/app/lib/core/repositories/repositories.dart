import '../mock/josi_mock_data.dart';
import '../mock/josi_models.dart';
import '../services/api_client.dart';
import '../auth/token_storage.dart';

class AuthResult {
  const AuthResult._({
    required this.isAuthenticated,
    required this.message,
    this.user,
  });

  const AuthResult.authenticated(
    JosiUser user, {
    String message = '',
  }) : this._(isAuthenticated: true, user: user, message: message);

  const AuthResult.unauthenticated({
    required String message,
    JosiUser? user,
  }) : this._(isAuthenticated: false, user: user, message: message);

  final bool isAuthenticated;
  final JosiUser? user;
  final String message;
}

class CustomerNameParts {
  const CustomerNameParts({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  String get fullName {
    return <String>[firstName, lastName]
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .join(' ');
  }
}

class AuthRepository {
  const AuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient? _apiClient;
  final TokenStorage? _tokenStorage;

  ApiClient get _api => _apiClient ?? ApiClient();

  TokenStorage get _tokens => _tokenStorage ?? const SecureTokenStorage();

  Future<JosiUser?> restoreSession() async {
    final String? token = await _tokens.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    if (!_api.isConfigured) {
      await _tokens.clearToken();
      return null;
    }

    try {
      return _fetchAuthenticatedUser(token);
    } on Object {
      await _tokens.clearToken();
      return null;
    }
  }

  Future<AuthResult> signIn({
    required String identity,
    required String password,
    String role = 'customer',
  }) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/login',
      body: <String, Object?>{
        'identifier': identity,
        'password': password,
      },
    );
    return _persistAuthPayload(
      ApiClient.dataFromEnvelope(envelope),
      message: ApiClient.messageFromEnvelope(envelope),
      requireToken: true,
    );
  }

  Future<AuthResult> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final CustomerNameParts parts = splitFullName(fullName);
    final Map<String, Object?> body = <String, Object?>{
      // Existing Laravel RegisterCustomerRequest requires `name`.
      'name': parts.fullName,
      'first_name': parts.firstName,
      if (parts.lastName.isNotEmpty) 'last_name': parts.lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    final Map<String, Object?> envelope = await _api.post(
      '/auth/register/customer',
      body: body,
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return _persistAuthPayload(
      data,
      message: ApiClient.messageFromEnvelope(envelope),
      fallbackNameParts: parts,
      requireToken: false,
    );
  }

  Future<JosiUser> registerRider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'rider',
  }) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final CustomerNameParts parts = splitFullName(fullName);
    final Map<String, Object?> envelope = await _api.post(
      '/auth/register',
      body: <String, Object?>{
        'first_name': parts.firstName,
        'last_name': parts.lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'role': role,
      },
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return userFromPayload(data['user']);
  }

  Future<String> requestPasswordReset(String emailOrPhone) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/forgot-password',
      body: <String, Object?>{'identifier': emailOrPhone},
    );
    return ApiClient.messageFromEnvelope(envelope).isEmpty
        ? 'If this account exists, a reset code has been sent.'
        : ApiClient.messageFromEnvelope(envelope);
  }

  Future<void> verifyResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    await _api.post(
      '/auth/verify-reset-code',
      body: <String, Object?>{
        'identifier': emailOrPhone,
        'code': code,
      },
    );
  }

  Future<String> resetPassword({
    required String emailOrPhone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/reset-password',
      body: <String, Object?>{
        'identifier': emailOrPhone,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final String message = ApiClient.messageFromEnvelope(envelope);
    return message.isEmpty
        ? 'Password reset. You can now log in securely.'
        : message;
  }

  Future<void> signOut() async {
    final String? token = await _tokens.readToken();
    await _tokens.clearToken();
    if (token == null || token.isEmpty) {
      return;
    }

    if (!_api.isConfigured) {
      return;
    }

    await _api.post('/auth/logout', token: token);
  }

  Future<AuthResult> _persistAuthPayload(
    Map<String, Object?> data, {
    required String message,
    CustomerNameParts? fallbackNameParts,
    bool requireToken = true,
  }) async {
    final String? token =
        (data['token'] as String?) ?? (data['access_token'] as String?);
    final String tokenType = (data['token_type'] as String?) ?? 'bearer';
    final String? role = data['role'] as String?;
    if (token != null && token.isNotEmpty) {
      await _tokens.saveToken(token, tokenType: tokenType, userRole: role);
      try {
        return AuthResult.authenticated(
          await _fetchAuthenticatedUser(token, fallbackNameParts),
          message: message,
        );
      } on Object {
        await _tokens.clearToken();
        rethrow;
      }
    }

    if (requireToken) {
      throw const ApiException('Authentication token was not returned.');
    }

    return AuthResult.unauthenticated(
      message: message.isEmpty
          ? 'Account created successfully. Please sign in.'
          : message,
      user: _tryUserFromPayload(
        data['user'],
        fallbackNameParts: fallbackNameParts,
      ),
    );
  }

  Future<JosiUser> _fetchAuthenticatedUser(
    String token, [
    CustomerNameParts? fallbackNameParts,
  ]) async {
    final Map<String, Object?> envelope =
        await _api.get('/auth/me', token: token);
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return userFromPayload(data['user'], fallbackNameParts: fallbackNameParts);
  }

  JosiUser? _tryUserFromPayload(
    Object? value, {
    CustomerNameParts? fallbackNameParts,
  }) {
    try {
      return userFromPayload(value, fallbackNameParts: fallbackNameParts);
    } on ApiException {
      return null;
    }
  }

  static JosiUser userFromPayload(
    Object? value, {
    CustomerNameParts? fallbackNameParts,
  }) {
    final Map<String, Object?>? user = _mapFrom(value);
    if (user == null) {
      throw const ApiException('User profile was not returned by the API.');
    }

    final Map<String, Object?>? profile = _mapFrom(user['profile']);
    final String role = _string(user['role']) ?? 'customer';
    final String? firstName = _string(user['first_name']) ??
        _string(profile?['first_name']) ??
        fallbackNameParts?.firstName;
    final String? lastName = _string(user['last_name']) ??
        _string(profile?['last_name']) ??
        fallbackNameParts?.lastName;
    final String name = _string(user['name']) ??
        <String?>[firstName, lastName]
            .whereType<String>()
            .where((String value) => value.trim().isNotEmpty)
            .join(' ');
    return JosiUser(
      id: '${user['id'] ?? ''}',
      name: name,
      firstName: firstName,
      lastName: lastName,
      email: _string(user['email']) ?? '',
      phone: _string(user['phone']) ?? '',
      role: _appRoleFromApi(role),
      applicationStatus: _applicationStatusFromApi(
        user['application_status'] ?? user['status'],
      ),
      city: _string(user['city']) ?? _string(profile?['city']) ?? 'Abuja',
    );
  }

  static AppRole _appRoleFromApi(String role) {
    return switch (role) {
      'rider' || 'courier' || 'driver' => AppRole.rider,
      'pack_owner' || 'fleet_owner' => AppRole.fleetOwner,
      _ => AppRole.customer,
    };
  }

  static RiderApplicationStatus? _applicationStatusFromApi(Object? value) {
    return switch (value) {
      'pending' => RiderApplicationStatus.pending,
      'under_review' => RiderApplicationStatus.underReview,
      'approved' || 'active' => RiderApplicationStatus.approved,
      'rejected' => RiderApplicationStatus.rejected,
      'suspended' => RiderApplicationStatus.suspended,
      _ => null,
    };
  }

  static CustomerNameParts splitFullName(String fullName) {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return const CustomerNameParts(firstName: '', lastName: '');
    }

    return CustomerNameParts(
      firstName: parts.first,
      lastName: parts.length == 1 ? '' : parts.skip(1).join(' '),
    );
  }

  static Map<String, Object?>? _mapFrom(Object? value) {
    if (value is Map) {
      return value.map(
        (Object? key, Object? fieldValue) =>
            MapEntry<String, Object?>('$key', fieldValue),
      );
    }

    return null;
  }

  static String? _string(Object? value) {
    if (value == null) {
      return null;
    }

    final String stringValue = '$value'.trim();
    return stringValue.isEmpty ? null : stringValue;
  }
}

class CustomerRepository {
  const CustomerRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient? _apiClient;
  final TokenStorage? _tokenStorage;

  ApiClient get _api => _apiClient ?? ApiClient();

  TokenStorage get _tokens => _tokenStorage ?? const SecureTokenStorage();

  Future<JosiUser> profile() async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope =
        await _api.get('/customer/profile', token: token);
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return AuthRepository.userFromPayload(data['user']);
  }

  Future<List<QuickAction>> quickActions() async =>
      JosiMockData.customerActions;

  Future<List<String>> recentLocations() async {
    await _requireToken();
    // No backend endpoint exists yet for customer recent locations.
    return const <String>[];
  }

  Future<List<CustomerSavedAddress>> savedAddresses() async {
    await _requireToken();
    // No backend endpoint exists yet for customer saved addresses.
    return const <CustomerSavedAddress>[];
  }

  Future<List<Trip>> trips() async {
    await _requireToken();
    // No customer trip listing endpoint is exposed in routes/api.php yet.
    return const <Trip>[];
  }

  Future<String> _requireToken() async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final String? token = await _tokens.readToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Please sign in again to continue.');
    }

    return token;
  }
}

class RiderRepository {
  const RiderRepository();

  Future<JosiUser> profile() async => JosiMockData.rider;

  Future<RiderProfile> riderProfile() async => JosiMockData.riderProfile;

  Future<Vehicle> vehicle() async => JosiMockData.vehicle;

  Future<List<DocumentRequirement>> documents() async => JosiMockData.documents;
}

class TripRepository {
  const TripRepository();

  Future<List<Trip>> trips() async => JosiMockData.trips;

  Future<Trip> trip(String id) async {
    return JosiMockData.trips.firstWhere(
      (Trip trip) => trip.id == id,
      orElse: () => JosiMockData.trips.first,
    );
  }
}

class WalletRepository {
  const WalletRepository();

  Future<WalletSummary> summary(AppRole role) async {
    if (role == AppRole.rider) {
      return JosiMockData.riderWallet;
    }
    return JosiMockData.customerWallet;
  }

  Future<List<WalletTransaction>> transactions() async =>
      JosiMockData.transactions;

  Future<List<CashLedgerEntry>> cashLedger() async => JosiMockData.cashLedger;
}

class NotificationRepository {
  const NotificationRepository();

  Future<List<JosiNotification>> notifications() async =>
      JosiMockData.notifications;
}
