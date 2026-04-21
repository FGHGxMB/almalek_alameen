// lib/data/models/unified_transaction.dart

enum TransactionType { invoice, returnDoc, receipt }

class UnifiedTransaction {
  final String id;
  final TransactionType type;
  final DateTime date;
  final int localNumber;
  final int globalNumber;
  final String customerName;
  final double amount;
  final bool isSynced;
  final dynamic originalDoc; // نحتفظ بالوثيقة الأصلية لفتح التفاصيل لاحقاً

  UnifiedTransaction({
    required this.id,
    required this.type,
    required this.date,
    required this.localNumber,
    required this.globalNumber,
    required this.customerName,
    required this.amount,
    required this.isSynced,
    required this.originalDoc,
  });
}