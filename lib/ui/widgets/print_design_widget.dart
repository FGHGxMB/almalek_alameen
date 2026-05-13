// lib/ui/widgets/print_design_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/unified_transaction.dart';
import '../../data/models/transaction_item_model.dart';

class PrintDesignWidget extends StatelessWidget {
  final TransactionType type;
  final String docNumber;
  final DateTime date;
  final String delegateName;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String companyInfoText;
  final List<TransactionItemModel> items; // فارغة في حالة السند
  final List<String> productNames; // أسماء المواد المطابقة للأقلام
  final double totalAmount;
  final double discount;

  const PrintDesignWidget({
    Key? key, required this.type, required this.docNumber, required this.date,
    required this.delegateName, required this.customerName, required this.customerAddress,
    required this.customerPhone, required this.companyInfoText, required this.items,
    required this.productNames, required this.totalAmount, this.discount = 0.0,
  }) : super(key: key);

  String _formatNum(double num) => NumberFormat('#,##0').format(num);

  @override
  Widget build(BuildContext context) {
    String title = type == TransactionType.invoice ? 'فاتورة مبيع' : (type == TransactionType.returnDoc ? 'فاتورة مرتجع' : 'إيصال قبض');

    // العرض 384 بكسل هو العرض القياسي لطابعات 58mm الحرارية (48mm مساحة الطباعة * 8 نقطة/ملم)
    return Container(
      width: 384,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          // ---------------- القسم الأول (الشركة) ----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Text('رقم: $docNumber', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(width: 10),
                        Text('الموزع: $delegateName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // اللوغو (تأكد من وجوده في assets/print_logo.png)
              Image.asset('assets/print_logo.png', width: 80, height: 80, fit: BoxFit.contain, errorBuilder: (c, e, s) => const SizedBox(width: 80, height: 80, child: Center(child: Icon(Icons.broken_image)))),
            ],
          ),
          const SizedBox(height: 8),
          if (companyInfoText.isNotEmpty)
            Text(companyInfoText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black)),
          const Divider(thickness: 1.5, color: Colors.black),

          // ---------------- القسم الثاني (الزبون والتاريخ) ----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text('الزبون: $customerName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    if (customerAddress.isNotEmpty) Text('المقيم في: $customerAddress', style: const TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text('التاريخ: ${DateFormat('yyyy-MM-dd | HH:mm').format(date)}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                    if (customerPhone.isNotEmpty) Text('هاتف: $customerPhone', style: const TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(thickness: 1.5, color: Colors.black),

          // ---------------- القسم الثالث (الجدول أو نص السند) ----------------
          if (type == TransactionType.receipt) ...[
            const SizedBox(height: 24),
            // Text('تم استلام مبلغ ${_formatNum(totalAmount)} ليرة سورية كدفعة على الحساب.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Text('تم استلام مبلغ ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: Colors.black)), Text(_formatNum(totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)), const Text(" ليرة سورية كدفعة على الحساب.", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: Colors.black))]),
            // const SizedBox(height: 32),
          ] else ...[
            Table(
              border: TableBorder.all(color: Colors.black, width: 0.8),
              columnWidths: const {
                0: FlexColumnWidth(4), // المادة
                1: FlexColumnWidth(2), // الكمية
                2: FlexColumnWidth(2), // الوحدة
                3: FlexColumnWidth(2), // الإفرادي
                4: FlexColumnWidth(3), // الإجمالي
              },
              children:[
                // ترويسة الجدول
                const TableRow(
                    decoration: BoxDecoration(color: Colors.black12),
                    children:[
                      Padding(padding: EdgeInsets.all(4), child: Text('اسم المادة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                      Padding(padding: EdgeInsets.all(4), child: Text('الكمية', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                      Padding(padding: EdgeInsets.all(4), child: Text('الوحدة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                      Padding(padding: EdgeInsets.all(4), child: Text('إفرادي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                      Padding(padding: EdgeInsets.all(4), child: Text('الإجمالي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                    ]
                ),
                // الأقلام
                ...items.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  String pName = productNames[idx];
                  return TableRow(
                      children:[
                        Padding(padding: const EdgeInsets.all(4), child: Text(item.isGift ? '$pName (هدية)' : pName, style: const TextStyle(fontSize: 12, color: Colors.black))),
                        Padding(padding: const EdgeInsets.all(4), child: Text(_formatNum(item.quantity), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black))),
                        Padding(padding: const EdgeInsets.all(4), child: Text(item.unit, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black))),
                        Padding(padding: const EdgeInsets.all(4), child: Text(item.isGift ? '0' : _formatNum(item.price), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black))),
                        Padding(padding: const EdgeInsets.all(4), child: Text(item.isGift ? '0' : _formatNum(item.quantity * item.price), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                      ]
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 8),
            // الملخص
            if (discount > 0) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[const Text('الحسم:', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black)), Text(_formatNum(discount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)), const Text(" ليرة سورية", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: Colors.black))]),
            const Divider(color: Colors.black),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Text(' الصافي النهائي: ', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: Colors.black)), Text(_formatNum(totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)), const Text(" ليرة سورية", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: Colors.black))]),
          ],
          // const SizedBox(height: 24),
          // const Text('توقيع المستلم', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(height: 40), // مساحة للقطع
        ],
      ),
    );
  }
}