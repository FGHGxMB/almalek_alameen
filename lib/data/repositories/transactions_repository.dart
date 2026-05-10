import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';
import '../models/invoice_model.dart';
import '../models/return_model.dart';
import '../models/receipt_model.dart';
import '../models/user_model.dart';

class TransactionsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _calculateTotal(List items, double discount) {
    double total = 0;
    for (var item in items) { total += (item.price * item.quantity); }
    return total - discount;
  }

  void _applySaleImpact(WriteBatch batch, String delegateId, String customerId, String paymentMethod, double amount, DateTime date) {
    if (amount == 0) return;
    final dateStr = date.toIso8601String().split('T')[0];
    if (paymentMethod == 'cash') {
      final cashRef = _firestore.collection(FirestoreKeys.users).doc(delegateId).collection(FirestoreKeys.dailyCash).doc(dateStr);
      batch.set(cashRef, {'amount': FieldValue.increment(amount), 'date': Timestamp.fromDate(date)}, SetOptions(merge: true));
    } else if (paymentMethod == 'credit') {
      final customerRef = _firestore.collection(FirestoreKeys.customers).doc(customerId);
      batch.update(customerRef, {FirestoreKeys.balance: FieldValue.increment(amount)});
    }
  }

  void _applyReceiptImpact(WriteBatch batch, String delegateId, String customerId, double amount, DateTime date) {
    if (amount == 0) return;
    final dateStr = date.toIso8601String().split('T')[0];
    final cashRef = _firestore.collection(FirestoreKeys.users).doc(delegateId).collection(FirestoreKeys.dailyCash).doc(dateStr);
    batch.set(cashRef, {'amount': FieldValue.increment(amount), 'date': Timestamp.fromDate(date)}, SetOptions(merge: true));
    final customerRef = _firestore.collection(FirestoreKeys.customers).doc(customerId);
    batch.update(customerRef, {FirestoreKeys.balance: FieldValue.increment(-amount)});
  }

  Future<void> createInvoice(InvoiceModel invoice, UserModel currentUser) async {
    final batch = _firestore.batch();
    final invoiceRef = _firestore.collection(FirestoreKeys.invoices).doc();
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);
    final amount = _calculateTotal(invoice.items, invoice.discount);
    final newLocalCounter = currentUser.delegateInvoiceCounter + 1;

    final finalInvoice = invoice.copyWith(
      id: invoiceRef.id, delegateInvoiceNumber: newLocalCounter,
      invoiceNumber: 0, // تم الإلغاء
      isSynced: true, pendingAction: "",
    );

    batch.set(invoiceRef, finalInvoice.toFirestore());
    batch.update(userRef, {FirestoreKeys.delegateInvoiceCounter: FieldValue.increment(1)});
    _applySaleImpact(batch, invoice.delegateId, invoice.customerId, invoice.paymentMethod, amount, invoice.invoiceDate);
    await batch.commit();
  }

  // --- تعديل الفاتورة ---
  Future<void> updateInvoice(InvoiceModel oldInvoice, InvoiceModel newInvoice) async {
    final batch = _firestore.batch();
    final oldAmount = _calculateTotal(oldInvoice.items, oldInvoice.discount);
    final newAmount = _calculateTotal(newInvoice.items, newInvoice.discount);

    // عكس الأثر القديم
    _applySaleImpact(batch, oldInvoice.delegateId, oldInvoice.customerId, oldInvoice.paymentMethod, -oldAmount, oldInvoice.invoiceDate);
    // تطبيق الأثر الجديد
    _applySaleImpact(batch, newInvoice.delegateId, newInvoice.customerId, newInvoice.paymentMethod, newAmount, newInvoice.invoiceDate);

    final docRef = _firestore.collection(FirestoreKeys.invoices).doc(newInvoice.id);
    final updated = newInvoice.copyWith(updatedAt: DateTime.now(), isSynced: true, pendingAction: "");
    batch.update(docRef, updated.toFirestore());

    await batch.commit();
  }

  // --- حذف الفاتورة ---
  Future<void> deleteInvoice(InvoiceModel invoice) async {
    final batch = _firestore.batch();
    final amount = _calculateTotal(invoice.items, invoice.discount);

    // عكس الأثر المالي
    _applySaleImpact(batch, invoice.delegateId, invoice.customerId, invoice.paymentMethod, -amount, invoice.invoiceDate);

    final docRef = _firestore.collection(FirestoreKeys.invoices).doc(invoice.id);
    batch.delete(docRef);
    await batch.commit();
  }

  Future<void> createReturn(ReturnModel returnDoc, UserModel currentUser) async {
    final batch = _firestore.batch();
    final returnRef = _firestore.collection(FirestoreKeys.returns).doc();
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);
    final amount = _calculateTotal(returnDoc.items, 0);
    final newLocalCounter = currentUser.delegateReturnCounter + 1;

    final finalReturn = returnDoc.copyWith(
      id: returnRef.id, delegateReturnNumber: newLocalCounter,
      returnNumber: 0, // تم الإلغاء
      isSynced: true, pendingAction: "",
    );

    batch.set(returnRef, finalReturn.toFirestore());
    batch.update(userRef, {FirestoreKeys.delegateReturnCounter: FieldValue.increment(1)});
    _applySaleImpact(batch, returnDoc.delegateId, returnDoc.customerId, returnDoc.paymentMethod, -amount, returnDoc.returnDate);
    await batch.commit();
  }

  // --- تعديل المرتجع ---
  Future<void> updateReturn(ReturnModel oldReturn, ReturnModel newReturn) async {
    final batch = _firestore.batch();
    final oldAmount = _calculateTotal(oldReturn.items, 0);
    final newAmount = _calculateTotal(newReturn.items, 0);

    // عكس الأثر القديم للمرتجع (المرتجع يرسل مبلغه كـ سالب أصلاً، فعكسه موجب)
    _applySaleImpact(batch, oldReturn.delegateId, oldReturn.customerId, oldReturn.paymentMethod, oldAmount, oldReturn.returnDate);
    // تطبيق الأثر الجديد
    _applySaleImpact(batch, newReturn.delegateId, newReturn.customerId, newReturn.paymentMethod, -newAmount, newReturn.returnDate);

    final docRef = _firestore.collection(FirestoreKeys.returns).doc(newReturn.id);
    final updated = newReturn.copyWith(updatedAt: DateTime.now(), isSynced: true, pendingAction: "");
    batch.update(docRef, updated.toFirestore());

    await batch.commit();
  }

  // --- حذف المرتجع ---
  Future<void> deleteReturn(ReturnModel returnDoc) async {
    final batch = _firestore.batch();
    final amount = _calculateTotal(returnDoc.items, 0);

    // عكس الأثر المالي
    _applySaleImpact(batch, returnDoc.delegateId, returnDoc.customerId, returnDoc.paymentMethod, amount, returnDoc.returnDate);

    final docRef = _firestore.collection(FirestoreKeys.returns).doc(returnDoc.id);
    batch.delete(docRef);
    await batch.commit();
  }

  Future<void> createReceipt(ReceiptModel receipt, UserModel currentUser) async {
    final batch = _firestore.batch();
    final receiptRef = _firestore.collection(FirestoreKeys.receipts).doc();
    final userRef = _firestore.collection(FirestoreKeys.users).doc(currentUser.id);
    final newLocalCounter = currentUser.delegateReceiptCounter + 1;

    final finalReceipt = receipt.copyWith(
      id: receiptRef.id, delegateReceiptNumber: newLocalCounter,
      receiptNumber: 0, // تم الإلغاء
      isSynced: true, pendingAction: "",
    );

    batch.set(receiptRef, finalReceipt.toFirestore());
    batch.update(userRef, {FirestoreKeys.delegateReceiptCounter: FieldValue.increment(1)});
    _applyReceiptImpact(batch, receipt.delegateId, receipt.creditorAccount, receipt.amount, receipt.date);
    await batch.commit();
  }

  // --- تعديل السند ---
  Future<void> updateReceipt(ReceiptModel oldReceipt, ReceiptModel newReceipt) async {
    final batch = _firestore.batch();

    // عكس الأثر القديم للسند (- المبلغ)
    _applyReceiptImpact(batch, oldReceipt.delegateId, oldReceipt.creditorAccount, -oldReceipt.amount, oldReceipt.date);
    // تطبيق الأثر الجديد (+ المبلغ)
    _applyReceiptImpact(batch, newReceipt.delegateId, newReceipt.creditorAccount, newReceipt.amount, newReceipt.date);

    final docRef = _firestore.collection(FirestoreKeys.receipts).doc(newReceipt.id);
    final updated = newReceipt.copyWith(updatedAt: DateTime.now(), isSynced: true, pendingAction: "");
    batch.update(docRef, updated.toFirestore());

    await batch.commit();
  }

  // --- حذف السند ---
  Future<void> deleteReceipt(ReceiptModel receipt) async {
    final batch = _firestore.batch();

    // عكس الأثر المالي للسند (- المبلغ)
    _applyReceiptImpact(batch, receipt.delegateId, receipt.creditorAccount, -receipt.amount, receipt.date);

    final docRef = _firestore.collection(FirestoreKeys.receipts).doc(receipt.id);
    batch.delete(docRef);
    await batch.commit();
  }

  Stream<List<InvoiceModel>> getInvoicesStream(List<String> delegateIds) {
    return _firestore.collection(FirestoreKeys.invoices).where(FirestoreKeys.delegateId, whereIn: delegateIds).snapshots(includeMetadataChanges: true).map((snap) {
      final list = snap.docs.map((doc) => InvoiceModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ReturnModel>> getReturnsStream(List<String> delegateIds) {
    return _firestore.collection(FirestoreKeys.returns).where(FirestoreKeys.delegateId, whereIn: delegateIds).snapshots(includeMetadataChanges: true).map((snap) {
      final list = snap.docs.map((doc) => ReturnModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ReceiptModel>> getReceiptsStream(List<String> delegateIds) {
    return _firestore.collection(FirestoreKeys.receipts).where(FirestoreKeys.delegateId, whereIn: delegateIds).snapshots(includeMetadataChanges: true).map((snap) {
      final list = snap.docs.map((doc) => ReceiptModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<double> getCurrencyRate() async {
    try {
      final doc = await _firestore.collection(FirestoreKeys.settings).doc(FirestoreKeys.appConfigDoc).get();
      return (doc.data()?['currency_rate'] ?? 1.0).toDouble();
    } catch (e) { return 1.0; }
  }

  Future<void> savePrintData(String collectionName, String docId, String address, String phone) async {
    await _firestore.collection(collectionName).doc(docId).update({
      'print_address': address,
      'print_phone': phone,
    });
  }
}