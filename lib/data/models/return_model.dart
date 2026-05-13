// lib/data/models/return_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import 'transaction_item_model.dart';

class ReturnModel {
  final String id;
  final int returnNumber;
  final int delegateReturnNumber;
  final DateTime returnDate;
  final String customerId; // Document ID of the customer
  final String customerName;
  final String warehouseCode;
  final String paymentMethod; // "cash" | "credit"
  final String returnNote;
  final String invoiceRef; // The ID of the original invoice, if any
  final String costCenterCode;
  final bool isSynced;
  final String pendingAction; // "create" | "update" | "delete"
  final DateTime createdAt;
  final DateTime updatedAt;
  final String delegateId;
  final List<TransactionItemModel> items;
  final String printAddress;
  final String printPhone;
  final String printName;

  ReturnModel({
    required this.id, required this.returnNumber, required this.delegateReturnNumber,
    required this.returnDate, required this.customerId, required this.customerName,
    required this.warehouseCode, required this.paymentMethod, required this.returnNote,
    required this.invoiceRef, required this.costCenterCode, required this.isSynced,
    required this.pendingAction, required this.createdAt, required this.updatedAt,
    required this.delegateId, required this.items,
    this.printAddress = '',
    this.printPhone = '',
    this.printName = '',
  });

  factory ReturnModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ReturnModel(
      id: doc.id,
      returnNumber: data[FirestoreKeys.returnNumber] ?? 0,
      delegateReturnNumber: data[FirestoreKeys.delegateReturnNumber] ?? 0,
      returnDate: (data[FirestoreKeys.returnDate] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerId: data[FirestoreKeys.customerId] ?? '',
      customerName: data[FirestoreKeys.customerName] ?? '',
      warehouseCode: data[FirestoreKeys.warehouseCode] ?? '',
      paymentMethod: data[FirestoreKeys.paymentMethod] ?? 'cash',
      returnNote: data[FirestoreKeys.returnNote] ?? '',
      invoiceRef: data[FirestoreKeys.invoiceRef] ?? '',
      costCenterCode: data[FirestoreKeys.costCenterCode] ?? '',
      isSynced: !doc.metadata.hasPendingWrites,
      pendingAction: data[FirestoreKeys.pendingAction] ?? '',
      createdAt: (data[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data[FirestoreKeys.updatedAt] as Timestamp?)?.toDate() ?? DateTime.now(),
      delegateId: data[FirestoreKeys.delegateId] ?? '',
      items: (data[FirestoreKeys.items] as List<dynamic>?)
          ?.map((item) => TransactionItemModel.fromMap(item as Map<String, dynamic>))
          .toList() ??[],
      printAddress: data['print_address'] ?? '',
      printPhone: data['print_phone'] ?? '',
      printName: data['print_name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.returnNumber: returnNumber,
      FirestoreKeys.delegateReturnNumber: delegateReturnNumber,
      FirestoreKeys.returnDate: Timestamp.fromDate(returnDate),
      FirestoreKeys.customerId: customerId,
      FirestoreKeys.customerName: customerName,
      FirestoreKeys.warehouseCode: warehouseCode,
      FirestoreKeys.paymentMethod: paymentMethod,
      FirestoreKeys.returnNote: returnNote,
      FirestoreKeys.invoiceRef: invoiceRef,
      FirestoreKeys.costCenterCode: costCenterCode,
      FirestoreKeys.isSynced: isSynced,
      FirestoreKeys.pendingAction: pendingAction,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      FirestoreKeys.updatedAt: Timestamp.fromDate(updatedAt),
      FirestoreKeys.delegateId: delegateId,
      FirestoreKeys.items: items.map((e) => e.toMap()).toList(),
      'print_address': printAddress,
      'print_phone': printPhone,
      'print_name': printName,
    };
  }

  ReturnModel copyWith({
    String? id, int? returnNumber, int? delegateReturnNumber, DateTime? returnDate,
    String? customerId, String? customerName, String? warehouseCode, String? paymentMethod,
    String? returnNote, String? invoiceRef, String? costCenterCode, bool? isSynced,
    String? pendingAction, DateTime? createdAt, DateTime? updatedAt,
    String? delegateId, List<TransactionItemModel>? items,
    String? printName,
  }) {
    return ReturnModel(
      id: id ?? this.id, returnNumber: returnNumber ?? this.returnNumber, delegateReturnNumber: delegateReturnNumber ?? this.delegateReturnNumber,
      returnDate: returnDate ?? this.returnDate, customerId: customerId ?? this.customerId, customerName: customerName ?? this.customerName,
      warehouseCode: warehouseCode ?? this.warehouseCode, paymentMethod: paymentMethod ?? this.paymentMethod, returnNote: returnNote ?? this.returnNote,
      invoiceRef: invoiceRef ?? this.invoiceRef, costCenterCode: costCenterCode ?? this.costCenterCode, isSynced: isSynced ?? this.isSynced,
      pendingAction: pendingAction ?? this.pendingAction, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
      delegateId: delegateId ?? this.delegateId, items: items ?? this.items,
      printName: printName ?? this.printName,
    );
  }
}