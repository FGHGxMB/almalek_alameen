// lib/data/repositories/dashboard_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_keys.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. جلب الكاش اليومي كـ Stream لمندوب محدد وفي تاريخ محدد
  Stream<double> getDailyCashStream(String delegateId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];

    return _firestore
        .collection(FirestoreKeys.users)
        .doc(delegateId)
        .collection(FirestoreKeys.dailyCash)
        .doc(dateStr)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['amount'] ?? 0).toDouble() : 0.0);
  }

  // 2. جلب إحصاءات الفواتير لليوم المحدد (لمجموعة من المندوبين)
  Future<Map<String, dynamic>> getDailyStats({
    required List<String> delegateIds,
    required DateTime date,
  }) async {
    // تحديد بداية ونهاية اليوم للبحث في Firestore
    final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    // جلب الفواتير
    final invoicesSnap = await _firestore
        .collection(FirestoreKeys.invoices)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .where(FirestoreKeys.invoiceDate, isGreaterThanOrEqualTo: startOfDay)
        .where(FirestoreKeys.invoiceDate, isLessThanOrEqualTo: endOfDay)
        .get();

    // جلب المرتجعات
    final returnsSnap = await _firestore
        .collection(FirestoreKeys.returns)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .where(FirestoreKeys.returnDate, isGreaterThanOrEqualTo: startOfDay)
        .where(FirestoreKeys.returnDate, isLessThanOrEqualTo: endOfDay)
        .get();

    // جلب السندات
    final receiptsSnap = await _firestore
        .collection(FirestoreKeys.receipts)
        .where(FirestoreKeys.delegateId, whereIn: delegateIds)
        .where(FirestoreKeys.date, isGreaterThanOrEqualTo: startOfDay)
        .where(FirestoreKeys.date, isLessThanOrEqualTo: endOfDay)
        .get();

    // حساب الإحصاءات
    int cashInvoicesCount = 0;
    int creditInvoicesCount = 0;
    double totalSales = 0;

    for (var doc in invoicesSnap.docs) {
      final data = doc.data();
      final method = data[FirestoreKeys.paymentMethod] ?? 'cash';

      double itemsTotal = 0;
      final items = data[FirestoreKeys.items] as List<dynamic>? ?? [];
      for (var item in items) {
        itemsTotal += ((item[FirestoreKeys.price] ?? 0) * (item[FirestoreKeys.quantity] ?? 0));
      }
      final finalTotal = itemsTotal - (data[FirestoreKeys.discount] ?? 0);

      totalSales += finalTotal;
      if (method == 'cash') cashInvoicesCount++;
      else creditInvoicesCount++;
    }

    double totalReturns = 0;
    for (var doc in returnsSnap.docs) {
      final data = doc.data();
      final items = data[FirestoreKeys.items] as List<dynamic>? ?? [];
      for (var item in items) {
        totalReturns += ((item[FirestoreKeys.price] ?? 0) * (item[FirestoreKeys.quantity] ?? 0));
      }
    }

    double totalReceipts = 0;
    for (var doc in receiptsSnap.docs) {
      totalReceipts += (doc.data()[FirestoreKeys.amount] ?? 0).toDouble();
    }

    return {
      'cashInvoicesCount': cashInvoicesCount,
      'creditInvoicesCount': creditInvoicesCount,
      'totalSales': totalSales,
      'totalReturns': totalReturns,
      'totalReceipts': totalReceipts,
    };
  }
}