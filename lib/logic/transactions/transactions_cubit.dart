import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_state.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/unified_transaction.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/return_model.dart';
import '../../data/models/receipt_model.dart';
import '../../core/utils/excel_exporter.dart';
import '../../data/local/transactions_filters_storage.dart';
import '../../core/constants/firestore_keys.dart';

class TransactionFilters {
  TransactionFilters();
  String sortMode = 'date_desc';
  bool sortByDocType = false;
  bool sortByDelegate = false;
  bool sortByPayment = false;

  List<String> selectedDelegates = [];
  List<String> selectedPaymentMethods =[];
  List<String> selectedDocTypes =[];
  double? minAmount;
  double? maxAmount;
  DateTime? fromDate; // فلتر التاريخ الجديد
  DateTime? toDate;

  Map<String, dynamic> toJson() => {
    'sortMode': sortMode, 'sortByDocType': sortByDocType, 'sortByDelegate': sortByDelegate, 'sortByPayment': sortByPayment,
    'selectedDelegates': selectedDelegates, 'selectedPaymentMethods': selectedPaymentMethods, 'selectedDocTypes': selectedDocTypes,
    'minAmount': minAmount, 'maxAmount': maxAmount,
    'fromDate': fromDate?.toIso8601String(), 'toDate': toDate?.toIso8601String(),
  };

