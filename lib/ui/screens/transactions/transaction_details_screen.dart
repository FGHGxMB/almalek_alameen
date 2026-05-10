// lib/ui/screens/transactions/transaction_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/transaction_details/transaction_details_cubit.dart';
import '../../../logic/transaction_details/transaction_details_state.dart';
import '../../../data/models/unified_transaction.dart';
import '../../../data/repositories/products_repository.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/return_model.dart';
import '../../../data/models/receipt_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final UnifiedTransaction transaction;

  const TransactionDetailsScreen({Key? key, required this.transaction}) : super(key: key);

  void _printDoc(BuildContext context) async {
    final printer = PrinterService();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الاتصال بالطابعة...')));
    try {
      await printer.printTransaction(transaction);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الطباعة بنجاح!'), backgroundColor: Colors.green));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  // تنسيق الأرقام بدون فواصل عشرية مع فواصل الآلاف
  String _formatNumber(double num) {
    return NumberFormat('#,##0').format(num);
  }

  @override
  Widget build(BuildContext context) {
    String typeLabel = '';
    Color primaryColor = Colors.teal;

    if (transaction.type == TransactionType.invoice) {
      typeLabel = transaction.paymentMethod == 'gift' ? 'فاتورة هدايا' : (transaction.paymentMethod == 'cash' ? 'فاتورة مبيعات نقدية' : 'فاتورة مبيعات آجلة');
      primaryColor = transaction.paymentMethod == 'gift' ? Colors.indigo : Colors.blue;
    } else if (transaction.type == TransactionType.returnDoc) {
      typeLabel = transaction.paymentMethod == 'cash' ? 'مرتجع مبيعات نقدي' : 'مرتجع مبيعات آجل';
      primaryColor = Colors.red;
    } else {
      typeLabel = 'سند قبض';
      primaryColor = Colors.green;
    }

    return BlocProvider(
      create: (context) => TransactionDetailsCubit(context.read<ProductsRepository>())..loadDetails(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(typeLabel),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          actions:[
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: 'طباعة',
              onPressed: () => _printDoc(context),
            )
          ],
        ),
        body: BlocBuilder<TransactionDetailsCubit, TransactionDetailsState>(
          builder: (context, state) {
            if (state is TransactionDetailsLoading) return const Center(child: CircularProgressIndicator());
            if (state is TransactionDetailsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:[
                    // 1. بطاقة المعلومات الأساسية
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children:[
                            Text(transaction.customerName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor), textAlign: TextAlign.center),
                            const Divider(height: 32),
                            _buildInfoRow('رقم المعاملة (محلي):', transaction.localNumber.toString()),
                            if (transaction.isSynced) _buildInfoRow('الرقم العام (سيرفر):', transaction.globalNumber.toString()),
                            _buildInfoRow('المندوب المسؤول:', transaction.delegateName),
                            _buildInfoRow('تاريخ الإنشاء:', DateFormat('yyyy-MM-dd | HH:mm').format(transaction.date)),
                            if (transaction.showModifiedDate && transaction.updatedAt.difference(transaction.date).inMinutes > 1)
                              _buildInfoRow('آخر تعديل:', DateFormat('yyyy-MM-dd | HH:mm').format(transaction.updatedAt), color: Colors.orange.shade800),
                            if (!transaction.isSynced)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: const[Icon(Icons.cloud_off, color: Colors.orange, size: 18), SizedBox(width: 8), Text('في انتظار الإنترنت للمزامنة', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))],
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. جدول المواد (فقط للفواتير والمرتجعات)
                    if (transaction.type != TransactionType.receipt) ...[
                      const Text('الأقلام (تفاصيل المواد)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // لتجنب مشاكل الشاشات الصغيرة
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                            columnSpacing: 16,
                            columns: const[
                              DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('المادة', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الوحدة', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الإفرادي', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _buildDataRows(transaction, state.productNames),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 3. السندات أو قسم الملاحظات والملخص
                    Card(
                      elevation: 2,
                      color: primaryColor.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryColor.withOpacity(0.3))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children:[
                            if (transaction.type == TransactionType.receipt) ...[
                              _buildInfoRow('البيان (ملاحظات السند):', (transaction.originalDoc as ReceiptModel).lineNote),
                              const Divider(),
                            ],
                            if (transaction.type == TransactionType.invoice) ...[
                              _buildInfoRow('إجمالي المواد:', _formatNumber(transaction.amount + (transaction.originalDoc as InvoiceModel).discount)),
                              _buildInfoRow('الحسم:', _formatNumber((transaction.originalDoc as InvoiceModel).discount), color: Colors.red),
                              _buildInfoRow('البيان:', (transaction.originalDoc as InvoiceModel).invoiceNote),
                              const Divider(thickness: 2),
                            ],
                            if (transaction.type == TransactionType.returnDoc) ...[
                              _buildInfoRow('رقم الفاتورة الأصلية:', (transaction.originalDoc as ReturnModel).invoiceRef),
                              _buildInfoRow('البيان:', (transaction.originalDoc as ReturnModel).returnNote),
                              const Divider(thickness: 2),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('الصافي النهائي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(_formatNumber(transaction.amount), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Expanded(flex: 2, child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  List<DataRow> _buildDataRows(UnifiedTransaction t, Map<String, String> namesMap) {
    List<dynamic> items =[];
    if (t.type == TransactionType.invoice) items = (t.originalDoc as InvoiceModel).items;
    if (t.type == TransactionType.returnDoc) items = (t.originalDoc as ReturnModel).items;

    List<DataRow> rows =[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final name = namesMap[item.productId] ?? 'مادة غير معروفة';
      final total = item.quantity * item.price;

      // إذا كانت هدية نغير لون الصف أو نكتب (هدية) بجانب السعر
      final isGift = item.isGift;

      rows.add(DataRow(
        color: isGift ? MaterialStateProperty.all(Colors.indigo.shade50) : null,
        cells:[
          DataCell(Text('${i + 1}')),
          DataCell(Text(isGift ? '$name (هدية)' : name)),
          DataCell(Text(item.unit)),
          DataCell(Text(_formatNumber(item.quantity))),
          DataCell(Text(isGift ? '0' : _formatNumber(item.price))),
          DataCell(Text(isGift ? '0' : _formatNumber(total), style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ));
    }
    return rows;
  }
}