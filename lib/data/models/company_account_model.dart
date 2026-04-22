// lib/data/models/company_account_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class CompanyAccountModel {
  final String id;
  final String accountName;
  final double balance;
  final String currency; // الحقل الجديد: العملة
  final String accountType; // "customer" | "supplier"
  final String themeColor;
  final String backgroundColor;
  final int orderIndex; // الحقل الجديد: للترتيب
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyAccountModel({
    required this.id, required this.accountName, required this.balance,
    required this.currency, required this.accountType, required this.themeColor,
    required this.backgroundColor, required this.orderIndex,
    required this.createdAt, required this.updatedAt,
  });

  factory CompanyAccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CompanyAccountModel(
      id: doc.id,
      accountName: data[FirestoreKeys.accountName] ?? '',
      balance: (data[FirestoreKeys.balance] ?? 0).toDouble(),
      currency: data['currency'] ?? 'SYP', // افتراضي للبيانات القديمة
      accountType: data['account_type'] ?? 'customer',
      themeColor: data['theme_color'] ?? '#009688',
      backgroundColor: data['background_color'] ?? '#E0F2F1',
      orderIndex: data['order_index'] ?? 0, // افتراضي للبيانات القديمة
      createdAt: (data[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data[FirestoreKeys.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.accountName: accountName,
      FirestoreKeys.balance: balance,
      'currency': currency,
      'account_type': accountType,
      'theme_color': themeColor,
      'background_color': backgroundColor,
      'order_index': orderIndex,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      FirestoreKeys.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  CompanyAccountModel copyWith({
    String? id, String? accountName, double? balance, String? currency,
    String? accountType, String? themeColor, String? backgroundColor,
    int? orderIndex, DateTime? createdAt, DateTime? updatedAt,
  }) {
    return CompanyAccountModel(
      id: id ?? this.id, accountName: accountName ?? this.accountName,
      balance: balance ?? this.balance, currency: currency ?? this.currency,
      accountType: accountType ?? this.accountType, themeColor: themeColor ?? this.themeColor,
      backgroundColor: backgroundColor ?? this.backgroundColor, orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}