  factory TransactionFilters.fromJson(Map<String, dynamic> json) {
    final f = TransactionFilters();
    f.sortMode = json['sortMode'] ?? 'date_desc'; f.sortByDocType = json['sortByDocType'] ?? false;
    f.sortByDelegate = json['sortByDelegate'] ?? false; f.sortByPayment = json['sortByPayment'] ?? false;
    f.selectedDelegates = List<String>.from(json['selectedDelegates'] ??[]);
    f.selectedPaymentMethods = List<String>.from(json['selectedPaymentMethods'] ??[]);
    f.selectedDocTypes = List<String>.from(json['selectedDocTypes'] ?? []);
    f.minAmount = json['minAmount']; f.maxAmount = json['maxAmount'];
    if (json['fromDate'] != null) f.fromDate = DateTime.tryParse(json['fromDate']);
    if (json['toDate'] != null) f.toDate = DateTime.tryParse(json['toDate']);
    return f;
  }
}

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepository _repository;
  final UserModel currentUser;

  StreamSubscription? _invoicesSub;
  StreamSubscription? _returnsSub;
  StreamSubscription? _receiptsSub;

  List<InvoiceModel> _invoices =[];
  List<ReturnModel> _returns =[];
  List<ReceiptModel> _receipts =[];
  List<UnifiedTransaction> _allUnified =[];

  TransactionFilters filters = TransactionFilters();
  Set<String> selectedIds = {};
  bool isSelectionMode = false;
  double currencyRate = 1.0;
  Map<String, UserModel> usersMap = {};

  bool get hasActiveFilters =>
      filters.sortMode != 'date_desc' || filters.sortByDocType || filters.sortByDelegate || filters.sortByPayment ||
          filters.selectedPaymentMethods.isNotEmpty || filters.selectedDocTypes.isNotEmpty ||
          filters.minAmount != null || filters.maxAmount != null || filters.fromDate != null || filters.toDate != null || (filters.selectedDelegates.length > 1);

  TransactionsCubit(this._repository, this.currentUser) : super(TransactionsLoading()) {
    _initData();
  }

  Future<void> _initData() async {
    currencyRate = await _repository.getCurrencyRate();
    final savedFilters = await TransactionsFiltersStorage.getFilters();
    if (savedFilters != null) filters = savedFilters;
    else filters.selectedDelegates = [currentUser.id];

    await refreshDelegates();
    _initStreams();
  }

  Future<void> refreshDelegates() async {
    try {
      currencyRate = await _repository.getCurrencyRate();
      final delegateIds = [currentUser.id, ...currentUser.canMonitor];
      final snap = await FirebaseFirestore.instance.collection(FirestoreKeys.users).where(FieldPath.documentId, whereIn: delegateIds).get();
      for (var doc in snap.docs) usersMap[doc.id] = UserModel.fromFirestore(doc);
    } catch(e){}
  }

  void _initStreams() {
    final delegateIds = [currentUser.id, ...currentUser.canMonitor];
    _invoicesSub = _repository.getInvoicesStream(delegateIds).listen((data) { _invoices = data; _mergeAndEmit(); });
    _returnsSub = _repository.getReturnsStream(delegateIds).listen((data) { _returns = data; _mergeAndEmit(); });
    _receiptsSub = _repository.getReceiptsStream(delegateIds).listen((data) { _receipts = data; _mergeAndEmit(); });
  }

  void _mergeAndEmit() {
    _allUnified =[];
    for (var inv in _invoices) {
      bool isGiftInvoice = inv.items.isNotEmpty && inv.items.every((i) => i.isGift);
      String method = isGiftInvoice ? 'gift' : inv.paymentMethod;
      final isMine = inv.delegateId == currentUser.id;
      final showModDate = (!isMine) || (isMine && currentUser.permissions.invoiceEdit);

      _allUnified.add(UnifiedTransaction(
        id: inv.id, type: TransactionType.invoice, date: inv.createdAt, updatedAt: inv.updatedAt,
        localNumber: inv.delegateInvoiceNumber, globalNumber: inv.invoiceNumber, customerName: inv.customerName,
        amount: _calculateInvoiceTotal(inv), isSynced: inv.isSynced, delegateId: inv.delegateId,
        delegateName: usersMap[inv.delegateId]?.accountName ?? 'مجهول', delegateColor: usersMap[inv.delegateId]?.accountColor ?? '#000000',
        delegateSuffix: usersMap[inv.delegateId]?.customerSuffix ?? '', // تمرير البادئة
        paymentMethod: method, showModifiedDate: showModDate, originalDoc: inv,
      ));
    }

    for (var ret in _returns) {
      final isMine = ret.delegateId == currentUser.id;
      final showModDate = (!isMine) || (isMine && currentUser.permissions.returnEdit);

      _allUnified.add(UnifiedTransaction(
        id: ret.id, type: TransactionType.returnDoc, date: ret.createdAt, updatedAt: ret.updatedAt,
        localNumber: ret.delegateReturnNumber, globalNumber: ret.returnNumber, customerName: ret.customerName,
        amount: _calculateReturnTotal(ret), isSynced: ret.isSynced, delegateId: ret.delegateId,
        delegateName: usersMap[ret.delegateId]?.accountName ?? 'مجهول', delegateColor: usersMap[ret.delegateId]?.accountColor ?? '#000000',
        delegateSuffix: usersMap[ret.delegateId]?.customerSuffix ?? '',
        paymentMethod: ret.paymentMethod, showModifiedDate: showModDate, originalDoc: ret,
      ));
    }

    for (var rec in _receipts) {
      final isMine = rec.delegateId == currentUser.id;
      final showModDate = (!isMine) || (isMine && currentUser.permissions.receiptEdit);

      _allUnified.add(UnifiedTransaction(
        id: rec.id, type: TransactionType.receipt, date: rec.createdAt, updatedAt: rec.updatedAt,
        localNumber: rec.delegateReceiptNumber, globalNumber: rec.receiptNumber, customerName: 'سند قبض',
        amount: rec.amount, isSynced: rec.isSynced, delegateId: rec.delegateId,
        delegateName: usersMap[rec.delegateId]?.accountName ?? 'مجهول', delegateColor: usersMap[rec.delegateId]?.accountColor ?? '#000000',
        delegateSuffix: usersMap[rec.delegateId]?.customerSuffix ?? '',
        paymentMethod: 'cash', showModifiedDate: showModDate, originalDoc: rec,
      ));
    }
    applyFilters();
  }

  void applyFilters() {
    List<UnifiedTransaction> filtered = List.from(_allUnified);

    filtered = filtered.where((t) {
      if (filters.selectedDelegates.isNotEmpty && !filters.selectedDelegates.contains(t.delegateId)) return false;
      if (filters.selectedPaymentMethods.isNotEmpty && !filters.selectedPaymentMethods.contains(t.paymentMethod)) return false;
      if (filters.minAmount != null && t.amount <= filters.minAmount!) return false;
      if (filters.maxAmount != null && t.amount >= filters.maxAmount!) return false;
      if (filters.fromDate != null && t.date.isBefore(filters.fromDate!)) return false;
      if (filters.toDate != null && t.date.isAfter(filters.toDate!.add(const Duration(days: 1)))) return false;

      if (filters.selectedDocTypes.isNotEmpty) {
        String tType = t.type == TransactionType.invoice ? 'invoice' : t.type == TransactionType.returnDoc ? 'return' : 'receipt';
        if (!filters.selectedDocTypes.contains(tType)) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      int result = 0;
      if (filters.sortByDocType) { result = a.type.index.compareTo(b.type.index); if (result != 0) return result; }
      if (filters.sortByPayment) { result = a.paymentMethod.compareTo(b.paymentMethod); if (result != 0) return result; }
      if (filters.sortByDelegate) { result = a.delegateId.compareTo(b.delegateId); if (result != 0) return result; }

      if (filters.sortMode == 'value_desc') result = b.amount.compareTo(a.amount);
      else if (filters.sortMode == 'value_asc') result = a.amount.compareTo(b.amount);
      else result = b.date.compareTo(a.date);
      return result;
    });

    emit(TransactionsLoaded(transactions: filtered));
  }

  void toggleSelectionMode(String id) { isSelectionMode = true; selectedIds.add(id); applyFilters(); }
  void toggleSelection(String id) {
    if (selectedIds.contains(id)) selectedIds.remove(id); else selectedIds.add(id);
    if (selectedIds.isEmpty) isSelectionMode = false;
    applyFilters();
  }
  void selectAll(List<UnifiedTransaction> list) {
    if (selectedIds.length == list.length) { selectedIds.clear(); isSelectionMode = false; }
    else { selectedIds = list.map((e) => e.id).toSet(); }
    applyFilters();
  }

  void updateFilters(TransactionFilters newFilters) { filters = newFilters; TransactionsFiltersStorage.saveFilters(filters); applyFilters(); }
  void resetFilters() { filters = TransactionFilters(); filters.selectedDelegates = [currentUser.id]; TransactionsFiltersStorage.saveFilters(filters); applyFilters(); }

  double _calculateInvoiceTotal(InvoiceModel inv) {
    double t = 0;
    for (var item in inv.items) t += item.price * item.quantity;
    return t - inv.discount;
  }
  double _calculateReturnTotal(ReturnModel ret) {
    double t = 0;
    for (var item in ret.items) t += item.price * item.quantity;
    return t;
  }

  Future<void> exportDataToExcel() async {
    try {
      List<InvoiceModel> invs = []; List<ReturnModel> rets =[]; List<ReceiptModel> recs =[];
      List<UnifiedTransaction> source = _allUnified;
      if (state is TransactionsLoaded) {
        source = (state as TransactionsLoaded).transactions;
        if (selectedIds.isNotEmpty) source = source.where((t) => selectedIds.contains(t.id)).toList();
      }

      for (var t in source) {
        if (t.type == TransactionType.invoice) invs.add(t.originalDoc);
        if (t.type == TransactionType.returnDoc) rets.add(t.originalDoc);
        if (t.type == TransactionType.receipt) recs.add(t.originalDoc);
      }
      await ExcelExporter.exportTransactions(invoices: invs, returns: rets, receipts: recs);
    } catch (e) { emit(TransactionsError('فشل التصدير: $e')); applyFilters(); }
  }

  @override
  Future<void> close() {
    _invoicesSub?.cancel(); _returnsSub?.cancel(); _receiptsSub?.cancel();
    return super.close();
  }
}