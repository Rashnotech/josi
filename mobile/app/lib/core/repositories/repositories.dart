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

  Future<AuthResult> registerRider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
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
        // Laravel public rider registration expects split names, not full_name.
        'name': parts.fullName,
        'first_name': parts.firstName,
        if (parts.lastName.isNotEmpty) 'last_name': parts.lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
      },
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    return _persistAuthPayload(
      data,
      message: ApiClient.messageFromEnvelope(envelope),
      fallbackNameParts: parts,
      requireToken: true,
    );
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

  Future<String> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!_api.isConfigured) {
      throw const ApiException(
          'Josi API is not configured. Please set JOSI_API_BASE_URL.');
    }

    final String? token = await _tokens.readToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Please sign in again to continue.');
    }

    final Map<String, Object?> envelope = await _api.post(
      '/auth/change-password',
      token: token,
      body: <String, Object?>{
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final String message = ApiClient.messageFromEnvelope(envelope);
    return message.isEmpty ? 'Password updated successfully.' : message;
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
        data,
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
    return userFromPayload(data, fallbackNameParts: fallbackNameParts);
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
    final Map<String, Object?>? payload = _mapFrom(value);
    final Map<String, Object?>? user = _mapFrom(payload?['user']) ?? payload;
    if (user == null) {
      throw const ApiException('User profile was not returned by the API.');
    }

    final Map<String, Object?>? profile =
        _mapFrom(payload?['profile']) ?? _mapFrom(user['profile']);
    final String role =
        _string(payload?['role']) ?? _string(user['role']) ?? 'customer';
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
        profile?['application_status'] ?? user['application_status'],
      ),
      city: _string(user['city']) ?? _string(profile?['city']) ?? 'Abuja',
      gender: _string(user['gender']) ?? _string(profile?['gender']),
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

  Future<JosiUser> updateProfile({
    required String name,
    required String phone,
    required String email,
    String? gender,
  }) async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.put(
      '/customer/profile',
      token: token,
      body: <String, Object?>{
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        if (gender != null && gender.trim().isNotEmpty && gender != 'Select')
          'gender': gender.trim(),
      },
    );
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
    final String token = await _requireToken();
    final Map<String, Object?> envelope =
        await _api.get('/customer/addresses', token: token);
    final Object? addresses = ApiClient.dataFromEnvelope(envelope)['addresses'];
    if (addresses is! List) {
      return const <CustomerSavedAddress>[];
    }

    return addresses
        .whereType<Map>()
        .map((Map<Object?, Object?> value) => _addressFromPayload(value))
        .toList();
  }

  Future<CustomerSavedAddress> createSavedAddress({
    required String label,
    required String address,
    String? floor,
    String? landmark,
    double? latitude,
    double? longitude,
  }) async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.post(
      '/customer/addresses',
      token: token,
      body: <String, Object?>{
        'label': label.trim(),
        'address': address.trim(),
        if (floor?.trim().isNotEmpty ?? false) 'floor': floor!.trim(),
        if (landmark?.trim().isNotEmpty ?? false) 'landmark': landmark!.trim(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    final Map<String, Object?>? addressPayload = _mapFrom(data['address']);
    if (addressPayload == null) {
      throw const ApiException('Saved address was not returned by the API.');
    }

    return _addressFromPayload(addressPayload);
  }

  Future<List<Trip>> trips() async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope =
        await _api.get('/customer/trips', token: token);
    final Object? trips = ApiClient.dataFromEnvelope(envelope)['trips'];
    if (trips is! List) {
      return const <Trip>[];
    }

    return trips
        .whereType<Map>()
        .map((Map<Object?, Object?> value) => _tripFromPayload(value))
        .toList();
  }

  Future<Trip> requestTrip({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required String destinationAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    String paymentMethod = 'cash',
    String serviceType = 'ride',
  }) async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.post(
      '/customer/trips',
      token: token,
      body: <String, Object?>{
        'pickup_address': pickupAddress.trim(),
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'destination_address': destinationAddress.trim(),
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'payment_method': paymentMethod,
        'service_type': serviceType,
      },
    );
    final Map<String, Object?> data = ApiClient.dataFromEnvelope(envelope);
    final Map<String, Object?>? tripPayload = _mapFrom(data['trip']);
    if (tripPayload == null) {
      throw const ApiException('Trip was not returned by the API.');
    }

    return _tripFromPayload(tripPayload);
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

  static CustomerSavedAddress _addressFromPayload(Map<Object?, Object?> value) {
    final Map<String, Object?> payload = value.map(
      (Object? key, Object? fieldValue) =>
          MapEntry<String, Object?>('$key', fieldValue),
    );
    return CustomerSavedAddress(
      id: _string(payload['id']),
      title:
          _string(payload['label']) ?? _string(payload['title']) ?? 'Address',
      address: _string(payload['address']) ?? '',
      floor: _string(payload['floor']),
      landmark: _string(payload['landmark']),
    );
  }

  static Trip _tripFromPayload(Map<Object?, Object?> value) {
    final Map<String, Object?> payload = value.map(
      (Object? key, Object? fieldValue) =>
          MapEntry<String, Object?>('$key', fieldValue),
    );
    final String destination = _string(payload['destination_address']) ??
        _string(payload['destination']) ??
        'Destination';
    return Trip(
      id: _string(payload['id']) ?? '',
      pickup: _string(payload['pickup_address']) ?? 'Pickup',
      destination: destination,
      fare: _fareLabel(payload['amount']),
      status: _tripStatus(payload['trip_status']),
      paymentMethod: _paymentMethod(payload['payment_method']),
      dateLabel: _string(payload['requested_at']) ?? '',
      riderName: _string(payload['rider_name']) ?? '',
      customerName: _string(payload['customer_name']) ?? '',
      distance: _string(payload['distance']) ?? '',
      duration: _string(payload['duration']) ?? '',
    );
  }

  static String _fareLabel(Object? value) {
    final double? amount =
        value is num ? value.toDouble() : double.tryParse(_string(value) ?? '');
    if (amount == null) {
      return 'To be calculated';
    }

    return 'NGN ${amount.toStringAsFixed(0)}';
  }

  static TripStatus _tripStatus(Object? value) {
    return switch (_string(value)) {
      'completed' => TripStatus.completed,
      'cancelled' => TripStatus.cancelled,
      'requested' || 'assigned' => TripStatus.searching,
      _ => TripStatus.active,
    };
  }

  static PaymentMethod _paymentMethod(Object? value) {
    return switch (_string(value)) {
      'wallet' => PaymentMethod.wallet,
      'card' || 'transfer' || 'online' => PaymentMethod.online,
      _ => PaymentMethod.cash,
    };
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

class RiderRepository {
  const RiderRepository({
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
        await _api.get('/auth/me', token: token);
    return AuthRepository.userFromPayload(
      ApiClient.dataFromEnvelope(envelope),
    );
  }

  Future<RiderOnboarding> onboarding() async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope =
        await _api.get('/driver/onboarding', token: token);
    return _onboardingFromPayload(ApiClient.dataFromEnvelope(envelope));
  }

  Future<RiderProfile> riderProfile() async {
    final RiderProfile? profile = (await onboarding()).profile;
    if (profile == null) {
      throw const ApiException('Rider profile was not returned by the API.');
    }
    return profile;
  }

  Future<Vehicle> vehicle() async {
    final Vehicle? vehicle = (await onboarding()).ridingDetails;
    if (vehicle == null) {
      throw const ApiException('Riding details have not been completed yet.');
    }
    return vehicle;
  }

  Future<RiderOnboarding> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String city,
    String? state,
    String? address,
    String? profilePhoto,
  }) async {
    final String token = await _requireToken();
    final CustomerNameParts parts = AuthRepository.splitFullName(fullName);
    await _api.put(
      '/driver/profile',
      token: token,
      body: <String, Object?>{
        'first_name': parts.firstName,
        'last_name': parts.lastName,
        if (phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (gender.trim().isNotEmpty && gender != 'Select') 'gender': gender,
        if (city.trim().isNotEmpty) 'city': city.trim(),
        if (state?.trim().isNotEmpty ?? false) 'state': state!.trim(),
        if (address?.trim().isNotEmpty ?? false) 'address': address!.trim(),
        if (profilePhoto?.trim().isNotEmpty ?? false)
          'profile_photo': profilePhoto!.trim(),
      },
    );
    return onboarding();
  }

  Future<List<DocumentRequirement>> documents() async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope =
        await _api.get('/driver/documents', token: token);
    final Object? documents = ApiClient.dataFromEnvelope(envelope)['documents'];
    if (documents is! List) {
      return const <DocumentRequirement>[];
    }

    return documents
        .whereType<Map>()
        .map((Map<Object?, Object?> value) => _documentFromPayload(value))
        .toList();
  }

  Future<RiderOnboarding> saveProfilePicture({
    required String profilePhoto,
  }) async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.post(
      '/driver/onboarding/profile-picture',
      token: token,
      body: <String, Object?>{
        // Backend stores a profile photo path or URL for now.
        'profile_photo': profilePhoto,
      },
    );
    return _onboardingFromPayload(ApiClient.dataFromEnvelope(envelope));
  }

  Future<RiderOnboarding> saveBankAccount({
    required String accountNumber,
    required String bankName,
    required String accountName,
  }) async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.post(
      '/driver/onboarding/bank-account',
      token: token,
      body: <String, Object?>{
        'account_number': accountNumber,
        'bank_name': bankName,
        'account_name': accountName,
      },
    );
    return _onboardingFromPayload(ApiClient.dataFromEnvelope(envelope));
  }

  Future<RiderOnboarding> saveRidingDetails({
    required String vehicleType,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required String registrationNumber,
    required String city,
    String? state,
    String? licenseNumber,
  }) async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.post(
      '/driver/onboarding/riding-details',
      token: token,
      body: <String, Object?>{
        'vehicle_type': vehicleType,
        'brand': brand,
        'model': model,
        'color': color,
        'plate_number': plateNumber,
        if (registrationNumber.trim().isNotEmpty)
          'registration_number': registrationNumber,
        if (city.trim().isNotEmpty) 'city': city,
        if (state?.trim().isNotEmpty ?? false) 'state': state,
        if (licenseNumber?.trim().isNotEmpty ?? false)
          'license_number': licenseNumber,
      },
    );
    return _onboardingFromPayload(ApiClient.dataFromEnvelope(envelope));
  }

  Future<RiderOnboarding> submitOnboarding() async {
    final String token = await _requireToken();
    final Map<String, Object?> envelope = await _api.post(
      '/driver/onboarding/submit',
      token: token,
    );
    return _onboardingFromPayload(ApiClient.dataFromEnvelope(envelope));
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

  static RiderOnboarding _onboardingFromPayload(Map<String, Object?> data) {
    final Map<String, Object?>? profile = _mapFrom(data['profile']);
    final Map<String, Object?>? bank = _mapFrom(data['bank_account']);
    final Map<String, Object?>? ridingDetails =
        _mapFrom(data['riding_details']);
    final Map<String, Object?> onboarding =
        _mapFrom(data['onboarding']) ?? const <String, Object?>{};

    return RiderOnboarding(
      profile: profile == null ? null : _riderProfileFromPayload(profile, bank),
      bankAccount: _bankFromPayload(bank),
      ridingDetails:
          ridingDetails == null ? null : _vehicleFromPayload(ridingDetails),
      profilePictureComplete:
          _bool(onboarding['profile_picture_complete']) ?? false,
      bankAccountComplete: _bool(onboarding['bank_account_complete']) ?? false,
      ridingDetailsComplete:
          _bool(onboarding['riding_details_complete']) ?? false,
      isSubmitted: _bool(onboarding['is_submitted']) ?? false,
      submittedAt: _string(onboarding['submitted_at']),
      missingSteps: _stringList(onboarding['missing_steps']),
    );
  }

  static RiderProfile _riderProfileFromPayload(
    Map<String, Object?> profile,
    Map<String, Object?>? bank,
  ) {
    final String firstName = _string(profile['first_name']) ?? '';
    final String lastName = _string(profile['last_name']) ?? '';
    final String fullName = <String>[firstName, lastName]
        .where((String value) => value.trim().isNotEmpty)
        .join(' ');

    return RiderProfile(
      fullName: fullName.isEmpty ? 'Rider' : fullName,
      phone: _string(profile['phone']) ?? '',
      gender: _string(profile['gender']) ?? '',
      dateOfBirth: _string(profile['date_of_birth']) ?? '',
      address: _string(profile['address']) ?? '',
      city: _string(profile['city']) ?? '',
      state: _string(profile['state']) ?? '',
      rating: _double(profile['rating']) ?? 0,
      completedTrips: _int(profile['completed_trips']) ?? 0,
      profilePhoto: _string(profile['profile_photo']),
      licenseNumber: _string(profile['license_number']),
      applicationStatus: AuthRepository._applicationStatusFromApi(
          profile['application_status']),
      bankName: _string(bank?['bank_name']) ?? _string(profile['bank_name']),
      bankAccountName: _string(bank?['account_name']) ??
          _string(profile['bank_account_name']),
      bankAccountNumber: _string(bank?['account_number']) ??
          _string(profile['bank_account_number']),
    );
  }

  static RiderBankAccount? _bankFromPayload(Map<String, Object?>? bank) {
    if (bank == null) {
      return null;
    }

    final String bankName = _string(bank['bank_name']) ?? '';
    final String accountName = _string(bank['account_name']) ?? '';
    final String accountNumber = _string(bank['account_number']) ?? '';
    if (bankName.isEmpty && accountName.isEmpty && accountNumber.isEmpty) {
      return null;
    }

    return RiderBankAccount(
      bankName: bankName,
      accountName: accountName,
      accountNumber: accountNumber,
    );
  }

  static Vehicle _vehicleFromPayload(Map<String, Object?> vehicle) {
    return Vehicle(
      type: _titleCase(_string(vehicle['vehicle_type']) ?? ''),
      brand: _string(vehicle['brand']) ?? '',
      model: _string(vehicle['model']) ?? '',
      color: _string(vehicle['color']) ?? '',
      plateNumber: _string(vehicle['plate_number']) ?? '',
      registrationNumber: _string(vehicle['registration_number']) ?? '',
      chassisNumber: _string(vehicle['chassis_number']) ?? '',
      engineNumber: _string(vehicle['engine_number']) ?? '',
    );
  }

  static DocumentRequirement _documentFromPayload(
    Map<Object?, Object?> document,
  ) {
    final Map<String, Object?> payload = document.map(
      (Object? key, Object? value) => MapEntry<String, Object?>('$key', value),
    );
    final String type = _string(payload['document_type']) ??
        _string(payload['title']) ??
        'Document';
    return DocumentRequirement(
      title: _titleCase(type),
      description: _string(payload['original_file_name']) ??
          _string(payload['description']) ??
          '',
      status: _documentStatus(
        payload['status'] ?? payload['verification_status'],
      ),
      rejectionReason: _string(payload['rejection_reason']),
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

  static bool? _bool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final String? stringValue = _string(value)?.toLowerCase();
    return switch (stringValue) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => null,
    };
  }

  static double? _double(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(_string(value) ?? '');
  }

  static int? _int(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_string(value) ?? '');
  }

  static String? _string(Object? value) {
    if (value == null) {
      return null;
    }

    final String stringValue = '$value'.trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }

    return value
        .map(_string)
        .whereType<String>()
        .where((String step) => step.isNotEmpty)
        .toList();
  }

  static DocumentStatus _documentStatus(Object? value) {
    return switch (_string(value)) {
      'pending' || 'under_review' => DocumentStatus.pending,
      'verified' || 'approved' => DocumentStatus.verified,
      'rejected' => DocumentStatus.rejected,
      _ => DocumentStatus.notUploaded,
    };
  }

  static String _titleCase(String value) {
    final List<String> parts = value
        .replaceAll('_', ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return value;
    }

    return parts
        .map((String part) =>
            part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }
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
