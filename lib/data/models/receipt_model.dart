// lib/data/models/receipt_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class ReceiptModel {
  final String id;
  final int receiptNumber;
  final int delegateReceiptNumber;
  final String creditorAccount; // ID of the customer who paid
  final String debtorAccount; // ID of the account receiving the money
  final double amount;
  final String lineNote;
  final String costCenterCode;
  final DateTime date;
  final bool isSynced;
  final String pendingAction;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String delegateId;
  final String printAddress;
  final String printPhone;

  ReceiptModel({
    required this.id, required this.receiptNumber, required this.delegateReceiptNumber,
    required this.creditorAccount, required this.debtorAccount, required this.amount,
    required this.lineNote, required this.costCenterCode, required this.date,
    required this.isSynced, required this.pendingAction, required this.createdAt,
    required this.updatedAt, required this.delegateId,
    this.printAddress = '',
    this.printPhone = '',
  });

  factory ReceiptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ReceiptModel(
      id: doc.id,
      receiptNumber: data[FirestoreKeys.receiptNumber] ?? 0,
      delegateReceiptNumber: data[FirestoreKeys.delegateReceiptNumber] ?? 0,
      creditorAccount: data[FirestoreKeys.creditorAccount] ?? '',
      debtorAccount: data[FirestoreKeys.debtorAccount] ?? '',
      amount: (data[FirestoreKeys.amount] ?? 0).toDouble(),
      lineNote: data[FirestoreKeys.lineNote] ?? '',
      costCenterCode: data[FirestoreKeys.costCenterCode] ?? '',
      date: (data[FirestoreKeys.date] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSynced: !doc.metadata.hasPendingWrites,
      pendingAction: data[FirestoreKeys.pendingAction] ?? '',
      createdAt: (data[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data[FirestoreKeys.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      delegateId: data[FirestoreKeys.delegateId] ?? '',
      printAddress: data['print_address'] ?? '',
      printPhone: data['print_phone'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.receiptNumber: receiptNumber,
      FirestoreKeys.delegateReceiptNumber: delegateReceiptNumber,
      FirestoreKeys.creditorAccount: creditorAccount,
      FirestoreKeys.debtorAccount: debtorAccount,
      FirestoreKeys.amount: amount,
      FirestoreKeys.lineNote: lineNote,
      FirestoreKeys.costCenterCode: costCenterCode,
      FirestoreKeys.date: Timestamp.fromDate(date),
      FirestoreKeys.isSynced: isSynced,
      FirestoreKeys.pendingAction: pendingAction,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      FirestoreKeys.updatedAt: Timestamp.fromDate(updatedAt),
      FirestoreKeys.delegateId: delegateId,
      'print_address': printAddress,
      'print_phone': printPhone,
    };
  }

  ReceiptModel copyWith({
    String? id, int? receiptNumber, int? delegateReceiptNumber, String? creditorAccount,
    String? debtorAccount, double? amount, String? lineNote, String? costCenterCode,
    DateTime? date, bool? isSynced, String? pendingAction, DateTime? createdAt,
    DateTime? updatedAt, String? delegateId,
  }) {
    return ReceiptModel(
      id: id ?? this.id, receiptNumber: receiptNumber ?? this.receiptNumber,
      delegateReceiptNumber: delegateReceiptNumber ?? this.delegateReceiptNumber,
      creditorAccount: creditorAccount ?? this.creditorAccount, debtorAccount: debtorAccount ?? this.debtorAccount,
      amount: amount ?? this.amount, lineNote: lineNote ?? this.lineNote,
      costCenterCode: costCenterCode ?? this.costCenterCode, date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced, pendingAction: pendingAction ?? this.pendingAction,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
      delegateId: delegateId ?? this.delegateId,
    );
  }
}