// lib/logic/transactions/transactions_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transactions_state.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/unified_transaction.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/return_model.dart';
import '../../data/models/receipt_model.dart';
import '../../core/utils/excel_exporter.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepository _repository;
  final UserModel currentUser;

  StreamSubscription? _invoicesSub;
  StreamSubscription? _returnsSub;
  StreamSubscription? _receiptsSub;

  List<InvoiceModel> _invoices = [];
  List<ReturnModel> _returns =[];
  List<ReceiptModel> _receipts =[];

  TransactionsCubit(this._repository, this.currentUser) : super(TransactionsLoading()) {
    _initStreams();
  }

  void _initStreams() {
    final delegateIds = [currentUser.id, ...currentUser.canMonitor];

    _invoicesSub = _repository.getInvoicesStream(delegateIds).listen((data) {
      _invoices = data;
      _mergeAndEmit();
    });

    _returnsSub = _repository.getReturnsStream(delegateIds).listen((data) {
      _returns = data;
      _mergeAndEmit();
    });

    _receiptsSub = _repository.getReceiptsStream(delegateIds).listen((data) {
      _receipts = data;
      _mergeAndEmit();
    });
  }

  void _mergeAndEmit() {
    List<UnifiedTransaction> all =[];

    for (var inv in _invoices) {
      all.add(UnifiedTransaction(
        id: inv.id,
        type: TransactionType.invoice,
        date: inv.invoiceDate,
        localNumber: inv.delegateInvoiceNumber,
        globalNumber: inv.invoiceNumber,
        customerName: inv.customerName,
        amount: _calculateInvoiceTotal(inv),
        isSynced: inv.isSynced,
        originalDoc: inv,
      ));
    }

    for (var ret in _returns) {
      all.add(UnifiedTransaction(
        id: ret.id,
        type: TransactionType.returnDoc,
        date: ret.returnDate,
        localNumber: ret.delegateReturnNumber,
        globalNumber: ret.returnNumber,
        customerName: ret.customerName,
        amount: _calculateReturnTotal(ret),
        isSynced: ret.isSynced,
        originalDoc: ret,
      ));
    }

    for (var rec in _receipts) {
      all.add(UnifiedTransaction(
        id: rec.id,
        type: TransactionType.receipt,
        date: rec.date,
        localNumber: rec.delegateReceiptNumber,
        globalNumber: rec.receiptNumber,
        customerName: 'سند قبض - حساب دائن', // سيتم تحسينها لاحقاً لجلب الاسم
        amount: rec.amount,
        isSynced: rec.isSynced,
        originalDoc: rec,
      ));
    }

    // ترتيب القائمة من الأحدث للأقدم
    all.sort((a, b) => b.date.compareTo(a.date));

    emit(TransactionsLoaded(transactions: all));
  }

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

  @override
  Future<void> close() {
    _invoicesSub?.cancel();
    _returnsSub?.cancel();
    _receiptsSub?.cancel();
    return super.close();
  }

  Future<void> exportDataToExcel() async {
    try {
      await ExcelExporter.exportTransactions(
        invoices: _invoices,
        returns: _returns,
        receipts: _receipts,
      );
    } catch (e) {
      emit(TransactionsError('فشل التصدير: $e'));
    }
  }
}