// lib/ui/widgets/transaction_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/unified_transaction.dart';
import '../../core/services/printer_service.dart';

class TransactionCard extends StatelessWidget {
  final UnifiedTransaction transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  void _printDoc(BuildContext context) async {
    final printer = PrinterService(); // يمكن جلب الـ IP من الإعدادات لاحقاً

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الاتصال بالطابعة...'), duration: Duration(seconds: 2)),
    );

    try {
      await printer.printTransaction(transaction);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الطباعة بنجاح!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = transaction.isSynced ? Colors.white : Colors.orange.shade50;
    final borderColor = transaction.isSynced ? Colors.grey.shade300 : Colors.orange.shade300;

    IconData icon;
    Color iconColor;
    String typeLabel;

    switch (transaction.type) {
      case TransactionType.invoice:
        icon = Icons.point_of_sale;
        iconColor = Colors.blue;
        typeLabel = 'فاتورة مبيعات';
        break;
      case TransactionType.returnDoc:
        icon = Icons.assignment_return;
        iconColor = Colors.red;
        typeLabel = 'مرتجع مبيعات';
        break;
      case TransactionType.receipt:
        icon = Icons.receipt_long;
        iconColor = Colors.green;
        typeLabel = 'سند قبض';
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: transaction.isSynced ? 1 : 1.5),
      ),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children:[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(transaction.customerName, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                    Text(
                      NumberFormat.currency(symbol: '', decimalDigits: 1).format(transaction.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy-MM-dd').format(transaction.date),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
                // زر الطباعة الجديد هنا!
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.grey),
                  tooltip: 'طباعة الإيصال',
                  onPressed: () => _printDoc(context),
                ),
              ],
            ),
            if (!transaction.isSynced) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text('في انتظار الإنترنت للمزامنة', style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}