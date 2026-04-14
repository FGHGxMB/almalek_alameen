// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class PermissionsModel {
  final bool adminAccess;
  final bool exportData;
  final bool companyAccountsView;
  final bool companyAccountsEdit;
  final bool invoiceCreate;
  final bool invoiceEdit;
  final bool invoiceDelete;
  final bool returnCreate;
  final bool returnEdit;
  final bool returnDelete;
  final bool receiptCreate;
  final bool receiptEdit;
  final bool receiptDelete;
  final bool customerCreate;
  final bool customerEdit;
  final bool customerDelete;

  PermissionsModel({
    required this.adminAccess,
    required this.exportData,
    required this.companyAccountsView,
    required this.companyAccountsEdit,
    required this.invoiceCreate,
    required this.invoiceEdit,
    required this.invoiceDelete,
    required this.returnCreate,
    required this.returnEdit,
    required this.returnDelete,
    required this.receiptCreate,
    required this.receiptEdit,
    required this.receiptDelete,
    required this.customerCreate,
    required this.customerEdit,
    required this.customerDelete,
  });

  factory PermissionsModel.fromMap(Map<String, dynamic> map) {
    return PermissionsModel(
      adminAccess: map['admin_access'] ?? false,
      exportData: map['export_data'] ?? false,
      companyAccountsView: map['company_accounts_view'] ?? false,
      companyAccountsEdit: map['company_accounts_edit'] ?? false,
      invoiceCreate: map['invoice_create'] ?? false,
      invoiceEdit: map['invoice_edit'] ?? false,
      invoiceDelete: map['invoice_delete'] ?? false,
      returnCreate: map['return_create'] ?? false,
      returnEdit: map['return_edit'] ?? false,
      returnDelete: map['return_delete'] ?? false,
      receiptCreate: map['receipt_create'] ?? false,
      receiptEdit: map['receipt_edit'] ?? false,
      receiptDelete: map['receipt_delete'] ?? false,
      customerCreate: map['customer_create'] ?? false,
      customerEdit: map['customer_edit'] ?? false,
      customerDelete: map['customer_delete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'admin_access': adminAccess,
      'export_data': exportData,
      'company_accounts_view': companyAccountsView,
      'company_accounts_edit': companyAccountsEdit,
      'invoice_create': invoiceCreate,
      'invoice_edit': invoiceEdit,
      'invoice_delete': invoiceDelete,
      'return_create': returnCreate,
      'return_edit': returnEdit,
      'return_delete': returnDelete,
      'receipt_create': receiptCreate,
      'receipt_edit': receiptEdit,
      'receipt_delete': receiptDelete,
      'customer_create': customerCreate,
      'customer_edit': customerEdit,
      'customer_delete': customerDelete,
    };
  }
}

class UserModel {
  final String id;
  final String accountName;
  final String email;
  final String rank;
  final String warehouseCode;
  final String mainCustomerAccount;
  final String costCenterCode;
  final String customerSuffix;
  final List<String> canMonitor;
  final bool isActive;
  final int delegateInvoiceCounter;
  final int delegateReturnCounter;
  final int delegateReceiptCounter;
  final int customerCounter;
  final PermissionsModel permissions;

  UserModel({
    required this.id,
    required this.accountName,
    required this.email,
    required this.rank,
    required this.warehouseCode,
    required this.mainCustomerAccount,
    required this.costCenterCode,
    required this.customerSuffix,
    required this.canMonitor,
    required this.isActive,
    required this.delegateInvoiceCounter,
    required this.delegateReturnCounter,
    required this.delegateReceiptCounter,
    required this.customerCounter,
    required this.permissions,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      accountName: data[FirestoreKeys.accountName] ?? '',
      email: data[FirestoreKeys.email] ?? '',
      rank: data[FirestoreKeys.rank] ?? '',
      warehouseCode: data[FirestoreKeys.warehouseCode] ?? '',
      mainCustomerAccount: data[FirestoreKeys.mainCustomerAccount] ?? '',
      costCenterCode: data[FirestoreKeys.costCenterCode] ?? '',
      customerSuffix: data[FirestoreKeys.customerSuffix] ?? '',
      canMonitor: List<String>.from(data[FirestoreKeys.canMonitor] ??[]),
      isActive: data[FirestoreKeys.isActive] ?? false,
      delegateInvoiceCounter: data[FirestoreKeys.delegateInvoiceCounter] ?? 0,
      delegateReturnCounter: data[FirestoreKeys.delegateReturnCounter] ?? 0,
      delegateReceiptCounter: data[FirestoreKeys.delegateReceiptCounter] ?? 0,
      customerCounter: data[FirestoreKeys.customerCounter] ?? 0,
      permissions: PermissionsModel.fromMap(data[FirestoreKeys.permissions] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirestoreKeys.accountName: accountName,
      FirestoreKeys.email: email,
      FirestoreKeys.rank: rank,
      FirestoreKeys.warehouseCode: warehouseCode,
      FirestoreKeys.mainCustomerAccount: mainCustomerAccount,
      FirestoreKeys.costCenterCode: costCenterCode,
      FirestoreKeys.customerSuffix: customerSuffix,
      FirestoreKeys.canMonitor: canMonitor,
      FirestoreKeys.isActive: isActive,
      FirestoreKeys.delegateInvoiceCounter: delegateInvoiceCounter,
      FirestoreKeys.delegateReturnCounter: delegateReturnCounter,
      FirestoreKeys.delegateReceiptCounter: delegateReceiptCounter,
      FirestoreKeys.customerCounter: customerCounter,
      FirestoreKeys.permissions: permissions.toMap(),
    };
  }

  UserModel copyWith({
    String? id,
    String? accountName,
    String? email,
    String? rank,
    String? warehouseCode,
    String? mainCustomerAccount,
    String? costCenterCode,
    String? customerSuffix,
    List<String>? canMonitor,
    bool? isActive,
    int? delegateInvoiceCounter,
    int? delegateReturnCounter,
    int? delegateReceiptCounter,
    int? customerCounter,
    PermissionsModel? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      email: email ?? this.email,
      rank: rank ?? this.rank,
      warehouseCode: warehouseCode ?? this.warehouseCode,
      mainCustomerAccount: mainCustomerAccount ?? this.mainCustomerAccount,
      costCenterCode: costCenterCode ?? this.costCenterCode,
      customerSuffix: customerSuffix ?? this.customerSuffix,
      canMonitor: canMonitor ?? this.canMonitor,
      isActive: isActive ?? this.isActive,
      delegateInvoiceCounter: delegateInvoiceCounter ?? this.delegateInvoiceCounter,
      delegateReturnCounter: delegateReturnCounter ?? this.delegateReturnCounter,
      delegateReceiptCounter: delegateReceiptCounter ?? this.delegateReceiptCounter,
      customerCounter: customerCounter ?? this.customerCounter,
      permissions: permissions ?? this.permissions,
    );
  }
}