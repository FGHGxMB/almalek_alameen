enum TransactionType { invoice, returnDoc, receipt }

class UnifiedTransaction {
  final String id;
  final TransactionType type;
  final DateTime date;
  final DateTime updatedAt;
  final int localNumber;
  final int globalNumber; // سنبقيه كمتغير لعدم كسر الكود القديم، لكن قيمته ستكون دائماً 0
  final String customerId;
  final String customerName;
  final double amount;
  final bool isSynced;

  final String delegateId;
  final String delegateName;
  final String delegateColor;
  final String delegateSuffix; // <--- الحقل الجديد لإخفاء البادئة
  final String paymentMethod;
  final bool showModifiedDate;
  final dynamic originalDoc;

  UnifiedTransaction({
    required this.id, required this.type, required this.date, required this.updatedAt,
    required this.localNumber, required this.globalNumber, required this.customerId, required this.customerName,
    required this.amount, required this.isSynced, required this.delegateId,
    required this.delegateName, required this.delegateColor, required this.delegateSuffix,
    required this.paymentMethod, required this.showModifiedDate, required this.originalDoc,
  });
}