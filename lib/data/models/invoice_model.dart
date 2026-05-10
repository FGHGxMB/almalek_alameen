// lib/data/models/invoice_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import 'transaction_item_model.dart';

class InvoiceModel {
  final String id;
  final int invoiceNumber;
  final int delegateInvoiceNumber;
  final DateTime invoiceDate;
  final String customerId; // Document ID of the customer
  final String customerName; // Display only
  final String warehouseCode;
  final String paymentMethod; // "cash" | "credit"
  final String invoiceNote;
  final double discount;
  final String costCenterCode;
  final bool isSynced;
  final String pendingAction; // "create" | "update" | "delete"
  final DateTime createdAt;
  final DateTime updatedAt;
  final String delegateId;
  final List<TransactionItemModel> items;
  final String printAddress;
  final String printPhone;

  InvoiceModel({
    required this.id, required this.invoiceNumber, required this.delegateInvoiceNumber,
    required this.invoiceDate, required this.customerId, required this.customerName,
    required this.warehouseCode, required this.paymentMethod, required this.invoiceNote,
    required this.discount, required this.costCenterCode, required this.isSynced,
    required this.pendingAction, required this.createdAt, required this.updatedAt,
    required this.delegateId, required this.items,
    this.printAddress = '',
    this.printPhone = '',
  });

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return InvoiceModel(
      id: doc.id,
      invoiceNumber: data[FirestoreKeys.invoiceNumber] ?? 0,
      delegateInvoiceNumber: data[FirestoreKeys.delegateInvoiceNumber] ?? 0,
      invoiceDate: (data[FirestoreKeys.invoiceDate] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerId: data[FirestoreKeys.customerId] ?? '',
      customerName: data[FirestoreKeys.customerName] ?? '',
      warehouseCode: data[FirestoreKeys.warehouseCode] ?? '',
      paymentMethod: data[FirestoreKeys.paymentMethod] ?? 'cash',
      invoiceNote: data[FirestoreKeys.invoiceNote] ?? '',
      discount: (data[FirestoreKeys.discount] ?? 0).toDouble(),
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.invoiceNumber: invoiceNumber,
      FirestoreKeys.delegateInvoiceNumber: delegateInvoiceNumber,
      FirestoreKeys.invoiceDate: Timestamp.fromDate(invoiceDate),
      FirestoreKeys.customerId: customerId,
      FirestoreKeys.customerName: customerName,
      FirestoreKeys.warehouseCode: warehouseCode,
      FirestoreKeys.paymentMethod: paymentMethod,
      FirestoreKeys.invoiceNote: invoiceNote,
      FirestoreKeys.discount: discount,
      FirestoreKeys.costCenterCode: costCenterCode,
      FirestoreKeys.isSynced: isSynced,
      FirestoreKeys.pendingAction: pendingAction,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
      FirestoreKeys.updatedAt: Timestamp.fromDate(updatedAt),
      FirestoreKeys.delegateId: delegateId,
      FirestoreKeys.items: items.map((e) => e.toMap()).toList(),
      'print_address': printAddress,
      'print_phone': printPhone,
    };
  }

  InvoiceModel copyWith({
    String? id, int? invoiceNumber, int? delegateInvoiceNumber, DateTime? invoiceDate,
    String? customerId, String? customerName, String? warehouseCode, String? paymentMethod,
    String? invoiceNote, double? discount, String? costCenterCode, bool? isSynced,
    String? pendingAction, DateTime? createdAt, DateTime? updatedAt,
    String? delegateId, List<TransactionItemModel>? items,
  }) {
    return InvoiceModel(
      id: id ?? this.id, invoiceNumber: invoiceNumber ?? this.invoiceNumber, delegateInvoiceNumber: delegateInvoiceNumber ?? this.delegateInvoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate, customerId: customerId ?? this.customerId, customerName: customerName ?? this.customerName,
      warehouseCode: warehouseCode ?? this.warehouseCode, paymentMethod: paymentMethod ?? this.paymentMethod, invoiceNote: invoiceNote ?? this.invoiceNote,
      discount: discount ?? this.discount, costCenterCode: costCenterCode ?? this.costCenterCode, isSynced: isSynced ?? this.isSynced,
      pendingAction: pendingAction ?? this.pendingAction, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
      delegateId: delegateId ?? this.delegateId, items: items ?? this.items,
    );
  }
}