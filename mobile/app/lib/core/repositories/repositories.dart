import '../mock/josi_mock_data.dart';
import '../mock/josi_models.dart';
import '../services/api_client.dart';
import '../auth/token_storage.dart';

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
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return null;
    }

    final String? token = await _tokens.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final Map<String, Object?> envelope =
          await _api.get('/auth/me', token: token);
      final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
      return _userFromPayload(data['user']);
    } on Object {
      await _tokens.clearToken();
      return null;
    }
  }

  Future<JosiUser> signIn(
      {required String identity,
      required String password,
      String role = 'customer'}) async {
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _mockUserForRole(role);
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/login',
      body: <String, Object?>{
        'email_or_phone': identity,
        'password': password,
      },
    );
    return _persistAuthPayload(ApiClient.dataFromEnvelope(envelope));
  }

  Future<JosiUser> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return JosiMockData.customer;
    }

    final List<String> parts = _splitName(fullName);
    final Map<String, Object?> envelope = await _api.post(
      '/auth/register/customer',
      body: <String, Object?>{
        'name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
      },
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return _persistAuthPayload(data, fallbackNameParts: parts);
  }

  Future<JosiUser> registerRider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'rider',
  }) async {
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return _mockUserForRole(role);
    }

    final List<String> parts = _splitName(fullName);
    final Map<String, Object?> envelope = await _api.post(
      '/auth/register',
      body: <String, Object?>{
        'first_name': parts.first,
        'last_name': parts.last,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'role': role,
      },
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return _userFromPayload(data['user']);
  }

  Future<String> requestPasswordReset(String emailOrPhone) async {
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return 'If this account exists, a reset code has been sent.';
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/forgot-password',
      body: <String, Object?>{'email_or_phone': emailOrPhone},
    );
    return ApiClient.messageFromEnvelope(envelope);
  }

  Future<void> verifyResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return;
    }

    await _api.post(
      '/auth/verify-reset-code',
      body: <String, Object?>{
        'email_or_phone': emailOrPhone,
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
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return 'Password reset. You can now log in securely.';
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/reset-password',
      body: <String, Object?>{
        'email_or_phone': emailOrPhone,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return ApiClient.messageFromEnvelope(envelope);
  }

  Future<void> signOut() async {
    if (!_api.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return;
    }

    final String? token = await _tokens.readToken();
    await _tokens.clearToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await _api.post('/auth/logout', token: token);
  }

  Future<JosiUser> _persistAuthPayload(
    Map<String, Object?> data, {
    List<String>? fallbackNameParts,
  }) async {
    final String? token =
        (data['token'] as String?) ?? (data['access_token'] as String?);
    if (token != null && token.isNotEmpty) {
      await _tokens.saveToken(token);
    }

    return _userFromPayload(data['user'], fallbackNameParts: fallbackNameParts);
  }

  JosiUser _userFromPayload(
    Object? value, {
    List<String>? fallbackNameParts,
  }) {
    if (value is! Map<String, Object?>) {
      throw const ApiException('User profile was not returned by the API.');
    }

    final String role = (value['role'] as String?) ?? 'customer';
    return JosiUser(
      id: '${value['id']}',
      name: (value['name'] as String?) ??
          fallbackNameParts?.join(' ') ??
          'Josi user',
      email: (value['email'] as String?) ?? '',
      phone: (value['phone'] as String?) ?? '',
      role: _appRoleFromApi(role),
      applicationStatus: _applicationStatusFromApi(value['status']),
    );
  }

  AppRole _appRoleFromApi(String role) {
    return switch (role) {
      'rider' || 'courier' || 'driver' => AppRole.rider,
      'pack_owner' || 'fleet_owner' => AppRole.fleetOwner,
      _ => AppRole.customer,
    };
  }

  RiderApplicationStatus? _applicationStatusFromApi(Object? value) {
    return switch (value) {
      'pending' => RiderApplicationStatus.pending,
      'under_review' => RiderApplicationStatus.underReview,
      'approved' || 'active' => RiderApplicationStatus.approved,
      'rejected' => RiderApplicationStatus.rejected,
      'suspended' => RiderApplicationStatus.suspended,
      _ => null,
    };
  }

  JosiUser _mockUserForRole(String role) {
    return switch (role) {
      'rider' || 'courier' => JosiMockData.rider,
      _ => JosiMockData.customer,
    };
  }

  List<String> _splitName(String fullName) {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return <String>['Josi', 'User'];
    }
    if (parts.length == 1) {
      return <String>[parts.first, 'User'];
    }
    return <String>[parts.first, parts.skip(1).join(' ')];
  }
}

class CustomerRepository {
  const CustomerRepository();

  Future<JosiUser> profile() async => JosiMockData.customer;

  Future<List<QuickAction>> quickActions() async =>
      JosiMockData.customerActions;
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
