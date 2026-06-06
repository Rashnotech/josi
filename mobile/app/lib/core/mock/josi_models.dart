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
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final AppRole role;
  final RiderApplicationStatus? applicationStatus;
  final String city;
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
  });

  final String type;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final String chassisNumber;
  final String engineNumber;
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
