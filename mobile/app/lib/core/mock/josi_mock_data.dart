import 'package:flutter/material.dart';

import '../constants/app_routes.dart';
import 'josi_models.dart';

class JosiMockData {
  const JosiMockData._();

  static const JosiUser customer = JosiUser(
    id: 'cus_001',
    name: 'Rik Space',
    email: 'rik@josi.ng',
    phone: '+234 801 234 5678',
    role: AppRole.customer,
  );

  static const JosiUser rider = JosiUser(
    id: 'drv_001',
    name: 'Amina Yusuf',
    email: 'amina@josi.ng',
    phone: '+234 802 345 6789',
    role: AppRole.rider,
    applicationStatus: RiderApplicationStatus.underReview,
  );

  static const RiderProfile riderProfile = RiderProfile(
    fullName: 'Amina Yusuf',
    phone: '+234 802 345 6789',
    gender: 'Female',
    dateOfBirth: '12 Aug 1994',
    address: '22 Adetokunbo Ademola Crescent',
    city: 'Abuja',
    state: 'FCT',
    rating: 4.8,
    completedTrips: 128,
  );

  static const Vehicle vehicle = Vehicle(
    type: 'Car',
    brand: 'Toyota',
    model: 'Corolla',
    color: 'White',
    plateNumber: 'ABC 482 JK',
    chassisNumber: 'JTDBR32E123456789',
    engineNumber: '2ZR-789432',
  );

  static const List<Trip> trips = <Trip>[
    Trip(
      id: 'TRP-2408',
      pickup: 'Wuse Market',
      destination: 'Jabi Lake Mall',
      fare: 'NGN 3,500',
      status: TripStatus.completed,
      paymentMethod: PaymentMethod.cash,
      dateLabel: 'Today, 10:24 AM',
      riderName: 'Amina Yusuf',
      customerName: 'Rik Space',
      distance: '7.6 km',
      duration: '18 mins',
    ),
    Trip(
      id: 'TRP-2409',
      pickup: 'Gwarinpa Estate',
      destination: 'Maitama District',
      fare: 'NGN 4,800',
      status: TripStatus.active,
      paymentMethod: PaymentMethod.wallet,
      dateLabel: 'Today, 1:05 PM',
      riderName: 'Tanzir Fahad',
      customerName: 'Rik Space',
      distance: '11.2 km',
      duration: '29 mins',
    ),
    Trip(
      id: 'TRP-2410',
      pickup: 'Utako Park',
      destination: 'Asokoro Hospital',
      fare: 'NGN 2,900',
      status: TripStatus.cancelled,
      paymentMethod: PaymentMethod.online,
      dateLabel: 'Yesterday',
      riderName: 'Chinedu Okafor',
      customerName: 'Fatima Bello',
      distance: '5.1 km',
      duration: '16 mins',
    ),
  ];

  static const WalletSummary customerWallet = WalletSummary(
    balance: 'NGN 18,250',
    totalEarnings: 'NGN 0',
    availableBalance: 'NGN 18,250',
    pendingRemittance: 'NGN 0',
    todayEarnings: 'NGN 0',
  );

  static const WalletSummary riderWallet = WalletSummary(
    balance: 'NGN 42,600',
    totalEarnings: 'NGN 284,300',
    availableBalance: 'NGN 42,600',
    pendingRemittance: 'NGN 7,200',
    todayEarnings: 'NGN 16,400',
  );

  static const List<WalletTransaction> transactions = <WalletTransaction>[
    WalletTransaction(
      title: 'Trip payment',
      subtitle: 'TRP-2408',
      amount: 'NGN 3,500',
      isCredit: false,
      status: 'Completed',
    ),
    WalletTransaction(
      title: 'Wallet top up',
      subtitle: 'Debit card',
      amount: 'NGN 10,000',
      isCredit: true,
      status: 'Successful',
    ),
    WalletTransaction(
      title: 'Rider earning',
      subtitle: 'TRP-2409',
      amount: 'NGN 3,840',
      isCredit: true,
      status: 'Settled',
    ),
  ];

  static const List<CashLedgerEntry> cashLedger = <CashLedgerEntry>[
    CashLedgerEntry(
      tripId: 'TRP-2408',
      cashCollected: 'NGN 3,500',
      companyShare: 'NGN 700',
      amountToRemit: 'NGN 700',
      status: 'pending',
    ),
    CashLedgerEntry(
      tripId: 'TRP-2388',
      cashCollected: 'NGN 6,200',
      companyShare: 'NGN 1,240',
      amountToRemit: 'NGN 0',
      status: 'remitted',
    ),
  ];

  static const List<JosiNotification> notifications = <JosiNotification>[
    JosiNotification(
      title: 'Trip completed',
      body: 'Your Wuse to Jabi trip receipt is ready.',
      type: 'Trips',
      time: '8 min',
      isRead: false,
    ),
    JosiNotification(
      title: 'Document review',
      body: 'Your driver license is under review.',
      type: 'Rider',
      time: '2 hr',
      isRead: false,
    ),
    JosiNotification(
      title: 'Wallet update',
      body: 'NGN 10,000 top up was successful.',
      type: 'Wallet',
      time: 'Yesterday',
      isRead: true,
    ),
  ];

  static const List<DocumentRequirement> documents = <DocumentRequirement>[
    DocumentRequirement(
      title: 'Driver license',
      description: 'Front and back images',
      status: DocumentStatus.pending,
    ),
    DocumentRequirement(
      title: 'National ID',
      description: 'NIN slip or national card',
      status: DocumentStatus.verified,
    ),
    DocumentRequirement(
      title: 'Utility bill',
      description: 'Recent proof of address',
      status: DocumentStatus.notUploaded,
    ),
    DocumentRequirement(
      title: 'Guarantor form',
      description: 'Signed guarantor document',
      status: DocumentStatus.rejected,
      rejectionReason: 'Uploaded form is not signed.',
    ),
    DocumentRequirement(
      title: 'Profile photo',
      description: 'Clear face photo',
      status: DocumentStatus.pending,
    ),
  ];

  static const List<QuickAction> customerActions = <QuickAction>[
    QuickAction(
        label: 'Book Ride',
        icon: Icons.local_taxi_rounded,
        route: AppRoutes.customerSelectLocation),
    QuickAction(
        label: 'Send Package',
        icon: Icons.inventory_2_rounded,
        route: AppRoutes.customerSelectLocation),
    QuickAction(
        label: 'Trip History',
        icon: Icons.history_rounded,
        route: AppRoutes.customerTrips),
    QuickAction(
        label: 'Wallet',
        icon: Icons.account_balance_wallet_rounded,
        route: AppRoutes.customerWallet),
  ];

  static const List<String> recentLocations = <String>[
    'Jabi Lake Mall',
    'Wuse Market',
    'Nnamdi Azikiwe Airport',
    'Maitama District',
  ];

  static const Map<String, String> zonePricing = <String, String>{
    'Base fare': 'NGN 900',
    'Per km': 'NGN 230',
    'Wuse to Jabi estimate': 'NGN 3,500 - NGN 4,200',
  };
}
