// lib/data/models/customer_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class CustomerModel {
  final String id;
  final String accountCode;
  final String customerName;
  final String phone1;
  final String phone2;
  final String email;
  final String notes;
  final String country;
  final String city;
  final String region;
  final String district;
  final String street;
  final String gender;
  final double previousBalance;
  final double balance;
  final String delegateId;

  CustomerModel({
    required this.id,
    required this.accountCode,
    required this.customerName,
    required this.phone1,
    required this.phone2,
    required this.email,
    required this.notes,
    required this.country,
    required this.city,
    required this.region,
    required this.district,
    required this.street,
    required this.gender,
    required this.previousBalance,
    required this.balance,
    required this.delegateId,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerModel(
      id: doc.id,
      accountCode: data[FirestoreKeys.accountCode] ?? '',
      customerName: data[FirestoreKeys.customerName] ?? '',
      phone1: data[FirestoreKeys.phone1] ?? '',
      phone2: data[FirestoreKeys.phone2] ?? '',
      email: data[FirestoreKeys.email] ?? '',
      notes: data[FirestoreKeys.notes] ?? '',
      country: data[FirestoreKeys.country] ?? '',
      city: data[FirestoreKeys.city] ?? '',
      region: data[FirestoreKeys.region] ?? '',
      district: data[FirestoreKeys.district] ?? '',
      street: data[FirestoreKeys.street] ?? '',
      gender: data[FirestoreKeys.gender] ?? '',
      previousBalance: (data[FirestoreKeys.previousBalance] ?? 0).toDouble(),
      balance: (data[FirestoreKeys.balance] ?? 0).toDouble(),
      delegateId: data[FirestoreKeys.delegateId] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.accountCode: accountCode,
      FirestoreKeys.customerName: customerName,
      FirestoreKeys.phone1: phone1,
      FirestoreKeys.phone2: phone2,
      FirestoreKeys.email: email,
      FirestoreKeys.notes: notes,
      FirestoreKeys.country: country,
      FirestoreKeys.city: city,
      FirestoreKeys.region: region,
      FirestoreKeys.district: district,
      FirestoreKeys.street: street,
      FirestoreKeys.gender: gender,
      FirestoreKeys.previousBalance: previousBalance,
      FirestoreKeys.balance: balance,
      FirestoreKeys.delegateId: delegateId,
    };
  }

  CustomerModel copyWith({
    String? id, String? accountCode, String? customerName, String? phone1, String? phone2,
    String? email, String? notes, String? country, String? city, String? region,
    String? district, String? street, String? gender, double? previousBalance,
    double? balance, String? delegateId,
  }) {
    return CustomerModel(
      id: id ?? this.id, accountCode: accountCode ?? this.accountCode, customerName: customerName ?? this.customerName,
      phone1: phone1 ?? this.phone1, phone2: phone2 ?? this.phone2, email: email ?? this.email,
      notes: notes ?? this.notes, country: country ?? this.country, city: city ?? this.city,
      region: region ?? this.region, district: district ?? this.district, street: street ?? this.street,
      gender: gender ?? this.gender, previousBalance: previousBalance ?? this.previousBalance,
      balance: balance ?? this.balance, delegateId: delegateId ?? this.delegateId,
    );
  }
}