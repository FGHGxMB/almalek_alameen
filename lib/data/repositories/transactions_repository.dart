// lib/data/repositories/transactions_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../models/invoice_model.dart';
import '../models/return_model.dart';
import '../models/receipt_model.dart';
import '../models/user_model.dart';

class TransactionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // دوال مساعدة لحساب الأثر المالي داخل الـ Batch
  // ---------------------------------------------------------------------------
  double _calculateTotal(List items, double discount) {
    double total = 0;
    for (var item in items) {
      total += (item.price * item.quantity);
    }
    return total - discount;
  }

  void _applySaleImpact(WriteBatch batch, String delegateId, String customerId, String paymentMethod, double amount, DateTime date) {
    if (amount == 0) return;
    final dateStr = date.toIso8601String().split('T')[0];

    if (paymentMethod == 'cash') {
      final cashRef = _firestore.collection(FirestoreKeys.users).doc(delegateId).collection(FirestoreKeys.dailyCash).doc(dateStr);
      batch.set(cashRef, {
        'amount': FieldValue.increment(amount),
        'date': Timestamp.fromDate(date),
      }, SetOptions(merge: true));
    } else if (paymentMethod == 'credit') {
      final customerRef = _firestore.collection(FirestoreKeys.customers).doc(customerId);
      batch.update(customerRef, {
        FirestoreKeys.balance: FieldValue.increment(amount),
      });
    }
  }

  void _applyReceiptImpact(WriteBatch batch, String delegateId, String customerId, double amount, DateTime date) {
    if (amount == 0) return;
    final dateStr = date.toIso8601String().split('T')[0];

    // زيادة الكاش
    final cashRef = _firestore.collection(FirestoreKeys.users).doc(delegateId).collection(FirestoreKeys.dailyCash).doc(dateStr);
    batch.set(cashRef, {
      'amount': FieldValue.increment(amount),
      'date': Timestamp.fromDate(date),
    }, SetOptions(merge: true));

    // إنقاص رصيد الزبون
    final customerRef = _firestore.collection(FirestoreKeys.customers).doc(customerId);
    batch.update(customerRef, {
      FirestoreKeys.balance: FieldValue.increment(-amount),
    });
  }

  // ---------------------------------------------------------------------------
  // 1. الفواتير (Invoices)
  // ---------------------------------------------------------------------------
  Future<void> createInvoice(InvoiceModel invoice, UserModel currentUser) async {
    final batch = _firestore.batch();
    final invoiceRef = _firestore.collection(FirestoreKeys.invoices).doc();
    final configRef = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc);
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);

    // حساب المبلغ
    final amount = _calculateTotal(invoice.items, invoice.discount);

    // تحديث العدادات
    final newLocalCounter = currentUser.delegateInvoiceCounter + 1;

    // إنشاء نسخة جديدة من الفاتورة مع المعرفات والأرقام الصحيحة
    final finalInvoice = invoice.copyWith(
      id: invoiceRef.id,
      delegateInvoiceNumber: newLocalCounter,
      isSynced: true, // لن نستخدم Pending Action بما أننا نستخدم Batch
      pendingAction: "",
    );

    // تسجيل الفاتورة
    batch.set(invoiceRef, finalInvoice.toFirestore());

    // تحديث العدادات بـ Increment لضمان عدم التضارب (حتى في وضع الاوفلاين)
    batch.update(configRef, {FirestoreKeys.invoiceCounter: FieldValue.increment(1)});
    batch.update(userRef, {FirestoreKeys.delegateInvoiceCounter: FieldValue.increment(1)});

    // تطبيق الأثر المالي
    _applySaleImpact(batch, invoice.delegateId, invoice.customerId, invoice.paymentMethod, amount, invoice.invoiceDate);

    // تنفيذ كل العمليات معاً
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // 2. المرتجعات (Returns)
  // ---------------------------------------------------------------------------
  Future<void> createReturn(ReturnModel returnDoc, UserModel currentUser) async {
    final batch = _firestore.batch();
    final returnRef = _firestore.collection(FirestoreKeys.returns).doc();
    final configRef = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc);
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);

    final amount = _calculateTotal(returnDoc.items, 0); // لا حسم في المرتجع
    final newLocalCounter = currentUser.delegateReturnCounter + 1;

    final finalReturn = returnDoc.copyWith(
      id: returnRef.id,
      delegateReturnNumber: newLocalCounter,
      isSynced: true,
      pendingAction: "",
    );

    batch.set(returnRef, finalReturn.toFirestore());
    batch.update(configRef, {FirestoreKeys.returnCounter: FieldValue.increment(1)});
    batch.update(userRef, {FirestoreKeys.delegateReturnCounter: FieldValue.increment(1)});

    // المرتجع ينقص من الكاش/الرصيد لذا نرسل المبلغ بالسالب
    _applySaleImpact(batch, returnDoc.delegateId, returnDoc.customerId, returnDoc.paymentMethod, -amount, returnDoc.returnDate);

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // 3. السندات (Receipts)
  // ---------------------------------------------------------------------------
  Future<void> createReceipt(ReceiptModel receipt, UserModel currentUser) async {
    final batch = _firestore.batch();
    final receiptRef = _firestore.collection(FirestoreKeys.receipts).doc();
    final configRef = _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc);
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);

    final newLocalCounter = currentUser.delegateReceiptCounter + 1;

    final finalReceipt = receipt.copyWith(
      id: receiptRef.id,
      delegateReceiptNumber: newLocalCounter,
      isSynced: true,
      pendingAction: "",
    );

    batch.set(receiptRef, finalReceipt.toFirestore());
    batch.update(configRef, {FirestoreKeys.receiptCounter: FieldValue.increment(1)});
    batch.update(userRef, {FirestoreKeys.delegateReceiptCounter: FieldValue.increment(1)});

    _applyReceiptImpact(batch, receipt.delegateId, receipt.creditorAccount, receipt.amount, receipt.date);

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // 4. دوال جلب البيانات (Streams)
  // ---------------------------------------------------------------------------

  Stream<List<InvoiceModel>> getInvoicesStream(List<String> delegateIds) {
    return _firestore
        .collection(FirestoreKeys.invoices)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => InvoiceModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ReturnModel>> getReturnsStream(List<String> delegateIds) {
    return _firestore
        .collection(FirestoreKeys.returns)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => ReturnModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ReceiptModel>> getReceiptsStream(List<String> delegateIds) {
    return _firestore
        .collection(FirestoreKeys.receipts)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((doc) => ReceiptModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}