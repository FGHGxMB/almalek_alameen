import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/unified_transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';

class TransactionCard extends StatelessWidget {
  final UnifiedTransaction transaction;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TransactionCard({
    Key? key, required this.transaction, required this.isSelected,
    required this.onTap, required this.onLongPress,
  }) : super(key: key);

  Color _hexToColor(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#', 'ff'), radix: 16)); } catch(e) { return Colors.orange; }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final String myId = (authState is AuthAuthenticated) ? authState.user.id : '';
    final bool isMine = transaction.delegateId == myId;

    final isSynced = transaction.isSynced;

    Color primaryColor;
    Color bgColor;
    String typeLabel;
    IconData icon;

    if (transaction.type == TransactionType.invoice) {
      if (transaction.paymentMethod == 'gift') {
        primaryColor = Colors.pink; bgColor = Colors.pink.shade50; typeLabel = 'فاتورة مبيعات (هدية)'; icon = Icons.card_giftcard;
      } else {
        primaryColor = Colors.grey.shade700; bgColor = Colors.grey.shade100;
        typeLabel = transaction.paymentMethod == 'cash' ? 'فاتورة مبيعات (نقدي)' : 'فاتورة مبيعات (آجل)';
        icon = Icons.point_of_sale;
      }
    } else if (transaction.type == TransactionType.returnDoc) {
      primaryColor = Colors.red; bgColor = Colors.red.shade50; typeLabel = transaction.paymentMethod == 'cash' ? 'مرتجع مبيعات (نقدي)' : 'مرتجع مبيعات (آجل)'; icon = Icons.assignment_return;
    } else {
      primaryColor = Colors.green; bgColor = Colors.green.shade50; typeLabel = 'سند قبض'; icon = Icons.receipt_long;
    }

    // تم إلغاء تغيير لون الخلفية للبطاقة الغير متزامنة لكي تحافظ على شكلها
    if (isSelected) bgColor = Colors.teal.shade100;

    final bool isModified = transaction.updatedAt.difference(transaction.date).inMinutes > 1;

    String displayCustomerName = transaction.customerName;
    if (transaction.delegateSuffix.isNotEmpty && displayCustomerName.startsWith(transaction.delegateSuffix)) {
      displayCustomerName = displayCustomerName.replaceFirst(transaction.delegateSuffix, '').trim();
    }

    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryColor.withOpacity(0.5), width: isSelected ? 2 : 1)),
      color: bgColor,
      child: InkWell(
        onTap: onTap, onLongPress: onLongPress, borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children:[
              if (isSelected)
                const CircleAvatar(backgroundColor: Colors.teal, radius: 20, child: Icon(Icons.check, color: Colors.white))
              else
                Column(
                  children:[
                    CircleAvatar(backgroundColor: primaryColor, radius: 20, child: Icon(icon, color: Colors.white, size: 20)),
                    if (!isMine && transaction.delegateName != 'مجهول')
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _hexToColor(transaction.delegateColor), borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:[Text(transaction.delegateName, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold))],
                        ),
                      )
                  ],
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    // أيقونة الأوفلاين البرتقالية بجانب اسم نوع الفاتورة
                    Row(
                      children:[
                        Text(typeLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor)),
                        if (!isSynced) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                        ]
                      ],
                    ),
                    if (displayCustomerName.isNotEmpty && displayCustomerName != 'سند قبض')
                      Text(displayCustomerName, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('تاريخ: ${DateFormat('yyyy-MM-dd | hh:mm a').format(transaction.date)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    if (isModified && transaction.showModifiedDate)
                      Text('آخر تعديل: ${DateFormat('yyyy-MM-dd | hh:mm a').format(transaction.updatedAt)}', style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                  if (transaction.paymentMethod == 'gift')
                    Text('هدية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor))
                  else
                    Text(NumberFormat('#,##0').format(transaction.amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),

                  Text('رقم: ${transaction.localNumber.toString().padLeft(4, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}