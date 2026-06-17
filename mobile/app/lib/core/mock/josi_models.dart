import 'package:flutter/material.dart';

enum AppRole { customer, rider, fleetOwner }

enum RiderApplicationStatus {
  pending,
  underReview,
  approved,
  rejected,
  suspended
}

enum TripStatus { active, completed, cancelled, searching }

enum PaymentMethod { cash, online, wallet }

enum DocumentStatus { notUploaded, pending, verified, rejected }

class JosiUser {
  const JosiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.applicationStatus,
    this.city = 'Abuja',
    this.firstName,
    this.lastName,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final AppRole role;
  final RiderApplicationStatus? applicationStatus;
  final String city;
  final String? firstName;
  final String? lastName;

  String get displayName {
    final String trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName;
    }

    return <String?>[firstName, lastName]
        .whereType<String>()
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .join(' ');
  }

  String get greetingName {
    final String trimmedFirstName = firstName?.trim() ?? '';
    if (trimmedFirstName.isNotEmpty) {
      return trimmedFirstName;
    }

    final String fallbackName = displayName;
    if (fallbackName.isEmpty) {
      return 'there';
    }

    return fallbackName.split(RegExp(r'\s+')).first;
  }
}

class RiderProfile {
  const RiderProfile({
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.state,
    required this.rating,
    required this.completedTrips,
    this.profilePhoto,
    this.licenseNumber,
    this.applicationStatus,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
  });

  final String fullName;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final String address;
  final String city;
  final String state;
  final double rating;
  final int completedTrips;
  final String? profilePhoto;
  final String? licenseNumber;
  final RiderApplicationStatus? applicationStatus;
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
}

class Vehicle {
  const Vehicle({
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.chassisNumber,
    required this.engineNumber,
    this.registrationNumber = '',
  });

  final String type;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final String chassisNumber;
  final String engineNumber;
  final String registrationNumber;
}

class RiderBankAccount {
  const RiderBankAccount({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
}

class RiderOnboarding {
  const RiderOnboarding({
    this.profile,
    this.bankAccount,
    this.ridingDetails,
    this.profilePictureComplete = false,
    this.bankAccountComplete = false,
    this.ridingDetailsComplete = false,
    this.isSubmitted = false,
    this.submittedAt,
    this.missingSteps = const <String>[],
  });

  final RiderProfile? profile;
  final RiderBankAccount? bankAccount;
  final Vehicle? ridingDetails;
  final bool profilePictureComplete;
  final bool bankAccountComplete;
  final bool ridingDetailsComplete;
  final bool isSubmitted;
  final String? submittedAt;
  final List<String> missingSteps;

  bool get isComplete =>
      profilePictureComplete && bankAccountComplete && ridingDetailsComplete;
}

class Trip {
  const Trip({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.fare,
    required this.status,
    required this.paymentMethod,
    required this.dateLabel,
    required this.riderName,
    required this.customerName,
    required this.distance,
    required this.duration,
  });

  final String id;
  final String pickup;
  final String destination;
  final String fare;
  final TripStatus status;
  final PaymentMethod paymentMethod;
  final String dateLabel;
  final String riderName;
  final String customerName;
  final String distance;
  final String duration;
}

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final String status;
}

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.totalEarnings,
    required this.availableBalance,
    required this.pendingRemittance,
    required this.todayEarnings,
  });

  final String balance;
  final String totalEarnings;
  final String availableBalance;
  final String pendingRemittance;
  final String todayEarnings;
}

class CashLedgerEntry {
  const CashLedgerEntry({
    required this.tripId,
    required this.cashCollected,
    required this.companyShare,
    required this.amountToRemit,
    required this.status,
  });

  final String tripId;
  final String cashCollected;
  final String companyShare;
  final String amountToRemit;
  final String status;
}

class JosiNotification {
  const JosiNotification({
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.isRead,
  });

  final String title;
  final String body;
  final String type;
  final String time;
  final bool isRead;
}

class DocumentRequirement {
  const DocumentRequirement({
    required this.title,
    required this.description,
    required this.status,
    this.rejectionReason,
  });

  final String title;
  final String description;
  final DocumentStatus status;
  final String? rejectionReason;
}

class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class CustomerSavedAddress {
  const CustomerSavedAddress({
    required this.title,
    required this.address,
  });

  final String title;
  final String address;
}
