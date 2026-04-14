// lib/data/models/company_account_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class CompanyAccountModel {
  final String id;
  final String accountName;
  final double balance;
  final String accountType; // "customer" | "supplier"
  final String themeColor;
  final String backgroundColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyAccountModel({
    required this.id, required this.accountName, required this.balance,
    required this.accountType, required this.themeColor, required this.backgroundColor,
    required this.createdAt, required this.updatedAt,
  });

  factory CompanyAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CompanyAccountModel(
      id: doc.id,
      accountName: data[FirestoreKeys.accountName] ?? '',
      balance: (data[FirestoreKeys.balance] ?? 0).toDouble(),
      accountType: data['account_type'] ?? 'customer', // Fixed string since it wasn't in keys
      themeColor: data['theme_color'] ?? '#FFFFFF',
      backgroundColor: data['background_color'] ?? '#000000',
      createdAt: (data[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data[FirestoreKeys.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.accountName: accountName,
      FirestoreKeys.balance: balance,
      'account_type': accountType,
      'theme_color': themeColor,
      'background_color': backgroundColor,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      FirestoreKeys.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  CompanyAccountModel copyWith({
    String? id, String? accountName, double? balance, String? accountType,
    String? themeColor, String? backgroundColor, DateTime? createdAt, DateTime? updatedAt,
  }) {
    return CompanyAccountModel(
      id: id ?? this.id, accountName: accountName ?? this.accountName,
      balance: balance ?? this.balance, accountType: accountType ?? this.accountType,
      themeColor: themeColor ?? this.themeColor, backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}