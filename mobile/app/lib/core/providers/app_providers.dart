import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';
import '../mock/josi_models.dart';
import '../repositories/repositories.dart';
import '../services/api_client.dart';

class AuthSession {
  const AuthSession({
    required this.isLoading,
    this.user,
    this.errorMessage,
  });

  const AuthSession.unknown() : this(isLoading: true);

  const AuthSession.guest() : this(isLoading: false);

  final bool isLoading;
  final JosiUser? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthSession copyWith({
    bool? isLoading,
    JosiUser? user,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthSession(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      errorMessage: errorMessage,
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
    final JosiUser? restoredUser = await _repository.restoreSession();
    state = restoredUser == null
        ? const AuthSession.guest()
        : AuthSession(isLoading: false, user: restoredUser);
  }

  Future<void> signIn(
      {required String identity,
      required String password,
      String role = 'customer'}) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearUser: true);
    try {
      final JosiUser user = await _repository.signIn(
        identity: identity,
        password: password,
        role: role,
      );
      state = AuthSession(isLoading: false, user: user);
    } on Object catch (error) {
      state = AuthSession(
        isLoading: false,
        errorMessage:
            _friendlyError(error, 'Invalid email, phone, or password.'),
      );
    }
  }

  Future<void> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearUser: true);
    try {
      final JosiUser user = await _repository.registerCustomer(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      state = AuthSession(isLoading: false, user: user);
    } on Object catch (error) {
      state = AuthSession(
        isLoading: false,
        errorMessage: _friendlyError(error, 'Unable to create account.'),
      );
    }
  }

  Future<void> registerRider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'rider',
  }) async {
    state =
        state.copyWith(isLoading: true, errorMessage: null, clearUser: true);
    try {
      final JosiUser user = await _repository.registerRider(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = AuthSession(isLoading: false, user: user);
    } on Object catch (error) {
      state = AuthSession(
        isLoading: false,
        errorMessage: _friendlyError(error, 'Unable to create account.'),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
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
  return const CustomerRepository();
});

final Provider<RiderRepository> riderRepositoryProvider =
    Provider<RiderRepository>((Ref ref) {
  return const RiderRepository();
});

final Provider<TripRepository> tripRepositoryProvider =
    Provider<TripRepository>((Ref ref) {
  return const TripRepository();
});

final Provider<WalletRepository> walletRepositoryProvider =
    Provider<WalletRepository>((Ref ref) {
  return const WalletRepository();
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

final FutureProvider<JosiUser> currentRiderProvider =
    FutureProvider<JosiUser>((Ref ref) {
  return ref.watch(riderRepositoryProvider).profile();
});

final FutureProvider<RiderProfile> riderProfileProvider =
    FutureProvider<RiderProfile>((Ref ref) {
  return ref.watch(riderRepositoryProvider).riderProfile();
});

final FutureProvider<List<DocumentRequirement>> riderDocumentsProvider =
    FutureProvider<List<DocumentRequirement>>((Ref ref) {
  return ref.watch(riderRepositoryProvider).documents();
});

final FutureProvider<List<Trip>> tripsProvider =
    FutureProvider<List<Trip>>((Ref ref) {
  return ref.watch(tripRepositoryProvider).trips();
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
  return ref.watch(walletRepositoryProvider).transactions();
});

final FutureProvider<List<CashLedgerEntry>> cashLedgerProvider =
    FutureProvider<List<CashLedgerEntry>>((Ref ref) {
  return ref.watch(walletRepositoryProvider).cashLedger();
});

final FutureProvider<List<JosiNotification>> notificationsProvider =
    FutureProvider<List<JosiNotification>>((Ref ref) {
  return ref.watch(notificationRepositoryProvider).notifications();
});
