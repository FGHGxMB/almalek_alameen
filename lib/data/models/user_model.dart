// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class PermissionsModel {
  final bool adminAccess; final bool exportData;
  final bool companyAccountsView; final bool companyAccountsEdit;
  final bool invoiceCreate; final bool invoiceEdit; final bool invoiceDelete;
  final bool returnCreate; final bool returnEdit; final bool returnDelete;
  final bool receiptCreate; final bool receiptEdit; final bool receiptDelete;
  final bool customerCreate; final bool customerEdit; final bool customerDelete;
  // الصلاحيات الجديدة الخاصة بالحسابات المراقبة
  final bool customerCreateMonitored; final bool customerEditMonitored; final bool customerDeleteMonitored;
  final bool invoiceCreateMonitored; final bool invoiceEditMonitored; final bool invoiceDeleteMonitored;
  final bool returnCreateMonitored; final bool returnEditMonitored; final bool returnDeleteMonitored;
  final bool receiptCreateMonitored; final bool receiptEditMonitored; final bool receiptDeleteMonitored;
  final bool updateCurrency;

  PermissionsModel({
    required this.adminAccess, required this.exportData, required this.companyAccountsView, required this.companyAccountsEdit,
    required this.invoiceCreate, required this.invoiceEdit, required this.invoiceDelete,
    required this.returnCreate, required this.returnEdit, required this.returnDelete,
    required this.receiptCreate, required this.receiptEdit, required this.receiptDelete,
    required this.customerCreate, required this.customerEdit, required this.customerDelete,
    required this.customerCreateMonitored, required this.customerEditMonitored, required this.customerDeleteMonitored,
    required this.invoiceCreateMonitored, required this.invoiceEditMonitored, required this.invoiceDeleteMonitored,
    required this.returnCreateMonitored, required this.returnEditMonitored, required this.returnDeleteMonitored,
    required this.receiptCreateMonitored, required this.receiptEditMonitored, required this.receiptDeleteMonitored,
    required this.updateCurrency,
  });

  factory PermissionsModel.fromMap(Map<String, dynamic> map) {
    return PermissionsModel(
      adminAccess: map['admin_access'] ?? false, exportData: map['export_data'] ?? false,
      companyAccountsView: map['company_accounts_view'] ?? false, companyAccountsEdit: map['company_accounts_edit'] ?? false,
      invoiceCreate: map['invoice_create'] ?? false, invoiceEdit: map['invoice_edit'] ?? false, invoiceDelete: map['invoice_delete'] ?? false,
      returnCreate: map['return_create'] ?? false, returnEdit: map['return_edit'] ?? false, returnDelete: map['return_delete'] ?? false,
      receiptCreate: map['receipt_create'] ?? false, receiptEdit: map['receipt_edit'] ?? false, receiptDelete: map['receipt_delete'] ?? false,
      customerCreate: map['customer_create'] ?? false, customerEdit: map['customer_edit'] ?? false, customerDelete: map['customer_delete'] ?? false,
      customerCreateMonitored: map['customer_create_monitored'] ?? false, customerEditMonitored: map['customer_edit_monitored'] ?? false, customerDeleteMonitored: map['customer_delete_monitored'] ?? false,
      invoiceCreateMonitored: map['invoice_create_monitored'] ?? false, invoiceEditMonitored: map['invoice_edit_monitored'] ?? false, invoiceDeleteMonitored: map['invoice_delete_monitored'] ?? false,
      returnCreateMonitored: map['return_create_monitored'] ?? false, returnEditMonitored: map['return_edit_monitored'] ?? false, returnDeleteMonitored: map['return_delete_monitored'] ?? false,
      receiptCreateMonitored: map['receipt_create_monitored'] ?? false, receiptEditMonitored: map['receipt_edit_monitored'] ?? false, receiptDeleteMonitored: map['receipt_delete_monitored'] ?? false,
      updateCurrency: map['update_currency'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'admin_access': adminAccess, 'export_data': exportData, 'company_accounts_view': companyAccountsView, 'company_accounts_edit': companyAccountsEdit,
    'invoice_create': invoiceCreate, 'invoice_edit': invoiceEdit, 'invoice_delete': invoiceDelete,
    'return_create': returnCreate, 'return_edit': returnEdit, 'return_delete': returnDelete,
    'receipt_create': receiptCreate, 'receipt_edit': receiptEdit, 'receipt_delete': receiptDelete,
    'customer_create': customerCreate, 'customer_edit': customerEdit, 'customer_delete': customerDelete,
    'customer_create_monitored': customerCreateMonitored, 'customer_edit_monitored': customerEditMonitored, 'customer_delete_monitored': customerDeleteMonitored,
    'invoice_create_monitored': invoiceCreateMonitored, 'invoice_edit_monitored': invoiceEditMonitored, 'invoice_delete_monitored': invoiceDeleteMonitored,
    'return_create_monitored': returnCreateMonitored, 'return_edit_monitored': returnEditMonitored, 'return_delete_monitored': returnDeleteMonitored,
    'receipt_create_monitored': receiptCreateMonitored, 'receipt_edit_monitored': receiptEditMonitored, 'receipt_delete_monitored': receiptDeleteMonitored,
    'update_currency': updateCurrency,
  };
}

class UserModel {
  final String id; final String accountName; final String email; final String rank;
  final String warehouseCode; final String mainCustomerAccount; final String costCenterCode;
  final String customerSuffix; final String accountColor; // الحقل الجديد
  final List<String> canMonitor; final bool isActive;
  final int delegateInvoiceCounter; final int delegateReturnCounter;
  final int delegateReceiptCounter; final int customerCounter;
  final PermissionsModel permissions;

  UserModel({
    required this.id, required this.accountName, required this.email, required this.rank,
    required this.warehouseCode, required this.mainCustomerAccount, required this.costCenterCode,
    required this.customerSuffix, required this.accountColor, required this.canMonitor,
    required this.isActive, required this.delegateInvoiceCounter, required this.delegateReturnCounter,
    required this.delegateReceiptCounter, required this.customerCounter, required this.permissions,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id, accountName: data[FirestoreKeys.accountName] ?? '', email: data[FirestoreKeys.email] ?? '',
      rank: data[FirestoreKeys.rank] ?? '', warehouseCode: data[FirestoreKeys.warehouseCode] ?? '',
      mainCustomerAccount: data[FirestoreKeys.mainCustomerAccount] ?? '', costCenterCode: data[FirestoreKeys.costCenterCode] ?? '',
      customerSuffix: data[FirestoreKeys.customerSuffix] ?? '', accountColor: data[FirestoreKeys.accountColor] ?? '#009688',
      canMonitor: List<String>.from(data[FirestoreKeys.canMonitor] ?? []), isActive: data[FirestoreKeys.isActive] ?? false,
      delegateInvoiceCounter: data[FirestoreKeys.delegateInvoiceCounter] ?? 0, delegateReturnCounter: data[FirestoreKeys.delegateReturnCounter] ?? 0,
      delegateReceiptCounter: data[FirestoreKeys.delegateReceiptCounter] ?? 0, customerCounter: data[FirestoreKeys.customerCounter] ?? 0,
      permissions: PermissionsModel.fromMap(data[FirestoreKeys.permissions] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
    FirestoreKeys.accountName: accountName, FirestoreKeys.email: email, FirestoreKeys.rank: rank,
    FirestoreKeys.warehouseCode: warehouseCode, FirestoreKeys.mainCustomerAccount: mainCustomerAccount,
    FirestoreKeys.costCenterCode: costCenterCode, FirestoreKeys.customerSuffix: customerSuffix,
    FirestoreKeys.accountColor: accountColor, FirestoreKeys.canMonitor: canMonitor, FirestoreKeys.isActive: isActive,
    FirestoreKeys.delegateInvoiceCounter: delegateInvoiceCounter, FirestoreKeys.delegateReturnCounter: delegateReturnCounter,
    FirestoreKeys.delegateReceiptCounter: delegateReceiptCounter, FirestoreKeys.customerCounter: customerCounter,
    FirestoreKeys.permissions: permissions.toMap(),
  };
}