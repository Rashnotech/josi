import '../mock/josi_mock_data.dart';
import '../mock/josi_models.dart';

class AuthRepository {
  const AuthRepository();

  Future<JosiUser?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return null;
  }

  Future<JosiUser> signIn(
      {required String identity, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return JosiMockData.customer;
  }

  Future<JosiUser> registerCustomer() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return JosiMockData.customer;
  }

  Future<JosiUser> registerRider() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return JosiMockData.rider;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
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
