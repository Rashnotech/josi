import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../auth/token_storage.dart';
import '../mock/josi_models.dart';
import '../repositories/repositories.dart';
import '../services/api_client.dart';
import '../services/phone_call_service.dart';
import '../services/profile_photo_picker.dart';

class AuthSession {
  const AuthSession({
    required this.isLoading,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.fieldErrors = const <String, String>{},
  });

  const AuthSession.unknown() : this(isLoading: true);

  const AuthSession.guest() : this(isLoading: false);

  final bool isLoading;
  final JosiUser? user;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, String> fieldErrors;

  bool get isAuthenticated => user != null;

  AuthSession copyWith({
    bool? isLoading,
    JosiUser? user,
    String? errorMessage,
    String? successMessage,
    Map<String, String>? fieldErrors,
    bool clearUser = false,
  }) {
    return AuthSession(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      fieldErrors: fieldErrors ?? const <String, String>{},
    );
  }
}

class AuthController extends StateNotifier<AuthSession> {
  AuthController(this._repository) : super(const AuthSession.unknown()) {
    restore();
  }

  final AuthRepository _repository;

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final JosiUser? restoredUser = await _repository.restoreSession();
      state = restoredUser == null
          ? const AuthSession.guest()
          : AuthSession(isLoading: false, user: restoredUser);
    } on Object {
      state = const AuthSession.guest();
    }
  }

  Future<void> signIn(
      {required String identity,
      required String password,
      String role = 'customer'}) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearUser: true);
    try {
      final AuthResult result = await _repository.signIn(
        identity: identity,
        password: password,
        role: role,
      );
      final JosiUser? user = result.user;
      state = user == null || !result.isAuthenticated
          ? const AuthSession(
              isLoading: false,
              errorMessage: 'Unable to verify your session. Please try again.',
            )
          : AuthSession(
              isLoading: false,
              user: user,
              successMessage: result.message,
            );
    } on Object catch (error) {
      state = AuthSession(
        isLoading: false,
        errorMessage:
            _friendlyError(error, 'Invalid email, phone, or password.'),
        fieldErrors: _fieldErrors(error),
      );
    }
  }

  Future<void> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearUser: true);
    try {
      final AuthResult result = await _repository.registerCustomer(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AuthSession(
        isLoading: false,
        user: result.isAuthenticated ? result.user : null,
        successMessage: result.message,
      );
    } on Object catch (error) {
      state = AuthSession(
        isLoading: false,
        errorMessage: _friendlyError(error, 'Unable to create account.'),
        fieldErrors: _fieldErrors(error),
      );
    }
  }

  Future<void> registerRider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String role = 'rider',
  }) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearUser: true);
    try {
      final AuthResult result = await _repository.registerRider(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      state = AuthSession(
        isLoading: false,
        user: result.isAuthenticated ? result.user : null,
        successMessage: result.message,
      );
    } on Object catch (error) {
      state = AuthSession(
        isLoading: false,
        errorMessage: _friendlyError(error, 'Unable to create account.'),
        fieldErrors: _fieldErrors(error),
      );
    }
  }

  Future<void> verifyEmail(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyEmail(code: code);
      final JosiUser? currentUser = state.user;
      state = AuthSession(
        isLoading: false,
        user: currentUser?.copyWith(emailVerified: true),
        successMessage: 'Email verified successfully.',
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error, 'Invalid or expired code.'),
        fieldErrors: _fieldErrors(error),
      );
    }
  }

  Future<void> resendEmailVerification() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final String message = await _repository.resendEmailVerification();
      state = state.copyWith(isLoading: false, successMessage: message);
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error, 'Unable to send verification code.'),
      );
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthSession.guest();
  }

  String _friendlyError(Object error, String fallback) {
    if (error is ApiException) {
      final Object? first =
          error.errors.values.isEmpty ? null : error.errors.values.first;
      if (first is List<Object?> && first.isNotEmpty) {
        return '${first.first}';
      }
      return error.message;
    }

    return fallback;
  }

  Map<String, String> _fieldErrors(Object error) {
    if (error is! ApiException || error.errors.isEmpty) {
      return const <String, String>{};
    }

    return error.errors.map((String key, Object? value) {
      if (value is List && value.isNotEmpty) {
        return MapEntry<String, String>(key, '${value.first}');
      }

      return MapEntry<String, String>(key, '$value');
    });
  }
}

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  return ApiClient();
});

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((Ref ref) {
  return const SecureTokenStorage();
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<CustomerRepository> customerRepositoryProvider =
    Provider<CustomerRepository>((Ref ref) {
  return CustomerRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<RiderRepository> riderRepositoryProvider =
    Provider<RiderRepository>((Ref ref) {
  return RiderRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<PhoneCallService> phoneCallServiceProvider =
    Provider<PhoneCallService>((Ref ref) {
  return const PhoneCallService();
});

final Provider<ProfilePhotoPicker> profilePhotoPickerProvider =
    Provider<ProfilePhotoPicker>((Ref ref) {
  return DeviceProfilePhotoPicker();
});

final Provider<TripRepository> tripRepositoryProvider =
    Provider<TripRepository>((Ref ref) {
  return const TripRepository();
});

final Provider<WalletRepository> walletRepositoryProvider =
    Provider<WalletRepository>((Ref ref) {
  return WalletRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>((Ref ref) {
  return const NotificationRepository();
});

final StateNotifierProvider<AuthController, AuthSession>
    authControllerProvider =
    StateNotifierProvider<AuthController, AuthSession>((Ref ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

final FutureProvider<JosiUser> currentCustomerProvider =
    FutureProvider<JosiUser>((Ref ref) {
  return ref.watch(customerRepositoryProvider).profile();
});

final FutureProvider<List<String>> customerRecentLocationsProvider =
    FutureProvider<List<String>>((Ref ref) {
  return ref.watch(customerRepositoryProvider).recentLocations();
});

final FutureProvider<List<CustomerSavedAddress>>
    customerSavedAddressesProvider =
    FutureProvider<List<CustomerSavedAddress>>((Ref ref) {
  return ref.watch(customerRepositoryProvider).savedAddresses();
});

final FutureProvider<List<Trip>> customerTripsProvider =
    FutureProvider<List<Trip>>((Ref ref) {
  return ref.watch(customerRepositoryProvider).trips();
});

final StateProvider<Trip?> activeCustomerTripProvider =
    StateProvider<Trip?>((Ref ref) => null);

final customerTripProvider =
    FutureProvider.family<Trip, String>((Ref ref, String id) {
  return ref.watch(customerRepositoryProvider).trip(id);
});

final FutureProvider<JosiUser> currentRiderProvider =
    FutureProvider<JosiUser>((Ref ref) {
  return ref.watch(riderRepositoryProvider).profile();
});

final FutureProvider<RiderProfile> riderProfileProvider =
    FutureProvider<RiderProfile>((Ref ref) {
  return ref.watch(riderRepositoryProvider).riderProfile();
});

final FutureProvider<RiderOnboarding> riderOnboardingProvider =
    FutureProvider<RiderOnboarding>((Ref ref) {
  return ref.watch(riderRepositoryProvider).onboarding();
});

final FutureProvider<List<DocumentRequirement>> riderDocumentsProvider =
    FutureProvider<List<DocumentRequirement>>((Ref ref) {
  return ref.watch(riderRepositoryProvider).documents();
});

final FutureProvider<List<Trip>> tripsProvider =
    FutureProvider<List<Trip>>((Ref ref) {
  return ref.watch(riderRepositoryProvider).availableTrips();
});

final riderTripProvider =
    FutureProvider.family<Trip, String>((Ref ref, String id) {
  return ref.watch(riderRepositoryProvider).trip(id);
});

final FutureProvider<WalletSummary> customerWalletProvider =
    FutureProvider<WalletSummary>((Ref ref) {
  return ref.watch(walletRepositoryProvider).summary(AppRole.customer);
});

final FutureProvider<WalletSummary> riderWalletProvider =
    FutureProvider<WalletSummary>((Ref ref) {
  return ref.watch(walletRepositoryProvider).summary(AppRole.rider);
});

final FutureProvider<List<WalletTransaction>> walletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((Ref ref) {
  return ref.watch(walletRepositoryProvider).transactions(AppRole.customer);
});

final FutureProvider<List<WalletTransaction>> riderWalletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((Ref ref) {
  return ref.watch(walletRepositoryProvider).transactions(AppRole.rider);
});

final FutureProvider<List<CashLedgerEntry>> cashLedgerProvider =
    FutureProvider<List<CashLedgerEntry>>((Ref ref) {
  return ref.watch(walletRepositoryProvider).cashLedger();
});

final FutureProvider<List<JosiNotification>> notificationsProvider =
    FutureProvider<List<JosiNotification>>((Ref ref) {
  return ref.watch(notificationRepositoryProvider).notifications();
});
